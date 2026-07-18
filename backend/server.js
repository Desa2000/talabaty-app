const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);

// Initialize Socket.io
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.get('/', (req, res) => {
  res.send('Talabaty WebSocket Tracking Server is Running 🚀');
});

io.on('connection', (socket) => {
  console.log(`🔌 Client connected: ${socket.id}`);

  // When Courier or Customer joins a specific tracking room
  socket.on('joinOrderRoom', (orderId) => {
    socket.join(orderId);
    console.log(`📦 Client ${socket.id} joined tracking room: ${orderId}`);
  });

  // When Courier emits a location update
  socket.on('updateLocation', (data) => {
    const { orderId, lat, lng } = data;
    
    // Broadcast this location to everyone else in the same room (i.e. the Customer)
    socket.to(orderId).emit('locationUpdated', { lat, lng });
    
    // Optional log for testing:
    // console.log(`📍 Order ${orderId} location updated: ${lat}, ${lng}`);
  });

  socket.on('disconnect', () => {
    console.log(`❌ Client disconnected: ${socket.id}`);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`
=============================================
🚀 Talabaty Live Tracking Server Started
🌐 Running on port ${PORT}
=============================================
  `);
});
