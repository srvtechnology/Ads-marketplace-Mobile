import 'package:eClassify/data/cubits/bank_details_cubit.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => const BankDetailsScreen(),
    );
  }

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    context.read<BankDetailsCubit>().fetchBankDetails();
  }

  @override
  void dispose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderNameController.dispose();
    super.dispose();
  }

  void _onUpdatePressed() {
    if (_formKey.currentState!.validate()) {
      context.read<BankDetailsCubit>().updateBankDetails(
            bankName: bankNameController.text.trim(),
            accountNumber: accountNumberController.text.trim(),
            accountHolderName: accountHolderNameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: "bankAccountDetails".translate(context)),
      body: BlocConsumer<BankDetailsCubit, BankDetailsState>(
        listener: (context, state) {
          if (state is BankDetailsFetchSuccess) {
            bankNameController.text = state.data['bank_name'] ?? "";
            accountNumberController.text = state.data['account_number'] ?? "";
            accountHolderNameController.text =
                state.data['account_holder_name'] ?? "";
          } else if (state is BankDetailsUpdateSuccess) {
            HelperUtils.showSnackBarMessage(context, state.message);
            // Optionally pop or keep on screen
          } else if (state is BankDetailsFetchFailure) {
            HelperUtils.showSnackBarMessage(context, state.errorMessage);
          } else if (state is BankDetailsUpdateFailure) {
            HelperUtils.showSnackBarMessage(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          bool isFetching = state is BankDetailsFetchInProgress;
          bool isUpdating = state is BankDetailsUpdateInProgress;

          if (isFetching && state is! BankDetailsUpdateSuccess) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.territoryColor,
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField(
                        context,
                        title: "bankName",
                        controller: bankNameController,
                      ),
                      buildTextField(
                        context,
                        title: "accountNumber",
                        controller: accountNumberController,
                      ),
                      buildTextField(
                        context,
                        title: "accountHolder",
                        controller: accountHolderNameController,
                      ),
                      const SizedBox(height: 25),
                      UiUtils.buildButton(
                        context,
                        onPressed: _onUpdatePressed,
                        height: 48,
                        buttonTitle: "updateProfile".translate(context),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUpdating)
                Center(
                  child: UiUtils.progress(
                    normalProgressColor: context.color.territoryColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTextField(BuildContext context,
      {required String title,
      required TextEditingController controller,
      bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        CustomText(
          title.translate(context),
          color: context.color.textDefaultColor,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: controller,
          isReadOnly: readOnly,
          // Add validators if needed
          validator: CustomTextFieldValidator.nullCheck,
          fillColor: context.color.secondaryColor,
        ),
      ],
    );
  }
}
