import 'package:eClassify/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChangeOfferStatusState {}

class ChangeOfferStatusInitial extends ChangeOfferStatusState {}

class ChangeOfferStatusInProgress extends ChangeOfferStatusState {}

class ChangeOfferStatusSuccess extends ChangeOfferStatusState {
  final String status; // 'A' or 'R'
  final String message;
  final int itemOfferId;
  final int chatId;

  ChangeOfferStatusSuccess(
      this.status, this.message, this.itemOfferId, this.chatId);
}

class ChangeOfferStatusFailure extends ChangeOfferStatusState {
  final String errorMessage;

  ChangeOfferStatusFailure(this.errorMessage);
}

class ChangeOfferStatusCubit extends Cubit<ChangeOfferStatusState> {
  final ChatRepository _chatRepository = ChatRepository();

  ChangeOfferStatusCubit() : super(ChangeOfferStatusInitial());

  Future<void> changeOfferStatus({
    required int chatId,
    required int itemOfferId,
    required String status,
  }) async {
    try {
      emit(ChangeOfferStatusInProgress());
      Map<String, dynamic> response = await _chatRepository.changeOfferStatus(
        chatId: chatId,
        itemOfferId: itemOfferId,
        status: status,
      );
      emit(ChangeOfferStatusSuccess(
        status,
        response['message'],
        itemOfferId,
        chatId,
      ));
    } catch (e) {
      emit(ChangeOfferStatusFailure(e.toString()));
    }
  }

  /// Called from the Pusher real-time listener when the server broadcasts an
  /// offer accept/reject event (type: 'status_change').  Emits the success
  /// state directly — no API call needed because the server already processed
  /// it; we just need to update the UI bubble that matches [chatId].
  void notifyStatusChange({
    required int chatId,
    required int itemOfferId,
    required String status,
    String message = '',
  }) {
    emit(ChangeOfferStatusSuccess(status, message, itemOfferId, chatId));
  }
}
