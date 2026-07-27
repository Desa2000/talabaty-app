import express from 'express';
import http from 'http';
import cors from 'cors';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import crypto from 'crypto';
import { Server } from 'socket.io';
import { config } from './config';
import {
  registerCustomer,
  registerMerchant,
  registerCourier,
  login,
  changePassword,
  verifySetupToken,
  completeFirstTimeSetup,
  refresh,
  logout,
  getMe,
  otpLogin,
} from './modules/auth/auth.controller';
import {
  getStores,
  getStoreById,
  updateMerchantStore,
} from './modules/stores/store.controller';
import {
  createProduct,
  updateProduct,
  deleteProduct,
} from './modules/products/product.controller';
import { validateCart } from './modules/cart/cart.controller';
import {
  createOrder,
  getMyOrders,
  getOrderById,
  merchantAcceptOrder,
  merchantRejectOrder,
  merchantPreparing,
  merchantReadyForPickup,
  courierAcceptOrder,
  courierRejectOffer,
  courierPickupOrder,
  courierOnTheWay,
  courierArrived,
  courierDelivered,
  customerCancelOrder,
  rateOrder,
  submitBankakPayment,
  switchToCashPayment,
} from './modules/orders/order.controller';
import {
  getAddresses,
  createAddress,
  deleteAddress,
} from './modules/address/address.controller';
import {
  computeRouteHandler,
  calculateDeliveryFeeHandler,
} from './modules/routing/routing.controller';
import { routingStats } from './services/routing.service';
import {
  updateCourierLocation,
  updateCourierStatus,
} from './modules/courier/courier.controller';
import {
  getAdminOverview,
  getAdminOrders,
  getAdminOrderById,
  adminReassignCourier,
  adminCancelOrder,
  getAdminMerchants,
  updateMerchantStatus,
  getAdminCouriers,
  getAdminLiveMap,
  getAdminLiveRoute,
  updateCourierStatus as adminUpdateCourierStatus,
  getAdminCustomers,
  updateCustomerStatus,
  getAdminPayments,
  verifyBankakPayment,
  rejectBankakPayment,
  getAdminCoverage,
  updateAdminCoverage,
  getAdminSupportTickets,
  getAdminAuditLogs,
  getAdminSettings,
  updateAdminSettings,
  getAdminUsers,
  createAdminUser,
} from './modules/admin/admin.controller';
import jwt from 'jsonwebtoken';
import { prisma } from './utils/prisma';
import { authenticate, authorizeRoles, isAdminRole } from './middleware/auth.middleware';
import { startDispatchWorker } from './workers/dispatch.worker';

// IP Rate Limiting for Login Protection
const loginIpAttempts = new Map<string, { count: number; resetTime: number }>();

const loginRateLimiter = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const ip = req.ip || req.socket.remoteAddress || 'unknown';
  const now = Date.now();
  const windowMs = 15 * 60 * 1000; // 15 minutes window
  const maxAttempts = 10;

  const attempt = loginIpAttempts.get(ip);
  if (!attempt || now > attempt.resetTime) {
    loginIpAttempts.set(ip, { count: 1, resetTime: now + windowMs });
    return next();
  }

  if (attempt.count >= maxAttempts) {
    return res.status(429).json({ error: 'تم تجاوز الحد المسموح من محاولات الدخول، يرجى الانتظار 15 دقيقة' });
  }

  attempt.count += 1;
  return next();
};


const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'https://mytalabaty.com,https://www.mytalabaty.com')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

const corsOrigin = (origin: string | undefined, callback: (error: Error | null, allow?: boolean) => void) => {
  if (!origin || allowedOrigins.includes(origin)) {
    return callback(null, true);
  }
  return callback(new Error('CORS origin not allowed'));
};

const apiRateBuckets = new Map<string, { count: number; resetTime: number }>();
const apiRateLimiter = (limit: number, windowMs: number) =>
  (req: express.Request, res: express.Response, next: express.NextFunction) => {
    const key = `${req.ip || req.socket.remoteAddress || 'unknown'}:${req.path}`;
    const now = Date.now();
    const bucket = apiRateBuckets.get(key);
    if (!bucket || now > bucket.resetTime) {
      apiRateBuckets.set(key, { count: 1, resetTime: now + windowMs });
      return next();
    }
    if (bucket.count >= limit) {
      return res.status(429).json({ error: 'تم تجاوز الحد المسموح من الطلبات، حاول لاحقاً' });
    }
    bucket.count += 1;
    return next();
  };

const app = express();
export const server = http.createServer(app);

const productUploadDir = path.resolve(process.cwd(), 'uploads/products');
fs.mkdirSync(productUploadDir, { recursive: true });

const productImageStorage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, productUploadDir),
  filename: (_req, file, cb) => {
    const safeExt = path.extname(file.originalname || '').toLowerCase();
    const ext = ['.jpg', '.jpeg', '.png', '.webp'].includes(safeExt)
      ? safeExt
      : '.jpg';
    cb(null, `product-${Date.now()}-${crypto.randomBytes(8).toString('hex')}${ext}`);
  },
});

const productImageUpload = multer({
  storage: productImageStorage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const allowed = new Set([
      'image/jpeg',
      'image/png',
      'image/webp',
    ]);

    if (!allowed.has(file.mimetype)) {
      return cb(new Error('نوع الصورة غير مدعوم'));
    }

    cb(null, true);
  },
});

// CORS Configuration
app.use(
  cors({
    origin: corsOrigin,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Body Parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static(path.resolve(process.cwd(), 'uploads')));

// Health Check
app.get('/', (req, res) => {
  res.send('Talabaty REST & Socket Real-Time Server is Running 🚀');
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', system: 'Talabaty API', timestamp: new Date() });
});

import {
  registerDeviceToken,
  unregisterDeviceToken,
} from './modules/devices/device.controller';

// 1. Auth & Device Routes
app.post('/api/auth/register/customer', registerCustomer);
app.post('/api/auth/register/merchant', registerMerchant);
app.post('/api/auth/register/courier', registerCourier);
app.post('/api/auth/login', loginRateLimiter, login);
app.post('/api/auth/otp-login', otpLogin);
app.post('/api/auth/change-password', authenticate, changePassword);
app.get('/api/admin/setup-verify', verifySetupToken);
app.post('/api/admin/setup-password', completeFirstTimeSetup);
app.post('/api/auth/refresh', refresh);
app.post('/api/auth/logout', logout);
app.get('/api/auth/me', authenticate, getMe);
app.post('/api/devices/token', authenticate, registerDeviceToken);
app.delete('/api/devices/token', authenticate, unregisterDeviceToken);

// Authenticated product image upload for Merchant Android app.
app.post(
  '/api/upload',
  authenticate,
  authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'),
  productImageUpload.single('file'),
  (req, res) => {
    if (!req.file) {
      return res.status(400).json({ error: 'ملف الصورة مطلوب' });
    }

    const publicBaseUrl = (
      process.env.PUBLIC_API_URL || 'https://api.mytalabaty.com'
    ).replace(/\/+$/, '');

    return res.status(201).json({
      url: `${publicBaseUrl}/uploads/products/${req.file.filename}`,
    });
  }
);

// 2. Store Routes
app.get('/api/stores', getStores);
app.get('/api/stores/:id', getStoreById);
app.put('/api/merchant/stores/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), updateMerchantStore);

// 3. Product Routes
app.post('/api/merchant/products', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), createProduct);
app.put('/api/merchant/products/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), updateProduct);
app.delete('/api/merchant/products/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), deleteProduct);

// 4. Cart & Routing Routes
app.post('/api/cart/validate', validateCart);
app.post('/api/routing/route', authenticate, apiRateLimiter(60, 60_000), computeRouteHandler);
app.post('/api/routing/delivery-fee', authenticate, apiRateLimiter(30, 60_000), calculateDeliveryFeeHandler);

// 5. Order Routes
app.post('/api/orders', authenticate, createOrder);
app.get('/api/orders/my', authenticate, getMyOrders);
app.get('/api/orders/:id', authenticate, getOrderById);

// Merchant Order Flow
app.post('/api/orders/:id/merchant/accept', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), merchantAcceptOrder);
app.post('/api/orders/:id/merchant/reject', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), merchantRejectOrder);
app.post('/api/orders/:id/preparing', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), merchantPreparing);
app.post('/api/orders/:id/ready', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), merchantReadyForPickup);

// Courier Order Flow
app.post('/api/orders/:id/courier/accept', authenticate, authorizeRoles('COURIER'), courierAcceptOrder);
app.post('/api/orders/:id/courier/reject', authenticate, authorizeRoles('COURIER'), courierRejectOffer);
app.post('/api/orders/:id/picked-up', authenticate, authorizeRoles('COURIER'), courierPickupOrder);
app.post('/api/orders/:id/on-the-way', authenticate, authorizeRoles('COURIER'), courierOnTheWay);
app.post('/api/orders/:id/arrived', authenticate, authorizeRoles('COURIER'), courierArrived);
app.post('/api/orders/:id/delivered', authenticate, authorizeRoles('COURIER'), courierDelivered);
app.post('/api/orders/:id/completed', authenticate, authorizeRoles('COURIER'), courierDelivered);
app.post('/api/orders/:id/cancel', authenticate, customerCancelOrder);
app.post('/api/orders/:id/rate', authenticate, rateOrder);
app.post('/api/orders/:id/bankak-submit', authenticate, submitBankakPayment);
app.post('/api/orders/:id/switch-to-cash', authenticate, switchToCashPayment);

// 6. Address Routes
app.get('/api/addresses', authenticate, getAddresses);
app.post('/api/addresses', authenticate, createAddress);
app.delete('/api/addresses/:id', authenticate, deleteAddress);

// 7. Courier Routes
app.post('/api/courier/location', authenticate, authorizeRoles('COURIER', 'ADMIN', 'SUPER_ADMIN'), updateCourierLocation);
app.post('/api/courier/status', authenticate, authorizeRoles('COURIER', 'ADMIN', 'SUPER_ADMIN'), updateCourierStatus);

// =============================================
// 8. ADMIN DASHBOARD & RBAC ROUTES
// =============================================
const adminRoles = ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'];
const opsRoles = ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS'];
const financeRoles = ['SUPER_ADMIN', 'ADMIN', 'FINANCE'];
const superAdminOnly = ['SUPER_ADMIN'];

app.get('/api/admin/overview', authenticate, authorizeRoles(...adminRoles), getAdminOverview);
// Usage monitoring: Google API call counters (in-memory, resets on restart)
app.get('/api/admin/routing-stats', authenticate, authorizeRoles(...adminRoles), (_req, res) => {
  res.json({
    ...routingStats,
    googleConfigured: !!(process.env.GOOGLE_ROUTES_API_KEY),
    estimatedCostPerOrder: routingStats.computeRouteCalls > 0
      ? `~${(routingStats.computeRouteCalls * 0.005 + routingStats.routeMatrixElementsTotal * 0.001).toFixed(3)} USD`
      : 'No data yet',
  });
});
app.get('/api/admin/orders', authenticate, authorizeRoles(...adminRoles), getAdminOrders);
app.get('/api/admin/orders/:id', authenticate, authorizeRoles(...adminRoles), getAdminOrderById);
app.post('/api/admin/orders/:id/reassign-courier', authenticate, authorizeRoles(...opsRoles), adminReassignCourier);
app.post('/api/admin/orders/:id/cancel', authenticate, authorizeRoles(...opsRoles), adminCancelOrder);

app.get('/api/admin/merchants', authenticate, authorizeRoles(...adminRoles), getAdminMerchants);
app.post('/api/admin/merchants/:id/status', authenticate, authorizeRoles(...opsRoles), updateMerchantStatus);

app.get('/api/admin/couriers', authenticate, authorizeRoles(...adminRoles), getAdminCouriers);
app.get('/api/admin/live-map', authenticate, authorizeRoles(...opsRoles), getAdminLiveMap);
app.get('/api/admin/live-map/:courierId/route', authenticate, authorizeRoles(...opsRoles), getAdminLiveRoute);
app.post('/api/admin/couriers/:id/status', authenticate, authorizeRoles(...opsRoles), adminUpdateCourierStatus);

app.get('/api/admin/customers', authenticate, authorizeRoles(...adminRoles), getAdminCustomers);
app.post('/api/admin/customers/:id/status', authenticate, authorizeRoles(...opsRoles), updateCustomerStatus);

app.get('/api/admin/payments', authenticate, authorizeRoles(...adminRoles), getAdminPayments);
app.post('/api/admin/payments/:id/verify', authenticate, authorizeRoles(...financeRoles), verifyBankakPayment);
app.post('/api/admin/payments/:id/reject', authenticate, authorizeRoles(...financeRoles), rejectBankakPayment);

app.get('/api/admin/coverage', authenticate, authorizeRoles(...adminRoles), getAdminCoverage);
app.put('/api/admin/coverage/:id', authenticate, authorizeRoles(...opsRoles), updateAdminCoverage);

app.get('/api/admin/support', authenticate, authorizeRoles(...adminRoles), getAdminSupportTickets);
app.get('/api/admin/audit', authenticate, authorizeRoles(...adminRoles), getAdminAuditLogs);

app.get('/api/admin/settings', authenticate, authorizeRoles(...adminRoles), getAdminSettings);
app.put('/api/admin/settings', authenticate, authorizeRoles(...superAdminOnly), updateAdminSettings);

app.get('/api/admin/users', authenticate, authorizeRoles(...superAdminOnly), getAdminUsers);
app.post('/api/admin/users', authenticate, authorizeRoles(...superAdminOnly), createAdminUser);

// Socket.io Real-Time System
export const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    methods: ['GET', 'POST'],
  },
});

type SocketUser = {
  id: string;
  role: string;
  email: string | null;
  phone: string;
  tokenVersion: number;
};

type SocketAck = (response: {
  ok: boolean;
  error?: string;
}) => void;

// Authenticate every socket connection with the same
// access JWT and tokenVersion rules used by the REST API.
io.use(async (socket, next) => {
  try {
    const handshakeToken = socket.handshake.auth?.token;
    const authorizationHeader =
      socket.handshake.headers.authorization;

    let token: string | null = null;

    if (
      typeof handshakeToken === 'string' &&
      handshakeToken.trim()
    ) {
      token = handshakeToken.trim();

      if (token.startsWith('Bearer ')) {
        token = token.slice(7).trim();
      }
    } else if (
      typeof authorizationHeader === 'string' &&
      authorizationHeader.startsWith('Bearer ')
    ) {
      token = authorizationHeader
        .slice(7)
        .trim();
    }

    if (!token) {
      return next(
        new Error('SOCKET_UNAUTHORIZED')
      );
    }

    const decoded = jwt.verify(
      token,
      config.jwtAccessSecret
    ) as {
      sub: string;
      role: string;
      email: string | null;
      phone: string;
      tokenVersion?: number;
    };

    if (
      !decoded.sub ||
      typeof decoded.sub !== 'string'
    ) {
      return next(
        new Error('SOCKET_UNAUTHORIZED')
      );
    }

    const dbUser = await prisma.user.findUnique({
      where: {
        id: decoded.sub,
      },
      select: {
        id: true,
        role: true,
        email: true,
        phone: true,
        isActive: true,
        tokenVersion: true,
      },
    });

    if (!dbUser || !dbUser.isActive) {
      return next(
        new Error('SOCKET_UNAUTHORIZED')
      );
    }

    if (
      decoded.tokenVersion !== undefined &&
      decoded.tokenVersion !== dbUser.tokenVersion
    ) {
      return next(
        new Error('SOCKET_SESSION_REVOKED')
      );
    }

    const socketUser: SocketUser = {
      id: dbUser.id,
      role: dbUser.role,
      email: dbUser.email,
      phone: dbUser.phone,
      tokenVersion: dbUser.tokenVersion,
    };

    socket.data.user = socketUser;

    return next();
  } catch (error) {
    console.warn(
      '[Socket Auth] Connection rejected'
    );

    return next(
      new Error('SOCKET_UNAUTHORIZED')
    );
  }
});

io.on('connection', (socket) => {
  const user = socket.data.user as SocketUser;

  console.log(
    `[Socket] Authenticated connection: ${socket.id}`
  );

  // Every authenticated connection automatically joins
  // only its own private user room.
  socket.join(`user_${user.id}`);

  // Admin room membership comes from the authenticated DB role.
  if (isAdminRole(user.role)) {
    socket.join('admins');
  }

  if (
    user.role === 'SUPER_ADMIN' ||
    user.role === 'ADMIN' ||
    user.role === 'OPERATIONS'
  ) {
    socket.join('operations_admins');
  }

  // Kept for existing clients, but a client can only request
  // its own authenticated user room.
  socket.on(
    'joinUserRoom',
    (
      requestedUserId: string,
      ack?: SocketAck
    ) => {
      if (requestedUserId !== user.id) {
        ack?.({
          ok: false,
          error: 'FORBIDDEN',
        });
        return;
      }

      socket.join(`user_${user.id}`);

      ack?.({
        ok: true,
      });
    }
  );

  socket.on(
    'joinOrderRoom',
    async (
      orderId: string,
      ack?: SocketAck
    ) => {
      try {
        if (
          typeof orderId !== 'string' ||
          !orderId.trim()
        ) {
          ack?.({
            ok: false,
            error: 'INVALID_ORDER',
          });
          return;
        }

        const order = await prisma.order.findUnique({
          where: {
            id: orderId,
          },
          select: {
            customerId: true,
            courierId: true,
            store: {
              select: {
                merchant: {
                  select: {
                    userId: true,
                  },
                },
              },
            },
          },
        });

        if (!order) {
          ack?.({
            ok: false,
            error: 'FORBIDDEN',
          });
          return;
        }

        const allowed =
          isAdminRole(user.role) ||
          order.customerId === user.id ||
          order.courierId === user.id ||
          order.store.merchant.userId === user.id;

        if (!allowed) {
          ack?.({
            ok: false,
            error: 'FORBIDDEN',
          });
          return;
        }

        socket.join(`order_${orderId}`);

        ack?.({
          ok: true,
        });
      } catch (error) {
        console.error(
          '[Socket] joinOrderRoom failed:',
          error
        );

        ack?.({
          ok: false,
          error: 'SERVER_ERROR',
        });
      }
    }
  );

  socket.on(
    'joinStoreRoom',
    async (
      storeId: string,
      ack?: SocketAck
    ) => {
      try {
        if (
          typeof storeId !== 'string' ||
          !storeId.trim()
        ) {
          ack?.({
            ok: false,
            error: 'INVALID_STORE',
          });
          return;
        }

        const store = await prisma.store.findUnique({
          where: {
            id: storeId,
          },
          select: {
            merchant: {
              select: {
                userId: true,
              },
            },
          },
        });

        const allowed =
          !!store &&
          (
            isAdminRole(user.role) ||
            store.merchant.userId === user.id
          );

        if (!allowed) {
          ack?.({
            ok: false,
            error: 'FORBIDDEN',
          });
          return;
        }

        socket.join(`store_${storeId}`);

        ack?.({
          ok: true,
        });
      } catch (error) {
        console.error(
          '[Socket] joinStoreRoom failed:',
          error
        );

        ack?.({
          ok: false,
          error: 'SERVER_ERROR',
        });
      }
    }
  );

  // This legacy room is no longer used for broad order
  // broadcasting, but access remains restricted for compatibility.
  socket.on(
    'joinCourierChannel',
    async (ack?: SocketAck) => {
      try {
        if (user.role !== 'COURIER') {
          ack?.({
            ok: false,
            error: 'FORBIDDEN',
          });
          return;
        }

        const courier =
          await prisma.courierProfile.findUnique({
            where: {
              userId: user.id,
            },
            select: {
              verificationStatus: true,
              status: true,
              isOnline: true,
            },
          });

        if (
          !courier ||
          courier.verificationStatus !== 'APPROVED' ||
          courier.status !== 'AVAILABLE' ||
          !courier.isOnline
        ) {
          ack?.({
            ok: false,
            error: 'COURIER_NOT_AVAILABLE',
          });
          return;
        }

        socket.join('couriers_available');

        ack?.({
          ok: true,
        });
      } catch (error) {
        console.error(
          '[Socket] joinCourierChannel failed:',
          error
        );

        ack?.({
          ok: false,
          error: 'SERVER_ERROR',
        });
      }
    }
  );

  // Kept for compatibility. The supplied token is intentionally
  // ignored because admin authorization came from the handshake JWT.
  socket.on(
    'joinAdminRoom',
    (
      _legacyAdminToken?: string,
      ack?: SocketAck
    ) => {
      if (!isAdminRole(user.role)) {
        ack?.({
          ok: false,
          error: 'FORBIDDEN',
        });
        return;
      }

      socket.join('admins');

      ack?.({
        ok: true,
      });
    }
  );

  socket.on(
    'updateLocation',
    async (
      data: {
        orderId?: string;
        lat?: number;
        lng?: number;
        heading?: number;
      },
      ack?: SocketAck
    ) => {
      try {
        if (user.role !== 'COURIER') {
          ack?.({ ok: false, error: 'FORBIDDEN' });
          return;
        }

        const orderId =
          typeof data?.orderId === 'string' && data.orderId.trim()
            ? data.orderId.trim()
            : null;
        const lat = data?.lat;
        const lng = data?.lng;

        if (
          typeof lat !== 'number' ||
          typeof lng !== 'number' ||
          !Number.isFinite(lat) ||
          !Number.isFinite(lng) ||
          lat < -90 ||
          lat > 90 ||
          lng < -180 ||
          lng > 180
        ) {
          ack?.({ ok: false, error: 'INVALID_LOCATION' });
          return;
        }

        if (orderId) {
          const assignedOrder = await prisma.order.findFirst({
            where: {
              id: orderId,
              courierId: user.id,
              status: {
                in: ['COURIER_ASSIGNED', 'COURIER_ACCEPTED', 'PICKED_UP', 'ON_THE_WAY', 'ARRIVED'],
              },
            },
            select: { id: true },
          });

          if (!assignedOrder) {
            ack?.({ ok: false, error: 'FORBIDDEN' });
            return;
          }
        }

        const courierUpdate = await prisma.courierProfile.updateMany({
          where: {
            userId: user.id,
            verificationStatus: 'APPROVED',
            isOnline: true,
          },
          data: {
            currentLatitude: lat,
            currentLongitude: lng,
            lastLocationUpdate: new Date(),
          },
        });

        if (courierUpdate.count !== 1) {
          ack?.({ ok: false, error: 'COURIER_NOT_AVAILABLE' });
          return;
        }

        const heading =
          typeof data.heading === 'number' && Number.isFinite(data.heading)
            ? Math.max(0, Math.min(data.heading, 360))
            : 0;

        const payload = {
          courierId: user.id,
          orderId,
          latitude: lat,
          longitude: lng,
          heading,
          lastLocationAt: new Date().toISOString(),
        };

        if (orderId) {
          io.to(`order_${orderId}`).emit('courier.location_updated', payload);
        }
        io.to('operations_admins').emit('courier.location_updated', payload);

        ack?.({ ok: true });
      } catch (error) {
        console.error('[Socket] updateLocation failed:', error);
        ack?.({ ok: false, error: 'SERVER_ERROR' });
      }
    }
  );

  socket.on('disconnect', () => {
    console.log(
      `[Socket] Disconnected: ${socket.id}`
    );
  });
});
// Start Server
const PORT = config.port;
server.listen(PORT, () => {
  console.log(`
=============================================
🚀 Talabaty Express REST & Socket Server Started
🌐 Server listening on port ${PORT}
⚙️ Environment: ${config.nodeEnv}
=============================================
  `);

  startDispatchWorker(io);
});
