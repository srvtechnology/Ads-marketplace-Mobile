import 'package:eClassify/app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String? image;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.image,
  });

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => ComingSoonScreen(
        title: args?['title'] ?? 'Coming Soon',
        image: args?['image'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: title,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.contactUs);
              },
              icon: Icon(
                Icons.support_agent,
                color: context.color.textDefaultColor,
                size: 28,
              ),
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                int count = 0;
                if (state is CartSuccess) {
                  count = state.cart.totalItemsCount > 0
                      ? state.cart.totalItemsCount
                      : state.cart.items.fold(0, (sum, i) => sum + i.qty);
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        color: context.color.textDefaultColor,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.ecommerceCart);
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (image != null && image!.isNotEmpty) ...[
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: context.color.territoryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: UiUtils.imageType(
                        image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.color.territoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.color.territoryColor,
                      width: 1,
                    ),
                  ),
                  child: CustomText(
                    "COMING SOON",
                    fontSize: context.font.small,
                    fontWeight: FontWeight.bold,
                    color: context.color.territoryColor,
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(
                  "$title is Coming Soon!",
                  fontSize: context.font.extraLarge,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  color: context.color.textColorDark,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomText(
                    "We are working on integrating $title into our platform. Get ready to explore exclusive products and offers very soon!",
                    fontSize: context.font.large,
                    textAlign: TextAlign.center,
                    color: context.color.textDefaultColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 36),
                UiUtils.buildButton(
                  context,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  buttonTitle: "Explore Other Brands",
                  radius: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
