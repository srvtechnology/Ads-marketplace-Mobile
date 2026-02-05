# Real-Time Chat Implementation Using Socket.IO
## Backend Developer Requirements Documentation

### Version: 1.0
### Date: February 3, 2026
### Author: Technical Architect (Flutter Developer Perspective)

---

## 📋 Table of Contents
1. [Executive Summary](#executive-summary)
2. [Current System Analysis](#current-system-analysis)
3. [Socket Architecture Requirements](#socket-architecture-requirements)
4. [Socket Events Specification](#socket-events-specification)
5. [Database Schema Updates](#database-schema-updates)
6. [API Endpoints](#api-endpoints)
7. [Real-Time Features](#real-time-features)
8. [Security & Authentication](#security--authentication)
9. [Performance Optimization](#performance-optimization)
10. [Testing Requirements](#testing-requirements)
11. [Migration Strategy](#migration-strategy)

---

## 📊 Executive Summary

This document outlines the technical requirements for upgrading the Ads Marketplace chat system from a REST API polling-based architecture to a real-time Socket.IO implementation. This upgrade will significantly enhance user experience by providing:

- **Instant message delivery** (no polling delays)
- **Real-time typing indicators**
- **Online/offline presence**
- **Message delivery & read receipts**
- **Reduced server load** (eliminate polling)
- **Battery optimization** (mobile apps)

---

## 🔍 Current System Analysis

### Current Architecture (REST API Based)

#### **Chat Flow Overview:**

```
Buyer/Seller Flow:
1. Buyer browses items → Initiates chat → Creates item_offer
2. Both parties exchange messages via REST API calls
3. Messages stored in database with sender_id, receiver_id, item_offer_id
4. App polls server periodically to fetch new messages
```

#### **Current API Endpoints:**
1. `GET /chat-list` - Fetch chat user lists (buyer/seller)
2. `POST /chat-messages` - Fetch messages for a conversation
3. `POST /send-message` - Send a new message
4. `POST /chat-messages/status-change-offer` - Accept/Reject offers
5. `POST /block-user` - Block a user
6. `POST /unblock-user` - Unblock a user
7. `GET /blocked-users` - Get blocked users list

#### **Current Data Models:**

**ChatUser Model:**
```json
{
  "id": 1,
  "seller_id": 123,
  "buyer_id": 456,
  "item_id": 789,
  "created_at": "2026-02-03 10:00:00",
  "updated_at": "2026-02-03 10:30:00",
  "amount": 5000.00,
  "seller": {
    "id": 123,
    "name": "John Doe",
    "profile": "https://example.com/profile.jpg"
  },
  "buyer": {
    "id": 456,
    "name": "Jane Smith",
    "profile": "https://example.com/profile2.jpg"
  },
  "item": {
    "id": 789,
    "name": "iPhone 15 Pro",
    "description": "Excellent condition",
    "price": 50000.00,
    "image": "https://example.com/item.jpg",
    "status": "active",
    "is_purchased": 0
  },
  "user_blocked": false,
  "unread_chat_count": 5
}
```

**ChatMessage Model:**
```json
{
  "id": 1,
  "sender_id": 123,
  "receiver_id": 456,
  "item_offer_id": 1,
  "message": "Hello, is this available?",
  "file": "https://example.com/attachment.jpg",
  "audio": "https://example.com/audio.wav",
  "type": "N",
  "amount": null,
  "offer_status": null,
  "created_at": "2026-02-03 10:00:00",
  "updated_at": "2026-02-03 10:00:00"
}
```

#### **Message Types:**
- `N` - Normal message
- `O` - Offer message (contains amount field)

#### **Offer Status:**
- `null` - Pending
- `A` - Accepted
- `R` - Rejected

#### **Item Status:**
- `active` - Item is active
- `inactive` - Deactivated by seller
- `sold out` - Item sold
- `review` - Under review
- `rejected` - Rejected by admin
- `soft rejected` - Temporary rejection
- `permanent rejected` - Banned

#### **Problems with Current System:**
1. ❌ **High Latency:** Messages delayed by polling interval (5-30 seconds)
2. ❌ **Server Load:** Constant polling from thousands of users
3. ❌ **Battery Drain:** Mobile apps constantly polling
4. ❌ **No Real-Time Features:** No typing indicators, presence, read receipts
5. ❌ **Poor UX:** Users wait for messages to appear
6. ❌ **Bandwidth Waste:** Repeated API calls returning no new data

---

## 🏗️ Socket Architecture Requirements

### Technology Stack

**Backend:**
- **Socket.IO Server** (Node.js recommended)
- **Redis** for socket session management and pub/sub
- **Database:** Existing MySQL/PostgreSQL
- **Message Queue:** Redis or RabbitMQ for message persistence

**Why Socket.IO?**
- ✅ Cross-platform support (iOS, Android, Web)
- ✅ Auto-reconnection & fallback mechanisms
- ✅ Room-based broadcasting
- ✅ Large ecosystem & community
- ✅ Proven reliability at scale

### High-Level Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (iOS/Android)  │
└────────┬────────┘
         │ WebSocket (Socket.IO)
         │
┌────────▼────────────────────────────────┐
│     Load Balancer (Nginx/HAProxy)      │
└────────┬────────────────────────────────┘
         │
    ┌────┴────┬────────┬────────┐
    │         │        │        │
┌───▼───┐ ┌──▼──┐ ┌───▼───┐ ┌──▼──┐
│Socket │ │Socket│ │Socket │ │Socket│
│Server1│ │Server2│ │Server3│ │Server4│
└───┬───┘ └──┬──┘ └───┬───┘ └──┬──┘
    │        │        │        │
    └────────┴────┬───┴────────┘
                  │
         ┌────────▼────────┐
         │  Redis Pub/Sub  │
         │  (Session Store)│
         └────────┬────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼───┐    ┌────▼────┐   ┌───▼────┐
│ MySQL │    │ Message │   │ File   │
│   DB  │    │  Queue  │   │Storage │
└───────┘    └─────────┘   └────────┘
```

### Scalability Considerations

1. **Horizontal Scaling:** Multiple socket servers behind load balancer
2. **Sticky Sessions:** User connects to same server (session affinity)
3. **Redis Pub/Sub:** Cross-server message broadcasting
4. **Database Connection Pooling:** Optimize DB connections
5. **CDN for Media:** Offload file/image storage

---

## 🔌 Socket Events Specification

### 1. Connection & Authentication

#### **Client → Server: `authenticate`**
```javascript
// Event Name: authenticate
// Description: Authenticate user after socket connection

{
  "token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": 123,
  "device_id": "unique-device-uuid",
  "platform": "android" // or "ios", "web"
}
```

**Server Response:**
```javascript
// Success
{
  "status": "authenticated",
  "user_id": 123,
  "socket_id": "socket_abc123",
  "timestamp": "2026-02-03T10:00:00Z"
}

// Error
{
  "status": "error",
  "error": "Invalid token",
  "code": "AUTH_FAILED"
}
```

---

### 2. Chat Room Management

#### **Client → Server: `join_chat_room`**
```javascript
// Event Name: join_chat_room
// Description: Join a specific chat conversation

{
  "item_offer_id": 1,
  "user_id": 123,
  "other_user_id": 456 // Optional for validation
}
```

**Server Response:**
```javascript
// Success - Join room and send history
{
  "status": "joined",
  "room_id": "chat_1",
  "item_offer_id": 1,
  "messages": [
    // Last 50 messages (or configurable)
  ],
  "unread_count": 5,
  "other_user": {
    "id": 456,
    "name": "Jane Smith",
    "profile": "https://...",
    "is_online": true,
    "last_seen": "2026-02-03T09:55:00Z"
  }
}
```

#### **Client → Server: `leave_chat_room`**
```javascript
{
  "item_offer_id": 1,
  "user_id": 123
}
```

---

### 3. Messaging Events

#### **Client → Server: `send_message`**
```javascript
// Event Name: send_message
// Description: Send a new message

{
  "item_offer_id": 1,
  "sender_id": 123,
  "receiver_id": 456,
  "message": "Hello, is this still available?",
  "type": "N", // N = Normal, O = Offer
  "amount": null, // Only for type = "O"
  "file": null, // File URL if attachment
  "audio": null, // Audio URL if voice message
  "temp_id": "temp_msg_12345", // Client-generated ID
  "timestamp": "2026-02-03T10:00:00Z"
}
```

**Server → All Room Members: `message_received`**
```javascript
// Broadcast to all users in the room
{
  "id": 12345, // Server-generated ID
  "item_offer_id": 1,
  "sender_id": 123,
  "receiver_id": 456,
  "message": "Hello, is this still available?",
  "type": "N",
  "amount": null,
  "file": null,
  "audio": null,
  "offer_status": null,
  "temp_id": "temp_msg_12345",
  "created_at": "2026-02-03T10:00:00Z",
  "updated_at": "2026-02-03T10:00:00Z",
  "sender": {
    "id": 123,
    "name": "John Doe",
    "profile": "https://..."
  }
}
```

**Server → Sender Only: `message_sent`**
```javascript
// Confirmation to sender
{
  "status": "sent",
  "temp_id": "temp_msg_12345",
  "message_id": 12345,
  "timestamp": "2026-02-03T10:00:00Z"
}
```

**Error Response to Sender:**
```javascript
{
  "status": "error",
  "temp_id": "temp_msg_12345",
  "error": "User is blocked",
  "code": "USER_BLOCKED"
}
```

---

### 4. Typing Indicators

#### **Client → Server: `typing_start`**
```javascript
{
  "item_offer_id": 1,
  "user_id": 123
}
```

**Server → Other User: `user_typing`**
```javascript
{
  "item_offer_id": 1,
  "user_id": 123,
  "user_name": "John Doe",
  "is_typing": true
}
```

#### **Client → Server: `typing_stop`**
```javascript
{
  "item_offer_id": 1,
  "user_id": 123
}
```

**Server → Other User: `user_typing`**
```javascript
{
  "item_offer_id": 1,
  "user_id": 123,
  "user_name": "John Doe",
  "is_typing": false
}
```

---

### 5. Message Status Events

#### **Client → Server: `message_delivered`**
```javascript
// Sent when user's app receives message (even in background)
{
  "message_ids": [12345, 12346, 12347],
  "user_id": 456,
  "delivered_at": "2026-02-03T10:00:05Z"
}
```

**Server → Sender: `messages_delivered`**
```javascript
{
  "message_ids": [12345, 12346, 12347],
  "delivered_to": 456,
  "delivered_at": "2026-02-03T10:00:05Z"
}
```

#### **Client → Server: `message_read`**
```javascript
// Sent when user opens chat and views messages
{
  "message_ids": [12345, 12346, 12347],
  "user_id": 456,
  "read_at": "2026-02-03T10:01:00Z"
}
```

**Server → Sender: `messages_read`**
```javascript
{
  "message_ids": [12345, 12346, 12347],
  "read_by": 456,
  "read_at": "2026-02-03T10:01:00Z"
}
```

---

### 6. Online Presence

#### **Server → All Active Chats: `user_online`**
```javascript
// Broadcast when user connects
{
  "user_id": 123,
  "is_online": true,
  "last_seen": "2026-02-03T10:00:00Z"
}
```

#### **Server → All Active Chats: `user_offline`**
```javascript
// Broadcast when user disconnects
{
  "user_id": 123,
  "is_online": false,
  "last_seen": "2026-02-03T10:30:00Z"
}
```

#### **Client → Server: `get_user_status`**
```javascript
{
  "user_ids": [123, 456, 789]
}
```

**Server Response:**
```javascript
{
  "users": [
    {
      "user_id": 123,
      "is_online": true,
      "last_seen": "2026-02-03T10:00:00Z"
    },
    {
      "user_id": 456,
      "is_online": false,
      "last_seen": "2026-02-03T09:45:00Z"
    }
  ]
}
```

---

### 7. Offer Management Events

#### **Client → Server: `send_offer`**
```javascript
{
  "item_offer_id": 1,
  "sender_id": 123,
  "receiver_id": 456,
  "amount": 45000.00,
  "message": "I can offer 45,000 for this item",
  "temp_id": "temp_offer_123"
}
```

**Server → Room: `offer_received`**
```javascript
{
  "id": 12345,
  "item_offer_id": 1,
  "sender_id": 123,
  "receiver_id": 456,
  "message": "I can offer 45,000 for this item",
  "type": "O",
  "amount": 45000.00,
  "offer_status": null,
  "temp_id": "temp_offer_123",
  "created_at": "2026-02-03T10:00:00Z"
}
```

#### **Client → Server: `update_offer_status`**
```javascript
{
  "chat_id": 12345,
  "item_offer_id": 1,
  "offer_status": "A", // "A" = Accepted, "R" = Rejected
  "user_id": 456
}
```

**Server → Room: `offer_status_updated`**
```javascript
{
  "chat_id": 12345,
  "item_offer_id": 1,
  "offer_status": "A",
  "updated_by": 456,
  "updated_at": "2026-02-03T10:05:00Z"
}
```

---

### 8. File/Media Upload Events

#### **Client → Server: `upload_media_start`**
```javascript
{
  "item_offer_id": 1,
  "user_id": 123,
  "file_name": "image.jpg",
  "file_size": 2048000,
  "file_type": "image/jpeg"
}
```

**Server Response:**
```javascript
{
  "status": "ready",
  "upload_url": "https://upload.example.com/chat/...",
  "upload_id": "upload_123",
  "max_file_size": 5242880 // 5MB
}
```

#### **Client → Server: `upload_media_complete`**
```javascript
{
  "upload_id": "upload_123",
  "file_url": "https://cdn.example.com/chat/image.jpg"
}
```

---

### 9. Block/Unblock Events

#### **Client → Server: `block_user`**
```javascript
{
  "blocker_id": 123,
  "blocked_user_id": 456
}
```

**Server → Blocked User: `user_blocked_you`**
```javascript
{
  "blocked_by": 123,
  "item_offer_id": 1,
  "timestamp": "2026-02-03T10:00:00Z"
}
```

**Server → Blocker: `user_blocked_success`**
```javascript
{
  "status": "blocked",
  "blocked_user_id": 456,
  "timestamp": "2026-02-03T10:00:00Z"
}
```

#### **Client → Server: `unblock_user`**
```javascript
{
  "blocker_id": 123,
  "blocked_user_id": 456
}
```

---

### 10. Chat List Updates

#### **Server → User: `chat_list_update`**
```javascript
// Broadcast when new message in any chat
{
  "item_offer_id": 1,
  "last_message": {
    "id": 12345,
    "message": "Hello there!",
    "sender_id": 456,
    "created_at": "2026-02-03T10:00:00Z"
  },
  "unread_count": 6,
  "updated_at": "2026-02-03T10:00:00Z"
}
```

---

### 11. Item Status Updates

#### **Server → Room: `item_status_changed`**
```javascript
// Broadcast when item status changes
{
  "item_id": 789,
  "item_offer_id": 1,
  "old_status": "active",
  "new_status": "sold out",
  "updated_at": "2026-02-03T10:00:00Z",
  "sold_to": 456 // If sold
}
```

---

### 12. Error Events

#### **Server → Client: `error`**
```javascript
{
  "error_code": "RATE_LIMIT_EXCEEDED",
  "error_message": "Too many messages sent. Please slow down.",
  "retry_after": 30, // seconds
  "timestamp": "2026-02-03T10:00:00Z"
}
```

**Common Error Codes:**
- `AUTH_FAILED` - Authentication failed
- `INVALID_TOKEN` - JWT token invalid/expired
- `USER_BLOCKED` - User is blocked
- `RATE_LIMIT_EXCEEDED` - Too many requests
- `ROOM_NOT_FOUND` - Chat room doesn't exist
- `PERMISSION_DENIED` - User doesn't have access
- `MESSAGE_TOO_LARGE` - Message exceeds size limit
- `FILE_TOO_LARGE` - File upload too large
- `INVALID_REQUEST` - Malformed request data

---

## 💾 Database Schema Updates

### New Tables

#### 1. **socket_sessions**
```sql
CREATE TABLE socket_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    socket_id VARCHAR(255) NOT NULL,
    device_id VARCHAR(255),
    platform VARCHAR(50), -- 'android', 'ios', 'web'
    ip_address VARCHAR(45),
    connected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_heartbeat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_user_id (user_id),
    INDEX idx_socket_id (socket_id),
    INDEX idx_active (is_active),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 2. **message_status**
```sql
CREATE TABLE message_status (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    message_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    status ENUM('sent', 'delivered', 'read') DEFAULT 'sent',
    delivered_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_message_id (message_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    FOREIGN KEY (message_id) REFERENCES chat_messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 3. **user_presence**
```sql
CREATE TABLE user_presence (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    platform VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_online (is_online),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Updated Tables

#### **chat_messages** (Add new columns)
```sql
ALTER TABLE chat_messages
ADD COLUMN temp_id VARCHAR(255) NULL COMMENT 'Client-generated temporary ID',
ADD COLUMN delivered_at TIMESTAMP NULL,
ADD COLUMN read_at TIMESTAMP NULL,
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE,
ADD COLUMN deleted_at TIMESTAMP NULL,
ADD INDEX idx_temp_id (temp_id),
ADD INDEX idx_delivered (delivered_at),
ADD INDEX idx_read (read_at);
```

#### **item_offers** (Add unread tracking)
```sql
ALTER TABLE item_offers
ADD COLUMN buyer_unread_count INT DEFAULT 0,
ADD COLUMN seller_unread_count INT DEFAULT 0,
ADD COLUMN last_message_at TIMESTAMP NULL,
ADD COLUMN last_message_preview TEXT NULL,
ADD INDEX idx_last_message (last_message_at);
```

---

## 🔐 Security & Authentication

### 1. **JWT Token Validation**
```javascript
// Middleware for socket authentication
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    socket.userId = decoded.user_id;
    socket.userRole = decoded.role;
    
    next();
  } catch (error) {
    next(new Error('Authentication failed'));
  }
});
```

### 2. **Room Access Control**
```javascript
// Verify user has access to chat room
async function canAccessRoom(userId, itemOfferId) {
  const offer = await db.query(
    'SELECT * FROM item_offers WHERE id = ? AND (buyer_id = ? OR seller_id = ?)',
    [itemOfferId, userId, userId]
  );
  
  return offer.length > 0;
}
```

### 3. **Rate Limiting**
```javascript
// Limit messages per user per minute
const rateLimiter = new RateLimiter({
  tokensPerInterval: 20, // 20 messages
  interval: 'minute'
});

socket.on('send_message', async (data) => {
  if (!await rateLimiter.removeTokens(socket.userId, 1)) {
    socket.emit('error', {
      error_code: 'RATE_LIMIT_EXCEEDED',
      error_message: 'Too many messages'
    });
    return;
  }
  
  // Process message...
});
```

### 4. **Message Content Validation**
```javascript
function validateMessage(data) {
  const errors = [];
  
  // Check message length
  if (data.message && data.message.length > 5000) {
    errors.push('Message too long (max 5000 chars)');
  }
  
  // Validate file types
  if (data.file) {
    const allowedTypes = ['jpg', 'jpeg', 'png', 'pdf'];
    const ext = data.file.split('.').pop().toLowerCase();
    if (!allowedTypes.includes(ext)) {
      errors.push('Invalid file type');
    }
  }
  
  // Check for blocked users
  if (await isUserBlocked(data.sender_id, data.receiver_id)) {
    errors.push('User is blocked');
  }
  
  return {
    valid: errors.length === 0,
    errors
  };
}
```

### 5. **XSS Protection**
```javascript
const xss = require('xss');

function sanitizeMessage(message) {
  return xss(message, {
    whiteList: {}, // No HTML allowed
    stripIgnoreTag: true
  });
}
```

---

## ⚡ Performance Optimization

### 1. **Redis Caching Strategy**

```javascript
// Cache user presence
await redis.setex(`user:${userId}:online`, 300, 'true');

// Cache unread counts
await redis.hincrby(`chat:${itemOfferId}:unread`, userId, 1);

// Cache recent messages
await redis.zadd(
  `chat:${itemOfferId}:messages`,
  timestamp,
  JSON.stringify(message)
);
```

### 2. **Message Batching**
```javascript
// Batch delivery receipts
const deliveryBatch = [];
socket.on('message_delivered', (data) => {
  deliveryBatch.push(data);
  
  // Flush every 5 seconds or 50 messages
  if (deliveryBatch.length >= 50) {
    flushDeliveryReceipts();
  }
});

setInterval(flushDeliveryReceipts, 5000);
```

### 3. **Message Pagination**
```javascript
// Load messages in chunks
async function loadMessages(itemOfferId, page = 1, limit = 50) {
  const offset = (page - 1) * limit;
  
  return await db.query(
    `SELECT * FROM chat_messages 
     WHERE item_offer_id = ? 
     ORDER BY created_at DESC 
     LIMIT ? OFFSET ?`,
    [itemOfferId, limit, offset]
  );
}
```

### 4. **Connection Pooling**
```javascript
// Database connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  connectionLimit: 100,
  queueLimit: 0
});
```

### 5. **Compression**
```javascript
// Enable socket compression
const io = require('socket.io')(server, {
  perMessageDeflate: {
    threshold: 1024, // Compress messages > 1KB
    zlibDeflateOptions: {
      chunkSize: 1024,
      memLevel: 7,
      level: 3
    }
  }
});
```

---

## 🧪 Testing Requirements

### 1. **Unit Tests**
```javascript
describe('Socket Message Handler', () => {
  it('should send message to room', async () => {
    const message = {
      item_offer_id: 1,
      sender_id: 123,
      receiver_id: 456,
      message: 'Test message'
    };
    
    const result = await sendMessage(message);
    expect(result.status).toBe('sent');
    expect(result.message_id).toBeDefined();
  });
  
  it('should reject message from blocked user', async () => {
    // Test blocked user scenario
  });
});
```

### 2. **Integration Tests**
- Test complete message flow from sender to receiver
- Test reconnection and message recovery
- Test file upload workflow
- Test offer accept/reject flow

### 3. **Load Tests**
```javascript
// Artillery.io config
config:
  target: 'wss://api.example.com'
  phases:
    - duration: 60
      arrivalRate: 100 // 100 connections per second
      name: 'Warm up'
    - duration: 120
      arrivalRate: 500 // 500 connections per second
      name: 'Sustained load'

scenarios:
  - name: 'Send messages'
    engine: 'socketio'
    flow:
      - emit:
          channel: 'authenticate'
          data:
            token: '{{ token }}'
      - emit:
          channel: 'send_message'
          data:
            message: 'Load test message'
```

### 4. **Stress Tests**
- 10,000 concurrent connections
- 1,000 messages per second
- Network latency simulation
- Server crash recovery

---

## 🚀 Migration Strategy

### Phase 1: Preparation (Week 1-2)
1. ✅ Set up Socket.IO server infrastructure
2. ✅ Deploy Redis cluster
3. ✅ Update database schema
4. ✅ Create migration scripts
5. ✅ Set up monitoring & logging

### Phase 2: Development (Week 3-4)
1. ✅ Implement core socket events
2. ✅ Implement authentication
3. ✅ Implement message persistence
4. ✅ Implement presence system
5. ✅ Unit & integration tests

### Phase 3: Beta Testing (Week 5)
1. ✅ Deploy to staging environment
2. ✅ Beta test with 100 users
3. ✅ Monitor performance & bugs
4. ✅ Optimize based on feedback

### Phase 4: Gradual Rollout (Week 6-7)
1. ✅ **Hybrid Mode:** Support both REST and Socket
2. ✅ 10% users → Socket.IO
3. ✅ Monitor metrics (latency, errors, battery)
4. ✅ 50% users → Socket.IO
5. ✅ 100% users → Socket.IO

### Phase 5: REST Deprecation (Week 8)
1. ✅ Disable REST polling endpoints
2. ✅ Keep REST endpoints for fallback
3. ✅ Monitor for 2 weeks
4. ✅ Remove old polling code

---

## 📊 Monitoring & Metrics

### Key Metrics to Track

1. **Connection Metrics:**
   - Active connections
   - Connection rate (per second)
   - Disconnection rate
   - Reconnection attempts
   - Average connection time

2. **Message Metrics:**
   - Messages sent per second
   - Message delivery time (avg/p95/p99)
   - Failed message rate
   - Messages in queue

3. **Performance Metrics:**
   - Server CPU usage
   - Memory usage
   - Network bandwidth
   - Database query time
   - Redis latency

4. **Business Metrics:**
   - Messages per user per day
   - Average response time
   - Chat engagement rate
   - Offer acceptance rate

### Monitoring Tools
- **Prometheus** - Metrics collection
- **Grafana** - Dashboards & visualization
- **ELK Stack** - Log aggregation
- **Sentry** - Error tracking
- **New Relic/DataDog** - APM

---

## 📝 API Endpoints (REST - Still Required)

Keep these REST endpoints for fallback and initial data:

### 1. **GET /api/chat/history**
```javascript
// Fetch chat history (when app opens)
GET /api/chat/history?item_offer_id=1&page=1&limit=50

Response:
{
  "status": "success",
  "data": {
    "messages": [...],
    "total": 150,
    "has_more": true
  }
}
```

### 2. **POST /api/chat/upload**
```javascript
// Upload media files
POST /api/chat/upload
Content-Type: multipart/form-data

{
  "file": <binary>,
  "item_offer_id": 1
}

Response:
{
  "status": "success",
  "data": {
    "url": "https://cdn.example.com/chat/file.jpg",
    "thumbnail": "https://cdn.example.com/chat/thumb.jpg"
  }
}
```

### 3. **GET /api/chat/unread-counts**
```javascript
// Get unread counts for all chats
GET /api/chat/unread-counts

Response:
{
  "status": "success",
  "data": {
    "total_unread": 23,
    "chats": [
      {
        "item_offer_id": 1,
        "unread_count": 5
      },
      {
        "item_offer_id": 2,
        "unread_count": 3
      }
    ]
  }
}
```

---

## 🔔 Push Notifications Integration

When user is offline, fallback to push notifications:

```javascript
// Check if user is online
async function sendMessageWithFallback(message) {
  const isOnline = await redis.get(`user:${message.receiver_id}:online`);
  
  if (isOnline) {
    // Send via socket
    io.to(`user_${message.receiver_id}`).emit('message_received', message);
  } else {
    // Send push notification
    await sendPushNotification({
      user_id: message.receiver_id,
      title: message.sender_name,
      body: message.message,
      data: {
        type: 'new_message',
        item_offer_id: message.item_offer_id,
        sender_id: message.sender_id
      }
    });
  }
}
```

---

## 💡 Best Practices

### 1. **Idempotency**
```javascript
// Use temp_id to prevent duplicate messages
const existingMsg = await db.query(
  'SELECT id FROM chat_messages WHERE temp_id = ?',
  [data.temp_id]
);

if (existingMsg.length > 0) {
  return existingMsg[0].id; // Return existing message ID
}
```

### 2. **Message Queuing**
```javascript
// Queue messages for offline users
if (!isUserOnline(receiverId)) {
  await messageQueue.add({
    user_id: receiverId,
    message: message,
    retry: 3
  });
}
```

### 3. **Graceful Degradation**
```javascript
// Fallback to REST if socket fails
try {
  await sendViaSocket(message);
} catch (error) {
  await sendViaREST(message);
}
```

### 4. **Heartbeat Mechanism**
```javascript
// Keep connection alive
setInterval(() => {
  socket.emit('ping');
}, 30000);

socket.on('pong', () => {
  // Update last_heartbeat in database
});
```

---

## 🎯 Success Criteria

### Before Launch:
- ✅ 99.9% message delivery success rate
- ✅ < 100ms average message latency
- ✅ Support 10,000+ concurrent users
- ✅ < 1% error rate
- ✅ Zero data loss

### Post Launch:
- ✅ 50% reduction in server load
- ✅ 70% reduction in battery usage
- ✅ 90% user satisfaction with real-time chat
- ✅ 2x increase in message frequency

---

## 📚 Additional Resources

### Documentation Links:
- Socket.IO Docs: https://socket.io/docs/
- Redis Pub/Sub: https://redis.io/topics/pubsub
- JWT Auth: https://jwt.io/introduction/
- Flutter Socket.IO: https://pub.dev/packages/socket_io_client

### Sample Implementations:
- WhatsApp-like architecture patterns
- Slack messaging infrastructure
- Discord real-time messaging

---

## 🤝 Support & Questions

For technical questions or clarifications, contact:
- **Flutter Developer:** Lead Mobile Team
- **Backend Team Lead:** Socket Implementation
- **DevOps:** Infrastructure & Deployment

---

## 📝 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 3, 2026 | Technical Architect | Initial document |

---

## Appendix A: Sample Socket.IO Server (Node.js)

```javascript
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const jwt = require('jsonwebtoken');
const Redis = require('ioredis');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  },
  transports: ['websocket', 'polling']
});

const redis = new Redis();

// Authentication middleware
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.user_id;
    next();
  } catch (error) {
    next(new Error('Authentication failed'));
  }
});

io.on('connection', (socket) => {
  console.log(`User ${socket.userId} connected`);
  
  // Join user's personal room
  socket.join(`user_${socket.userId}`);
  
  // Update presence
  redis.set(`user:${socket.userId}:online`, 'true', 'EX', 300);
  
  // Authenticate
  socket.on('authenticate', async (data) => {
    // Store socket session
    await saveSocketSession(socket.userId, socket.id, data);
    
    socket.emit('authenticated', {
      status: 'authenticated',
      user_id: socket.userId,
      socket_id: socket.id
    });
  });
  
  // Join chat room
  socket.on('join_chat_room', async (data) => {
    const { item_offer_id } = data;
    
    // Validate access
    if (!await canAccessRoom(socket.userId, item_offer_id)) {
      socket.emit('error', { error_code: 'PERMISSION_DENIED' });
      return;
    }
    
    socket.join(`chat_${item_offer_id}`);
    
    // Load messages
    const messages = await loadMessages(item_offer_id);
    
    socket.emit('joined', {
      status: 'joined',
      room_id: `chat_${item_offer_id}`,
      messages: messages
    });
  });
  
  // Send message
  socket.on('send_message', async (data) => {
    try {
      // Validate
      const validation = await validateMessage(data);
      if (!validation.valid) {
        socket.emit('error', {
          error_code: 'INVALID_REQUEST',
          errors: validation.errors
        });
        return;
      }
      
      // Save to database
      const message = await saveMessage(data);
      
      // Broadcast to room
      io.to(`chat_${data.item_offer_id}`).emit('message_received', message);
      
      // Confirm to sender
      socket.emit('message_sent', {
        status: 'sent',
        temp_id: data.temp_id,
        message_id: message.id
      });
      
      // Update chat list
      const receiverId = message.receiver_id;
      io.to(`user_${receiverId}`).emit('chat_list_update', {
        item_offer_id: data.item_offer_id,
        last_message: message,
        unread_count: await getUnreadCount(receiverId, data.item_offer_id)
      });
      
    } catch (error) {
      socket.emit('error', {
        error_code: 'MESSAGE_FAILED',
        error_message: error.message
      });
    }
  });
  
  // Typing indicators
  socket.on('typing_start', (data) => {
    socket.to(`chat_${data.item_offer_id}`).emit('user_typing', {
      item_offer_id: data.item_offer_id,
      user_id: socket.userId,
      is_typing: true
    });
  });
  
  socket.on('typing_stop', (data) => {
    socket.to(`chat_${data.item_offer_id}`).emit('user_typing', {
      item_offer_id: data.item_offer_id,
      user_id: socket.userId,
      is_typing: false
    });
  });
  
  // Disconnect
  socket.on('disconnect', async () => {
    console.log(`User ${socket.userId} disconnected`);
    
    // Update presence
    await redis.del(`user:${socket.userId}:online`);
    await updateLastSeen(socket.userId);
    
    // Broadcast offline status
    io.emit('user_offline', {
      user_id: socket.userId,
      is_online: false,
      last_seen: new Date().toISOString()
    });
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Socket.IO server running on port ${PORT}`);
});
```

---

**END OF DOCUMENT**

This comprehensive documentation provides all the requirements for implementing real-time chat using Socket.IO. Please review and provide feedback for any additional requirements or clarifications needed.
