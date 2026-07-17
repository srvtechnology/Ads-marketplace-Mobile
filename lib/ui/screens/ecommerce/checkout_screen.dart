import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/data/cubits/ecommerce/checkout_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EcommerceCheckoutScreen extends StatefulWidget {
  const EcommerceCheckoutScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => const EcommerceCheckoutScreen());
  }

  @override
  State<EcommerceCheckoutScreen> createState() => _EcommerceCheckoutScreenState();
}

class _EcommerceCheckoutScreenState extends State<EcommerceCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _shippingAddressController;
  late TextEditingController _shippingZipcodeController;
  late TextEditingController _shippingLandmarkController;
  late TextEditingController _billingAddressController;
  late TextEditingController _billingZipcodeController;
  late TextEditingController _billingLandmarkController;
  late TextEditingController _remarksController;

  String _paymentMode = 'COD'; // Default to COD
  bool _isBillingSameAsShipping = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill user data
    final user = context.read<UserDetailsCubit>().state.user;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _mobileController = TextEditingController(text: user?.mobile ?? '');
    _shippingAddressController = TextEditingController(text: user?.address ?? '');
    _shippingZipcodeController = TextEditingController();
    _shippingLandmarkController = TextEditingController();
    _billingAddressController = TextEditingController(text: user?.address ?? '');
    _billingZipcodeController = TextEditingController();
    _billingLandmarkController = TextEditingController();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _shippingAddressController.dispose();
    _shippingZipcodeController.dispose();
    _shippingLandmarkController.dispose();
    _billingAddressController.dispose();
    _billingZipcodeController.dispose();
    _billingLandmarkController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submitCheckout() {
    if (_formKey.currentState!.validate()) {
      context.read<CheckoutCubit>().checkout(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        shippingAddress: _shippingAddressController.text.trim(),
        shippingZipcode: _shippingZipcodeController.text.trim(),
        shippingLandmark: _shippingLandmarkController.text.trim(),
        billingAddress: _isBillingSameAsShipping ? _shippingAddressController.text.trim() : _billingAddressController.text.trim(),
        billingZipcode: _isBillingSameAsShipping ? _shippingZipcodeController.text.trim() : _billingZipcodeController.text.trim(),
        billingLandmark: _isBillingSameAsShipping ? _shippingLandmarkController.text.trim() : _billingLandmarkController.text.trim(),
        remarks: _remarksController.text.trim(),
        paymentMode: _paymentMode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context, showBackButton: true, title: 'Checkout'),
      body: BlocListener<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutInProgress) {
            // Show loading if necessary
          } else if (state is CheckoutSuccess) {
            context.read<CartCubit>().fetchCart(); // clear cart on frontend
            HelperUtils.showSnackBarMessage(context, 'Order Placed Successfully!', type: MessageType.success);
            Navigator.popUntil(context, (route) => route.isFirst); // go back to home
          } else if (state is CheckoutFailure) {
            HelperUtils.showSnackBarMessage(context, state.errorMessage, type: MessageType.error);
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Contact Information'),
              _buildTextField('Full Name', _nameController, required: true),
              _buildTextField('Mobile Number', _mobileController, required: true),
              _buildTextField('Email Address', _emailController),
              
              const SizedBox(height: 20),
              _buildSectionTitle('Shipping Address'),
              _buildTextField('Address', _shippingAddressController, required: true, maxLines: 2),
              Row(
                children: [
                  Expanded(child: _buildTextField('Zipcode', _shippingZipcodeController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Landmark', _shippingLandmarkController)),
                ],
              ),

              const SizedBox(height: 10),
              CheckboxListTile(
                title: CustomText('Billing address is same as shipping address', fontSize: context.font.normal),
                value: _isBillingSameAsShipping,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: context.color.territoryColor,
                onChanged: (value) {
                  setState(() {
                    _isBillingSameAsShipping = value ?? true;
                  });
                },
              ),

              if (!_isBillingSameAsShipping) ...[
                const SizedBox(height: 20),
                _buildSectionTitle('Billing Address'),
                _buildTextField('Address', _billingAddressController, maxLines: 2),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Zipcode', _billingZipcodeController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Landmark', _billingLandmarkController)),
                  ],
                ),
              ],

              const SizedBox(height: 20),
              _buildSectionTitle('Additional Remarks'),
              _buildTextField('Remarks', _remarksController, maxLines: 2),

              const SizedBox(height: 20),
              _buildSectionTitle('Payment Method'),
              _buildPaymentModeSelector(),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.territoryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitCheckout,
                child: CustomText('Place Order', color: context.color.secondaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomText(
        title,
        fontSize: context.font.large,
        fontWeight: FontWeight.bold,
        color: context.color.textColorDark,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildPaymentModeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.color.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Cash on Delivery (COD)'),
            value: 'COD',
            groupValue: _paymentMode,
            onChanged: (value) {
              setState(() {
                _paymentMode = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Pay Online'),
            value: 'ONLINE',
            groupValue: _paymentMode,
            onChanged: (value) {
              setState(() {
                _paymentMode = value!;
              });
            },
          ),
        ],
      ),
    );
  }
}
