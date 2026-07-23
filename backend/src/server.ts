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
app.put('/api/merchant/stores/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), updateMerchantStore);

// 3. Product Routes
app.post('/api/merchant/products', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), createProduct);
app.put('/api/merchant/products/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), updateProduct);
app.delete('/api/merchant/products/:id', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), deleteProduct);

// 4. Cart Route
app.post('/api/cart/validate', validateCart);

// 5. Order Routes
app.post('/api/orders', authenticate, createOrder);
app.get('/api/orders/my', authenticate, getMyOrders);
app.get('/api/orders/:id', authenticate, getOrderById);

// Merchant Order Flow
app.post('/api/orders/:id/merchant/accept', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), merchantAcceptOrder);
app.post('/api/orders/:id/merchant/reject', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), merchantRejectOrder);
app.post('/api/orders/:id/preparing', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), merchantPreparing);
app.post('/api/orders/:id/ready', authenticate, authorizeRoles('MERCHANT', 'ADMIN'), merchantReadyForPickup);

// Courier Order Flow
app.post('/api/orders/:id/courier/accept', authenticate, authorizeRoles('COURIER', 'ADMIN'), courierAcceptOrder);
app.post('/api/orders/:id/picked-up', authenticate, authorizeRoles('COURIER', 'ADMIN'), courierPickupOrder);
app.post('/api/orders/:id/on-the-way', authenticate, authorizeRoles('COURIER', 'ADMIN'), courierOnTheWay);
app.post('/api/orders/:id/arrived', authenticate, authorizeRoles('COURIER', 'ADMIN'), courierArrived);
app.post('/api/orders/:id/delivered', authenticate, authorizeRoles('COURIER', 'ADMIN'), courierDelivered);
app.post('/api/orders/:id/completed', authenticate, courierDelivered); // Completed triggers delivery confirmation
app.post('/api/orders/:id/cancel', authenticate, customerCancelOrder);

// 6. Address Routes
app.get('/api/addresses', authenticate, getAddresses);
app.post('/api/addresses', authenticate, createAddress);
app.delete('/api/addresses/:id', authenticate, deleteAddress);

// 7. Courier Routes
app.post('/api/courier/location', authenticate, authorizeRoles('COURIER', 'ADMIN'), updateCourierLocation);
app.post('/api/courier/status', authenticate, authorizeRoles('COURIER', 'ADMIN'), updateCourierStatus);

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

  socket.on('updateLocation', (data: { orderId: string; lat: number; lng: number; heading?: number }) => {
    const { orderId, lat, lng, heading } = data;
    io.to(`order_${orderId}`).emit('courier.location_updated', { orderId, latitude: lat, longitude: lng, heading: heading || 0.0 });
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
