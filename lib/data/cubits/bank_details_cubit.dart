import 'package:eClassify/data/repositories/bank_details_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BankDetailsState {}

class BankDetailsInitial extends BankDetailsState {}

class BankDetailsFetchInProgress extends BankDetailsState {}

class BankDetailsFetchSuccess extends BankDetailsState {
  final Map<String, dynamic> data;
  BankDetailsFetchSuccess(this.data);
}

class BankDetailsFetchFailure extends BankDetailsState {
  final String errorMessage;
  BankDetailsFetchFailure(this.errorMessage);
}

class BankDetailsUpdateInProgress extends BankDetailsState {}

class BankDetailsUpdateSuccess extends BankDetailsState {
  final Map<String, dynamic> data;
  final String message;
  BankDetailsUpdateSuccess({required this.data, required this.message});
}

class BankDetailsUpdateFailure extends BankDetailsState {
  final String errorMessage;
  BankDetailsUpdateFailure(this.errorMessage);
}

class BankDetailsCubit extends Cubit<BankDetailsState> {
  final BankDetailsRepository _repository;

  BankDetailsCubit(this._repository) : super(BankDetailsInitial());

  void fetchBankDetails() async {
    emit(BankDetailsFetchInProgress());
    try {
      final result = await _repository.getBankAccountDetails();
      emit(BankDetailsFetchSuccess(result['data']));
    } catch (e) {
      emit(BankDetailsFetchFailure(e.toString()));
    }
  }

  void updateBankDetails({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    emit(BankDetailsUpdateInProgress());
    try {
      final result = await _repository.updateBankAccountDetails(
        bankName: bankName,
        accountNumber: accountNumber,
        accountHolderName: accountHolderName,
      );

      // Update local hive data if successful?
      // The user model has these fields, maybe we should update them too.
      // But the cubit just handles its own state for now.

      emit(BankDetailsUpdateSuccess(
        data: result['data'],
        message: result['message'] ?? "Details Updated Successfully",
      ));
    } catch (e) {
      emit(BankDetailsUpdateFailure(e.toString()));
    }
  }
}
