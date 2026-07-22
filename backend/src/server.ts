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
import { authenticate } from './middleware/auth.middleware';

const app = express();
const server = http.createServer(app);

// Cors Configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
}));

// Body Parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// HTTP REST API Root check
app.get('/', (req, res) => {
  res.send('Talabaty REST & Tracking Server is Running 🚀');
});

// Authentication Routes
app.post('/api/auth/register/customer', registerCustomer);
app.post('/api/auth/register/merchant', registerMerchant);
app.post('/api/auth/register/courier', registerCourier);
app.post('/api/auth/login', login);
app.post('/api/auth/refresh', refresh);
app.post('/api/auth/logout', logout);
app.get('/api/auth/me', authenticate, getMe);

// Initialize Socket.io (matching original WebSocket server configuration)
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

io.on('connection', (socket) => {
  console.log(`🔌 Live Tracking Client connected: ${socket.id}`);

  socket.on('joinOrderRoom', (orderId) => {
    socket.join(orderId);
    console.log(`📦 Client ${socket.id} joined tracking room: ${orderId}`);
  });

  socket.on('updateLocation', (data) => {
    const { orderId, lat, lng } = data;
    socket.to(orderId).emit('locationUpdated', { lat, lng });
  });

  socket.on('disconnect', () => {
    console.log(`❌ Live Tracking Client disconnected: ${socket.id}`);
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
