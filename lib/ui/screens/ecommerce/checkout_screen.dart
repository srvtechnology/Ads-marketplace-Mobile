import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/data/cubits/ecommerce/checkout_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eClassify/data/repositories/bfs_payment_repository.dart';
import 'package:eClassify/ui/screens/payment/bfs_payment_screen.dart';

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
  late TextEditingController _countryCodeController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _shippingAddressController;
  late TextEditingController _shippingZipcodeController;
  late TextEditingController _shippingLandmarkController;
  late TextEditingController _billingAddressController;
  late TextEditingController _billingZipcodeController;
  late TextEditingController _billingLandmarkController;
  late TextEditingController _remarksController;

  // Cash on Delivery (COD) option commented out and hidden. Default payment mode set to ONLINE.
  // String _paymentMode = 'COD';
  String _paymentMode = 'ONLINE';
  bool _isBillingSameAsShipping = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserDetailsCubit>().state.user;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _countryCodeController = TextEditingController(text: '+975');
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
    _countryCodeController.dispose();
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
      if (_paymentMode == 'ONLINE' || _paymentMode == 'BFS') {
        double grandTotal = 0.0;
        final cartState = context.read<CartCubit>().state;
        if (cartState is CartSuccess) {
          grandTotal = cartState.cart.grandTotal;
        }

        final customerDetails = {
          'name': _nameController.text.trim(),
          'country_code': _countryCodeController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'shipping_address': _shippingAddressController.text.trim(),
          'email': _emailController.text.trim(),
          'shipping_zipcode': _shippingZipcodeController.text.trim(),
          'shipping_landmark': _shippingLandmarkController.text.trim(),
          'billing_address': _isBillingSameAsShipping ? _shippingAddressController.text.trim() : _billingAddressController.text.trim(),
          'billing_zipcode': _isBillingSameAsShipping ? _shippingZipcodeController.text.trim() : _billingZipcodeController.text.trim(),
          'billing_landmark': _isBillingSameAsShipping ? _shippingLandmarkController.text.trim() : _billingLandmarkController.text.trim(),
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BfsPaymentScreen(
              paymentType: BfsPaymentType.cartCheckout,
              price: grandTotal,
              packageName: "Cart Order Payment",
              customerDetails: customerDetails,
            ),
          ),
        );
      } else {
        context.read<CheckoutCubit>().checkout(
          name: _nameController.text.trim(),
          countryCode: _countryCodeController.text.trim(),
          mobile: _mobileController.text.trim(),
          shippingAddress: _shippingAddressController.text.trim(),
          paymentMode: _paymentMode,
          email: _emailController.text.trim(),
          shippingZipcode: _shippingZipcodeController.text.trim(),
          shippingLandmark: _shippingLandmarkController.text.trim(),
          billingAddress: _isBillingSameAsShipping ? _shippingAddressController.text.trim() : _billingAddressController.text.trim(),
          billingZipcode: _isBillingSameAsShipping ? _shippingZipcodeController.text.trim() : _billingZipcodeController.text.trim(),
          billingLandmark: _isBillingSameAsShipping ? _shippingLandmarkController.text.trim() : _billingLandmarkController.text.trim(),
          remarks: _remarksController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context, showBackButton: true, title: 'Checkout'),
      body: BlocListener<CheckoutCubit, CheckoutState>(
        listener: (context, state) async {
          if (state is CheckoutInProgress) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => Center(child: UiUtils.progress()),
            );
          } else if (state is CheckoutSuccess) {
            Navigator.of(context, rootNavigator: true).pop(); // dismiss progress dialog
            context.read<CartCubit>().fetchCart();
            HelperUtils.showSnackBarMessage(context, 'Order Placed Successfully!', type: MessageType.success);

            if (state.checkoutResponse.paymentUrl != null && state.checkoutResponse.paymentUrl!.isNotEmpty) {
              final Uri uri = Uri.parse(state.checkoutResponse.paymentUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }

            Navigator.pushReplacementNamed(context, Routes.ecommerceOrderList);
          } else if (state is CheckoutFailure) {
            Navigator.of(context, rootNavigator: true).pop(); // dismiss progress dialog
            HelperUtils.showSnackBarMessage(context, state.errorMessage, type: MessageType.error);
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Customer Contact'),
              _buildTextField('Full Name', _nameController, required: true),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: _buildTextField('Code', _countryCodeController, required: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('Mobile Number', _mobileController, required: true, keyboardType: TextInputType.phone),
                  ),
                ],
              ),
              _buildTextField('Email Address', _emailController, keyboardType: TextInputType.emailAddress),
              
              const SizedBox(height: 16),
              _buildSectionTitle('Shipping Address'),
              _buildTextField('Shipping Address', _shippingAddressController, required: true, maxLines: 2),
              Row(
                children: [
                  Expanded(child: _buildTextField('Zipcode', _shippingZipcodeController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Landmark', _shippingLandmarkController)),
                ],
              ),

              Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  title: Text('Billing address same as shipping', style: TextStyle(fontSize: 14, color: context.color.textDefaultColor)),
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
              ),

              if (!_isBillingSameAsShipping) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Billing Address'),
                _buildTextField('Billing Address', _billingAddressController, maxLines: 2),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Zipcode', _billingZipcodeController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Landmark', _billingLandmarkController)),
                  ],
                ),
              ],

              const SizedBox(height: 16),
              _buildSectionTitle('Payment Method'),
              _buildPaymentModeSelector(),

              const SizedBox(height: 16),
              _buildSectionTitle('Special Instructions'),
              _buildTextField('Order Remarks', _remarksController, maxLines: 2),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.territoryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _submitCheckout,
                child: Text('Place Order', style: TextStyle(color: context.color.buttonColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.color.textDefaultColor,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: context.color.textDefaultColor),
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          labelStyle: TextStyle(color: context.color.textLightColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.color.borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.color.borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.color.territoryColor)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required field';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildPaymentModeSelector() {
    return Material(
      color: context.color.secondaryColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.color.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Cash on Delivery (COD) option commented out and hidden
          /*
          RadioListTile<String>(
            title: Text('Cash on Delivery (COD)', style: TextStyle(color: context.color.textDefaultColor, fontWeight: FontWeight.w600)),
            value: 'COD',
            groupValue: _paymentMode,
            activeColor: context.color.territoryColor,
            onChanged: (value) => setState(() => _paymentMode = value!),
          ),
          Divider(height: 1, color: context.color.borderColor),
          */
          RadioListTile<String>(
            title: Text('Pay Online', style: TextStyle(color: context.color.textDefaultColor, fontWeight: FontWeight.w600)),
            value: 'ONLINE',
            groupValue: _paymentMode,
            activeColor: context.color.territoryColor,
            onChanged: (value) => setState(() => _paymentMode = value!),
          ),
        ],
      ),
    );
  }
}
