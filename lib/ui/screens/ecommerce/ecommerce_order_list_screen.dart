import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_orders_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/ecommerce_order_status_helper.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 64, color: context.color.textLightColor),
                    const SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.color.textDefaultColor,
                      ),
                    ),
                  ],
                ),
              );
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
    final status = order.status ?? order.deliveryStatus;

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Order #${order.orderId ?? order.id ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.color.textDefaultColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (status != null && status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: EcommerceOrderStatusHelper.getStatusColor(context, status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    EcommerceOrderStatusHelper.getStatusText(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: EcommerceOrderStatusHelper.getStatusColor(context, status),
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
            ],
          ),
        ],
      ),
    );
  }
}

