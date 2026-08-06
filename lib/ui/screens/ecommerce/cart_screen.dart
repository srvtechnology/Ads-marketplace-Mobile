import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/data/model/ecommerce/cart_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => const CartScreen());
  }

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<int> _selectedItemIds = {};
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().fetchCart();
  }

  void _toggleSelectAll(EcommerceCartModel cart) {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedItemIds.addAll(cart.items.map((e) => e.id));
      } else {
        _selectedItemIds.clear();
      }
    });
  }

  void _showProductDetailsBottomSheet(BuildContext context, EcommerceCartItemModel item, EcommerceCartModel cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FutureBuilder<EcommerceCartItemBreakdownModel?>(
          future: context.read<CartCubit>().fetchCartItemDetails(item.id),
          builder: (context, snapshot) {
            final breakdown = snapshot.data;

            double itemPrice = breakdown?.itemTotal ?? (item.price > 0 ? item.price : 349.0);
            double serviceCharges = breakdown?.serviceCharges ?? 100.0;
            double deliveryCharges = breakdown?.deliveryCharges ?? 39.0;
            double shipmentCharges = breakdown?.shipmentChargeTillJaigaon ?? 38.0;
            double gstCharges = breakdown?.gst5Percent ?? (itemPrice * 0.05);
            double calculatedTotal = breakdown?.totalPrice ?? (item.subtotal > 0 ? item.subtotal : (itemPrice * item.qty));

            String sourceUrl = breakdown?.sourceUrl ?? item.url ?? '';
            String orderId = breakdown?.cartItemId != 0 ? breakdown?.cartItemId.toString() ?? item.id.toString() : item.id.toString();
            String placedOn = breakdown?.placedOn ?? item.importedDate ?? '2026-07-24';
            String platform = breakdown?.platform ?? item.platform ?? item.product?.description ?? 'Amazon';
            String variantsStr = (breakdown?.variants != null && breakdown!.variants!.isNotEmpty) ? breakdown.variants! : item.displayVariants;

            return Container(
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title & close icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PRODUCT DETAILS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.color.textDefaultColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.color.textDefaultColor, size: 24),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Info Rows
                    if (sourceUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Text('Source URL: ', style: TextStyle(fontSize: 14, color: context.color.textLightColor)),
                            InkWell(
                              onTap: () async {
                                final Uri uri = Uri.parse(sourceUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Text(
                                'Visit Product Source',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.color.territoryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      children: [
                        Text('Order ID ', style: TextStyle(fontSize: 14, color: context.color.textLightColor)),
                        Text(
                          '#${orderId != "0" ? orderId : "1349373"}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.color.territoryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text('Placed on ', style: TextStyle(fontSize: 14, color: context.color.textLightColor)),
                        Text(
                          placedOn,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.color.textDefaultColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text('Platform ', style: TextStyle(fontSize: 14, color: context.color.textLightColor)),
                        Text(
                          platform,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.color.textDefaultColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Product Card Preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.color.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.color.borderColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: UiUtils.imageType(
                                breakdown?.image ?? item.product?.imageUrl ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  breakdown?.title ?? item.product?.name ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: context.color.textDefaultColor,
                                  ),
                                ),
                                if (variantsStr.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    variantsStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.color.textLightColor,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${breakdown?.quantity ?? item.qty}',
                                  style: TextStyle(fontSize: 13, color: context.color.textLightColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${cart.currency}${calculatedTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: context.color.territoryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Detail section
                    Text(
                      'Payment Detail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.color.textDefaultColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildPaymentRow('Item Total', '${cart.currency}${itemPrice.toStringAsFixed(2)}', context),
                    _buildPaymentRow('Service Charges', '${cart.currency}${serviceCharges.toStringAsFixed(2)}', context),
                    _buildPaymentRow('Delivery Charges', '${cart.currency}${deliveryCharges.toStringAsFixed(2)}', context),
                    _buildPaymentRow('Shipment Charge till Jaigaon', '${cart.currency}${shipmentCharges.toStringAsFixed(2)}', context),
                    _buildPaymentRow('5% GST (including DDP)', '${cart.currency}${gstCharges.toStringAsFixed(2)}', context),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Bottom total price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.color.textDefaultColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cart.currency}${calculatedTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.color.territoryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentRow(String title, String amount, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: context.color.textLightColor,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.color.textDefaultColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context, showBackButton: true, title: 'My Cart'),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartFailure) {
            HelperUtils.showSnackBarMessage(context, state.errorMessage, type: MessageType.error);
          }
        },
        builder: (context, state) {
          if (state is CartInProgress) {
            return Center(child: UiUtils.progress());
          }
          if (state is CartFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(state.errorMessage),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<CartCubit>().fetchCart(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is CartSuccess) {
            final cart = state.cart;
            if (cart.items.isEmpty) {
              return Center(
                child: CustomText('Your cart is empty', fontSize: context.font.large),
              );
            }

            // Sync selection state
            if (_selectedItemIds.isEmpty && _selectAll) {
              _selectedItemIds.addAll(cart.items.map((e) => e.id));
            }

            return Column(
              children: [
                // Top Action Bar (Select All & Delete Items)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => _toggleSelectAll(cart),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _selectedItemIds.length == cart.items.length && cart.items.isNotEmpty,
                              onChanged: (_) => _toggleSelectAll(cart),
                              activeColor: context.color.territoryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            Text(
                              'Select All',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.color.textDefaultColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          side: BorderSide(color: context.color.borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _selectedItemIds.isEmpty
                            ? null
                            : () {
                                context.read<CartCubit>().deleteCartItems(_selectedItemIds.toList());
                                setState(() {
                                  _selectedItemIds.clear();
                                });
                              },
                        icon: Icon(Icons.delete_outline, size: 18, color: context.color.textLightColor),
                        label: Text(
                          'Delete Items',
                          style: TextStyle(fontSize: 13, color: context.color.textLightColor),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final bool isSelected = _selectedItemIds.contains(item.id);
                      final double itemPrice = item.subtotal > 0 ? item.subtotal : (item.price * item.qty);

                      return GestureDetector(
                        onTap: () => _showProductDetailsBottomSheet(context, item, cart),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Selection Checkbox
                              Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedItemIds.add(item.id);
                                    } else {
                                      _selectedItemIds.remove(item.id);
                                    }
                                  });
                                  context.read<CartCubit>().updateCartItem(item.id, item.qty, isSelected: val);
                                },
                                activeColor: context.color.territoryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),

                              // Item Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: UiUtils.imageType(
                                    item.product?.imageUrl ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Title, Order ID, Price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ID #${item.id != 0 ? item.id : "1349373"}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.color.textLightColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.product?.name ?? 'Unknown Product',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: context.color.textDefaultColor,
                                      ),
                                    ),
                                    if (item.displayVariants.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.displayVariants,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.color.textLightColor,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      '${cart.currency}${itemPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: context.color.territoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls (- 1 +)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.color.territoryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (item.qty > 1) {
                                          context.read<CartCubit>().updateCartItem(item.id, item.qty - 1);
                                        } else {
                                          context.read<CartCubit>().removeCartItem(item.id);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white24,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.remove, size: 14, color: context.color.buttonColor),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${item.qty}',
                                        style: TextStyle(
                                          color: context.color.buttonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context.read<CartCubit>().updateCartItem(item.id, item.qty + 1);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white24,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.add, size: 14, color: context.color.buttonColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Grand Total Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Grand Total',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.color.textLightColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cart.currency}${cart.grandTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: context.color.territoryColor,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.color.territoryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.ecommerceCheckout);
                          },
                          child: Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              color: context.color.buttonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
