import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_order_details_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EcommerceOrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const EcommerceOrderDetailsScreen({super.key, required this.orderId});

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => FetchEcommerceOrderDetailsCubit()..fetchOrderDetails(args?['orderId'] ?? 0),
        child: EcommerceOrderDetailsScreen(orderId: args?['orderId'] ?? 0),
      ),
    );
  }

  @override
  State<EcommerceOrderDetailsScreen> createState() => _EcommerceOrderDetailsScreenState();
}

class _EcommerceOrderDetailsScreenState extends State<EcommerceOrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'Order Details',
      ),
      body: BlocBuilder<FetchEcommerceOrderDetailsCubit, FetchEcommerceOrderDetailsState>(
        builder: (context, state) {
          if (state is FetchEcommerceOrderDetailsInProgress || state is FetchEcommerceOrderDetailsInitial) {
            return Center(child: UiUtils.progress());
          }

          if (state is FetchEcommerceOrderDetailsFailure) {
            return Center(child: CustomText(state.errorMessage));
          }

          if (state is FetchEcommerceOrderDetailsSuccess) {
            return _buildOrderDetails(context, state.order);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, EcommerceOrderModel order) {
    String formattedDate = '';
    if (order.createdAt != null) {
      try {
        DateTime parsedDate = DateTime.parse(order.createdAt!);
        formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(parsedDate.toLocal());
      } catch (e) {
        formattedDate = order.createdAt!;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            title: 'Order Information',
            children: [
              _buildInfoRow(context, 'Order ID', order.orderNo ?? ''),
              _buildInfoRow(context, 'Date', formattedDate),
              _buildInfoRow(context, 'Status', _getStatusText(order.status)),
              _buildInfoRow(context, 'Payment Mode', order.paymentMode ?? 'Unknown'),
              if (order.remarks != null && order.remarks!.isNotEmpty)
                _buildInfoRow(context, 'Remarks', order.remarks!),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: 'Shipping Address',
            children: [
              CustomText(order.shippingAddress ?? 'No Address', color: context.color.textColorDark),
              if (order.shippingZipcode != null && order.shippingZipcode!.isNotEmpty)
                CustomText('Zip: ${order.shippingZipcode}', color: context.color.textLightColor),
              if (order.shippingLandmark != null && order.shippingLandmark!.isNotEmpty)
                CustomText('Landmark: ${order.shippingLandmark}', color: context.color.textLightColor),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: 'Billing Address',
            children: [
              CustomText(order.billingAddress ?? 'No Address', color: context.color.textColorDark),
              if (order.billingZipcode != null && order.billingZipcode!.isNotEmpty)
                CustomText('Zip: ${order.billingZipcode}', color: context.color.textLightColor),
              if (order.billingLandmark != null && order.billingLandmark!.isNotEmpty)
                CustomText('Landmark: ${order.billingLandmark}', color: context.color.textLightColor),
            ],
          ),
          const SizedBox(height: 16),
          CustomText('Items', fontSize: context.font.large, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return _buildItemCard(context, item);
            },
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: 'Order Summary',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText('Total Amount', fontWeight: FontWeight.bold, fontSize: context.font.large),
                  CustomText(
                    '\$${order.totalAmount ?? '0.00'}',
                    fontWeight: FontWeight.bold,
                    fontSize: context.font.large,
                    color: context.color.territoryColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.borderColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title, fontWeight: FontWeight.bold, fontSize: context.font.normal),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: CustomText(label, color: context.color.textLightColor)),
          Expanded(
            flex: 3,
            child: CustomText(
              value,
              color: context.color.textColorDark,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, EcommerceOrderItemModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.borderColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 70,
              height: 70,
              child: UiUtils.imageType(item.product?.imageUrl ?? '', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  item.product?.name ?? 'Product',
                  fontWeight: FontWeight.w600,
                  fontSize: context.font.normal,
                  maxLines: 2,
                ),
                if (item.variant != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: CustomText(
                      item.variant?.variantName ?? '',
                      fontSize: context.font.small,
                      color: context.color.textLightColor,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      'Qty: ${item.qty ?? 1}',
                      fontSize: context.font.small,
                      fontWeight: FontWeight.w500,
                    ),
                    CustomText(
                      '\$${item.price ?? '0.00'}',
                      fontSize: context.font.normal,
                      fontWeight: FontWeight.bold,
                      color: context.color.territoryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Unknown';
    switch (status.toUpperCase()) {
      case 'AA':
        return 'Active';
      case 'PP':
        return 'Pending';
      case 'CC':
        return 'Cancelled';
      case 'DD':
        return 'Delivered';
      default:
        return status;
    }
  }
}
