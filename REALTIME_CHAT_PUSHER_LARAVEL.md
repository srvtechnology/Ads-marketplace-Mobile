# Real-Time Chat Implementation Using Pusher + Laravel
## Backend Developer Requirements Documentation

### Version: 2.0 (Pusher Edition)
### Date: February 5, 2026
### Author: Technical Architect (Flutter Developer Perspective)

---

## 📋 Table of Contents
1. [Executive Summary](#executive-summary)
2. [Current System Analysis](#current-system-analysis)
3. [Pusher + Laravel Architecture](#pusher--laravel-architecture)
4. [Pusher Credentials & Setup](#pusher-credentials--setup)
5. [Channel Architecture](#channel-architecture)
6. [Event Specifications](#event-specifications)
7. [Laravel Implementation](#laravel-implementation)
8. [Flutter Client Integration](#flutter-client-integration)
9. [Database Schema](#database-schema)
10. [Security & Authentication](#security--authentication)
11. [Performance & Scaling](#performance--scaling)
12. [Testing Strategy](#testing-strategy)
13. [Cost Analysis](#cost-analysis)
14. [Migration Plan](#migration-plan)

---

## 📊 Executive Summary

This document outlines the technical requirements for upgrading the Ads Marketplace chat system from REST API polling to **real-time messaging using Pusher with Laravel Broadcasting**.

### Why Pusher + Laravel?

✅ **Managed Infrastructure** - No WebSocket server management  
✅ **Laravel Integration** - Native support via Broadcasting  
✅ **Proven Reliability** - Used by thousands of Laravel apps  
✅ **Easy Scaling** - Pusher handles all infrastructure  
✅ **Quick Setup** - Get real-time features in hours, not weeks  
✅ **Cross-Platform** - Works with iOS, Android, Web seamlessly  

### Key Benefits

- **Instant Message Delivery** - Messages appear in <100ms
- **Real-Time Typing Indicators** - See when other user is typing
- **Online Presence** - Know who's online/offline
- **Read Receipts** - Track message delivery & read status
- **Reduced Server Load** - No polling, event-driven architecture
- **Better Battery Life** - Push-based vs constant polling

---

## 🔍 Current System Analysis

### Current Architecture (REST API Polling)

**Problems:**
1. ❌ High latency (5-30 second delays)
2. ❌ Heavy server load from constant polling
3. ❌ Battery drain on mobile devices
4. ❌ No real-time features
5. ❌ Poor user experience
6. ❌ Wasted bandwidth

**Current Flow:**
```
User sends message → POST /send-message → Database
User polls → GET /chat-messages (every 5s) → Check for new messages
```

### New Architecture (Pusher + Laravel)

**Solution:**
```
User sends message → Laravel API → Broadcast Event → Pusher → Flutter App
                                                              ↓
                                                    Real-time delivery (<100ms)
```

### Current Data Models

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
  "created_at": "2026-02-05 10:00:00",
  "updated_at": "2026-02-05 10:00:00"
}
```

**Message Types:**
- `N` - Normal message
- `O` - Offer message (includes amount)

**Offer Status:**
- `null` - Pending
- `A` - Accepted
- `R` - Rejected

---

## 🏗️ Pusher + Laravel Architecture

### High-Level Architecture

```
┌──────────────────┐
│  Flutter App     │
│  (iOS/Android)   │
└────────┬─────────┘
         │
         │ Pusher WebSocket
         │ (pusher_client package)
         │
┌────────▼─────────────────────────┐
│     Pusher Cloud Service         │
│  (Managed WebSocket Infra)       │
└────────┬─────────────────────────┘
         │
         │ HTTP API (Broadcasting)
         │
┌────────▼─────────────────────────┐
│   Laravel Application            │
│   (Broadcasting Events)          │
└────────┬─────────────────────────┘
         │
    ┌────┴────┬────────┐
    │         │        │
┌───▼───┐ ┌───▼───┐ ┌──▼──┐
│ MySQL │ │ Redis │ │ S3  │
│   DB  │ │ Queue │ │Files│
└───────┘ └───────┘ └─────┘
```

### How It Works

1. **User Action**: User sends message in Flutter app
2. **API Call**: Flutter calls Laravel API endpoint
3. **Database**: Laravel saves message to MySQL
4. **Broadcast Event**: Laravel fires `MessageSent` event
5. **Pusher**: Laravel sends event to Pusher via HTTP
6. **Real-Time Delivery**: Pusher broadcasts to subscribed clients
7. **Flutter Receives**: Flutter app receives event instantly

### Key Components

**Laravel Side:**
- `Broadcasting` - Laravel's event broadcasting system
- `Pusher PHP SDK` - Send events to Pusher
- `Broadcast Events` - Event classes that trigger broadcasts
- `Channel Routes` - Authorization for private channels

**Flutter Side:**
- `pusher_client` package - Connect to Pusher
- `Channel subscriptions` - Subscribe to relevant channels
- `Event listeners` - Handle incoming events
- `HTTP Auth` - Authenticate for private channels

---

## 🔐 Pusher Credentials & Setup

### Your Pusher Account Details

```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID="2111430"
PUSHER_APP_KEY="ce3fd047d2f9980ea2a5"
PUSHER_APP_SECRET="9fe1bac892d1ac697c9f"
PUSHER_APP_CLUSTER="ap2"
```

> [!IMPORTANT]
> **Security Notice:**
> - `PUSHER_APP_KEY` - Safe to use in Flutter app (public)
> - `PUSHER_APP_SECRET` - Keep secure in Laravel `.env` (never expose)
> - `PUSHER_APP_CLUSTER` - Asia Pacific 2 (Singapore) - Good for India/Asia users

### Laravel Configuration

#### 1. Install Pusher PHP SDK

```bash
composer require pusher/pusher-php-server
```

#### 2. Configure `.env`

```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID=2111430
PUSHER_APP_KEY=ce3fd047d2f9980ea2a5
PUSHER_APP_SECRET=9fe1bac892d1ac697c9f
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=ap2

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
```

#### 3. Update `config/broadcasting.php`

```php
'connections' => [
    'pusher' => [
        'driver' => 'pusher',
        'key' => env('PUSHER_APP_KEY'),
        'secret' => env('PUSHER_APP_SECRET'),
        'app_id' => env('PUSHER_APP_ID'),
        'options' => [
            'cluster' => env('PUSHER_APP_CLUSTER'),
            'host' => env('PUSHER_HOST') ?: 'api-'.env('PUSHER_APP_CLUSTER', 'mt1').'.pusher.com',
            'port' => env('PUSHER_PORT', 443),
            'scheme' => env('PUSHER_SCHEME', 'https'),
            'encrypted' => true,
            'useTLS' => true,
        ],
        'client_options' => [
            // Guzzle client options: https://docs.guzzlephp.org/en/stable/request-options.html
        ],
    ],
],
```

#### 4. Enable Broadcasting

```php
// config/app.php
'providers' => [
    // ...
    App\Providers\BroadcastServiceProvider::class,
],
```

Uncomment `BroadcastServiceProvider` in `app.php`.

#### 5. Set up Queue (Recommended)

```env
QUEUE_CONNECTION=redis
```

Broadcasting works better with queues for performance.

---

## 📡 Channel Architecture

### Channel Types

Pusher supports 3 channel types:

1. **Public Channels** - Anyone can subscribe (not used in our case)
2. **Private Channels** - Require authorization
3. **Presence Channels** - Private + member tracking (who's online)

### Our Channel Structure

#### 1. Private Chat Channels

**Format:** `private-chat.{item_offer_id}`

**Purpose:** 1-to-1 messaging between buyer and seller

**Events:**
- `MessageSent`
- `UserTyping`
- `OfferReceived`
- `OfferStatusUpdated`
- `ItemStatusChanged`

**Authorization:** Only buyer and seller of the item can join

**Example:**
```
private-chat.1
private-chat.2
private-chat.42
```

#### 2. Private User Channels

**Format:** `private-user.{user_id}`

**Purpose:** User-specific notifications and updates

**Events:**
- `ChatListUpdated`
- `MessageDelivered`
- `MessageRead`
- `NewChatCreated`

**Authorization:** Only the specific user can join

**Example:**
```
private-user.123
private-user.456
```

#### 3. Presence Channel (Online Status)

**Format:** `presence-users`

**Purpose:** Track which users are currently online

**Events:**
- `pusher:member_added` (automatic)
- `pusher:member_removed` (automatic)
- `pusher:subscription_succeeded` (automatic)

**Authorization:** All authenticated users

**User Info Included:**
```json
{
  "user_id": 123,
  "user_info": {
    "id": 123,
    "name": "John Doe",
    "profile": "https://example.com/profile.jpg"
  }
}
```

---

## 🎯 Event Specifications

### Event Naming Convention

Laravel events use **PascalCase**: `MessageSent`, `UserTyping`  
Pusher broadcasts them as-is: `MessageSent`, `UserTyping`

### 1. Message Events

#### Event: `MessageSent`

**Channel:** `private-chat.{item_offer_id}`

**Triggered When:** User sends a message

**Laravel Event Payload:**
```json
{
  "message": {
    "id": 12345,
    "sender_id": 123,
    "receiver_id": 456,
    "item_offer_id": 1,
    "message": "Hello, is this still available?",
    "type": "N",
    "amount": null,
    "file": null,
    "audio": null,
    "offer_status": null,
    "created_at": "2026-02-05T10:00:00.000000Z",
    "updated_at": "2026-02-05T10:00:00.000000Z",
    "temp_id": "temp_msg_12345"
  },
  "sender": {
    "id": 123,
    "name": "John Doe",
    "profile": "https://example.com/profile.jpg"
  }
}
```

**Flutter Handler:**
```dart
channel.bind('MessageSent', (event) {
  final data = jsonDecode(event.data);
  final message = ChatMessage.fromJson(data['message']);
  // Add message to UI
  _addMessageToChat(message);
});
```

---

#### Event: `OfferReceived`

**Channel:** `private-chat.{item_offer_id}`

**Triggered When:** User sends a price offer

**Payload:**
```json
{
  "message": {
    "id": 12346,
    "sender_id": 456,
    "receiver_id": 123,
    "item_offer_id": 1,
    "message": "I can offer 45,000 for this",
    "type": "O",
    "amount": 45000.00,
    "file": null,
    "audio": null,
    "offer_status": null,
    "created_at": "2026-02-05T10:05:00.000000Z",
    "updated_at": "2026-02-05T10:05:00.000000Z"
  },
  "sender": {
    "id": 456,
    "name": "Jane Smith",
    "profile": "https://example.com/profile2.jpg"
  }
}
```

---

#### Event: `OfferStatusUpdated`

**Channel:** `private-chat.{item_offer_id}`

**Triggered When:** Seller accepts/rejects offer

**Payload:**
```json
{
  "message_id": 12346,
  "item_offer_id": 1,
  "offer_status": "A",
  "updated_by": 123,
  "updated_at": "2026-02-05T10:10:00.000000Z"
}
```

**Offer Status Values:**
- `A` - Accepted
- `R` - Rejected

---

### 2. Typing Indicator Events

#### Event: `UserTyping`

**Channel:** `private-chat.{item_offer_id}`

**Triggered When:** User starts/stops typing

**Payload:**
```json
{
  "user_id": 123,
  "user_name": "John Doe",
  "is_typing": true,
  "timestamp": "2026-02-05T10:00:00.000000Z"
}
```

**Flutter Implementation:**
```dart
// Send typing start
Timer? _typingTimer;

void onMessageChanged(String text) {
  if (text.isNotEmpty && _typingTimer == null) {
    _sendTypingStatus(true);
    
    // Auto-stop after 3 seconds
    _typingTimer = Timer(Duration(seconds: 3), () {
      _sendTypingStatus(false);
      _typingTimer = null;
    });
  }
}

void _sendTypingStatus(bool isTyping) {
  // Call Laravel API to broadcast typing event
  api.post('/chat/typing', {
    'item_offer_id': itemOfferId,
    'is_typing': isTyping,
  });
}
```

---

### 3. Presence Events (Online Status)

#### Event: `pusher:member_added`

**Channel:** `presence-users`

**Triggered When:** User comes online

**Payload (automatic from Pusher):**
```json
{
  "user_id": "123",
  "user_info": {
    "id": 123,
    "name": "John Doe",
    "profile": "https://example.com/profile.jpg"
  }
}
```

**Flutter Handler:**
```dart
presenceChannel.bind('pusher:member_added', (event) {
  final member = jsonDecode(event.data);
  print('User ${member['user_info']['name']} is online');
  _updateUserStatus(member['user_id'], true);
});
```

#### Event: `pusher:member_removed`

**Channel:** `presence-users`

**Triggered When:** User goes offline

**Flutter Handler:**
```dart
presenceChannel.bind('pusher:member_removed', (event) {
  final member = jsonDecode(event.data);
  _updateUserStatus(member['user_id'], false);
});
```

---

### 4. Message Status Events

#### Event: `MessageDelivered`

**Channel:** `private-user.{sender_id}`

**Triggered When:** Receiver's app receives message

**Payload:**
```json
{
  "message_ids": [12345, 12346],
  "delivered_to": 456,
  "delivered_at": "2026-02-05T10:00:05.000000Z"
}
```

#### Event: `MessageRead`

**Channel:** `private-user.{sender_id}`

**Triggered When:** Receiver opens chat and views messages

**Payload:**
```json
{
  "message_ids": [12345, 12346],
  "read_by": 456,
  "item_offer_id": 1,
  "read_at": "2026-02-05T10:01:00.000000Z"
}
```

---

### 5. Chat List Events

#### Event: `ChatListUpdated`

**Channel:** `private-user.{user_id}`

**Triggered When:** New message in any chat

**Payload:**
```json
{
  "item_offer_id": 1,
  "last_message": {
    "id": 12345,
    "message": "Hello there!",
    "sender_id": 456,
    "created_at": "2026-02-05T10:00:00.000000Z"
  },
  "unread_count": 6,
  "updated_at": "2026-02-05T10:00:00.000000Z"
}
```

---

### 6. Item Status Events

#### Event: `ItemStatusChanged`

**Channel:** `private-chat.{item_offer_id}`

**Triggered When:** Item status changes (sold, inactive, etc.)

**Payload:**
```json
{
  "item_id": 789,
  "item_offer_id": 1,
  "old_status": "active",
  "new_status": "sold out",
  "sold_to": 456,
  "updated_at": "2026-02-05T10:00:00.000000Z"
}
```

---

## 💻 Laravel Implementation

### Directory Structure

```
app/
├── Events/
│   ├── MessageSent.php
│   ├── OfferReceived.php
│   ├── OfferStatusUpdated.php
│   ├── UserTyping.php
│   ├── ChatListUpdated.php
│   ├── MessageDelivered.php
│   ├── MessageRead.php
│   └── ItemStatusChanged.php
├── Http/
│   └── Controllers/
│       └── ChatController.php
└── Models/
    ├── ChatMessage.php
    └── ItemOffer.php

routes/
├── api.php
└── channels.php
```

### 1. Broadcast Events

#### `app/Events/MessageSent.php`

```php
<?php

namespace App\Events;

use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;
    public $sender;

    /**
     * Create a new event instance.
     */
    public function __construct(ChatMessage $message, User $sender)
    {
        $this->message = $message;
        $this->sender = $sender;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('chat.' . $this->message->item_offer_id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'MessageSent';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'message' => [
                'id' => $this->message->id,
                'sender_id' => $this->message->sender_id,
                'receiver_id' => $this->message->receiver_id,
                'item_offer_id' => $this->message->item_offer_id,
                'message' => $this->message->message,
                'type' => $this->message->type,
                'amount' => $this->message->amount,
                'file' => $this->message->file,
                'audio' => $this->message->audio,
                'offer_status' => $this->message->offer_status,
                'created_at' => $this->message->created_at->toISOString(),
                'updated_at' => $this->message->updated_at->toISOString(),
                'temp_id' => $this->message->temp_id,
            ],
            'sender' => [
                'id' => $this->sender->id,
                'name' => $this->sender->name,
                'profile' => $this->sender->profile,
            ],
        ];
    }
}
```

#### `app/Events/UserTyping.php`

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class UserTyping implements ShouldBroadcast
{
    use Dispatchable, SerializesModels;

    public $userId;
    public $userName;
    public $isTyping;
    public $itemOfferId;

    public function __construct($userId, $userName, $isTyping, $itemOfferId)
    {
        $this->userId = $userId;
        $this->userName = $userName;
        $this->isTyping = $isTyping;
        $this->itemOfferId = $itemOfferId;
    }

    public function broadcastOn()
    {
        return new PrivateChannel('chat.' . $this->itemOfferId);
    }

    public function broadcastAs()
    {
        return 'UserTyping';
    }

    public function broadcastWith()
    {
        return [
            'user_id' => $this->userId,
            'user_name' => $this->userName,
            'is_typing' => $this->isTyping,
            'timestamp' => now()->toISOString(),
        ];
    }
}
```

#### `app/Events/ChatListUpdated.php`

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;

class ChatListUpdated implements ShouldBroadcast
{
    public $userId;
    public $itemOfferId;
    public $lastMessage;
    public $unreadCount;

    public function __construct($userId, $itemOfferId, $lastMessage, $unreadCount)
    {
        $this->userId = $userId;
        $this->itemOfferId = $itemOfferId;
        $this->lastMessage = $lastMessage;
        $this->unreadCount = $unreadCount;
    }

    public function broadcastOn()
    {
        return new PrivateChannel('user.' . $this->userId);
    }

    public function broadcastAs()
    {
        return 'ChatListUpdated';
    }

    public function broadcastWith()
    {
        return [
            'item_offer_id' => $this->itemOfferId,
            'last_message' => $this->lastMessage,
            'unread_count' => $this->unreadCount,
            'updated_at' => now()->toISOString(),
        ];
    }
}
```

### 2. API Controller

#### `app/Http/Controllers/ChatController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Events\MessageSent;
use App\Events\UserTyping;
use App\Events\ChatListUpdated;
use App\Models\ChatMessage;
use App\Models\ItemOffer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Send a message
     */
    public function sendMessage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'item_offer_id' => 'required|exists:item_offers,id',
            'message' => 'nullable|string|max:5000',
            'type' => 'required|in:N,O',
            'amount' => 'nullable|numeric',
            'file' => 'nullable|file|max:5120', // 5MB
            'audio' => 'nullable|file|max:5120',
            'temp_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => true,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $user = Auth::user();
        $itemOffer = ItemOffer::findOrFail($request->item_offer_id);

        // Check if user is buyer or seller
        if ($itemOffer->buyer_id != $user->id && $itemOffer->seller_id != $user->id) {
            return response()->json([
                'error' => true,
                'message' => 'Unauthorized access to this chat',
            ], 403);
        }

        // Determine receiver
        $receiverId = $itemOffer->buyer_id == $user->id 
            ? $itemOffer->seller_id 
            : $itemOffer->buyer_id;

        // Check if user is blocked
        if ($this->isUserBlocked($user->id, $receiverId)) {
            return response()->json([
                'error' => true,
                'message' => 'You cannot send messages to this user',
            ], 403);
        }

        // Handle file upload
        $fileUrl = null;
        if ($request->hasFile('file')) {
            $fileUrl = $request->file('file')->store('chat/files', 's3');
        }

        // Handle audio upload
        $audioUrl = null;
        if ($request->hasFile('audio')) {
            $audioUrl = $request->file('audio')->store('chat/audio', 's3');
        }

        // Create message
        $message = ChatMessage::create([
            'sender_id' => $user->id,
            'receiver_id' => $receiverId,
            'item_offer_id' => $request->item_offer_id,
            'message' => $request->message,
            'type' => $request->type,
            'amount' => $request->amount,
            'file' => $fileUrl,
            'audio' => $audioUrl,
            'temp_id' => $request->temp_id,
        ]);

        // Broadcast message to chat room
        broadcast(new MessageSent($message, $user))->toOthers();

        // Update chat list for receiver
        $unreadCount = ChatMessage::where('item_offer_id', $request->item_offer_id)
            ->where('receiver_id', $receiverId)
            ->whereNull('read_at')
            ->count();

        broadcast(new ChatListUpdated(
            $receiverId,
            $request->item_offer_id,
            [
                'id' => $message->id,
                'message' => $message->message,
                'sender_id' => $user->id,
                'created_at' => $message->created_at->toISOString(),
            ],
            $unreadCount
        ));

        return response()->json([
            'error' => false,
            'message' => 'Message sent successfully',
            'data' => [
                'id' => $message->id,
                'temp_id' => $message->temp_id,
                'created_at' => $message->created_at->toISOString(),
            ],
        ]);
    }

    /**
     * Send typing indicator
     */
    public function sendTypingStatus(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'item_offer_id' => 'required|exists:item_offers,id',
            'is_typing' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => true,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $user = Auth::user();

        // Broadcast typing status
        broadcast(new UserTyping(
            $user->id,
            $user->name,
            $request->is_typing,
            $request->item_offer_id
        ))->toOthers();

        return response()->json([
            'error' => false,
            'message' => 'Typing status sent',
        ]);
    }

    /**
     * Mark messages as read
     */
    public function markAsRead(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'message_ids' => 'required|array',
            'message_ids.*' => 'exists:chat_messages,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => true,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $user = Auth::user();

        // Update messages
        ChatMessage::whereIn('id', $request->message_ids)
            ->where('receiver_id', $user->id)
            ->update(['read_at' => now()]);

        // Optionally broadcast MessageRead event to sender

        return response()->json([
            'error' => false,
            'message' => 'Messages marked as read',
        ]);
    }

    /**
     * Get chat messages
     */
    public function getMessages(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'item_offer_id' => 'required|exists:item_offers,id',
            'page' => 'nullable|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => true,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $user = Auth::user();
        $page = $request->page ?? 1;
        $perPage = 50;

        $messages = ChatMessage::where('item_offer_id', $request->item_offer_id)
            ->where(function($query) use ($user) {
                $query->where('sender_id', $user->id)
                      ->orWhere('receiver_id', $user->id);
            })
            ->with('sender:id,name,profile')
            ->orderBy('created_at', 'desc')
            ->paginate($perPage, ['*'], 'page', $page);

        return response()->json([
            'error' => false,
            'data' => [
                'data' => $messages->items(),
                'total' => $messages->total(),
                'current_page' => $messages->currentPage(),
                'last_page' => $messages->lastPage(),
            ],
        ]);
    }

    /**
     * Check if user is blocked
     */
    private function isUserBlocked($userId, $otherUserId)
    {
        return \DB::table('blocked_users')
            ->where('blocker_id', $otherUserId)
            ->where('blocked_user_id', $userId)
            ->exists();
    }
}
```

### 3. Channel Authorization

#### `routes/channels.php`

```php
<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\ItemOffer;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
*/

// Private chat channel - Only buyer and seller can access
Broadcast::channel('chat.{itemOfferId}', function ($user, $itemOfferId) {
    $itemOffer = ItemOffer::find($itemOfferId);
    
    if (!$itemOffer) {
        return false;
    }
    
    // Check if user is buyer or seller of this offer
    return $itemOffer->buyer_id === $user->id || $itemOffer->seller_id === $user->id;
});

// Private user channel - Only the user can access their own channel
Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});

// Presence channel - All authenticated users can join
Broadcast::channel('users', function ($user) {
    if ($user) {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'profile' => $user->profile,
        ];
    }
    return false;
});
```

### 4. API Routes

#### `routes/api.php`

```php
<?php

use App\Http\Controllers\ChatController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    // Chat endpoints
    Route::post('/chat/send-message', [ChatController::class, 'sendMessage']);
    Route::post('/chat/typing', [ChatController::class, 'sendTypingStatus']);
    Route::post('/chat/mark-as-read', [ChatController::class, 'markAsRead']);
    Route::post('/chat/messages', [ChatController::class, 'getMessages']);
    
    // Existing endpoints...
    Route::get('/chat-list', [ChatController::class, 'getChatList']);
    Route::post('/block-user', [ChatController::class, 'blockUser']);
    Route::post('/unblock-user', [ChatController::class, 'unblockUser']);
});
```

---

## 📱 Flutter Client Integration

### 1. Package Installation

#### `pubspec.yaml`

```yaml
dependencies:
  pusher_client: ^2.0.0
  http: ^1.1.0
```

Run:
```bash
flutter pub get
```

### 2. Pusher Service Setup

#### `lib/services/pusher_service.dart`

```dart
import 'package:pusher_client/pusher_client.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/constant.dart';

class PusherService {
  static PusherClient? _pusher;
  static Channel? _currentChatChannel;
  static Channel? _userChannel;
  static Channel? _presenceChannel;

  static const String _appKey = 'ce3fd047d2f9980ea2a5';
  static const String _cluster = 'ap2';

  /// Initialize Pusher
  static Future<void> initialize() async {
    try {
      final token = HiveUtils.getJWT();
      
      _pusher = PusherClient(
        _appKey,
        PusherOptions(
          cluster: _cluster,
          auth: PusherAuth(
            '${Constant.baseUrl}broadcasting/auth',
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        ),
        enableLogging: true,
      );

      _pusher!.onConnectionStateChange((state) {
        print('Pusher connection state: ${state!.currentState}');
      });

      _pusher!.onConnectionError((error) {
        print('Pusher connection error: ${error!.message}');
      });

      await _pusher!.connect();

      // Subscribe to user's personal channel
      await _subscribeToUserChannel();
      
      // Subscribe to presence channel for online status
      await _subscribeToPresenceChannel();

      print('Pusher initialized successfully');
    } catch (e) {
      print('Pusher initialization error: $e');
    }
  }

  /// Subscribe to user's personal channel
  static Future<void> _subscribeToUserChannel() async {
    final userId = HiveUtils.getUserId();
    if (userId == null) return;

    _userChannel = _pusher!.subscribe('private-user.$userId');

    _userChannel!.bind('ChatListUpdated', (event) {
      print('ChatListUpdated event: ${event!.data}');
      // Handle chat list update
      _handleChatListUpdate(event.data);
    });

    _userChannel!.bind('MessageDelivered', (event) {
      print('MessageDelivered event: ${event!.data}');
      // Handle message delivered
    });

    _userChannel!.bind('MessageRead', (event) {
      print('MessageRead event: ${event!.data}');
      // Handle message read
    });
  }

  /// Subscribe to presence channel for online status
  static Future<void> _subscribeToPresenceChannel() async {
    _presenceChannel = _pusher!.subscribe('presence-users');

    _presenceChannel!.bind('pusher:subscription_succeeded', (event) {
      final members = (_presenceChannel as PresenceChannel).members;
      print('Current online users: ${members.length}');
    });

    _presenceChannel!.bind('pusher:member_added', (event) {
      print('User came online: ${event!.data}');
      // Update UI to show user is online
    });

    _presenceChannel!.bind('pusher:member_removed', (event) {
      print('User went offline: ${event!.data}');
      // Update UI to show user is offline
    });
  }

  /// Subscribe to a chat channel
  static Future<void> subscribeToChatChannel(
    int itemOfferId,
    Function(Map<String, dynamic>) onMessageReceived,
    Function(Map<String, dynamic>) onTyping,
  ) async {
    // Unsubscribe from previous chat channel
    if (_currentChatChannel != null) {
      await _pusher!.unsubscribe('private-chat.$itemOfferId');
    }

    // Subscribe to new chat channel
    _currentChatChannel = _pusher!.subscribe('private-chat.$itemOfferId');

    // Listen for new messages
    _currentChatChannel!.bind('MessageSent', (event) {
      print('MessageSent event: ${event!.data}');
      final data = jsonDecode(event.data!);
      onMessageReceived(data);
    });

    // Listen for typing indicators
    _currentChatChannel!.bind('UserTyping', (event) {
      print('UserTyping event: ${event!.data}');
      final data = jsonDecode(event.data!);
      onTyping(data);
    });

    // Listen for offer updates
    _currentChatChannel!.bind('OfferStatusUpdated', (event) {
      print('OfferStatusUpdated event: ${event!.data}');
      // Handle offer status update
    });

    // Listen for item status changes
    _currentChatChannel!.bind('ItemStatusChanged', (event) {
      print('ItemStatusChanged event: ${event!.data}');
      // Handle item status change
    });

    print('Subscribed to chat channel: private-chat.$itemOfferId');
  }

  /// Unsubscribe from chat channel
  static Future<void> unsubscribeFromChatChannel(int itemOfferId) async {
    if (_currentChatChannel != null) {
      await _pusher!.unsubscribe('private-chat.$itemOfferId');
      _currentChatChannel = null;
      print('Unsubscribed from chat channel: private-chat.$itemOfferId');
    }
  }

  /// Disconnect Pusher
  static Future<void> disconnect() async {
    if (_pusher != null) {
      await _pusher!.disconnect();
      _pusher = null;
      _currentChatChannel = null;
      _userChannel = null;
      _presenceChannel = null;
      print('Pusher disconnected');
    }
  }

  /// Handle chat list update
  static void _handleChatListUpdate(String? data) {
    if (data == null) return;
    
    final Map<String, dynamic> updateData = jsonDecode(data);
    // Update chat list in your state management
    // Example: context.read<GetBuyerChatListCubit>().updateChat(updateData);
  }

  /// Check if user is online
  static bool isUserOnline(int userId) {
    if (_presenceChannel == null) return false;
    
    final members = (_presenceChannel as PresenceChannel).members;
    return members.any((member) => member['id'] == userId);
  }
}
```

### 3. Initialize in main.dart

#### `lib/main.dart`

```dart
import 'package:eClassify/services/pusher_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Your existing initialization...
  
  // Initialize Pusher after user login
  if (HiveUtils.isUserAuthenticated()) {
    await PusherService.initialize();
  }
  
  runApp(MyApp());
}
```

### 4. Update Chat Screen

#### `lib/ui/screens/chat/chat_screen.dart` (Updated sections)

```dart
class _ChatScreenState extends State<ChatScreen> {
  // ... existing code ...

  @override
  void initState() {
    super.initState();
    
    // Load initial messages via REST API
    context.read<LoadChatMessagesCubit>().load(
      itemOfferId: widget.itemOfferId,
    );

    // Subscribe to Pusher channel for real-time updates
    PusherService.subscribeToChatChannel(
      widget.itemOfferId,
      _onMessageReceived,
      _onTypingUpdate,
    );

    // ... rest of your existing code ...
  }

  @override
  void dispose() {
    // Unsubscribe from chat channel
    PusherService.unsubscribeFromChatChannel(widget.itemOfferId);
    super.dispose();
  }

  /// Handle incoming message from Pusher
  void _onMessageReceived(Map<String, dynamic> data) {
    final message = ChatMessage.fromJson(data['message']);
    
    // Add message to chat UI
    ChatMessageHandler.add(
      ChatMessage(
        key: ValueKey(message.id),
        id: message.id,
        message: message.message ?? '',
        senderId: message.senderId,
        createdAt: message.createdAt,
        file: message.file ?? '',
        audio: message.audio ?? '',
        itemOfferId: message.itemOfferId,
        updatedAt: message.updatedAt,
        offerStatus: message.offerStatus,
        type: message.type,
        amount: message.amount,
      ),
    );

    setState(() {
      totalMessageCount++;
    });
  }

  /// Handle typing indicator
  void _onTypingUpdate(Map<String, dynamic> data) {
    final userId = data['user_id'];
    final isTyping = data['is_typing'];
    
    // Don't show typing for current user
    if (userId.toString() == HiveUtils.getUserId()) return;

    setState(() {
      _isOtherUserTyping = isTyping;
    });

    // Auto-hide after 3 seconds
    if (isTyping) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isOtherUserTyping = false;
          });
        }
      });
    }
  }

  // ... rest of your existing code ...
}
```

### 5. Typing Indicator Implementation

Add this to your `ChatController`:

```dart
/// Send typing status to server
Timer? _typingTimer;
bool _isTyping = false;

void _onMessageTextChanged(String text) {
  controller.text = text;
  
  if (text.isNotEmpty && !_isTyping) {
    _sendTypingStatus(true);
    _isTyping = true;
  }

  // Cancel previous timer
  _typingTimer?.cancel();

  // Set new timer to stop typing after 2 seconds of inactivity
  _typingTimer = Timer(Duration(seconds: 2), () {
    if (_isTyping) {
      _sendTypingStatus(false);
      _isTyping = false;
    }
  });

  setState(() {});
}

Future<void> _sendTypingStatus(bool isTyping) async {
  try {
    await Api.post(
      url: '/chat/typing',
      parameter: {
        'item_offer_id': widget.itemOfferId,
        'is_typing': isTyping,
      },
    );
  } catch (e) {
    print('Error sending typing status: $e');
  }
}
```

---

## 💾 Database Schema

### Existing Tables (No Changes Needed)

Your existing tables work perfectly with Pusher:
- `chat_messages`
- `item_offers`
- `users`
- `blocked_users`

### Optional: Add Message Status Tracking

```sql
ALTER TABLE chat_messages
ADD COLUMN delivered_at TIMESTAMP NULL,
ADD COLUMN read_at TIMESTAMP NULL,
ADD COLUMN temp_id VARCHAR(255) NULL,
ADD INDEX idx_temp_id (temp_id),
ADD INDEX idx_delivered (delivered_at),
ADD INDEX idx_read (read_at);
```

### Optional: User Presence Table

```sql
CREATE TABLE user_presence (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_online (is_online),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 🔐 Security & Authentication

### 1. Channel Authorization

Laravel automatically handles authorization via `routes/channels.php`.

**How it works:**
1. Flutter app tries to subscribe to `private-chat.1`
2. Pusher client sends auth request to Laravel
3. Laravel checks if user can access this channel (buyer or seller)
4. Laravel returns signature if authorized
5. Pusher allows subscription

### 2. Rate Limiting

Add rate limiting to prevent spam:

```php
// app/Http/Middleware/RateLimitChat.php
public function handle($request, Closure $next)
{
    $user = Auth::user();
    $key = 'chat_rate_limit:' . $user->id;
    
    $attempts = Cache::get($key, 0);
    
    if ($attempts >= 20) {
        return response()->json([
            'error' => true,
            'message' => 'Too many messages. Please slow down.',
        ], 429);
    }
    
    Cache::put($key, $attempts + 1, now()->addMinute());
    
    return $next($request);
}
```

Apply to routes:
```php
Route::post('/chat/send-message', [ChatController::class, 'sendMessage'])
    ->middleware('throttle:chat');
```

### 3. Message Content Validation

```php
// In ChatController
private function validateMessageContent($message)
{
    // Check for spam patterns
    if (preg_match('/(.)\1{10,}/', $message)) {
        throw new \Exception('Message contains spam patterns');
    }
    
    // Check for malicious content
    if (strip_tags($message) !== $message) {
        throw new \Exception('HTML tags not allowed');
    }
    
    return true;
}
```

### 4. Block User Check

```php
private function isUserBlocked($userId, $otherUserId)
{
    return DB::table('blocked_users')
        ->where('blocker_id', $otherUserId)
        ->where('blocked_user_id', $userId)
        ->exists();
}
```

---

## ⚡ Performance & Scaling

### 1. Queue Broadcasting Events

Use queues for better performance:

```php
// .env
QUEUE_CONNECTION=redis

// Event class
class MessageSent implements ShouldBroadcast, ShouldQueue
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    
    // ... your code ...
}
```

Start queue worker:
```bash
php artisan queue:work
```

### 2. Redis Cache for Online Status

```php
// When user connects to Pusher
Cache::put('user_online:' . $userId, true, now()->addMinutes(5));

// Check if user is online
$isOnline = Cache::get('user_online:' . $userId, false);
```

### 3. Optimize Database Queries

```php
// Eager load relationships
$messages = ChatMessage::with(['sender:id,name,profile'])
    ->where('item_offer_id', $itemOfferId)
    ->latest()
    ->paginate(50);
```

### 4. Pusher Connection Limits

**Free Tier:**
- 100 concurrent connections
- 200,000 messages per day
- Unlimited channels

**If you exceed:**
- Upgrade to Sandbox plan ($49/month)
- 500 concurrent connections
- Unlimited messages

### 5. Message Batching

For heavy traffic, batch read receipts:

```php
// Instead of broadcasting each read receipt individually
// Collect them and broadcast in batches every 5 seconds

$readReceipts = Cache::get('read_receipts_batch', []);
$readReceipts[] = ['message_id' => $messageId, 'user_id' => $userId];
Cache::put('read_receipts_batch', $readReceipts);

// Schedule a job to broadcast batched receipts
```

---

## 🧪 Testing Strategy

### 1. Unit Tests

Test Laravel events:

```php
// tests/Unit/MessageSentEventTest.php
use App\Events\MessageSent;
use Illuminate\Support\Facades\Event;

public function test_message_sent_event_broadcasts()
{
    Event::fake();
    
    $message = ChatMessage::factory()->create();
    $sender = User::find($message->sender_id);
    
    event(new MessageSent($message, $sender));
    
    Event::assertDispatched(MessageSent::class);
}
```

### 2. Integration Tests

Test channel authorization:

```php
// tests/Feature/ChatChannelTest.php
public function test_user_can_access_own_chat_channel()
{
    $user = User::factory()->create();
    $offer = ItemOffer::factory()->create(['buyer_id' => $user->id]);
    
    $this->actingAs($user)
        ->post('/broadcasting/auth', [
            'channel_name' => 'private-chat.' . $offer->id,
        ])
        ->assertStatus(200);
}

public function test_user_cannot_access_others_chat_channel()
{
    $user = User::factory()->create();
    $offer = ItemOffer::factory()->create(); // Different user
    
    $this->actingAs($user)
        ->post('/broadcasting/auth', [
            'channel_name' => 'private-chat.' . $offer->id,
        ])
        ->assertStatus(403);
}
```

### 3. Flutter Widget Tests

Test Pusher service:

```dart
// test/services/pusher_service_test.dart
void main() {
  test('PusherService initializes correctly', () async {
    await PusherService.initialize();
    expect(PusherService._pusher, isNotNull);
  });
  
  test('subscribeToChatChannel subscribes to correct channel', () async {
    await PusherService.subscribeToChatChannel(
      1,
      (data) {},
      (data) {},
    );
    // Assert channel is subscribed
  });
}
```

### 4. Manual Testing Checklist

- [ ] Message sends and appears instantly
- [ ] Typing indicator works both ways
- [ ] Online status updates correctly
- [ ] Read receipts work
- [ ] Blocked users cannot send messages
- [ ] File uploads work
- [ ] Audio messages work
- [ ] Offer accept/reject works
- [ ] App reconnects after network loss
- [ ] Multiple devices sync correctly

---

## 💰 Cost Analysis

### Pusher Pricing (as of 2026)

#### Free Plan (Sandbox)
- ✅ 100 concurrent connections
- ✅ 200,000 messages per day
- ✅ Unlimited channels
- ✅ SSL encryption included
- ⚠️ Limited to development/testing

#### Startup Plan - $49/month
- ✅ 500 concurrent connections
- ✅ Unlimited messages
- ✅ 7-day message history
- ✅ Support

#### Scale Plan - $299/month
- ✅ 5,000 concurrent connections
- ✅ Unlimited messages
- ✅ 30-day message history
- ✅ Priority support

### Cost Comparison

**Socket.IO (Self-Hosted):**
- VPS/Cloud Server: $50-200/month
- Redis Server: $20-50/month
- Load Balancer: $20-50/month
- Maintenance: $500-2000/month (developer time)
- **Total: $590-2300/month**

**Pusher (Managed):**
- Startup Plan: $49/month
- No infrastructure management
- Automatic scaling
- **Total: $49/month**

### Recommendation

Start with **Free Tier** (100 connections) for initial launch.

**When to upgrade:**
- 80+ concurrent users → Upgrade to Startup ($49/month)
- 400+ concurrent users → Upgrade to Scale ($299/month)

**ROI:** Even at Scale plan, Pusher is cheaper than self-hosted Socket.IO when you factor in:
- No server management
- No DevOps costs
- No scaling headaches
- Automatic SSL/security updates

---

## 🚀 Migration Plan

### Phase 1: Setup & Testing (Week 1)

**Day 1-2: Laravel Setup**
- ✅ Install Pusher PHP SDK
- ✅ Configure `.env` with Pusher credentials
- ✅ Enable Broadcasting in Laravel
- ✅ Create channel authorization routes

**Day 3-4: Create Events**
- ✅ Create all broadcast event classes
- ✅ Test events fire correctly
- ✅ Test channel authorization works

**Day 5-7: Flutter Integration**
- ✅ Install `pusher_client` package
- ✅ Create PusherService
- ✅ Test connection and subscriptions
- ✅ Integrate with existing chat screens

### Phase 2: Development (Week 2-3)

**Week 2: Core Features**
- ✅ Implement message broadcasting
- ✅ Implement typing indicators
- ✅ Implement presence tracking
- ✅ Update chat list real-time

**Week 3: Advanced Features**
- ✅ Implement message delivery receipts
- ✅ Implement read receipts
- ✅ Implement offer broadcasting
- ✅ Implement item status updates

### Phase 3: Testing (Week 4)

**Testing Checklist:**
- ✅ Unit tests for Laravel events
- ✅ Integration tests for channels
- ✅ Flutter widget tests
- ✅ Manual end-to-end testing
- ✅ Load testing (simulate 50-100 users)
- ✅ Network interruption testing

### Phase 4: Beta Launch (Week 5)

**Hybrid Mode:**
- ✅ Keep existing REST polling as fallback
- ✅ Enable Pusher for 10% of users
- ✅ Monitor Pusher dashboard
- ✅ Track error rates and latency
- ✅ Collect user feedback

**Monitoring:**
- Pusher connection success rate
- Message delivery time
- Error rates
- User satisfaction scores

### Phase 5: Full Rollout (Week 6-7)

**Gradual Migration:**
- Week 6: 50% of users on Pusher
- Week 7: 100% of users on Pusher

**Success Metrics:**
- 99%+ message delivery rate
- <200ms average delivery time
- <1% error rate
- Positive user feedback

### Phase 6: Cleanup (Week 8)

**Deprecate Old System:**
- ✅ Remove REST polling code
- ✅ Keep REST endpoints for initial load
- ✅ Update documentation
- ✅ Archive old code

---

## 📊 Monitoring & Analytics

### Pusher Dashboard Metrics

Monitor in Pusher dashboard:
- Concurrent connections
- Messages per second
- Connection success rate
- Error rates
- Bandwidth usage

### Laravel Logging

```php
// Log important events
Log::info('Message sent via Pusher', [
    'message_id' => $message->id,
    'sender_id' => $user->id,
    'item_offer_id' => $itemOfferId,
]);
```

### Custom Metrics

Track in your analytics:
- Message delivery time
- User engagement (messages per day)
- Typing indicator usage
- Channel subscription errors
- Reconnection frequency

---

## 🆘 Troubleshooting

### Common Issues

#### 1. "Connection Failed"

**Cause:** Wrong credentials or cluster

**Solution:**
```dart
// Check credentials in Flutter
PusherClient(
  'ce3fd047d2f9980ea2a5', // Correct app key
  PusherOptions(
    cluster: 'ap2', // Correct cluster
  ),
);
```

#### 2. "Private Channel Subscription Failed"

**Cause:** Authorization endpoint not accessible

**Solution:**
```php
// Check Laravel broadcasting route is enabled
// routes/api.php
Broadcast::routes(['middleware' => ['auth:sanctum']]);
```

**Flutter:**
```dart
// Ensure auth token is sent
PusherAuth(
  '${Constant.baseUrl}broadcasting/auth',
  headers: {
    'Authorization': 'Bearer $token',
  },
);
```

#### 3. "Events Not Received"

**Cause:** Not subscribed to channel or wrong event name

**Solution:**
```dart
// Make sure channel is subscribed
await PusherService.subscribeToChatChannel(itemOfferId, ...);

// Check event name matches exactly
channel.bind('MessageSent', (event) { ... }); // Case-sensitive!
```

#### 4. "Broadcasting Not Working in Laravel"

**Cause:** Queue not running or broadcasting disabled

**Solution:**
```bash
# Start queue worker
php artisan queue:work

# Check broadcasting is enabled
php artisan config:clear
```

---

## 📚 Additional Resources

### Documentation
- [Pusher Documentation](https://pusher.com/docs/)
- [Laravel Broadcasting](https://laravel.com/docs/10.x/broadcasting)
- [pusher_client Package](https://pub.dev/packages/pusher_client)

### Tutorials
- [Laravel Real-Time Chat with Pusher](https://pusher.com/tutorials/chat-laravel)
- [Flutter Pusher Integration](https://pusher.com/tutorials/flutter-notifications)

### Support
- Pusher Support: support@pusher.com
- Laravel Community: https://laracasts.com/discuss
- Flutter Discord: https://discord.gg/flutter

---

## ✅ Launch Checklist

### Before Going Live

- [ ] Pusher credentials configured correctly
- [ ] Laravel broadcasting enabled
- [ ] Channel authorization working
- [ ] All events tested
- [ ] Flutter client tested on iOS and Android
- [ ] Rate limiting configured
- [ ] Message validation in place
- [ ] Queue workers running
- [ ] Monitoring set up
- [ ] Backup/rollback plan ready
- [ ] Documentation updated
- [ ] Team trained on new system

---

## 📝 Appendix: Quick Start Guide

### For Backend Developers

1. **Install Pusher SDK:**
   ```bash
   composer require pusher/pusher-php-server
   ```

2. **Configure `.env`:**
   ```env
   BROADCAST_DRIVER=pusher
   PUSHER_APP_ID=2111430
   PUSHER_APP_KEY=ce3fd047d2f9980ea2a5
   PUSHER_APP_SECRET=9fe1bac892d1ac697c9f
   PUSHER_APP_CLUSTER=ap2
   ```

3. **Create Event:**
   ```php
   php artisan make:event MessageSent --broadcast
   ```

4. **Fire Event:**
   ```php
   broadcast(new MessageSent($message, $user));
   ```

### For Flutter Developers

1. **Add Package:**
   ```yaml
   dependencies:
     pusher_client: ^2.0.0
   ```

2. **Initialize:**
   ```dart
   await PusherService.initialize();
   ```

3. **Subscribe to Channel:**
   ```dart
   await PusherService.subscribeToChatChannel(
     itemOfferId,
     onMessageReceived,
     onTyping,
   );
   ```

4. **Listen for Events:**
   ```dart
   void onMessageReceived(Map<String, dynamic> data) {
     // Handle new message
   }
   ```

---

**END OF DOCUMENTATION**

This comprehensive guide provides everything needed to implement real-time chat using Pusher + Laravel. For questions or support, refer to the troubleshooting section or contact the development team.
