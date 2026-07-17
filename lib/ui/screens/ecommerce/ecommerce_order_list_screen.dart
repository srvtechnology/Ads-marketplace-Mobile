import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_orders_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
              return Center(child: CustomText('No orders found.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderCard(context, order);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, EcommerceOrderModel order) {
    String formattedDate = '';
    if (order.createdAt != null) {
      try {
        DateTime parsedDate = DateTime.parse(order.createdAt!);
        formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(parsedDate.toLocal());
      } catch (e) {
        formattedDate = order.createdAt!;
      }
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  'Order #${order.orderNo ?? ''}',
                  fontWeight: FontWeight.bold,
                  fontSize: context.font.normal,
                  color: context.color.textColorDark,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomText(
                    _getStatusText(order.status),
                    fontSize: context.font.small,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(context, order.status),
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
                    CustomText(
                      'Date',
                      fontSize: context.font.small,
                      color: context.color.textLightColor,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      formattedDate,
                      fontSize: context.font.small,
                      color: context.color.textColorDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      'Total Amount',
                      fontSize: context.font.small,
                      color: context.color.textLightColor,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      '\$${order.totalAmount ?? '0.00'}',
                      fontSize: context.font.normal,
                      color: context.color.territoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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

  Color _getStatusColor(BuildContext context, String? status) {
    if (status == null) return context.color.textLightColor;
    switch (status.toUpperCase()) {
      case 'AA':
        return Colors.blue;
      case 'PP':
        return Colors.orange;
      case 'CC':
        return Colors.red;
      case 'DD':
        return Colors.green;
      default:
        return context.color.textLightColor;
    }
  }
}
