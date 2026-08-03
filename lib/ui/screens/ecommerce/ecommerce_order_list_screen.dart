import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_orders_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
// import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EcommerceOrderListScreen extends StatefulWidget {
  const EcommerceOrderListScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => FetchEcommerceOrdersCubit()..fetchOrders(),
        child: const EcommerceOrderListScreen(),
      ),
    );
  }

  @override
  State<EcommerceOrderListScreen> createState() => _EcommerceOrderListScreenState();
}

class _EcommerceOrderListScreenState extends State<EcommerceOrderListScreen> {
  /*
  // Cancel Order functionality commented out
  void _showCancelOrderDialog(BuildContext context, int orderId) {
    final TextEditingController remarksController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Cancel Order', style: TextStyle(color: context.color.textDefaultColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please specify a reason for cancellation:', style: TextStyle(fontSize: 14, color: context.color.textLightColor)),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                hintText: 'Enter reason (e.g. Changed my mind)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.color.forthColor),
            onPressed: () async {
              final remarks = remarksController.text.trim();
              Navigator.of(dialogCtx).pop();
              final success = await context.read<FetchEcommerceOrdersCubit>().cancelOrder(orderId, remarks.isEmpty ? 'Cancelled by user' : remarks);
              if (context.mounted) {
                if (success) {
                  HelperUtils.showSnackBarMessage(context, 'Order cancelled successfully', type: MessageType.success);
                } else {
                  HelperUtils.showSnackBarMessage(context, 'Failed to cancel order', type: MessageType.error);
                }
              }
            },
            child: Text('Confirm Cancel', style: TextStyle(color: context.color.buttonColor)),
          ),
        ],
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'My Orders',
      ),
      body: BlocBuilder<FetchEcommerceOrdersCubit, FetchEcommerceOrdersState>(
        builder: (context, state) {
          if (state is FetchEcommerceOrdersInProgress || state is FetchEcommerceOrdersInitial) {
            return Center(child: UiUtils.progress());
          }

          if (state is FetchEcommerceOrdersFailure) {
            return Center(child: CustomText(state.errorMessage));
          }

          if (state is FetchEcommerceOrdersSuccess) {
            if (state.orders.isEmpty) {
              return Center(child: CustomText('No orders found.', fontSize: context.font.large));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FetchEcommerceOrdersCubit>().fetchOrders();
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, EcommerceOrderModel order) {
    // bool canCancel = order.status == 'AA' || order.status == 'AP' || order.status == 'PP'; // Commented out with cancel order functionality

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.ecommerceOrderDetails,
          arguments: {'orderId': order.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId ?? order.id ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.color.textDefaultColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(context, order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Placed On', style: TextStyle(fontSize: 12, color: context.color.textLightColor)),
                    const SizedBox(height: 2),
                    Text(
                      order.placedOn ?? order.createdAt ?? 'N/A',
                      style: TextStyle(fontSize: 13, color: context.color.textDefaultColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total Amount', style: TextStyle(fontSize: 12, color: context.color.textLightColor)),
                    const SizedBox(height: 2),
                    Text(
                      'Nu. ${order.totalAmount ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 15,
                        color: context.color.territoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.ecommerceOrderDetails,
                      arguments: {'orderId': order.id},
                    );
                  },
                  icon: Icon(Icons.visibility_outlined, size: 16, color: context.color.territoryColor),
                  label: Text('View Details', style: TextStyle(color: context.color.territoryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                /*
                // Cancel Order button commented out
                if (canCancel && order.id != null)
                  TextButton.icon(
                    onPressed: () => _showCancelOrderDialog(context, order.id!),
                    icon: Icon(Icons.cancel_outlined, size: 16, color: context.color.forthColor),
                    label: Text('Cancel Order', style: TextStyle(color: context.color.forthColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                */
              ],
            ),
          ],
        ),
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

  Color _getStatusColor(BuildContext context, String? status) {
    if (status == null) return Colors.orange;
    switch (status.toUpperCase()) {
      case 'AA':
      case 'AP':
        return Colors.blue;
      case 'RE':
      case 'SHIPPED':
      case 'OUT':
        return Colors.deepPurple;
      case 'DELIVERED':
        return Colors.green;
      case 'CAN':
      case 'CC':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
