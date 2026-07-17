import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/data/cubits/ecommerce/fetch_product_details_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EcommerceProductDetailsScreen extends StatefulWidget {
  final int productId;

  const EcommerceProductDetailsScreen({super.key, required this.productId});

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => EcommerceProductDetailsScreen(
        productId: args?['productId'] ?? 0,
      ),
    );
  }

  @override
  State<EcommerceProductDetailsScreen> createState() => _EcommerceProductDetailsScreenState();
}

class _EcommerceProductDetailsScreenState extends State<EcommerceProductDetailsScreen> {
  int? _selectedVariantId;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    context.read<FetchProductDetailsCubit>().fetchProductDetails(widget.productId);
  }

  void _addToCart(EcommerceProductModel product) {
    if (_selectedVariantId == null) {
      HelperUtils.showSnackBarMessage(context, 'Please select a variant', type: MessageType.error);
      return;
    }
    context.read<CartCubit>().addToCart(product.id, _selectedVariantId!, _qty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context, showBackButton: true, title: 'Product Details'),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CartCubit, CartState>(
            listener: (context, state) {
              if (state is CartInProgress) {
                // Show loading indicator in a dialog manually if needed, but simple return is better.
                // Let's just use snackbar for progress too or skip it
              } else if (state is CartSuccess) {
                HelperUtils.showSnackBarMessage(context, 'Added to Cart Successfully', type: MessageType.success);
              } else if (state is CartFailure) {
                HelperUtils.showSnackBarMessage(context, state.errorMessage, type: MessageType.error);
              }
            },
          ),
        ],
        child: BlocBuilder<FetchProductDetailsCubit, FetchProductDetailsState>(
          builder: (context, state) {
            if (state is FetchProductDetailsInProgress) {
              return Center(child: UiUtils.progress());
            }
            if (state is FetchProductDetailsFailure) {
              return Center(child: Text(state.errorMessage));
            }
            if (state is FetchProductDetailsSuccess) {
              final product = state.product;
              
              // Automatically select first variant if none selected and variants exist
              if (_selectedVariantId == null && product.variants.isNotEmpty) {
                _selectedVariantId = product.variants.first.id;
              }

              final selectedVariant = product.variants.firstWhere(
                  (v) => v.id == _selectedVariantId, 
                  orElse: () => product.variants.isNotEmpty ? product.variants.first : EcommerceVariantModel(id: 0, productId: 0, price: 0)
              );

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSlider(product.images.isNotEmpty ? product.images : [product.imageUrl]),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  product.name,
                                  fontSize: context.font.larger,
                                  fontWeight: FontWeight.bold,
                                  color: context.color.textColorDark,
                                ),
                                const SizedBox(height: 8),
                                CustomText(
                                  '\$${selectedVariant.price.toStringAsFixed(2)}',
                                  fontSize: context.font.extraLarge,
                                  fontWeight: FontWeight.w600,
                                  color: context.color.territoryColor,
                                ),
                                const SizedBox(height: 20),
                                CustomText('Variants', fontSize: context.font.large, fontWeight: FontWeight.bold),
                                const SizedBox(height: 10),
                                _buildVariants(product.variants),
                                const SizedBox(height: 20),
                                CustomText('Description', fontSize: context.font.large, fontWeight: FontWeight.bold),
                                const SizedBox(height: 10),
                                CustomText(
                                  product.description ?? 'No description available.',
                                  color: context.color.textLightColor,
                                  fontSize: context.font.normal,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(product),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildImageSlider(List<String> images) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return UiUtils.imageType(images[index], fit: BoxFit.cover);
        },
      ),
    );
  }

  Widget _buildVariants(List<EcommerceVariantModel> variants) {
    if (variants.isEmpty) return const Text('No variants available');
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: variants.map((v) {
        final isSelected = _selectedVariantId == v.id;
        return ChoiceChip(
          label: Text('${v.variantName ?? "Variant"} - \$${v.price}'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedVariantId = v.id;
              });
            }
          },
          selectedColor: context.color.territoryColor.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? context.color.territoryColor : context.color.textColorDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: context.color.secondaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(EcommerceProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Qty selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.color.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_qty > 1) setState(() => _qty--);
                    },
                  ),
                  CustomText('$_qty', fontSize: context.font.large, fontWeight: FontWeight.bold),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _qty++);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.territoryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _addToCart(product),
                child: CustomText('Add to Cart', color: context.color.secondaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
