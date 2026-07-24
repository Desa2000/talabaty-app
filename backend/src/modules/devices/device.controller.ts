import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { NotificationService } from '../../services/notification.service';

export const registerDeviceToken = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'غير مصرح: يجب تسجيل الدخول أولاً' });
    }

    const { token, platform, appType } = req.body;

    if (!token || typeof token !== 'string') {
      return res.status(400).json({ error: 'رمز الجهاز (fcmToken) مطلوب' });
    }

    const result = await NotificationService.registerDeviceToken({
      userId,
      token,
      platform: platform || 'ANDROID',
      appType: appType || 'CUSTOMER',
    });

    return res.json({
      message: 'تم تسجيل رمز الإشعارات بنجاح',
      id: result.id,
      appType: result.appType,
    });
  } catch (error: any) {
    console.error('Error registering device token:', error);
    return res.status(500).json({ error: 'فشل في تسجيل رمز الإشعارات' });
  }
};

export const unregisterDeviceToken = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'غير مصرح' });
    }

    const { token } = req.body;
    if (!token) {
      return res.status(400).json({ error: 'رمز الجهاز (fcmToken) مطلوب' });
    }

    await NotificationService.unregisterDeviceToken(userId, token);
    return res.json({ message: 'تم إلغاء تفعيل رمز الإشعارات بنجاح' });
  } catch (error: any) {
    console.error('Error unregistering device token:', error);
    return res.status(500).json({ error: 'فشل في إلغاء رمز الإشعارات' });
  }
};
