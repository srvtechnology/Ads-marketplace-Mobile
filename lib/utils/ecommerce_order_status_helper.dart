import 'package:flutter/material.dart';

class EcommerceOrderStatusHelper {
  /// Maps raw status code (e.g. 'AA', 'SHIPPED', 'PREACHED_THIMPHU') to user-facing status text.
  /// If [uppercase] is true, returns exact uppercase string (e.g. 'AWAITING', 'PARTIALLY REACHED THIMPHU').
  /// Otherwise returns Title-Cased string for clean UI display (e.g. 'Awaiting', 'Partially Reached Thimphu').
  static String getStatusText(String? status, {bool uppercase = false}) {
    if (status == null || status.trim().isEmpty) {
      return uppercase ? 'AWAITING' : 'Awaiting';
    }

    final key = status.toUpperCase().trim();
    String upperResult;

    switch (key) {
      case 'AA':
      case 'AWAITING':
        upperResult = 'AWAITING';
        break;
      case 'AP':
      case 'APPROVED':
        upperResult = 'APPROVED';
        break;
      case 'RE':
      case 'REJECTED':
        upperResult = 'REJECTED';
        break;
      case 'SHIPPED':
        upperResult = 'SHIPPED';
        break;
      case 'REACHED_JAIGAON':
      case 'REACHED JAIGAON':
        upperResult = 'REACHED JAIGAON';
        break;
      case 'REACHED_THIMPHU':
      case 'REACHED THIMPHU':
        upperResult = 'REACHED THIMPHU';
        break;
      case 'REACHED_THIMPU':
      case 'REACHED THIMPU':
        upperResult = 'REACHED THIMPU';
        break;
      case 'OUT':
      case 'OUT FOR DELIVERY':
        upperResult = 'OUT FOR DELIVERY';
        break;
      case 'DELIVERED':
        upperResult = 'DELIVERED';
        break;
      case 'CAN':
      case 'CC':
      case 'CANCELLED':
        upperResult = 'CANCELLED';
        break;

      // Partial Statuses
      case 'PAA':
      case 'PARTIALLY AWAITING':
      case 'PARTIALLY_AWAITING':
        upperResult = 'PARTIALLY AWAITING';
        break;
      case 'PAP':
      case 'PARTIALLY APPROVED':
      case 'PARTIALLY_APPROVED':
        upperResult = 'PARTIALLY APPROVED';
        break;
      case 'PRE':
      case 'PARTIALLY REJECTED':
      case 'PARTIALLY_REJECTED':
        upperResult = 'PARTIALLY REJECTED';
        break;
      case 'PSHIPPED':
      case 'PARTIALLY SHIPPED':
      case 'PARTIALLY_SHIPPED':
        upperResult = 'PARTIALLY SHIPPED';
        break;
      case 'PREACHED_JAIGAON':
      case 'PARTIALLY REACHED JAIGAON':
      case 'PARTIALLY_REACHED_JAIGAON':
        upperResult = 'PARTIALLY REACHED JAIGAON';
        break;
      case 'PREACHED_THIMPHU':
      case 'PARTIALLY REACHED THIMPHU':
      case 'PARTIALLY_REACHED_THIMPHU':
        upperResult = 'PARTIALLY REACHED THIMPHU';
        break;
      case 'PREACHED_THIMPU':
      case 'PARTIALLY REACHED THIMPU':
      case 'PARTIALLY_REACHED_THIMPU':
        upperResult = 'PARTIALLY REACHED THIMPU';
        break;
      case 'POUT':
      case 'PARTIALLY OUT FOR DELIVERY':
      case 'PARTIALLY_OUT_FOR_DELIVERY':
        upperResult = 'PARTIALLY OUT FOR DELIVERY';
        break;
      case 'PDELIVERED':
      case 'PARTIALLY DELIVERED':
      case 'PARTIALLY_DELIVERED':
        upperResult = 'PARTIALLY DELIVERED';
        break;
      case 'PCAN':
      case 'PARTIALLY CANCELLED':
      case 'PARTIALLY_CANCELLED':
        upperResult = 'PARTIALLY CANCELLED';
        break;

      default:
        upperResult = status;
        break;
    }

    if (uppercase) return upperResult;

    // Convert upperResult to Title Case for UI
    return upperResult.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Returns appropriate badge theme color based on status.
  static Color getStatusColor(BuildContext context, String? status) {
    if (status == null || status.trim().isEmpty) return Colors.orange;

    final key = status.toUpperCase().trim();
    switch (key) {
      case 'AA':
      case 'AWAITING':
      case 'PAA':
      case 'PARTIALLY AWAITING':
      case 'PARTIALLY_AWAITING':
        return Colors.orange;

      case 'AP':
      case 'APPROVED':
      case 'PAP':
      case 'PARTIALLY APPROVED':
      case 'PARTIALLY_APPROVED':
        return Colors.blue;

      case 'RE':
      case 'REJECTED':
      case 'PRE':
      case 'PARTIALLY REJECTED':
      case 'PARTIALLY_REJECTED':
      case 'CAN':
      case 'CC':
      case 'CANCELLED':
      case 'PCAN':
      case 'PARTIALLY CANCELLED':
      case 'PARTIALLY_CANCELLED':
        return Colors.red;

      case 'SHIPPED':
      case 'PSHIPPED':
      case 'PARTIALLY SHIPPED':
      case 'PARTIALLY_SHIPPED':
      case 'REACHED_JAIGAON':
      case 'REACHED JAIGAON':
      case 'PREACHED_JAIGAON':
      case 'PARTIALLY REACHED JAIGAON':
      case 'PARTIALLY_REACHED_JAIGAON':
      case 'REACHED_THIMPHU':
      case 'REACHED THIMPHU':
      case 'PREACHED_THIMPHU':
      case 'PARTIALLY REACHED THIMPHU':
      case 'PARTIALLY_REACHED_THIMPHU':
      case 'REACHED_THIMPU':
      case 'REACHED THIMPU':
      case 'PREACHED_THIMPU':
      case 'PARTIALLY REACHED THIMPU':
      case 'PARTIALLY_REACHED_THIMPU':
      case 'OUT':
      case 'OUT FOR DELIVERY':
      case 'POUT':
      case 'PARTIALLY OUT FOR DELIVERY':
      case 'PARTIALLY_OUT_FOR_DELIVERY':
        return Colors.deepPurple;

      case 'DELIVERED':
      case 'PDELIVERED':
      case 'PARTIALLY DELIVERED':
      case 'PARTIALLY_DELIVERED':
        return Colors.green;

      default:
        return Colors.orange;
    }
  }
}
