# Cart Engine & Checkout API Documentation

This document describes the updated endpoints for the Cart Engine and order system. All endpoints require user authentication via Bearer Token.

---

## 1. Add Scraped Product to Cart

Saves a product scraped from an external brand platform (e.g. Amazon, Myntra) directly to the user's cart and dynamically calculates charges. By default, new items are added with `checkout_product: "Y"` and `is_selected: true`.

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

Retrieves all products in the user's cart along with their slab-calculated prices, selection statuses (`checkout_product` & `is_selected`), and grand total of checked items.

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
        "cart_item_id": 1820,
        "title": "DEELMO Men's Regular Fit Solid Spread Collar Cotton Casual Shirt",
        "platform": "Amazon",
        "image": "https://m.media-amazon.com/images/I/shirt1.jpg",
        "quantity": 2,
        "unit_price": 624.75,
        "total_calculated_price": 1249.50,
        "variants": "Colour: IN, Size: M",
        "is_selected": true,
        "checkout_product": "Y",
        "imported_date": "2026-09-16"
      },
      {
        "cart_item_id": 1831,
        "title": "Combo of Men's Casual Shirt",
        "platform": "Amazon",
        "image": "https://m.media-amazon.com/images/I/shirt2.jpg",
        "quantity": 1,
        "unit_price": 768.60,
        "total_calculated_price": 768.60,
        "variants": "Colour: 2XL",
        "is_selected": false,
        "checkout_product": "N",
        "imported_date": "2026-09-16"
      }
    ],
    "summary": {
      "selected_items_count": 1,
      "grand_total": 1249.50
    },
    "cart_grand_total": 1249.50
  }
}
```

---

## 3. Update Cart Selection / Checkbox Status (Single Unified Endpoint)

**🌟 Recommended for Mobile App:** Whenever a user checks/unchecks any product, clicks "Select All", or unselects all in the cart screen, call this single endpoint with the array of currently checked item IDs.

- **URL**: `/api/cart/update-selection` *(Aliases: `/api/cart/sync-selection`, `/api/cart/select-all`)*
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Request Payload (Option A - Checked Item IDs Array):
Pass the list of item IDs that are currently checked. All IDs in this list become `checkout_product: "Y"` / `is_selected: true`, and all other items in the user's cart become `checkout_product: "N"` / `is_selected: false`.
```json
{
  "selected_ids": [1820, 1830]
}
```

> **Note:**
> - If user unchecks everything, send: `{"selected_ids": []}`
> - If user clicks "Select All", send all item IDs: `{"selected_ids": [1820, 1830, 1831, 1832]}` (or `{"select_all": true}`)

### Response Payload (`200 OK`):
Returns the complete updated cart data and recalculated `cart_grand_total` immediately:
```json
{
  "success": true,
  "data": {
    "currency": "Nu.",
    "total_items_count": 4,
    "is_all_selected": false,
    "items": [
      {
        "cart_item_id": 1820,
        "title": "DEELMO Men's Regular Fit Solid Spread Collar Cotton Casual Shirt",
        "platform": "Amazon",
        "image": "https://m.media-amazon.com/images/I/shirt1.jpg",
        "quantity": 2,
        "unit_price": 624.75,
        "total_calculated_price": 1249.50,
        "variants": "Colour: IN, Size: M",
        "is_selected": true,
        "checkout_product": "Y",
        "imported_date": "2026-09-16"
      },
      {
        "cart_item_id": 1830,
        "title": "DEELMO Men's Casual Shirt",
        "platform": "Amazon",
        "image": "https://m.media-amazon.com/images/I/shirt3.jpg",
        "quantity": 1,
        "unit_price": 607.95,
        "total_calculated_price": 607.95,
        "variants": "Colour: IN",
        "is_selected": true,
        "checkout_product": "Y",
        "imported_date": "2026-09-16"
      },
      {
        "cart_item_id": 1831,
        "title": "Combo of Men's Casual Shirt",
        "platform": "Amazon",
        "image": "https://m.media-amazon.com/images/I/shirt2.jpg",
        "quantity": 1,
        "unit_price": 768.60,
        "total_calculated_price": 768.60,
        "variants": "Colour: 2XL",
        "is_selected": false,
        "checkout_product": "N",
        "imported_date": "2026-09-16"
      },
      {
        "cart_item_id": 1832,
        "title": "Kratos Selfie Stick Tripod",
        "platform": "Amazon",
        "image": "https://m.media-amazon.com/images/I/tripod.jpg",
        "quantity": 1,
        "unit_price": 457.80,
        "total_calculated_price": 457.80,
        "variants": "Colour: Pitch Black",
        "is_selected": false,
        "checkout_product": "N",
        "imported_date": "2026-09-16"
      }
    ],
    "summary": {
      "selected_items_count": 2,
      "grand_total": 1857.45
    },
    "cart_grand_total": 1857.45
  }
}
```

---

## 4. Fetch Cart Item Breakdown (Bottom Sheet Details Modal)

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
    "cart_item_id": 1820,
    "title": "DEELMO Men's Regular Fit Solid Spread Collar Cotton Casual Shirt",
    "platform": "Amazon",
    "source_url": "https://www.amazon.in/dp/B073Q1234",
    "placed_on": "2026-09-16",
    "image": "https://m.media-amazon.com/images/I/shirt1.jpg",
    "quantity": 2,
    "currency": "Nu.",
    "is_selected": true,
    "checkout_product": "Y",
    "payment_detail": {
      "item_total": 1249.50,
      "service_charges": 37.49,
      "delivery_charges": 39.00,
      "shipment_charge_till_jaigaon": 38.00,
      "gst_5_percent": 68.20,
      "total_price": 1432.19
    }
  }
}
```

---

## 5. Update Single Cart Item Quantity & Selection

Updates the quantity and/or selection status of an individual cart item.

- **URL**: `/api/cart/items/{cart_item_id}` *(Alias: `/api/cart/update/{cart_item_id}`)*
- **Method**: `PUT`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Request Payload:
```json
{
  "quantity": 2,
  "checkout_product": "Y"
}
```
*(You can pass `"checkout_product": "Y"` / `"N"` or `"is_selected": true` / `false`)*

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "message": "Cart updated",
  "data": {
    "cart_item_id": 1820,
    "quantity": 2,
    "is_selected": true,
    "checkout_product": "Y",
    "updated_item_total_price": 1249.50,
    "selected_items_count": 2,
    "cart_grand_total": 1857.45
  }
}
```

---

## 6. Delete Items (Single or Bulk)

Removes specified items from the user's cart (regardless of whether they are checked `Y` or unchecked `N`) and returns the updated count and recalculated grand total.

- **URL**: `/api/cart/items` *(or `/api/cart/remove/{cart_item_id}`)*
- **Method**: `DELETE`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

### Request Payload (Bulk Deletion):
```json
{
  "cart_item_ids": [1831, 1832]
}
```

### Response Payload (`200 OK`):
```json
{
  "success": true,
  "message": "Selected items removed from cart",
  "data": {
    "remaining_cart_count": 2,
    "selected_items_count": 2,
    "cart_grand_total": 1857.45
  }
}
```

---

## 7. Checkout Cart Items (Standard / COD)

Converts **only the checked products (`checkout_product = 'Y'`)** into a new order:
1. Calculates order totals from only the checked `'Y'` items.
2. Creates `Order` and `OrderItem` records for only the checked items.
3. Removes only the checked `'Y'` items from the `carts` table.
4. **Automatically resets all remaining unchecked items in the cart to `checkout_product = 'Y'` and `is_selected = true`** so they are ready for future checkout.

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
  "name": "Sonam Dorji",
  "country_code": "+975",
  "mobile": "17111111",
  "shipping_address": "Thimphu, Bhutan",
  "payment_mode": "COD",
  "email": "sonam@example.bt",
  "shipping_zipcode": "11001",
  "shipping_landmark": "Near Clock Tower",
  "billing_address": "Thimphu, Bhutan",
  "billing_zipcode": "11001",
  "billing_landmark": "Near Clock Tower",
  "status": "AA",
  "remarks": "Please deliver after 5 PM."
}
```

### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Order placed successfully",
  "data": {
    "id": 12,
    "order_id": "KORA-2026-1609-001",
    "delivery_otp": "854912",
    "otp": "854912",
    "total_amount": 1857.45,
    "payment_url": "https://gateway.bfs.bt/pay/KORA-2026-1609-001"
  }
}
```

### Error Response if no items are checked (`400 Bad Request`):
```json
{
  "error": true,
  "message": "No items selected for checkout. Please select at least one item.",
  "code": 400
}
```

---

## 8. Get Order List

Retrieves a paginated list of the user's placed orders.

- **URL**: `/api/orders` *(Alias: `/api/get-orders`)*
- **Method**: `GET`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Accept: application/json`

### Response Payload (`200 OK`):
```json
{
  "error": false,
  "success": true,
  "message": "Orders fetched successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 12,
        "order_id": "KORA-2026-1609-001",
        "delivery_otp": "854912",
        "otp": "854912",
        "payment_mode": "COD",
        "total_amount": 1857.45,
        "status": "AA",
        "delivery_status": "AWAITING",
        "placed_on": "2026-09-16 18:30:00"
      }
    ],
    "first_page_url": "https://admin.thebhutanmarket.com/api/orders?page=1",
    "from": 1,
    "last_page": 1,
    "last_page_url": "https://admin.thebhutanmarket.com/api/orders?page=1",
    "next_page_url": null,
    "path": "https://admin.thebhutanmarket.com/api/orders",
    "per_page": 15,
    "prev_page_url": null,
    "to": 1,
    "total": 1
  },
  "code": 200
}
```

---

## 9. Get Order Details

Retrieves complete details of a specific order, including all calculations and individual itemized charges. Can be requested by numeric ID (e.g. `12`) or Order No (e.g. `KORA-2026-1609-001`).

- **URL**: `/api/orders/{id_or_order_no}` *(Alias: `/api/get-order-details/{id_or_order_no}`)*
- **Method**: `GET`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Accept: application/json`

### Response Payload (`200 OK`):
```json
{
  "error": false,
  "success": true,
  "message": "Order details fetched successfully",
  "data": {
    "id": 12,
    "order_id": "KORA-2026-1609-001",
    "delivery_otp": "854912",
    "otp": "854912",
    "checkout_bfs_transaction_id": null,
    "name": "Sonam Dorji",
    "email": "sonam@example.bt",
    "country_code": "+975",
    "mobile": "17111111",
    "shipping_address": "Thimphu, Bhutan",
    "shipping_zipcode": "11001",
    "shipping_landmark": "Near Clock Tower",
    "billing_address": "Thimphu, Bhutan",
    "billing_zipcode": "11001",
    "billing_landmark": "Near Clock Tower",
    "payment_mode": "COD",
    "status": "AA",
    "delivery_status": "AWAITING",
    "remarks": "Please deliver after 5 PM.",
    "placed_on": "2026-09-16 18:30:00",
    "payment_detail": {
      "items_subtotal": 1857.45,
      "total_service_charge": 55.72,
      "total_delivery_charge": 78.00,
      "total_shipment_charge": 76.00,
      "total_gst_amount": 103.36,
      "grand_total": 1857.45
    },
    "items": [
      {
        "item_id": 24,
        "title": "DEELMO Men's Regular Fit Solid Spread Collar Cotton Casual Shirt",
        "platform": "Amazon",
        "source_url": "https://www.amazon.in/dp/B073Q1234",
        "image": "https://m.media-amazon.com/images/I/shirt1.jpg",
        "quantity": 2,
        "unit_price": 624.75,
        "variant_details": "Colour: IN, Size: M",
        "service_charge": 37.49,
        "delivery_charge": 39.00,
        "shipment_charge": 38.00,
        "gst_charge": 5.00,
        "gst_amount": 68.20,
        "final_amount": 1249.50,
        "delivery_date": null,
        "order_no": "KORA-2026-1609-001",
        "status": "AA",
        "status_label": "AWAITING",
        "remarks": null
      }
    ]
  }
}
```

---

## 10. Cancel Order

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

## 11. Online BFS Payment Gateway for Checkout (3-Step Flow)

When the user selects **ONLINE** payment during checkout, use the 3-step BFS payment gateway APIs (`checkoutar`, `checkoutae`, `checkoutdr`).

---

### Step 1: Authentication Request (AR)

Calculates total for **only checked items (`checkout_product = 'Y'`)**, generates a unique order number, creates a pending transaction record in `checkout_bfs_transactions`, and fetches the available bank list from BFS.

- **URL**: `/api/checkoutar`
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "name": "Sonam Dorji",
  "email": "sonam@example.bt",
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
  "order_no": "CHK17265000001234",
  "amount": 1857.45,
  "request": {
    "bfs_msgType": "AR",
    "bfs_benfTxnTime": "20260916183000",
    "bfs_orderNo": "CHK17265000001234",
    "bfs_benfId": "BE10000099",
    "bfs_benfBankCode": "01",
    "bfs_txnCurrency": "BTN",
    "bfs_txnAmount": "1857.45",
    "bfs_remitterEmail": "sonam@example.bt",
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
    "bfs_bfsTxnId": "BFS20260916001",
    "bfs_responseCode": "00",
    "bfs_responseDesc": "Success"
  }
}
```

---

### Step 2: Account Enquiry (AE)

Submits the selected remitter `bank_id` and `account_no` for bank verification.

- **URL**: `/api/checkoutae` *(Alias: `/api/checkouter`)*
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "order_no": "CHK17265000001234",
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
    "bfs_bfsTxnId": "BFS20260916001",
    "bfs_benfId": "BE10000099",
    "bfs_remitterBankId": "01",
    "bfs_remitterAccNo": "201234567"
  },
  "response": {
    "bfs_msgType": "AE",
    "bfs_bfsTxnId": "BFS20260916001",
    "bfs_responseCode": "00",
    "bfs_responseDesc": "OTP Sent to Mobile"
  }
}
```

---

### Step 3: Debit Request (DR) & Automatic Order Conversion

Submits the customer's OTP to execute the payment debit.
When debit authorization is successful (`bfs_debitAuthCode` = `"00"`):
1. Transaction status is set to `COMPLETED`.
2. **Only the checked `'Y'` cart items** are converted into a new `Order` with `payment_mode` = `"ONLINE"`.
3. **Only the checked `'Y'` items** are removed from the user's cart table.
4. **All remaining unchecked items in the cart are automatically updated to `checkout_product = 'Y'` and `is_selected = true`** for next time.
5. Email and SMS confirmation notifications are sent.

- **URL**: `/api/checkoutdr`
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <user_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "order_no": "CHK17265000001234",
  "otp": "123456"
}
```

#### Response Payload (`200 OK`):
```json
{
  "success": true,
  "request": {
    "bfs_msgType": "DR",
    "bfs_bfsTxnId": "BFS20260916001",
    "bfs_benfId": "BE10000099",
    "bfs_remitterOtp": "123456"
  },
  "response": {
    "bfs_msgType": "DR",
    "bfs_bfsTxnId": "BFS20260916001",
    "bfs_responseCode": "00",
    "bfs_debitAuthCode": "00",
    "bfs_responseDesc": "Payment Successful"
  },
  "transaction": {
    "id": 5,
    "order_no": "CHK17265000001234",
    "bfs_txn_id": "BFS20260916001",
    "status": "COMPLETED",
    "bank_id": "01",
    "account_no": "201234567",
    "amount": "1857.45",
    "customer_id": 12,
    "name": "Sonam Dorji",
    "email": "sonam@example.bt",
    "mobile": "17111111",
    "shipping_address": "Thimphu, Bhutan"
  },
  "order": {
    "id": 15,
    "customer_id": 12,
    "checkout_bfs_transaction_id": 5,
    "order_no": "CHK17265000001234",
    "name": "Sonam Dorji",
    "email": "sonam@example.bt",
    "mobile": "17111111",
    "payment_mode": "ONLINE",
    "total_amount": "1857.45",
    "status": "AA"
  }
}
```
