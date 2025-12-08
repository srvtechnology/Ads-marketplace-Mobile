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
import 'package:intl/intl.dart' as intl;

class ItemListingSubscriptionPlansItem extends StatefulWidget {
  final int itemIndex, index;
  final SubscriptionPackageModel model;

  const ItemListingSubscriptionPlansItem({
    super.key,
    required this.itemIndex,
    required this.index,
    required this.model,
  });

  @override
  _ItemListingSubscriptionPlansItemState createState() =>
      _ItemListingSubscriptionPlansItemState();
}

class _ItemListingSubscriptionPlansItemState
    extends State<ItemListingSubscriptionPlansItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        bottomNavigationBar: bottomWidget(),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AssignFreePackageCubit(),
            ),
          ],
          child: Builder(builder: (context) {
            return BlocListener<AssignFreePackageCubit, AssignFreePackageState>(
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
              child: Padding(
                padding: EdgeInsets.only(
                    top: (widget.index == widget.itemIndex) ? 40 : 70,
                    bottom: (widget.index == widget.itemIndex) ? 100 : 120),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (widget.model.isActive!)
                      ClipPath(
                        clipper: CapShapeClipper(),
                        child: Container(
                          alignment: Alignment.center,
                          color: context.color.territoryColor,
                          width: MediaQuery.of(context).size.width / 1.6,
                          height: 33,
                          padding: EdgeInsets.only(top: 3),
                          child: CustomText('activePlanLbl'.translate(context),
                              color: context.color.secondaryColor,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                        ),
                      ),
                    Card(
                      color: context.color.secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                              color: widget.model.isActive!
                                  ? context.color.territoryColor
                                  : context.color.secondaryColor,
                              width: 1.5)),
                      elevation: 0,
                      margin: EdgeInsets.fromLTRB(14, 33, 14, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 50),
                          ClipPath(
                            clipper: HexagonClipper(),
                            child: Container(
                              width: 100,
                              height: 110,
                              padding: EdgeInsets.all(30),
                              color: context.color.primaryColor,
                              child: UiUtils.imageType(widget.model.icon!,
                                  fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(height: 18),
                          widget.model.isActive! && widget.model.finalPrice! > 0
                              ? activeAdsData()
                              : adsData(),
                          const Spacer(),
                          CustomText(
                            widget.model.finalPrice! > 0
                                ? widget.model.finalPrice!.currencyFormat
                                : "free".translate(context),
                            fontSize: context.font.xxLarge,
                            fontWeight: FontWeight.bold,
                            color: context.color.textDefaultColor,
                          ),
                          if (widget.model.discount! > 0)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomText(
                                    "${widget.model.discount}%\t${"OFF".translate(context)}",
                                    color: context.color.forthColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    " ${Constant.currencySymbol}${widget.model.price.toString()}",
                                    style: const TextStyle(
                                        decoration: TextDecoration.lineThrough),
                                  )
                                ],
                              ),
                            ),
                          UiUtils.buildButton(context, onPressed: () {
                            UiUtils.checkUser(
                                onNotGuest: () {
                                  if (!widget.model.isActive!) {
                                    if (widget.model.finalPrice! > 0) {
                                      // BFS Payment
                                      Navigator.of(context)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BfsPaymentScreen(
                                            itemId: widget.model.id.toString(),
                                            packageName:
                                                widget.model.name ?? '',
                                            price: widget.model.finalPrice!
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
                                              packageId: widget.model.id!);
                                    }
                                  }
                                },
                                context: context);
                          },
                              radius: 10,
                              height: 46,
                              fontSize: context.font.large,
                              buttonColor: widget.model.isActive!
                                  ? context.color.textLightColor
                                      .withValues(alpha: 0.01)
                                  : context.color.territoryColor,
                              textColor: widget.model.isActive!
                                  ? context.color.textDefaultColor
                                      .withValues(alpha: 0.5)
                                  : context.color.secondaryColor,
                              buttonTitle: widget.model.isActive ?? false
                                  ? "purchased".translate(context)
                                  : "purchaseThisPackage".translate(context),
                              outerPadding: const EdgeInsets.all(20))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget adsData() {
    return Expanded(
      flex: 10,
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          CustomText(
            widget.model.name!,
            firstUpperCaseWidget: true,
            fontWeight: FontWeight.w600,
            fontSize: context.font.larger,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          if (widget.model.type == "item_listing")
            checkmarkPoint(context,
                "${widget.model.limit == "unlimited" ? "unlimitedLbl".translate(context) : widget.model.limit.toString()}\t${"itemsListing".translate(context)}"),
          if (widget.model.type == "advertisement")
            checkmarkPoint(context,
                "${widget.model.limit == "unlimited" ? "unlimitedLbl".translate(context) : widget.model.limit.toString()}\t${"featuredItemsListing".translate(context)}"),
          checkmarkPoint(context,
              "${widget.model.duration.toString()}\t${"days".translate(context)}"),
          if (widget.model.description != null &&
              widget.model.description != "") ...[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  widget.model.description!,
                  textAlign: TextAlign.start,
                  color: context.color.textDefaultColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget activeAdsData() {
    return Expanded(
      flex: 10,
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          CustomText(
            widget.model.name!,
            firstUpperCaseWidget: true,
            fontWeight: FontWeight.w600,
            fontSize: context.font.larger,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          if (widget.model.type == "item_listing")
            checkmarkPoint(context,
                "${widget.model.userPurchasedPackages![0].remainingItemLimit}/${widget.model.limit == "unlimited" ? "unlimitedLbl".translate(context) : widget.model.limit.toString()}\t${"itemsListing".translate(context)}"),
          if (widget.model.type == "advertisement")
            checkmarkPoint(context,
                "${widget.model.userPurchasedPackages![0].remainingItemLimit}/${widget.model.limit == "unlimited" ? "unlimitedLbl".translate(context) : widget.model.limit.toString()}\t${"featuredItemsListing".translate(context)}"),
          checkmarkPoint(context,
              "${widget.model.userPurchasedPackages![0].remainingDays}/${widget.model.duration.toString()}\t${"days".translate(context)}"),
          if (widget.model.description != null &&
              widget.model.description != "")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    widget.model.description!,
                    color:
                        context.color.textDefaultColor.withValues(alpha: 0.7),
                    textAlign: TextAlign.start,
                  )),
            ),
        ],
      ),
    );
  }

  SingleChildRenderObjectWidget bottomWidget() {
    if (widget.model.isActive! &&
        widget.model.finalPrice! > 0 &&
        widget.model.userPurchasedPackages != null &&
        widget.model.userPurchasedPackages![0].endDate != null) {
      DateTime dateTime =
          DateTime.parse(widget.model.userPurchasedPackages![0].endDate!);
      String formattedDate = intl.DateFormat.yMMMMd().format(dateTime);
      return Padding(
        padding: EdgeInsetsDirectional.only(
            bottom: 15.0,
            start: 15,
            end: 15), // EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: CustomText(
            "${"yourSubscriptionWillExpireOn".translate(context)} $formattedDate"),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget circlePoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.start,
        // width: context.screenWidth * 0.55,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 2.0),
            child: Icon(
              Icons.circle_rounded,
              size: 8,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
              child: CustomText(
            text,
            textAlign: TextAlign.start,
            color: context.color.textDefaultColor,
          )),
        ],
      ),
    );
  }

  Widget checkmarkPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        // width: context.screenWidth * 0.55,
        children: [
          UiUtils.getSvg(
            AppIcons.active_mark,
          ),
          SizedBox(width: 8),
          Expanded(
              child: CustomText(
            text,
            textAlign: TextAlign.start,
          )),
        ],
      ),
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
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
