import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/category_home_card.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class BrandWidgetHome extends StatelessWidget {
  const BrandWidgetHome({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> staticBrands = [
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
      {
        'name': 'Lacoste',
        'image': 'assets/brands_logo/lacoste-seeklogo.png',
        'url': 'https://www.lacoste.in/',
      },
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
        'image': 'assets/brands_logo/myntra.jpg',
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
        'name': 'Snitch',
        'image': 'assets/brands_logo/Snitch.png',
        'url': 'https://www.snitch.com/',
      },
      {
        'name': 'Rare Rabbit',
        'image': 'assets/brands_logo/rare_rabbit.jpeg',
        'url': 'https://thehouseofrare.com/',
      },
      {
        'name': 'The Bear House',
        'image': 'assets/brands_logo/the_bear houses.jpeg',
        'url': 'https://thebearhouse.com/',
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeader(
          title: "Browse by brands",
          onTap: () {
            Navigator.pushNamed(context, Routes.brands,
                arguments: {"from": Routes.home});
          },
        ),
        SizedBox(
          width: context.screenWidth,
          height: 103,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final brand = staticBrands[index];
              return CategoryHomeCard(
                title: brand['name']!,
                url: brand['image']!,
                onTap: () {
                  if (brand['isComingSoon'] == 'true' || brand['url'] == 'coming_soon') {
                    Navigator.pushNamed(
                      context,
                      Routes.comingSoonScreen,
                      arguments: {
                        'title': brand['name'],
                        'image': brand['image'],
                      },
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      Routes.brandWebViewScreen,
                      arguments: {
                        'title': brand['name'],
                        'url': brand['url'],
                      },
                    );
                  }
                },
              );
            },
            itemCount: staticBrands.length,
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 12,
              );
            },
          ),
        ),
      ],
    );
  }
}
