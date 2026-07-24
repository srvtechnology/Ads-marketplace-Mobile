import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_categories_cubit.dart';
import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_subcategories_cubit.dart';
import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_products_cubit.dart';
import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_product_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EcommerceProductListScreen extends StatefulWidget {
  final int platformId;
  final String brandName;

  const EcommerceProductListScreen({
    super.key,
    required this.platformId,
    required this.brandName,
  });

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => EcommerceProductListScreen(
        platformId: args?['platformId'] ?? 0,
        brandName: args?['brandName'] ?? '',
      ),
    );
  }

  @override
  State<EcommerceProductListScreen> createState() => _EcommerceProductListScreenState();
}

class _EcommerceProductListScreenState extends State<EcommerceProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    if (HiveUtils.isUserAuthenticated()) {
      context.read<CartCubit>().fetchCart();
    }
    context.read<FetchEcommerceCategoriesCubit>().fetchCategories();
    _fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<FetchEcommerceProductsCubit>().loadMore();
      }
    });
  }

  void _fetchProducts() {
    context.read<FetchEcommerceProductsCubit>().fetchProducts(
      platformId: widget.platformId,
      categoryId: _selectedCategoryId,
      subcategoryId: _selectedSubcategoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'Products',
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              int cartItemCount = 0;
              if (state is CartSuccess) {
                cartItemCount = state.cart.totalItemsCount > 0 
                    ? state.cart.totalItemsCount 
                    : state.cart.items.fold(0, (sum, i) => sum + i.qty);
              }
              return IconButton(
                icon: Badge(
                  isLabelVisible: cartItemCount > 0,
                  label: Text(cartItemCount.toString()),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                onPressed: () {
                  UiUtils.checkUser(
                    context: context,
                    onNotGuest: () {
                      Navigator.pushNamed(context, Routes.ecommerceCart);
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Filter Row
          BlocBuilder<FetchEcommerceCategoriesCubit, FetchEcommerceCategoriesState>(
            builder: (context, state) {
              if (state is FetchEcommerceCategoriesSuccess) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.color.backgroundColor,
                        border: Border(
                          bottom: BorderSide(
                            color: context.color.borderColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.categories.length + 1,
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final category = isAll ? null : state.categories[index - 1];
                          final isSelected = _selectedCategoryId == (category?.id);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = isAll ? null : category?.id;
                                _selectedSubcategoryId = null; // reset subcategory on category change
                              });
                              if (isAll) {
                                context.read<FetchEcommerceSubcategoriesCubit>().clearSubcategories();
                              } else {
                                context.read<FetchEcommerceSubcategoriesCubit>().fetchSubcategories(category!.id);
                              }
                              _fetchProducts();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected ? context.color.territoryColor : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: CustomText(
                                isAll ? 'All Products' : category!.name,
                                color: isSelected ? context.color.territoryColor : context.color.textLightColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: context.font.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Subcategories Filter Row
                    BlocBuilder<FetchEcommerceSubcategoriesCubit, FetchEcommerceSubcategoriesState>(
                      builder: (context, subState) {
                        if (subState is FetchEcommerceSubcategoriesSuccess && subState.subcategories.isNotEmpty) {
                          return Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: context.color.backgroundColor,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: subState.subcategories.length + 1,
                              itemBuilder: (context, index) {
                                final isAll = index == 0;
                                final subcategory = isAll ? null : subState.subcategories[index - 1];
                                final isSelected = _selectedSubcategoryId == (subcategory?.id);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSubcategoryId = isAll ? null : subcategory?.id;
                                    });
                                    _fetchProducts();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? context.color.territoryColor.withValues(alpha: 0.1) : context.color.secondaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? context.color.territoryColor : context.color.borderColor.withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: CustomText(
                                      isAll ? 'All' : subcategory!.name,
                                      color: isSelected ? context.color.territoryColor : context.color.textColorDark,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      fontSize: context.font.small,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                );
              }
              if (state is FetchEcommerceCategoriesInProgress) {
                return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
              }
              if (state is FetchEcommerceCategoriesFailure) {
                return SizedBox(height: 50, child: Center(child: Text('Error: ${state.errorMessage}')));
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Products Grid
          Expanded(
            child: BlocBuilder<FetchEcommerceProductsCubit, FetchEcommerceProductsState>(
              builder: (context, state) {
                if (state is FetchEcommerceProductsInProgress) {
                  return Center(child: UiUtils.progress());
                }
                
                if (state is FetchEcommerceProductsFailure) {
                  return Center(child: Text(state.errorMessage));
                }
                
                if (state is FetchEcommerceProductsSuccess) {
                  if (state.products.isEmpty) {
                    return Center(child: CustomText('No products found for this category.'));
                  }
                  
                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.products.length) {
                        return Center(child: UiUtils.progress());
                      }
                      
                      final product = state.products[index];
                      return _buildProductCard(context, product);
                    },
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, EcommerceProductModel product) {
    double minPrice = 0;
    if (product.variants.isNotEmpty) {
      minPrice = product.variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          Routes.ecommerceProductDetails, 
          arguments: {'productId': product.id}
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: context.color.borderColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: context.color.territoryColor.withValues(alpha: 0.05)),
                    UiUtils.imageType(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    product.name,
                    maxLines: 2,
                    fontWeight: FontWeight.w600,
                    fontSize: context.font.normal,
                    color: context.color.textColorDark,
                    height: 1.2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          '\$${minPrice.toStringAsFixed(2)}',
                          fontWeight: FontWeight.bold,
                          fontSize: context.font.large,
                          color: context.color.territoryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.color.territoryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.color.territoryColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_shopping_cart_rounded,
                          color: context.color.secondaryColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
