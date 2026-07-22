import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/category.dart';

import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_silver_grid_delegate.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class BrandListScreen extends StatefulWidget {
  final String? from;

  const BrandListScreen({super.key, this.from});

  @override
  State<BrandListScreen> createState() => _BrandListScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => BrandListScreen(from: args?['from']),
    );
  }
}

class _BrandListScreenState extends State<BrandListScreen> {

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> staticBrands = [
      {
        'name': 'Amazon',
        'image': 'assets/brands_logo/amazon.png',
        'url': 'https://www.amazon.in',
      },
      {
        'name': 'FLIPKART',
        'image': 'assets/brands_logo/flipkart.png',
        'url': 'https://www.flipkart.com',
      },
      {
        'name': 'Myntra',
        'image': 'assets/brands_logo/myntra.png',
        'url': 'https://www.myntra.com',
      },
      {
        'name': 'Decathlon',
        'image': 'assets/brands_logo/Decathlon.jpeg',
        'url': 'https://www.decathlon.in/',
      },
      {
        'name': 'Firstcry',
        'image': 'assets/brands_logo/firstcry.png',
        'url': 'https://www.firstcry.com/',
      },
      {
        'name': 'IKEA',
        'image': 'assets/brands_logo/ikea.png',
        'url': 'https://www.ikea.com/in/en/',
      },
      {
        'name': 'Sephora',
        'image': 'assets/brands_logo/sephora.png',
        'url': 'https://sephora.in/',
      },
      {
        'name': 'Uniqlo',
        'image': 'assets/brands_logo/uniqlo.png',
        'url': 'https://www.uniqlo.com/in/en/',
      },
      {
        'name': 'Zara',
        'image': 'assets/brands_logo/Zara.png',
        'url': 'https://www.zara.com/in/',
      },
    ];

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.secondaryColor),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: "Brands",
        ),
        body: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
            crossAxisCount: 3,
            height: MediaQuery.of(context).size.height * 0.18,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final brand = staticBrands[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.brandWebViewScreen,
                  arguments: {
                    'title': brand['name'],
                    'url': brand['url'],
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  border: Border.all(
                      color: context.color.textLightColor.withValues(alpha: 0.23)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: UiUtils.imageType(
                          brand['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        brand['name']!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.color.textColorDark,
                          fontSize: context.font.small,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: staticBrands.length,
        ),
      ),
    );
  }
}
