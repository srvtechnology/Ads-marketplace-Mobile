import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => const CartScreen());
  }

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().fetchCart();
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
              return Center(child: CustomText('Your cart is empty', fontSize: context.font.large));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: UiUtils.imageType(
                                  item.product?.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    item.product?.name ?? 'Unknown Product',
                                    maxLines: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 4),
                                  CustomText(
                                    item.variant?.variantName ?? '',
                                    color: context.color.textLightColor,
                                    fontSize: context.font.small,
                                  ),
                                  const SizedBox(height: 8),
                                  CustomText(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    fontWeight: FontWeight.bold,
                                    color: context.color.territoryColor,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: context.color.error),
                                  onPressed: () {
                                    context.read<CartCubit>().removeCartItem(item.id);
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: context.color.borderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (item.qty > 1) {
                                            context.read<CartCubit>().updateCartItem(item.id, item.qty - 1);
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.remove, size: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: CustomText('${item.qty}', fontWeight: FontWeight.bold),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          context.read<CartCubit>().updateCartItem(item.id, item.qty + 1);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText('Grand Total', fontSize: context.font.large, fontWeight: FontWeight.bold),
                            CustomText(
                              '\$${cart.grandTotal.toStringAsFixed(2)}',
                              fontSize: context.font.extraLarge,
                              fontWeight: FontWeight.bold,
                              color: context.color.territoryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.color.territoryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.ecommerceCheckout);
                            },
                            child: CustomText('Proceed to Checkout', color: context.color.secondaryColor, fontWeight: FontWeight.bold),
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
