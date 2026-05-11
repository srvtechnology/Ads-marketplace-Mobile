import 'package:eClassify/data/model/item/condition_model.dart';
import 'package:eClassify/utils/api.dart';

class ConditionRepository {
  Future<List<ConditionModel>> fetchConditionList() async {
    try {
      Map<String, dynamic> response = await Api.get(
        url: Api.getConditionListApi,
      );

      if (response['success'] == true && response['conditions'] != null) {
        List<ConditionModel> conditions = (response['conditions'] as List)
            .map((element) => ConditionModel.fromJson(element))
            .toList();
        return conditions;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
