import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Optional firebase-admin import (safe fallback if not configured or not installed)
let firebaseAdmin: any = null;

try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const admin = require('firebase-admin');
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    if (!admin.apps.length) {
      firebaseAdmin = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    } else {
      firebaseAdmin = admin.app();
    }
    console.log('[NotificationService] Firebase Admin SDK initialized successfully');
  } else {
    console.log('[NotificationService] FIREBASE_SERVICE_ACCOUNT_JSON not provided. Push notifications logged to console.');
  }
} catch (e) {
  console.log('[NotificationService] firebase-admin package or credentials not available. Push notifications logged to console.');
}

export interface PushNotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  appType?: 'CUSTOMER' | 'COURIER' | 'MERCHANT';
}

export class NotificationService {
  /**
   * Register or update a user's FCM device token
   */
  static async registerDeviceToken(params: {
    userId: string;
    token: string;
    platform?: string;
    appType?: string;
  }) {
    const { userId, token, platform = 'ANDROID', appType = 'CUSTOMER' } = params;

    return await prisma.deviceToken.upsert({
      where: { token },
      update: {
        userId,
        platform,
        appType,
        isActive: true,
        updatedAt: new Date(),
      },
      create: {
        userId,
        token,
        platform,
        appType,
        isActive: true,
      },
    });
  }

  /**
   * Deactivate or delete a device token (e.g. on logout)
   */
  static async unregisterDeviceToken(userId: string, token: string) {
    try {
      await prisma.deviceToken.updateMany({
        where: { userId, token },
        data: { isActive: false },
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /**
   * Send FCM push notification to a user's active devices
   */
  static async sendToUser(payload: PushNotificationPayload) {
    const { userId, title, body, data = {}, appType } = payload;

    try {
      // Find active device tokens for the user
      const tokens = await prisma.deviceToken.findMany({
        where: {
          userId,
          isActive: true,
          ...(appType ? { appType } : {}),
        },
        select: { token: true },
      });

      if (tokens.length === 0) {
        console.log(`[NotificationService] No active FCM token for user ${userId}`);
        return;
      }

      const tokenStrings = tokens.map((t) => t.token);

      console.log(`[NotificationService] Sending push "${title}" to user ${userId} (${tokenStrings.length} tokens)`);

      if (firebaseAdmin) {
        const message = {
          notification: { title, body },
          data,
          tokens: tokenStrings,
        };

        const response = await firebaseAdmin.messaging().sendEachForMulticast(message);
        console.log(`[NotificationService] FCM response: ${response.successCount} success, ${response.failureCount} failure`);
      } else {
        console.log(`[Notification] MOCK PUSH to User ${userId}: ${title} - ${body}`, data);
      }
    } catch (error) {
      console.error('[NotificationService] Error sending push notification:', error);
    }
  }
}
