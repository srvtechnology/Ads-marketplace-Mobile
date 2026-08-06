import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_order_details_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final paymentDetail = order.paymentDetail;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header Summary
          _buildInfoCard(
            context,
            title: 'Order Summary',
            children: [
              _buildInfoRow(context, 'Order ID', '#${order.orderId ?? order.id ?? ''}'),
              _buildInfoRow(context, 'Placed On', order.placedOn ?? order.createdAt ?? 'N/A'),
              _buildInfoRow(context, 'Status', _getStatusText(order.status)),
              _buildInfoRow(context, 'Payment Mode', order.paymentMode ?? 'Unknown'),
              if (order.deliveryOtp != null && order.deliveryOtp!.isNotEmpty)
                _buildInfoRow(context, 'Delivery OTP', order.deliveryOtp!),
              if (order.remarks != null && order.remarks!.isNotEmpty)
                _buildInfoRow(context, 'Remarks', order.remarks!),
            ],
          ),
          const SizedBox(height: 16),

          // Customer & Shipping Info
          _buildInfoCard(
            context,
            title: 'Shipping & Contact Details',
            children: [
              if (order.name != null && order.name!.isNotEmpty)
                _buildInfoRow(context, 'Customer Name', order.name!),
              if (order.mobile != null && order.mobile!.isNotEmpty)
                _buildInfoRow(context, 'Mobile', '${order.countryCode ?? "+975"} ${order.mobile}'),
              if (order.email != null && order.email!.isNotEmpty)
                _buildInfoRow(context, 'Email', order.email!),
              _buildInfoRow(context, 'Shipping Address', order.shippingAddress ?? 'N/A'),
              if (order.shippingZipcode != null && order.shippingZipcode!.isNotEmpty)
                _buildInfoRow(context, 'Zipcode', order.shippingZipcode!),
              if (order.shippingLandmark != null && order.shippingLandmark!.isNotEmpty)
                _buildInfoRow(context, 'Landmark', order.shippingLandmark!),
            ],
          ),
          const SizedBox(height: 16),

          // Items List
          Text('Ordered Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.color.textDefaultColor)),
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
          const SizedBox(height: 16),

          // Payment Detail Breakdown
          if (paymentDetail != null)
            _buildInfoCard(
              context,
              title: 'Payment Details Breakdown',
              children: [
                _buildPaymentRow('Items Subtotal', 'Nu. ${paymentDetail.itemsSubtotal.toStringAsFixed(2)}', context),
                _buildPaymentRow('Service Charge', 'Nu. ${paymentDetail.totalServiceCharge.toStringAsFixed(2)}', context),
                _buildPaymentRow('Delivery Charge', 'Nu. ${paymentDetail.totalDeliveryCharge.toStringAsFixed(2)}', context),
                _buildPaymentRow('Shipment Charge', 'Nu. ${paymentDetail.totalShipmentCharge.toStringAsFixed(2)}', context),
                _buildPaymentRow('GST Amount', 'Nu. ${paymentDetail.totalGstAmount.toStringAsFixed(2)}', context),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.color.textDefaultColor)),
                    Text(
                      'Nu. ${paymentDetail.grandTotal.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.color.territoryColor),
                    ),
                  ],
                ),
              ],
            )
          else
            _buildInfoCard(
              context,
              title: 'Payment Summary',
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.color.textDefaultColor)),
                    Text(
                      'Nu. ${order.totalAmount ?? '0.00'}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.color.territoryColor),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.color.textDefaultColor)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 13, color: context.color.textLightColor))),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: context.color.textDefaultColor, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: context.color.textLightColor)),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.color.textDefaultColor)),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, EcommerceOrderItemModel item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 65,
                  height: 65,
                  child: UiUtils.imageType(item.image ?? item.product?.imageUrl ?? '', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? item.product?.name ?? 'Product',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.color.textDefaultColor,
                      ),
                    ),
                    if (item.displayVariantDetails != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.displayVariantDetails!,
                          style: TextStyle(fontSize: 12, color: context.color.textLightColor),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qty: ${item.qty ?? 1}', style: TextStyle(fontSize: 13, color: context.color.textLightColor)),
                        Text(
                          'Nu. ${item.finalAmount > 0 ? item.finalAmount.toStringAsFixed(2) : (item.price ?? "0.00")}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.color.territoryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.sourceUrl != null && item.sourceUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () async {
                  final Uri uri = Uri.parse(item.sourceUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link, size: 16, color: context.color.territoryColor),
                    const SizedBox(width: 4),
                    Text(
                      'View Original Product Source',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.color.territoryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Awaiting';
    switch (status.toUpperCase()) {
      case 'AA':
        return 'Awaiting';
      case 'AP':
        return 'Approved';
      case 'RE':
        return 'Reserved';
      case 'SHIPPED':
        return 'Shipped';
      case 'OUT':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'CAN':
      case 'CC':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
