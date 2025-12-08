import 'package:eClassify/data/cubits/subscription/assign_free_package_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/data/model/subscription_package_model.dart';
import 'package:eClassify/ui/screens/payment/bfs_payment_screen.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/currency_formatter.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturedAdsSubscriptionPlansItem extends StatefulWidget {
  final List<SubscriptionPackageModel> modelList;

  const FeaturedAdsSubscriptionPlansItem({
    super.key,
    required this.modelList,
  });

  @override
  _FeaturedAdsSubscriptionPlansItemState createState() =>
      _FeaturedAdsSubscriptionPlansItemState();
}

class _FeaturedAdsSubscriptionPlansItemState
    extends State<FeaturedAdsSubscriptionPlansItem> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
  }

  Widget mainUi() {
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Card(
        color: context.color.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            UiUtils.getSvg(AppIcons.featuredAdsIcon),
            SizedBox(
              height: 35,
            ),
            CustomText(
              "featureItem".translate(context),
              fontWeight: FontWeight.w600,
              fontSize: context.font.larger,
            ),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  itemBuilder: (context, index) {
                    return itemData(index);
                  },
                  itemCount: widget.modelList.length),
            ),
            if (selectedIndex != null)
              BlocListener<AssignFreePackageCubit, AssignFreePackageState>(
                listener: (context, state) {
                  if (state is AssignFreePackageInSuccess) {
                    Widgets.hideLoder(context);
                    HelperUtils.showSnackBarMessage(
                        context, state.responseMessage);
                    Navigator.pop(context);
                  }
                  if (state is AssignFreePackageFailure) {
                    Widgets.hideLoder(context);
                    HelperUtils.showSnackBarMessage(
                        context, state.error.toString());
                  }
                  if (state is AssignFreePackageInProgress) {
                    Widgets.showLoader(context);
                  }
                },
                child: UiUtils.buildButton(context, onPressed: () {
                  UiUtils.checkUser(
                      onNotGuest: () {
                        if (!widget.modelList[selectedIndex!].isActive!) {
                          if (widget.modelList[selectedIndex!].finalPrice! >
                              0) {
                            // BFS Payment
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => BfsPaymentScreen(
                                  itemId: widget.modelList[selectedIndex!].id
                                      .toString(),
                                  packageName:
                                      widget.modelList[selectedIndex!].name ??
                                          '',
                                  price: widget
                                      .modelList[selectedIndex!].finalPrice!
                                      .toDouble(),
                                ),
                              ),
                            )
                                .then((value) {
                              if (value == true) {
                                HelperUtils.showSnackBarMessage(
                                    context, "Payment Successful",
                                    type: MessageType.success);
                                // Refresh logic if needed or pop
                              }
                            });
                          } else {
                            context
                                .read<AssignFreePackageCubit>()
                                .assignFreePackage(
                                    packageId:
                                        widget.modelList[selectedIndex!].id!);
                          }
                        }
                      },
                      context: context);
                },
                    radius: 10,
                    height: 46,
                    fontSize: context.font.large,
                    buttonColor: widget.modelList[selectedIndex!].isActive!
                        ? context.color.textLightColor.withValues(alpha: 0.01)
                        : context.color.territoryColor,
                    textColor: widget.modelList[selectedIndex!].isActive!
                        ? context.color.textDefaultColor.withValues(alpha: 0.5)
                        : context.color.secondaryColor,
                    buttonTitle: widget.modelList[selectedIndex!].finalPrice! >
                            0
                        ? "Purchase - ${widget.modelList[selectedIndex!].finalPrice!.currencyFormat}"
                        : "purchaseThisPackage".translate(context),
                    outerPadding: const EdgeInsets.all(20)),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AssignFreePackageCubit(),
        ),
      ],
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          body: mainUi(),
        ),
      ),
    );
  }

  Widget itemData(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          if (widget.modelList[index].isActive!)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 13.0),
              child: ClipPath(
                clipper: CapShapeClipper(),
                child: Container(
                  color: context.color.territoryColor,
                  width: MediaQuery.of(context).size.width / 3,
                  height: 17,
                  padding: EdgeInsets.only(top: 3),
                  child: CustomText('activePlanLbl'.translate(context),
                      color: context.color.secondaryColor,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
              ),
            ),
          InkWell(
            onTap: !widget.modelList[index].isActive!
                ? () {
                    setState(() {
                      selectedIndex = index;
                    });
                  }
                : null,
            child: Container(
              margin: EdgeInsets.only(top: 17),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                      color: widget.modelList[index].isActive! ||
                              index == selectedIndex
                          ? context.color.territoryColor
                          : context.color.textDefaultColor
                              .withValues(alpha: 0.13),
                      width: 1.5)),
              child: !widget.modelList[index].isActive!
                  ? adsWidget(index)
                  : activeAdsWidget(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget adsWidget(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                widget.modelList[index].name!,
                firstUpperCaseWidget: true,
                fontWeight: FontWeight.w600,
                fontSize: context.font.large,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    '${widget.modelList[index].limit == "unlimited" ? "unlimitedLbl".translate(context) : widget.modelList[index].limit.toString()}\t${"itemsLbl".translate(context)}\t\t·\t\t',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    color:
                        context.color.textDefaultColor.withValues(alpha: 0.5),
                  ),
                  Flexible(
                    child: CustomText(
                      '${widget.modelList[index].duration.toString()}\t${"days".translate(context)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      color:
                          context.color.textDefaultColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: CustomText(
            widget.modelList[index].finalPrice! > 0
                ? widget.modelList[index].finalPrice!.currencyFormat
                : "free".translate(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget activeAdsWidget(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                widget.modelList[index].name!,
                firstUpperCaseWidget: true,
                fontWeight: FontWeight.w600,
                fontSize: context.font.large,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: widget.modelList[index].limit == "unlimited"
                          ? "${"unlimitedLbl".translate(context)}\t${"itemsLbl".translate(context)}\t\t·\t\t"
                          : '',
                      style: TextStyle(
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.5),
                      ),
                      children: [
                        if (widget.modelList[index].limit != "unlimited")
                          TextSpan(
                            text:
                                '${widget.modelList[index].userPurchasedPackages![0].remainingItemLimit}',
                            style: TextStyle(
                                color: context.color.textDefaultColor),
                          ),
                        if (widget.modelList[index].limit != "unlimited")
                          TextSpan(
                            text:
                                '/${widget.modelList[index].limit.toString()}\t${"itemsLbl".translate(context)}\t\t·\t\t',
                          ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: widget.modelList[index].duration == "unlimited"
                            ? "${"unlimitedLbl".translate(context)}\t${"days".translate(context)}"
                            : '',
                        style: TextStyle(
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.5),
                        ),
                        children: [
                          if (widget.modelList[index].duration != "unlimited")
                            TextSpan(
                              text:
                                  '${widget.modelList[index].userPurchasedPackages![0].remainingDays}',
                              style: TextStyle(
                                  color: context.color.textDefaultColor),
                            ),
                          if (widget.modelList[index].duration != "unlimited")
                            TextSpan(
                              text:
                                  '/${widget.modelList[index].duration.toString()}\t${"days".translate(context)}',
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: CustomText(
            widget.modelList[index].finalPrice! > 0
                ? "${Constant.currencySymbol}${widget.modelList[index].finalPrice.toString()}"
                : "free".translate(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path
      ..moveTo(size.width / 2, 0) // moving to topCenter 1st, then draw the path
      ..lineTo(size.width, size.height * .25)
      ..lineTo(size.width, size.height * .75)
      ..lineTo(size.width * .5, size.height)
      ..lineTo(0, size.height * .75)
      ..lineTo(0, size.height * .25)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CapShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..cubicTo(
        size.width * 0.15,
        size.height,
        size.width * 0.1,
        size.height * 0.1,
        size.width * 0.25,
        size.height * 0.1,
      )
      ..lineTo(size.width * 0.75, size.height * 0.1)
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.1,
        size.width * 0.85,
        size.height,
        size.width,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
