import 'package:eClassify/data/cubits/brands/fetch_brands_cubit.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/category_home_card.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';

class BrandWidgetHome extends StatelessWidget {
  const BrandWidgetHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchBrandsCubit, FetchBrandsState>(
      builder: (context, state) {
        if (state is FetchBrandsSuccess) {
          if (state.brands.isEmpty) return SizedBox.shrink();
          
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
                    return CategoryHomeCard(
                      title: state.brands[index].name,
                      url: state.brands[index].image,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.ecommerceProductList,
                          arguments: {
                            'platformId': state.brands[index].id,
                            'brandName': state.brands[index].name,
                          },
                        );
                      },
                    );
                  },
                  itemCount: state.brands.length,
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
        
        if (state is FetchBrandsInProgress) {
          return Padding(
            padding: const EdgeInsets.all(sidePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomShimmer(
                  height: 20,
                  width: 150,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 103,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: const CustomShimmer(
                                height: 70,
                                width: 70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const CustomShimmer(
                              height: 10,
                              width: 50,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
