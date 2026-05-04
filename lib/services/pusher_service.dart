import 'dart:convert';
import 'dart:async';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherChannelsFlutter pusher =
      PusherChannelsFlutter.getInstance();

  static final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get eventsStream =>
      _eventsController.stream;

  static bool _isInitialized = false;

  static Future<void> init({
    required int userId,
  }) async {
    try {
      await pusher.init(
        apiKey: "ce3fd047d2f9980ea2a5",
        cluster: "ap2",
        onConnectionStateChange: (state, prev) {
          print("Pusher State: $state");
        },
        onError: (message, code, error) {
          print("Pusher Error: $message");
        },
      );
      _isInitialized = true;
    } catch (e) {
      print("Pusher init error (ignored if already initialized): $e");
    }

    try {
      await pusher.unsubscribe(channelName: "chat-user-$userId");
    } catch (e) {
      print("Pusher unsubscribe error (ignored): $e");
    }

    try {
      await pusher.subscribe(
        channelName: "chat-user-$userId",
        onEvent: (event) {
          print(
              "Pusher Event Received: ${event.eventName} - Data: ${event.data}");
          if (event.eventName == "receive_message") {
            try {
              final data = jsonDecode(event.data);
              print("Pusher Decoded Data: $data");
              _eventsController.add(data);
            } catch (e) {
              print("Error parsing Pusher message: $e");
            }
          }
        },
      );
    } catch (e) {
      print("Pusher subscribe error: $e");
    }

    try {
      await pusher.connect();
    } catch (e) {
      print("Pusher connect error: $e");
    }
  }

  static Future<void> disconnect(int userId) async {
    if (!_isInitialized) {
      print("Pusher not initialized, skipping disconnect");
      return;
    }
    
    try {
      await pusher.unsubscribe(channelName: "chat-user-$userId");
      await pusher.disconnect();
      _isInitialized = false;
    } catch (e) {
      print("Error disconnecting Pusher: $e");
    }
  }
}
