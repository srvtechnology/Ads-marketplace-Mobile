# Cart Engine & Checkout API Documentation

This document describes the updated endpoints for the Cart Engine and order system. All endpoints require user authentication via Bearer Token.

---

## 1. Add Scraped Product to Cart

Saves a product scraped from a external brand platform (e.g. Amazon, Myntra) directly to the user's cart and dynamically calculates charges.

- **URL**: `/api/cart/add`
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Request Payload:
```json
{
  "title": "ZEBRONICS-Transformer-M with a High-Performance Gold-Plated USB Mouse",
  "price": 349.00,
  "brand": "Amazon",
  "image": "https://m.media-amazon.com/images/I/61+XYZ.jpg",
  "url": "https://www.amazon.in/dp/B073Q1234",
  "variants": "Size: Standard, Colour: Black",
  "quantity": 1
}
```

### Response Payload (`201 Created`):
```json
{
  "success": true,
  "message": "Product successfully imported to cart",
  "data": {
    "cart_item_id": 1349373,
    "cart_count": 4
  }
}
```

---

## 2. Fetch User Cart

Retrieves all products in the user's cart along with their slab-calculated prices and summary details.

- **URL**: `/api/cart`
- **Method**: `GET`
- **Headers**:
  - `Authorization: Bearer <user_token>`

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "data": {
    "currency": "Nu.",
    "total_items_count": 2,
    "is_all_selected": false,
    "items": [
      {
        "cart_item_id": 1349373,
        "title": "ZEBRONICS-Transformer-M",
        "platform": "Amazon",
        "image": "https://m.media-amazon.com/images/I/61+XYZ.jpg",
        "quantity": 1,
        "unit_price": 349.00,
        "total_calculated_price": 552.30,
        "variants": "Colour: Black",
        "is_selected": true,
        "imported_date": "2026-07-21"
      }
    ],
    "summary": {
      "selected_items_count": 1,
      "grand_total": 552.30
    }
  }
}
```

---

## 3. Fetch Cart Item Breakdown (Bottom Sheet Details Modal)

Retrieves full breakdown of calculation charges for a specific item in the cart.

- **URL**: `/api/cart/items/{cart_item_id}/details`
- **Method**: `GET`
- **Headers**:
  - `Authorization: Bearer <user_token>`

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "data": {
    "cart_item_id": 1349373,
    "title": "ZEBRONICS-Transformer-M with a High-Performance Gold-Plated USB Mouse",
    "platform": "Amazon",
    "source_url": "https://www.amazon.in/dp/B073Q1234",
    "placed_on": "2026-07-21",
    "image": "https://m.media-amazon.com/images/I/61+XYZ.jpg",
    "quantity": 1,
    "currency": "Nu.",
    "payment_detail": {
      "item_total": 349.00,
      "service_charges": 100.00,
      "delivery_charges": 39.00,
      "shipment_charge_till_jaigaon": 38.00,
      "gst_5_percent": 26.30,
      "total_price": 552.30
    }
  }
}
```

---

## 4. Update Cart Item Quantity & Selection

Updates the quantity and/or selection status of a cart item and returns the updated item price and cart grand total.

- **URL**: `/api/cart/items/{cart_item_id}`
- **Method**: `PUT`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Request Payload:
```json
{
  "quantity": 2,
  "is_selected": true
}
```

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "message": "Cart updated",
  "data": {
    "cart_item_id": 1349373,
    "quantity": 2,
    "updated_item_total_price": 1104.60,
    "cart_grand_total": 1104.60
  }
}
```

---

## 5. Delete Items (Single or Bulk)

Removes specified items from the user's cart.

- **URL**: `/api/cart/items`
- **Method**: `DELETE`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Request Payload:
```json
{
  "cart_item_ids": [1349373, 1349374]
}
```

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "message": "Selected items removed from cart",
  "data": {
    "remaining_cart_count": 0
  }
}
```

---

## 6. Checkout Cart Items

Converts all items currently present in the user's cart into a new order and clears the cart on success.

- **URL**: `/api/checkout`
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Input Parameters:

| Parameter | Type | Required / Optional | Description |
|---|---|---|---|
| `name` | String | **Required** | Customer's full name |
| `country_code` | String | **Required** | Bhutan country calling code (e.g. `975` or `+975`) |
| `mobile` | String | **Required** | Customer's contact phone number |
| `shipping_address` | String | **Required** | Full shipping address in Bhutan |
| `payment_mode` | String | **Required** | Payment mode (e.g. `COD`, `ONLINE`, `BFS`) |
| `email` | String | Optional (Nullable) | Customer's email address |
| `shipping_zipcode` | String | Optional (Nullable) | Postal zip code for shipping address |
| `shipping_landmark` | String | Optional (Nullable) | Landmark for shipping address delivery |
| `billing_address` | String | Optional (Nullable) | Billing address (falls back to shipping address if empty) |
| `billing_zipcode` | String | Optional (Nullable) | Postal zip code for billing address |
| `billing_landmark` | String | Optional (Nullable) | Landmark for billing address |
| `status` | String | Optional (Nullable) | Initial order status (defaults to `AA` (Awaiting). Valid values: `AA`, `AP`, `RE`, `SHIPPED`, `REACHED_JAIGAON`, `REACHED_THIMPHU`, `REACHED_THIMPU`, `OUT`, `DELIVERED`, `CAN`, `OTHER`) |
| `remarks` | String | Optional (Nullable) | Special instructions or remarks |

### Request Payload Example:
```json
{
  "name": "Test Customer",
  "country_code": "+975",
  "mobile": "17111111",
  "shipping_address": "Thimphu, Bhutan",
  "payment_mode": "COD",
  "email": "test@example.com",
  "shipping_zipcode": "11001",
  "shipping_landmark": "Near Clock Tower",
  "billing_address": "Thimphu, Bhutan",
  "billing_zipcode": "11001",
  "billing_landmark": "Near Clock Tower",
  "status": "AA",
  "remarks": "Please deliver after 5 PM."
}
```

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "message": "Order placed successfully",
  "data": {
    "id": 12,
    "order_id": "KORA-2026-2307-001",
    "delivery_otp": "854912",
    "otp": "854912",
    "total_amount": 552.30,
    "payment_url": "https://gateway.bfs.bt/pay/KORA-2026-2307-001"
  }
}
```

---

## 7. Get Order List

Retrieves a paginated list of the user's placed orders.

- **URL**: `/api/orders`
- **Method**: `GET`
- **Headers**:
  - `Authorization: Bearer <user_token>`

### Response Payload (`200 OK`):
```json
{
  "error": false,
  "message": "Orders fetched successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 12,
        "order_id": "KORA-2026-2307-001",
        "delivery_otp": "854912",
        "otp": "854912",
        "payment_mode": "ONLINE",
        "total_amount": 552.30,
        "status": "AA",
        "delivery_status": "AWAITING",
        "placed_on": "2026-07-23 13:09:10"
      }
    ],
    "first_page_url": "https://admin.thebhutanmarket.com?page=1",
    "from": 1,
    "last_page": 1,
    "last_page_url": "https://admin.thebhutanmarket.com?page=1",
    "next_page_url": null,
    "path": "https://admin.thebhutanmarket.com",
    "per_page": 15,
    "prev_page_url": null,
    "to": 1,
    "total": 1
  }
}
```

---

## 8. Get Order Details

Retrieves complete details of a specific order, including all calculations and individual itemized charges.

- **URL**: `/api/orders/{id}`
- **Method**: `GET`
- **Headers**:
  - `Authorization: Bearer <user_token>`

### Response Payload (`200 OK`):
```json
{
  "error": false,
  "message": "Order details fetched successfully",
  "data": {
    "id": 12,
    "order_id": "KORA-2026-2307-001",
    "delivery_otp": "854912",
    "otp": "854912",
    "checkout_bfs_transaction_id": 5,
    "name": "Test Customer",
    "email": "test@example.com",
    "country_code": "+975",
    "mobile": "17111111",
    "shipping_address": "Thimphu, Bhutan",
    "shipping_zipcode": "11001",
    "shipping_landmark": "Near Clock Tower",
    "billing_address": "Thimphu, Bhutan",
    "billing_zipcode": "11001",
    "billing_landmark": "Near Clock Tower",
    "payment_mode": "ONLINE",
    "status": "AA",
    "delivery_status": "AWAITING",
    "remarks": "Paid via BFS Online Payment",
    "placed_on": "2026-07-23 13:09:10",
    "bfs_transaction": {
      "id": 5,
      "bfs_txn_id": "BFS2026072712345",
      "status": "COMPLETED",
      "bank_id": "BOB",
      "account_no": "201234567",
      "amount": 563.85,
      "response_code": "00",
      "response_desc": "Transaction Successful"
    },
    "payment_detail": {
      "items_subtotal": 300.00,
      "total_service_charge": 100.00,
      "total_delivery_charge": 100.00,
      "total_shipment_charge": 37.00,
      "total_gst_amount": 26.85,
      "grand_total": 563.85
    },
    "items": [
      {
        "item_id": 24,
        "title": "Test Scraped Keyboard",
        "platform": "Amazon",
        "source_url": "https://www.amazon.in/dp/B073Q1234",
        "image": "https://m.media-amazon.com/images/I/keyboard.jpg",
        "quantity": 2,
        "unit_price": 150.00,
        "variant_details": "Colour: Black",
        "service_charge": 100.00,
        "delivery_charge": 100.00,
        "shipment_charge": 37.00,
        "gst_charge": 5.00,
        "gst_amount": 26.85,
        "final_amount": 563.85,
        "delivery_date": "2026-07-30",
        "order_no": "ABC12345",
        "status": "AA",
        "status_label": "AWAITING",
        "remarks": "Order item remarks here"
      }
    ]
  }
}
```

---

## 9. Cancel Order

Allows a customer to cancel one of their orders and provide a reason/remarks.

- **URL**: `/api/orders/{id}/cancel`
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Request Payload:
```json
{
  "remarks": "Wrong item selected by mistake"
}
```

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "message": "Order cancelled successfully"
}
```

---

## 10. Online BFS Payment Gateway for Checkout (3-Step Flow)

When the user selects **ONLINE** payment during checkout, use the 3-step BFS payment gateway APIs (`checkoutar`, `checkoutae` / `checkouter`, `checkoutdr`).

---

### Step 1: Authentication Request (AR)

Calculates the cart total, generates a unique order number, creates a pending transaction record in `checkout_bfs_transactions`, and fetches the available bank list from BFS.

- **URL**: `/api/checkoutar` *(or `/api/bfs/checkoutar`)*
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "name": "Test Customer",
  "email": "test@example.com",
  "country_code": "+975",
  "mobile": "17111111",
  "shipping_address": "Thimphu, Bhutan",
  "shipping_zipcode": "11001",
  "shipping_landmark": "Near Clock Tower",
  "billing_address": "Thimphu, Bhutan",
  "billing_zipcode": "11001",
  "billing_landmark": "Near Clock Tower"
}
```

#### Response Payload (`200 OK`):
```json
{
  "success": true,
  "order_no": "KORA-2026-2707-001",
  "amount": 552.30,
  "request": {
    "bfs_msgType": "AR",
    "bfs_benfTxnTime": "20260727140000",
    "bfs_orderNo": "KORA-2026-2707-001",
    "bfs_benfId": "BE10000099",
    "bfs_benfBankCode": "01",
    "bfs_txnCurrency": "BTN",
    "bfs_txnAmount": "552.30",
    "bfs_remitterEmail": "test@example.com",
    "bfs_paymentDesc": "Cart Checkout Payment",
    "bfs_version": "1.0"
  },
  "bank_list": [
    {
      "id": "01",
      "name": "Bank of Bhutan"
    },
    {
      "id": "02",
      "name": "Bhutan National Bank"
    }
  ],
  "response": {
    "bfs_msgType": "AR",
    "bfs_bfsTxnId": "BFS20260727001",
    "bfs_responseCode": "00",
    "bfs_responseDesc": "Success"
  }
}
```

---

### Step 2: Account Enquiry (AE)

Submits the selected remitter `bank_id` and `account_no` for bank verification.

- **URL**: `/api/checkoutae` or `/api/checkouter` *(or `/api/bfs/checkoutae` / `/api/bfs/checkouter`)*
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "order_no": "KORA-2026-2707-001",
  "bank_id": "01",
  "account_no": "201234567"
}
```

#### Response Payload (`200 OK`):
```json
{
  "success": true,
  "request": {
    "bfs_msgType": "AE",
    "bfs_bfsTxnId": "BFS20260727001",
    "bfs_benfId": "BE10000099",
    "bfs_remitterBankId": "01",
    "bfs_remitterAccNo": "201234567"
  },
  "response": {
    "bfs_msgType": "AE",
    "bfs_bfsTxnId": "BFS20260727001",
    "bfs_responseCode": "00",
    "bfs_responseDesc": "OTP Sent to Mobile"
  }
}
```

---

### Step 3: Debit Request (DR) & Automatic Order Conversion

Submits the customer's OTP to execute the payment debit.
When debit authorization is successful (`bfs_debitAuthCode` = `"00"`):
1. The transaction status is set to `COMPLETED`.
2. Cart items are converted into a new `Order` with `payment_mode` = `"ONLINE"` and `checkout_bfs_transaction_id` linked.
3. Cart items are automatically cleared for the user.
4. Email and SMS notifications are sent.

- **URL**: `/api/checkoutdr` *(or `/api/bfs/checkoutdr`)*
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "order_no": "KORA-2026-2707-001",
  "otp": "123456"
}
```

#### Response Payload (`200 OK`):
```json
{
  "success": true,
  "request": {
    "bfs_msgType": "DR",
    "bfs_bfsTxnId": "BFS20260727001",
    "bfs_benfId": "BE10000099",
    "bfs_remitterOtp": "123456"
  },
  "response": {
    "bfs_msgType": "DR",
    "bfs_bfsTxnId": "BFS20260727001",
    "bfs_responseCode": "00",
    "bfs_debitAuthCode": "00",
    "bfs_responseDesc": "Payment Successful"
  },
  "transaction": {
    "id": 5,
    "order_no": "KORA-2026-2707-001",
    "bfs_txn_id": "BFS20260727001",
    "status": "COMPLETED",
    "bank_id": "01",
    "account_no": "201234567",
    "amount": "552.30",
    "customer_id": 12,
    "name": "Test Customer",
    "email": "test@example.com",
    "mobile": "17111111",
    "shipping_address": "Thimphu, Bhutan"
  },
  "order": {
    "id": 15,
    "customer_id": 12,
    "checkout_bfs_transaction_id": 5,
    "order_no": "KORA-2026-2707-001",
    "name": "Test Customer",
    "email": "test@example.com",
    "mobile": "17111111",
    "payment_mode": "ONLINE",
    "total_amount": "552.30",
    "status": "AA"
  }
}
```

