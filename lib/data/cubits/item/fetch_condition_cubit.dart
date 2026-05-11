import 'package:eClassify/data/model/item/condition_model.dart';
import 'package:eClassify/data/repositories/item/condition_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchConditionState {}

class FetchConditionInitial extends FetchConditionState {}

class FetchConditionInProgress extends FetchConditionState {}

class FetchConditionSuccess extends FetchConditionState {
  final List<ConditionModel> conditions;

  FetchConditionSuccess({required this.conditions});
}

class FetchConditionFail extends FetchConditionState {
  final dynamic error;

  FetchConditionFail(this.error);
}

class FetchConditionCubit extends Cubit<FetchConditionState> {
  FetchConditionCubit() : super(FetchConditionInitial());
  final ConditionRepository _conditionRepository = ConditionRepository();

  void fetchConditions() async {
    try {
      emit(FetchConditionInProgress());
      List<ConditionModel> conditions =
          await _conditionRepository.fetchConditionList();
      emit(FetchConditionSuccess(conditions: conditions));
    } catch (e) {
      emit(FetchConditionFail(e));
    }
  }
}
