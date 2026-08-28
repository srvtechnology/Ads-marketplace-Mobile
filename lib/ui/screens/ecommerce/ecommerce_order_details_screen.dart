import 'package:eClassify/data/cubits/ecommerce/fetch_ecommerce_order_details_cubit.dart';
import 'package:eClassify/data/model/ecommerce/ecommerce_order_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/ecommerce_order_status_helper.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isCancelling = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HelperUtils.showSnackBarMessage(
      context,
      '$label copied to clipboard',
      type: MessageType.success,
    );
  }

  void _showCancelOrderDialog(BuildContext context, EcommerceOrderModel order) {
    final TextEditingController remarksController = TextEditingController();
    String selectedReason = '';
    final List<String> quickReasons = [
      'Wrong item selected by mistake',
      'Delivery taking too long',
      'Found a better price elsewhere',
      'Changed my mind',
      'Other reason',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.color.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cancel Order #${order.orderId ?? order.id}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.color.textDefaultColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Please provide a reason for cancelling this order.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.color.textLightColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Text(
                      'Select a reason',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.color.textDefaultColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickReasons.map((reason) {
                        final isSelected = selectedReason == reason;
                        return ChoiceChip(
                          label: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : context.color.textDefaultColor,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: context.color.territoryColor,
                          backgroundColor: context.color.backgroundColor,
                          side: BorderSide(
                            color: isSelected ? context.color.territoryColor : Colors.grey.withValues(alpha: 0.2),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: (selected) {
                            setModalState(() {
                              selectedReason = selected ? reason : '';
                              if (selected && reason != 'Other reason') {
                                remarksController.text = reason;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Cancellation Remarks / Notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.color.textDefaultColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: remarksController,
                      maxLines: 3,
                      style: TextStyle(fontSize: 13, color: context.color.textDefaultColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your cancellation remarks here...',
                        hintStyle: TextStyle(fontSize: 13, color: context.color.textLightColor),
                        filled: true,
                        fillColor: context.color.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.color.territoryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                            ),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                            child: Text(
                              'Keep Order',
                              style: TextStyle(color: context.color.textDefaultColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isCancelling
                                ? null
                                : () async {
                                    final String remarks = remarksController.text.trim().isNotEmpty
                                        ? remarksController.text.trim()
                                        : (selectedReason.isNotEmpty ? selectedReason : 'Customer requested cancellation');

                                    Navigator.pop(bottomSheetContext);
                                    setState(() => _isCancelling = true);

                                    final cubit = context.read<FetchEcommerceOrderDetailsCubit>();
                                    final result = await cubit.cancelOrder(order.id ?? widget.orderId, remarks);

                                    if (mounted) {
                                      setState(() => _isCancelling = false);
                                      if (result['success'] == true) {
                                        HelperUtils.showSnackBarMessage(
                                          context,
                                          result['message']?.toString() ?? 'Order cancelled successfully',
                                          type: MessageType.success,
                                        );
                                      } else {
                                        HelperUtils.showSnackBarMessage(
                                          context,
                                          result['message']?.toString() ?? 'Failed to cancel order',
                                          type: MessageType.error,
                                        );
                                      }
                                    }
                                  },
                            child: _isCancelling
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Cancel Order',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'Order Details',
        actions: [
          IconButton(
            tooltip: 'Refresh Order',
            icon: Icon(Icons.refresh, color: context.color.textDefaultColor),
            onPressed: () {
              context.read<FetchEcommerceOrderDetailsCubit>().fetchOrderDetails(widget.orderId);
            },
          ),
        ],
      ),
      body: BlocBuilder<FetchEcommerceOrderDetailsCubit, FetchEcommerceOrderDetailsState>(
        builder: (context, state) {
          if (state is FetchEcommerceOrderDetailsInProgress || state is FetchEcommerceOrderDetailsInitial) {
            return Center(child: UiUtils.progress());
          }

          if (state is FetchEcommerceOrderDetailsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: context.color.textLightColor),
                    const SizedBox(height: 12),
                    CustomText(state.errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.territoryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        context.read<FetchEcommerceOrderDetailsCubit>().fetchOrderDetails(widget.orderId);
                      },
                      child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is FetchEcommerceOrderDetailsSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FetchEcommerceOrderDetailsCubit>().fetchOrderDetails(widget.orderId);
              },
              child: _buildOrderDetails(context, state.order),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, EcommerceOrderModel order) {
    final paymentDetail = order.paymentDetail;
    final bfsTxn = order.bfsTransaction;
    final orderStatus = order.status ?? order.deliveryStatus;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Primary Order Header & Status Card
          _buildOrderHeaderCard(context, order, orderStatus),
          const SizedBox(height: 14),

          // 2. Delivery OTP Card (if available)
          if (order.deliveryOtp != null && order.deliveryOtp!.trim().isNotEmpty) ...[
            _buildDeliveryOtpCard(context, order.deliveryOtp!.trim()),
            const SizedBox(height: 14),
          ],

          // 3. Order-level Remarks / Special Instructions Card (if available)
          if (order.remarks != null && order.remarks!.trim().isNotEmpty) ...[
            _buildRemarksCard(
              context,
              title: 'Order Remarks & Special Instructions',
              remarks: order.remarks!.trim(),
              icon: Icons.speaker_notes_outlined,
              badgeColor: context.color.territoryColor,
            ),
            const SizedBox(height: 14),
          ],

          // 4. Status Remarks Card (if present from admin/delivery)
          if (order.statusRemarks != null && order.statusRemarks!.trim().isNotEmpty) ...[
            _buildRemarksCard(
              context,
              title: 'Status Update Notes',
              remarks: order.statusRemarks!.trim(),
              icon: Icons.info_outline,
              badgeColor: Colors.blue,
            ),
            const SizedBox(height: 14),
          ],

          // 5. BFS Online Payment Transaction Details (if available)
          if (bfsTxn != null || (order.paymentMode?.toUpperCase() == 'ONLINE' && order.checkoutBfsTransactionId != null)) ...[
            _buildBfsTransactionCard(context, order, bfsTxn),
            const SizedBox(height: 14),
          ],

          // 6. Customer & Shipping / Billing Information Card
          _buildCustomerAndShippingCard(context, order),
          const SizedBox(height: 18),

          // 7. Ordered Items Section Header & List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ordered Items (${order.items.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.color.textDefaultColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 18),

          // 8. Payment Breakdown Card
          _buildPaymentSummaryCard(context, order, paymentDetail),
          const SizedBox(height: 20),

          // 9. Cancel Order Button (if order is cancellable)
          if (order.isCancellable) ...[
            _buildCancelOrderButton(context, order),
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrderHeaderCard(BuildContext context, EcommerceOrderModel order, String? orderStatus) {
    final displayOrderId = order.orderId ?? order.id?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '#$displayOrderId',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: context.color.textDefaultColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _copyToClipboard(displayOrderId, 'Order ID'),
                      child: Icon(Icons.copy_rounded, size: 16, color: context.color.textLightColor),
                    ),
                  ],
                ),
              ),
              if (orderStatus != null && orderStatus.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EcommerceOrderStatusHelper.getStatusColor(context, orderStatus).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: EcommerceOrderStatusHelper.getStatusColor(context, orderStatus).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    EcommerceOrderStatusHelper.getStatusText(orderStatus),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: EcommerceOrderStatusHelper.getStatusColor(context, orderStatus),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Placed On', order.placedOn ?? order.createdAt ?? 'N/A', icon: Icons.calendar_today_outlined),
          _buildInfoRow(
            context,
            'Payment Mode',
            order.paymentMode?.toUpperCase() == 'ONLINE' ? 'ONLINE (BFS Gateway)' : (order.paymentMode ?? 'Cash On Delivery'),
            icon: Icons.payments_outlined,
          ),
          if (order.deliveryStatus != null && order.deliveryStatus!.isNotEmpty && order.deliveryStatus != order.status)
            _buildInfoRow(
              context,
              'Delivery Status',
              EcommerceOrderStatusHelper.getStatusText(order.deliveryStatus),
              icon: Icons.local_shipping_outlined,
            ),
          if (order.deliveryDate != null && order.deliveryDate!.isNotEmpty)
            _buildInfoRow(
              context,
              'Expected Delivery',
              order.deliveryDate!,
              icon: Icons.event_available_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOtpCard(BuildContext context, String otp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.color.territoryColor.withValues(alpha: 0.12),
            context.color.territoryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.color.territoryColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: context.color.territoryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery Verification OTP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.color.territoryColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _copyToClipboard(otp, 'Delivery OTP'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.color.territoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 13, color: context.color.territoryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.color.territoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.color.territoryColor.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                otp.split('').join('  '),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: context.color.territoryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this OTP with the delivery agent only upon receiving your package.',
            style: TextStyle(
              fontSize: 11.5,
              color: context.color.textLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksCard(
    BuildContext context, {
    required String title,
    required String remarks,
    required IconData icon,
    required Color badgeColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: badgeColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            remarks,
            style: TextStyle(
              fontSize: 13,
              color: context.color.textDefaultColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBfsTransactionCard(BuildContext context, EcommerceOrderModel order, BfsTransactionModel? bfsTxn) {
    final status = bfsTxn?.status?.toUpperCase() ?? '';

    return _buildInfoCard(
      context,
      title: 'BFS Online Payment Details',
      headerIcon: Icons.account_balance_outlined,
      children: [
        if (bfsTxn?.bfsTxnId != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text('BFS Txn ID', style: TextStyle(fontSize: 13, color: context.color.textLightColor)),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          bfsTxn!.bfsTxnId!,
                          style: TextStyle(fontSize: 13, color: context.color.textDefaultColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _copyToClipboard(bfsTxn.bfsTxnId!, 'BFS Txn ID'),
                        child: Icon(Icons.copy_rounded, size: 14, color: context.color.textLightColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (bfsTxn?.bankId != null && bfsTxn!.bankId!.isNotEmpty)
          _buildInfoRow(context, 'Bank ID / Code', bfsTxn.bankId!),
        if (bfsTxn?.accountNo != null && bfsTxn!.accountNo!.isNotEmpty)
          _buildInfoRow(context, 'Account Number', bfsTxn.accountNo!),
        if (status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Payment Status', style: TextStyle(fontSize: 13, color: context.color.textLightColor)),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (status == 'COMPLETED' ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: status == 'COMPLETED' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (bfsTxn?.responseDesc != null && bfsTxn!.responseDesc!.isNotEmpty)
          _buildInfoRow(context, 'Gateway Response', bfsTxn.responseDesc!),
        if (bfsTxn != null && bfsTxn.amount > 0)
          _buildInfoRow(context, 'Paid Amount', 'Nu. ${bfsTxn.amount.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildCustomerAndShippingCard(BuildContext context, EcommerceOrderModel order) {
    return _buildInfoCard(
      context,
      title: 'Customer & Delivery Information',
      headerIcon: Icons.location_on_outlined,
      children: [
        if (order.name != null && order.name!.isNotEmpty)
          _buildInfoRow(context, 'Customer Name', order.name!, icon: Icons.person_outline),
        if (order.mobile != null && order.mobile!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: context.color.textLightColor),
                      const SizedBox(width: 6),
                      Text('Mobile', style: TextStyle(fontSize: 13, color: context.color.textLightColor)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () async {
                      final uri = Uri.parse('tel:${order.countryCode ?? "+975"}${order.mobile}');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${order.countryCode ?? "+975"} ${order.mobile}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.color.territoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.phone_forwarded_rounded, size: 14, color: context.color.territoryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (order.email != null && order.email!.isNotEmpty)
          _buildInfoRow(context, 'Email', order.email!, icon: Icons.email_outlined),
        const SizedBox(height: 6),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Text(
          'Shipping Address',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.color.textLightColor),
        ),
        const SizedBox(height: 4),
        Text(
          order.shippingAddress ?? 'No address provided',
          style: TextStyle(fontSize: 13, color: context.color.textDefaultColor, fontWeight: FontWeight.w600, height: 1.3),
        ),
        if (order.shippingLandmark != null && order.shippingLandmark!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              'Landmark: ${order.shippingLandmark!}',
              style: TextStyle(fontSize: 12, color: context.color.textLightColor),
            ),
          ),
        if (order.shippingZipcode != null && order.shippingZipcode!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              'Postal Code: ${order.shippingZipcode!}',
              style: TextStyle(fontSize: 12, color: context.color.textLightColor),
            ),
          ),
        if (order.billingAddress != null &&
            order.billingAddress!.isNotEmpty &&
            order.billingAddress != order.shippingAddress) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Text(
            'Billing Address',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.color.textLightColor),
          ),
          const SizedBox(height: 4),
          Text(
            order.billingAddress!,
            style: TextStyle(fontSize: 13, color: context.color.textDefaultColor, fontWeight: FontWeight.w600, height: 1.3),
          ),
          if (order.billingLandmark != null && order.billingLandmark!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                'Landmark: ${order.billingLandmark!}',
                style: TextStyle(fontSize: 12, color: context.color.textLightColor),
              ),
            ),
          if (order.billingZipcode != null && order.billingZipcode!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                'Postal Code: ${order.billingZipcode!}',
                style: TextStyle(fontSize: 12, color: context.color.textLightColor),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, EcommerceOrderItemModel item) {
    final itemStatus = item.effectiveStatus;
    final itemDeliveryDate = item.deliveryDate;
    final unitPrice = item.effectiveUnitPrice;
    final qty = item.qty ?? 1;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: UiUtils.imageType(
                    item.image ?? item.product?.imageUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? item.product?.name ?? 'Product Item',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.color.textDefaultColor,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (itemStatus != null && itemStatus.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: EcommerceOrderStatusHelper.getStatusColor(context, itemStatus).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                EcommerceOrderStatusHelper.getStatusText(itemStatus),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: EcommerceOrderStatusHelper.getStatusColor(context, itemStatus),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.platform != null && item.platform!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.color.backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              item.platform!,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: context.color.textLightColor),
                            ),
                          ),
                        if (item.orderNo != null && item.orderNo!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.color.backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'Item #${item.orderNo}',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: context.color.textLightColor),
                            ),
                          ),
                      ],
                    ),
                    if (item.displayVariantDetails != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.displayVariantDetails!,
                          style: TextStyle(fontSize: 12, color: context.color.textLightColor),
                        ),
                      ),
                    if (itemDeliveryDate != null && itemDeliveryDate.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 13, color: context.color.textLightColor),
                            const SizedBox(width: 4),
                            Text(
                              'Delivery: $itemDeliveryDate',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.color.textLightColor),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Item-level Remarks
          if (item.remarks != null && item.remarks!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.color.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.edit_note_rounded, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Remark: ${item.remarks!.trim()}',
                      style: TextStyle(fontSize: 11.5, color: context.color.textDefaultColor),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Item Charge Breakdown
          _buildItemChargeBreakdown(context, item, unitPrice, qty),

          // Original Platform Source Link
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
                    Icon(Icons.open_in_new_rounded, size: 14, color: context.color.territoryColor),
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

  Widget _buildItemChargeBreakdown(
    BuildContext context,
    EcommerceOrderItemModel item,
    double unitPrice,
    int qty,
  ) {
    final double itemSubtotal = unitPrice > 0 ? (unitPrice * qty) : 0.0;
    final double finalAmount = item.finalAmount > 0 ? item.finalAmount : (double.tryParse(item.subtotal ?? '0') ?? 0.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unit Price ($qty ${qty > 1 ? "items" : "item"})',
              style: TextStyle(fontSize: 12, color: context.color.textLightColor),
            ),
            Text(
              'Nu. ${unitPrice > 0 ? unitPrice.toStringAsFixed(2) : (item.price ?? "0.00")} × $qty = Nu. ${itemSubtotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.color.textDefaultColor),
            ),
          ],
        ),
        if (item.serviceCharge > 0)
          _buildItemChargeRow(context, 'Service Charge', item.serviceCharge),
        if (item.deliveryCharge > 0)
          _buildItemChargeRow(context, 'Delivery Charge', item.deliveryCharge),
        if (item.shipmentCharge > 0)
          _buildItemChargeRow(context, 'Shipment Charge', item.shipmentCharge),
        if (item.gstAmount > 0)
          _buildItemChargeRow(
            context,
            'GST ${item.gstCharge > 0 ? "(${item.gstCharge.toStringAsFixed(0)}%)" : ""}',
            item.gstAmount,
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item Total',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.color.textDefaultColor),
            ),
            Text(
              'Nu. ${finalAmount > 0 ? finalAmount.toStringAsFixed(2) : itemSubtotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.color.territoryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemChargeRow(BuildContext context, String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, color: context.color.textLightColor)),
          Text('Nu. ${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 11.5, color: context.color.textDefaultColor)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
    BuildContext context,
    EcommerceOrderModel order,
    EcommerceOrderPaymentDetailModel? paymentDetail,
  ) {
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
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 18, color: context.color.textDefaultColor),
              const SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.color.textDefaultColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (paymentDetail != null) ...[
            _buildPaymentRow('Items Subtotal', 'Nu. ${paymentDetail.itemsSubtotal.toStringAsFixed(2)}', context),
            _buildPaymentRow('Total Service Charge', 'Nu. ${paymentDetail.totalServiceCharge.toStringAsFixed(2)}', context),
            _buildPaymentRow('Total Delivery Charge', 'Nu. ${paymentDetail.totalDeliveryCharge.toStringAsFixed(2)}', context),
            _buildPaymentRow('Total Shipment Charge', 'Nu. ${paymentDetail.totalShipmentCharge.toStringAsFixed(2)}', context),
            _buildPaymentRow('Total GST Amount', 'Nu. ${paymentDetail.totalGstAmount.toStringAsFixed(2)}', context),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.color.textDefaultColor),
                ),
                Text(
                  'Nu. ${paymentDetail.grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.color.territoryColor),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.color.textDefaultColor),
                ),
                Text(
                  'Nu. ${order.totalAmount ?? '0.00'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.color.territoryColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCancelOrderButton(BuildContext context, EcommerceOrderModel order) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.red, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
        label: const Text(
          'Cancel Order',
          style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showCancelOrderDialog(context, order),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    IconData? headerIcon,
  }) {
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
          Row(
            children: [
              if (headerIcon != null) ...[
                Icon(headerIcon, size: 18, color: context.color.textDefaultColor),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.color.textDefaultColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: context.color.textLightColor),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 13, color: context.color.textLightColor),
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: context.color.textLightColor)),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.color.textDefaultColor)),
        ],
      ),
    );
  }
}

