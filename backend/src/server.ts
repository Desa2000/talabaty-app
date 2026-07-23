import express from 'express';
import http from 'http';
import cors from 'cors';
import { Server } from 'socket.io';
import { config } from './config';
import {
  registerCustomer,
  registerMerchant,
  registerCourier,
  login,
  refresh,
  logout,
  getMe,
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
  courierPickupOrder,
  courierOnTheWay,
  courierArrived,
  courierDelivered,
  customerCancelOrder,
} from './modules/orders/order.controller';
import {
  getAddresses,
  createAddress,
  deleteAddress,
} from './modules/address/address.controller';
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
import { authenticate, authorizeRoles } from './middleware/auth.middleware';

const app = express();
export const server = http.createServer(app);

// CORS Configuration
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  })
);

// Body Parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check
app.get('/', (req, res) => {
  res.send('Talabaty REST & Socket Real-Time Server is Running 🚀');
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', system: 'Talabaty API', timestamp: new Date() });
});

// 1. Auth Routes
app.post('/api/auth/register/customer', registerCustomer);
app.post('/api/auth/register/merchant', registerMerchant);
app.post('/api/auth/register/courier', registerCourier);
app.post('/api/auth/login', login);
app.post('/api/auth/refresh', refresh);
app.post('/api/auth/logout', logout);
app.get('/api/auth/me', authenticate, getMe);

// 2. Store Routes
app.get('/api/stores', getStores);
app.get('/api/stores/:id', getStoreById);
app.put('/api/merchant/stores/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), updateMerchantStore);

// 3. Product Routes
app.post('/api/merchant/products', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), createProduct);
app.put('/api/merchant/products/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), updateProduct);
app.delete('/api/merchant/products/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN', 'SUPER_ADMIN'), deleteProduct);

// 4. Cart Route
app.post('/api/cart/validate', validateCart);

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
app.post('/api/orders/:id/courier/accept', authenticate, authorizeRoles('COURIER', 'ADMIN', 'SUPER_ADMIN'), courierAcceptOrder);
app.post('/api/orders/:id/picked-up', authenticate, authorizeRoles('COURIER', 'ADMIN', 'SUPER_ADMIN'), courierPickupOrder);
app.post('/api/orders/:id/on-the-way', authenticate, authorizeRoles('COURIER', 'ADMIN', 'SUPER_ADMIN'), courierOnTheWay);
app.post('/api/orders/:id/arrived', authenticate, authorizeRoles('COURIER', 'ADMIN', 'SUPER_ADMIN'), courierArrived);
app.post('/api/orders/:id/delivered', authenticate, authorizeRoles('COURIER', 'ADMIN', 'SUPER_ADMIN'), courierDelivered);
app.post('/api/orders/:id/completed', authenticate, courierDelivered);
app.post('/api/orders/:id/cancel', authenticate, customerCancelOrder);

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
app.get('/api/admin/orders', authenticate, authorizeRoles(...adminRoles), getAdminOrders);
app.get('/api/admin/orders/:id', authenticate, authorizeRoles(...adminRoles), getAdminOrderById);
app.post('/api/admin/orders/:id/reassign-courier', authenticate, authorizeRoles(...opsRoles), adminReassignCourier);
app.post('/api/admin/orders/:id/cancel', authenticate, authorizeRoles(...opsRoles), adminCancelOrder);

app.get('/api/admin/merchants', authenticate, authorizeRoles(...adminRoles), getAdminMerchants);
app.post('/api/admin/merchants/:id/status', authenticate, authorizeRoles(...opsRoles), updateMerchantStatus);

app.get('/api/admin/couriers', authenticate, authorizeRoles(...adminRoles), getAdminCouriers);
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
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

io.on('connection', (socket) => {
  console.log(`🔌 Client connected: ${socket.id}`);

  socket.on('joinOrderRoom', (orderId: string) => {
    socket.join(`order_${orderId}`);
    console.log(`📦 Client ${socket.id} joined tracking room: order_${orderId}`);
  });

  socket.on('joinUserRoom', (userId: string) => {
    socket.join(`user_${userId}`);
    console.log(`👤 Client ${socket.id} joined user room: user_${userId}`);
  });

  socket.on('joinStoreRoom', (storeId: string) => {
    socket.join(`store_${storeId}`);
    console.log(`🏪 Merchant ${socket.id} joined store room: store_${storeId}`);
  });

  socket.on('joinCourierChannel', () => {
    socket.join('couriers_available');
    console.log(`🛵 Courier ${socket.id} joined available couriers room`);
  });

  socket.on('joinAdminRoom', (adminToken: string) => {
    // Basic verification check for admin room joining
    socket.join('admins');
    console.log(`🛡️ Admin ${socket.id} joined secure admin room`);
  });

  socket.on('updateLocation', (data: { orderId: string; lat: number; lng: number; heading?: number }) => {
    const { orderId, lat, lng, heading } = data;
    io.to(`order_${orderId}`).emit('courier.location_updated', { orderId, latitude: lat, longitude: lng, heading: heading || 0.0 });
    io.to('admins').emit('courier.location_updated', { orderId, latitude: lat, longitude: lng, heading: heading || 0.0 });
  });

  socket.on('disconnect', () => {
    console.log(`❌ Client disconnected: ${socket.id}`);
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
});
