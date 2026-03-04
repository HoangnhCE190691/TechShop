# LOGIC GIỎ HÀNG (CART) – TechShop

Tài liệu mô tả luồng xử lý giỏ hàng dựa trên model hiện tại: `CartItem`, `Order`, `OrderItem`, `InventoryItem`, `ProductVariant`.

---

## 1. Mô hình dữ liệu (đã có)

| Bảng / Model    | Ý nghĩa |
|-----------------|--------|
| **cart_items**  | Giỏ theo **customer_id** + **variant_id** + **quantity**. Mỗi dòng = một biến thể SP với số lượng. |
| **inventory_items** | Kho: mỗi dòng = 1 máy (1 IMEI), có **variant_id**, **status** (IN_STOCK / SOLD). |
| **orders**      | Đơn hàng: customer, địa chỉ, voucher, payment, **total_amount**. |
| **order_items** | Chi tiết đơn: mỗi dòng = **1 inventory_id** (1 máy đã bán) + **selling_price**. |

Quan hệ: **Giỏ (variant + quantity)** → khi thanh toán → **Order** + nhiều **OrderItem** (mỗi OrderItem = 1 inventory_id = 1 IMEI).

---

## 2. Luồng tổng quát

```
[Trang sản phẩm] → Add to cart (variant_id, quantity)
       ↓
[Cart Servlet] → Kiểm tra đăng nhập → Thêm/cập nhật cart_items
       ↓
[Trang giỏ hàng] → Hiển thị list CartItem (kèm tên SP, giá, tồn kho)
       ↓
[Update quantity / Remove item] → Gọi Cart Servlet (action=update / remove)
       ↓
[Checkout] → Nhập địa chỉ, thanh toán, voucher
       ↓
[Cart Servlet action=checkout] → Validate tồn kho → Tạo Order → Tạo OrderItem (theo inventory) → Cập nhật inventory SOLD → Xóa giỏ
```

---

## 3. Chi tiết từng bước

### 3.1. Thêm vào giỏ (Add to cart)

**Input:** `variant_id`, `quantity` (form hoặc link từ trang chi tiết sản phẩm).  
**Điều kiện:** User đã đăng nhập → lấy `customer_id` từ session.

**Logic:**

1. Lấy `customer_id` từ session. Nếu chưa đăng nhập → redirect login hoặc báo lỗi.
2. (Tùy chọn) Kiểm tra tồn kho: số `inventory_items` có `variant_id` và `status = 'IN_STOCK'` ≥ `quantity`. Nếu không đủ → báo “Không đủ hàng” và không thêm.
3. Kiểm tra đã có dòng giỏ cho `(customer_id, variant_id)` chưa:
   - **Có:** `UPDATE cart_items SET quantity = quantity + ? WHERE customer_id = ? AND variant_id = ?`.
   - **Chưa:** `INSERT INTO cart_items (customer_id, variant_id, quantity) VALUES (?, ?, ?)`.

**DAO cần thêm (nếu chưa có):**

- `CartItem getByCustomerAndVariant(int customerId, int variantId)` – để biết đã có hay chưa.
- Hoặc dùng: `getCartByCustomerId` rồi tìm trong list theo `variant_id`.

---

### 3.2. Xem giỏ hàng (View cart)

**Logic:**

1. Lấy `customer_id` từ session.
2. `List<CartItem> cart = CartItemDAO.getCartByCustomerId(customerId)`.
3. Với mỗi `CartItem` (variant_id, quantity), cần hiển thị thêm:
   - Tên sản phẩm (từ **product_variants** JOIN **products**).
   - Giá bán (từ **product_variants.selling_price**).
   - Số tồn kho hiện tại: đếm `inventory_items` có `variant_id` và `status = 'IN_STOCK'`.

Có thể:

- Viết query trong **CartItemDAO**: JOIN `cart_items` với `product_variants` và `products` để lấy tên + giá; subquery hoặc JOIN thêm để đếm tồn kho theo variant.
- Hoặc tạo DTO/bean “CartItemDisplay” (cart_item_id, variant_id, productName, sellingPrice, quantity, stockAvailable) và một method kiểu `getCartDisplayByCustomerId(customerId)` trả về list đó.

Trang JSP: hiển thị list, subtotal từng dòng (sellingPrice * quantity), tổng tiền giỏ.

---

### 3.3. Sửa số lượng (Update quantity)

**Input:** `cart_item_id`, `quantity` mới.

**Logic:**

1. (Tùy chọn) Kiểm tra tồn kho cho variant của dòng đó: nếu `quantity` mới > số inventory IN_STOCK → giới hạn về đúng số tồn hoặc báo lỗi.
2. `CartItemDAO.updateCartItem(item)` với `quantity` mới (đã có sẵn trong DAO).

---

### 3.4. Xóa khỏi giỏ (Remove item)

**Input:** `cart_item_id`.

**Logic:**  
`CartItemDAO.deleteCartItem(cart_item_id)` (đã có).

---

### 3.5. Thanh toán (Checkout)

**Input (từ form):** địa chỉ giao hàng, payment_method_id, voucher_id (nếu có), phone, email (nếu cần).

**Logic từng bước:**

1. **Lấy giỏ:**  
   `List<CartItem> cart = CartItemDAO.getCartByCustomerId(customerId)`.  
   Nếu cart rỗng → redirect giỏ hàng + báo “Giỏ trống”.

2. **Tính tổng tiền và validate tồn kho:**
   - Với mỗi CartItem (variant_id, quantity):
     - Lấy giá bán: `ProductVariant.sellingPrice` (hoặc từ query JOIN).
     - Đếm số inventory: `SELECT COUNT(*) FROM inventory_items WHERE variant_id = ? AND status = 'IN_STOCK'`.
     - Nếu `count < quantity` → báo “Sản phẩm X không đủ hàng (còn count)” và dừng (không tạo đơn).
     - Cộng dồn: `subtotal = sellingPrice * quantity`, rồi `totalAmount += subtotal`.
   - (Tùy chọn) Áp voucher: giảm `totalAmount` theo logic VoucherDAO.

3. **Tạo Order:**  
   `OrderDAO.insertOrder(new Order(customerId, voucherId, paymentMethodId, shippingAddress, totalAmount))`.  
   Sau khi insert cần lấy **order_id** vừa tạo (SELECT SCOPE_IDENTITY() hoặc RETURN_GENERATED_KEYS tùy DB).

4. **Tạo OrderItem và đánh dấu đã bán:**
   - Với mỗi CartItem (variant_id, quantity):
     - Lấy **đúng quantity** bản ghi `inventory_items` có `variant_id` và `status = 'IN_STOCK'` (ví dụ `ORDER BY inventory_id` và `LIMIT quantity` hoặc `TOP quantity`).
     - Với mỗi inventory_id trong số đó:
       - `OrderItemDAO.insertOrderItem(new OrderItem(orderId, inventoryId, sellingPrice))`.
       - `InventoryItemDAO.updateInventory(...)` set **status = 'SOLD'** cho inventory_id đó.

5. **Xóa giỏ:**  
   Xóa toàn bộ cart của customer:  
   `DELETE FROM cart_items WHERE customer_id = ?`  
   (cần thêm method `deleteByCustomerId` trong CartItemDAO nếu chưa có).

6. **Redirect:**  
   Trang “Đặt hàng thành công” hoặc chi tiết đơn (order detail) + set session message.

---

## 4. Cart Servlet – gợi ý action

| Action   | Method | Tham số              | Mô tả ngắn |
|----------|--------|----------------------|------------|
| view     | GET    | —                    | Hiển thị trang giỏ (đã có: forward cartPage.jsp). Cần set list cart (có tên SP, giá, tồn kho) vào request. |
| add      | POST   | variant_id, quantity | Thêm/cộng dồn vào giỏ (xem 3.1). |
| update   | POST   | cart_item_id, quantity | Cập nhật số lượng (3.3). |
| remove   | POST   | cart_item_id         | Xóa 1 dòng giỏ (3.4). |
| checkout | POST   | shipping_address, payment_method_id, voucher_id (optional), ... | Thực hiện luồng 3.5. |

Trong `doGet`: nếu `action == null` hoặc `view` → load giỏ và forward.  
Trong `doPost`: đọc `action` từ request → gọi đúng bước (add/update/remove/checkout) rồi redirect (về giỏ, về trang SP, hoặc trang thành công).

---

## 5. Cần bổ sung trong DAO / DB

- **CartItemDAO:**
  - `CartItem getByCustomerAndVariant(int customerId, int variantId)` (hoặc dùng getCartByCustomerId rồi duyệt).
  - `void deleteByCustomerId(int customerId)` – xóa hết giỏ sau khi checkout.
- **InventoryItemDAO:**
  - `List<InventoryItem> getAvailableByVariantId(int variantId, int limit)` – lấy tối đa `limit` bản ghi có `variant_id` và `status = 'IN_STOCK'` (để khi checkout gán vào OrderItem và đổi status SOLD).
- **OrderDAO:**
  - Sau `insertOrder` cần lấy `order_id` vừa sinh (SCOPE_IDENTITY / getGeneratedKeys) để dùng cho OrderItem.

---

## 6. Tóm tắt luồng Checkout (sơ đồ)

```
Cart (variant_id, quantity)
    ↓
Với mỗi (variant_id, quantity):
    - Kiểm tra số inventory IN_STOCK >= quantity
    - Tính subtotal = sellingPrice * quantity
    ↓
Tính totalAmount (có thể trừ voucher)
    ↓
INSERT orders → lấy order_id
    ↓
Với mỗi (variant_id, quantity):
    - Lấy đủ quantity bản ghi inventory (IN_STOCK)
    - Với mỗi inventory_id: INSERT order_items; UPDATE inventory_items SET status='SOLD'
    ↓
DELETE cart_items WHERE customer_id = ?
    ↓
Redirect + thông báo thành công
```

Bạn có thể implement từng phần (add → view → update/remove → checkout) và test từng bước. Nếu cần, có thể viết tiếp phần code mẫu cho từng action trong `cartServlet` hoặc từng method DAO cụ thể.
