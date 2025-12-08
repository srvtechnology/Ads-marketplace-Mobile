import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/data/model/bfs_model.dart';
import 'package:eClassify/data/repositories/bfs_payment_repository.dart';

abstract class BfsPaymentState {}

class BfsPaymentInitial extends BfsPaymentState {}

class BfsPaymentLoading extends BfsPaymentState {}

class BfsPaymentArSuccess extends BfsPaymentState {
  final BfsArResponse response;
  BfsPaymentArSuccess(this.response);
}

class BfsPaymentAeSuccess extends BfsPaymentState {
  final BfsAeResponse response;
  BfsPaymentAeSuccess(this.response);
}

class BfsPaymentDrSuccess extends BfsPaymentState {
  final BfsDrResponse response;
  BfsPaymentDrSuccess(this.response);
}

class BfsPaymentFailure extends BfsPaymentState {
  final String errorMessage;
  BfsPaymentFailure(this.errorMessage);
}

class BfsPaymentCubit extends Cubit<BfsPaymentState> {
  final BfsPaymentRepository _repository;

  BfsPaymentCubit(this._repository) : super(BfsPaymentInitial());

  Future<void> initiatePayment(
      {required String itemId, required String email}) async {
    emit(BfsPaymentLoading());
    try {
      final response =
          await _repository.initiatePayment(itemId: itemId, email: email);
      emit(BfsPaymentArSuccess(response));
    } catch (e) {
      emit(BfsPaymentFailure(e.toString()));
    }
  }

  Future<void> verifyAccount({
    required String orderNo,
    required String bankId,
    required String accountNo,
  }) async {
    emit(BfsPaymentLoading());
    try {
      final response = await _repository.verifyAccount(
        orderNo: orderNo,
        bankId: bankId,
        accountNo: accountNo,
      );
      if (response.success) {
        emit(BfsPaymentAeSuccess(response));
      } else {
        emit(BfsPaymentFailure(response.message));
      }
    } catch (e) {
      emit(BfsPaymentFailure(e.toString()));
    }
  }

  Future<void> submitOtp({required String orderNo, required String otp}) async {
    emit(BfsPaymentLoading());
    try {
      final response = await _repository.submitOtp(orderNo: orderNo, otp: otp);
      if (response.success) {
        emit(BfsPaymentDrSuccess(response));
      } else if (response.isPending) {
        // Start polling if pending - call DR again after delay
        _pollDrStatus(orderNo, otp);
      } else {
        emit(BfsPaymentDrSuccess(
            response)); // Passing response even on failure to show error msg from UI
      }
    } catch (e) {
      emit(BfsPaymentFailure(e.toString()));
    }
  }

  Future<void> _pollDrStatus(String orderNo, String otp,
      {int retryCount = 0}) async {
    if (retryCount >= 5) {
      // Max 5 retries (approx 15 seconds)
      emit(BfsPaymentFailure(
          "Transaction is taking longer than expected. Please check your bank statement."));
      return;
    }

    await Future.delayed(Duration(seconds: 3));

    try {
      // Re-call DR endpoint with the same order_no and otp
      final response = await _repository.submitOtp(orderNo: orderNo, otp: otp);

      if (response.success) {
        emit(BfsPaymentDrSuccess(response));
      } else if (response.isPending) {
        _pollDrStatus(orderNo, otp, retryCount: retryCount + 1);
      } else {
        emit(BfsPaymentDrSuccess(response)); // Fail eventually
      }
    } catch (e) {
      emit(BfsPaymentFailure("Failed to check status: ${e.toString()}"));
    }
  }
}
