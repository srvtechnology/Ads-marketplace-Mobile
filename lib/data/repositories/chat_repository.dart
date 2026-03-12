import 'package:dio/dio.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/ui/screens/chat/chat_audio/widgets/chat_widget.dart';
import 'package:eClassify/utils/api.dart';
import 'package:flutter/material.dart';

class ChatRepository {
  Future<DataOutput<ChatUser>> fetchBuyerChatList(int page) async {
    Map<String, dynamic> response = await Api.post(
        url: Api.getChatListApi, parameter: {"type": "buyer", "page": page});

    List<ChatUser> modelList = (response['data']['data'] as List).map(
      (e) {
        return ChatUser.fromJson(e);
      },
    ).toList();

    return DataOutput(total: response['data']['total'], modelList: modelList);
  }

  Future<DataOutput<ChatUser>> fetchSellerChatList(int page) async {
    Map<String, dynamic> response = await Api.post(
        url: Api.getChatListApi, parameter: {"page": page, "type": "seller"});

    List<ChatUser> modelList = (response['data']["data"] as List).map(
      (e) {
        return ChatUser.fromJson(e);
      },
    ).toList();

    return DataOutput(
        total: response['data']['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<ChatMessage>> getMessagesApi(
      {required int page, required int itemOfferId}) async {
    Map<String, dynamic> response = await Api.post(
      url: Api.chatMessagesApi,
      parameter: {
        "item_offer_id": itemOfferId,
        "page": page,
      },
    );

    // Extract item status from response
    Map<String, dynamic>? itemStatus = response['data']['item_status'];

    List<ChatMessage> modelList =
        (response['data']['chat']['data'] as List).map(
      (result) {
        int senderId = result['sender_id'];
        String? message = result['message'];
        String? file = result['file'];
        String? audio = result['audio'];
        String createdAt = result['created_at'];
        int itemOfferId = result['item_offer_id'];
        int id = result['id'];
        String? offerStatus = result['offer_status'];
        String? type = result['type'];
        double? amount = result['amount'] != null
            ? double.tryParse(result['amount'].toString())
            : null;

        if (amount == null && type == "O" && message != null) {
          String cleanMessage = message.trim();
          if (cleanMessage.startsWith("Offered:")) {
            String raw = cleanMessage.substring("Offered:".length).trim();
            amount = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
          }
        }

        return ChatMessage(
          key: ValueKey(id),
          id: id,
          message: message ?? "",
          senderId: senderId,
          createdAt: createdAt,
          file: file!,
          audio: audio!,
          itemOfferId: itemOfferId,
          updatedAt: createdAt,
          offerStatus: offerStatus,
          type: type,
          amount: amount,
        );
      },
    ).toList();

    return DataOutput(
      total: response['data']['chat']['total'] ?? 0,
      modelList: modelList,
      extraData: itemStatus != null
          ? ExtraData(data: itemStatus)
          : null, // Wrap in ExtraData
    );
  }

  Future<Map<String, dynamic>> sendMessageApi(
      {required int itemOfferId,
      required String message,
      required String type,
      double? amount,
      MultipartFile? audio,
      MultipartFile? attachment}) async {
    Map<String, dynamic> parameters = {
      "item_offer_id": itemOfferId,
      "type": type,
    };

    if (amount != null) {
      parameters['amount'] = amount;
    }

    if (attachment != null) {
      parameters['file'] = attachment;
    }
    if (audio != null) {
      parameters['audio'] = audio;
    }

    if (message != "") {
      parameters['message'] = message;
    }

    Map<String, dynamic> map =
        await Api.post(url: Api.sendMessageApi, parameter: parameters);

    return map;
  }

  Future<Map<String, dynamic>> blockUserApi({required int blockUserId}) async {
    Map<String, dynamic> parameters = {
      "blocked_user_id": blockUserId,
    };

    Map<String, dynamic> map =
        await Api.post(url: Api.blockUserApi, parameter: parameters);

    return map;
  }

  Future<Map<String, dynamic>> unBlockUserApi(
      {required int blockUserId}) async {
    Map<String, dynamic> parameters = {
      "blocked_user_id": blockUserId,
    };

    Map<String, dynamic> map =
        await Api.post(url: Api.unBlockUserApi, parameter: parameters);

    return map;
  }

  Future<DataOutput<BlockedUserModel>> blockedUsersListApi() async {
    Map<String, dynamic> response =
        await Api.get(url: Api.blockedUsersListApi, queryParameters: {});

    List<BlockedUserModel> modelList = (response['data'] as List).map(
      (e) {
        return BlockedUserModel.fromJson(e);
      },
    ).toList();

    return DataOutput(modelList: modelList, total: modelList.length);
  }

  Future<Map<String, dynamic>> changeOfferStatus({
    required int chatId,
    required int itemOfferId,
    required String status, // 'A' or 'R'
  }) async {
    Map<String, dynamic> parameters = {
      "chat_id": chatId,
      "item_offer_id": itemOfferId,
      "offer_status": status,
    };

    Map<String, dynamic> response = await Api.post(
      url: Api.statusChangeOffer,
      parameter: parameters,
    );

    return response;
  }
}
