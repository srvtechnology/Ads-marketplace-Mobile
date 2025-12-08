class BfsBank {
  final String id;
  final String name;
  final String status;

  BfsBank({required this.id, required this.name, required this.status});

  factory BfsBank.fromJson(Map<String, dynamic> json) {
    return BfsBank(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

enum BfsErrorType { success, bankDeclined, validation, timeout, unknown, none }

class BfsArResponse {
  final bool success;
  final String txnId;
  final String orderNo;
  final double amount;
  final String currency;
  final List<BfsBank> banks;

  BfsArResponse({
    required this.success,
    required this.txnId,
    required this.orderNo,
    required this.amount,
    required this.currency,
    required this.banks,
  });

  factory BfsArResponse.fromJson(Map<String, dynamic> json) {
    var bankList = json['bank_list'] ?? json['banks'] ?? [];
    var orderNo = json['order_no'] ?? json['orderNo'] ?? '';
    var amountVal = 0.0;
    if (json['request'] != null && json['request']['bfs_txnAmount'] != null) {
      amountVal =
          double.tryParse(json['request']['bfs_txnAmount'].toString()) ?? 0.0;
    }

    var responseObj = json['response'];
    if (responseObj is! Map) {
      responseObj = {};
    }

    return BfsArResponse(
      success: (bankList as List).isNotEmpty,
      txnId: responseObj['bfs_bfsTxnId'] ?? '',
      orderNo: orderNo,
      amount: amountVal,
      currency: 'BTN',
      banks: (bankList).map((e) => BfsBank.fromJson(e)).toList(),
    );
  }
}

class BfsAeResponse {
  final bool success;
  final String message;
  final bool otpRequired;
  final String? otp;

  BfsAeResponse({
    required this.success,
    required this.message,
    required this.otpRequired,
    this.otp,
  });

  factory BfsAeResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = json['success'] == true;

    var responseObj = json['response'];
    String msg = '';
    if (responseObj is Map) {
      msg = responseObj['bfs_responseDesc'] ?? '';
    }
    if (msg.isEmpty) {
      msg = json['message'] ?? '';
    }

    // Attempt to extract OTP if provided (e.g. for testing)
    String? otpVal = json['otp'];
    if (otpVal == null &&
        json['transaction'] != null &&
        json['transaction']['otp'] != null) {
      otpVal = json['transaction']['otp'].toString();
    }

    return BfsAeResponse(
      success: isSuccess,
      message: msg,
      otpRequired: true, // Always true for this flow as per requirement
      otp: otpVal,
    );
  }
}

class BfsDrResponse {
  final bool success;
  final bool isPending;
  final String status;
  final String txnId;
  final String authNo;
  final double amount;
  final String currency;
  final String timestamp;
  final BfsErrorType errorType;

  BfsDrResponse({
    required this.success,
    required this.isPending,
    required this.status,
    required this.txnId,
    required this.authNo,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.errorType,
  });

  factory BfsDrResponse.fromJson(Map<String, dynamic> json) {
    var responseObj = json['response'];
    if (responseObj is! Map) {
      responseObj = {};
    }
    var txnObj = json['transaction'] ?? {};

    bool isSuccess = false;
    bool isPending = false;
    String status = txnObj['status'] ?? responseObj['bfs_responseDesc'] ?? '';

    // Check success from transaction status or response code
    if (status == 'COMPLETED' || status == 'SUCCESS' || status == 'APPROVED') {
      isSuccess = true;
    } else if (responseObj['bfs_responseCode'] == '00') {
      isSuccess = true;
    } else if (status == 'PENDING') {
      isPending = true;
    }

    String responseCode = responseObj['bfs_responseCode'] ?? '';

    // Error Mapping
    BfsErrorType errorTypeVal = BfsErrorType.unknown;
    if (isSuccess) {
      errorTypeVal = BfsErrorType.success;
    } else if (isPending) {
      errorTypeVal = BfsErrorType.none; // No error per se, just pending
    } else {
      if (responseCode == '51' || responseCode == '61') {
        errorTypeVal = BfsErrorType.bankDeclined;
      } else if (responseCode == '80' || responseCode == 'BC') {
        errorTypeVal = BfsErrorType.validation;
      } else if (responseCode == 'TO') {
        errorTypeVal = BfsErrorType.timeout;
      } else if (responseCode == '00') {
        // Should be success but if logic flows here safe fallback
        errorTypeVal = BfsErrorType.success;
      } else {
        errorTypeVal = BfsErrorType.unknown;
      }
    }

    return BfsDrResponse(
      success: isSuccess,
      isPending: isPending,
      status: status,
      txnId: txnObj['bfs_txn_id'] ?? responseObj['bfs_bfsTxnId'] ?? '',
      authNo: responseObj['bfs_debitAuthCode'] ?? '',
      amount: double.tryParse(txnObj['amount']?.toString() ??
              responseObj['bfs_txnAmount']?.toString() ??
              '0') ??
          0.0,
      currency: responseObj['bfs_txnCurrency'] ?? 'BTN',
      timestamp: responseObj['bfs_bfsTxnTime'] ?? txnObj['created_at'] ?? '',
      errorType: errorTypeVal,
    );
  }
}
