import 'package:eClassify/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  Future<void> fetch() async {
    try {
      emit(GetApiKeysInProgress());
      await Api.get(url: Api.getPaymentSettingsApi);

      emit(GetApiKeysSuccess());
    } catch (e) {
      emit(GetApiKeysFail(e.toString()));
    }
  }
}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysFail extends GetApiKeysState {
  final String error;
  GetApiKeysFail(this.error);
}

class GetApiKeysSuccess extends GetApiKeysState {
  GetApiKeysSuccess();
}
