import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/brands/fetch_brands_cubit.dart';
import 'package:eClassify/data/model/brand_model.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/category.dart';

import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_silver_grid_delegate.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  void initState() {
    super.initState();
    // Fetch if not already loaded
    if (context.read<FetchBrandsCubit>().state is FetchBrandsInitial) {
      context.read<FetchBrandsCubit>().fetchBrands();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: BlocBuilder<FetchBrandsCubit, FetchBrandsState>(
          builder: (context, state) {
            if (state is FetchBrandsInProgress) {
              return UiUtils.progress();
            }
            if (state is FetchBrandsSuccess) {
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                        crossAxisCount: 3,
                        height: MediaQuery.of(context).size.height * 0.18,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        BrandModel brand = state.brands[index];
                        return CategoryCard(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.ecommerceProductList,
                              arguments: {
                                'platformId': brand.id,
                                'brandName': brand.name,
                              },
                            );
                          },
                          title: brand.name,
                          url: brand.image,
                        );
                      },
                      itemCount: state.brands.length,
                    ),
                  ),
                ],
              );
            }

            if (state is FetchBrandsFailure) {
              return Center(
                child: Text(state.errorMessage),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
