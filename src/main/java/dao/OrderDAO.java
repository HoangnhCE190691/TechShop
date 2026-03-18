/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Order;
import model.Voucher;
import utils.DBContext;
import java.sql.Statement;

/**
 *
 * @author WIN11
 */
public class OrderDAO extends DBContext {

    /**
     * Inserts order and returns the generated order_id; returns 0 on failure.
     */
    public int insertOrder(Order o) {
        String sql = """
        INSERT INTO orders
        (customer_id, voucher_id, payment_method_id, shipping_address, total_amount)
        VALUES (?, ?, ?, ?, ?)
        """;
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, o.getCustomerId());
            if (o.getVoucher() == null) {
                ps.setNull(2, java.sql.Types.INTEGER);
            } else {
                ps.setInt(2, o.getVoucher().getVoucherId());
            }
            ps.setInt(3, o.getPaymentMethodId());
            ps.setString(4, o.getShippingAddress());
            ps.setBigDecimal(5, o.getTotalAmount());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ===== READ ALL =====
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Voucher voucher = null;
                int vId = rs.getInt("voucher_id");
                if (!rs.wasNull()) {
                    voucher = new Voucher();
                    voucher.setVoucherId(vId);
                }

                list.add(new Order(
                        rs.getInt("order_id"),
                        rs.getInt("customer_id"),
                        voucher,
                        rs.getInt("payment_method_id"),
                        rs.getString("shipping_address"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("payment_status"),
                        rs.getString("status"),
                        rs.getTimestamp("created_at")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getAllOrdersWithFullInfo() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, c.full_name, v.code AS code, "
                + "(SELECT TOP 1 p.name FROM order_items oi "
                + " JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + " JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + " JOIN products p ON pv.product_id = p.product_id "
                + " WHERE oi.order_id = o.order_id) as representative_product, "
                + "(SELECT COUNT(*) FROM order_items WHERE order_id = o.order_id) as total_items "
                + "FROM orders o "
                + "JOIN customers c ON o.customer_id = c.customer_id "
                + "LEFT JOIN vouchers v ON o.voucher_id = v.voucher_id "
                //                + "WHERE EXISTS (SELECT 1 FROM order_items WHERE order_id = o.order_id)"
                + "ORDER BY o.created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {

                Voucher voucher = null;
                int vId = rs.getInt("voucher_id");
                if (!rs.wasNull()) {
                    voucher = new Voucher();
                    voucher.setVoucherId(vId);
                    voucher.setCode(rs.getString("code"));
                }

                Order o = new Order(
                        rs.getInt("order_id"),
                        rs.getInt("customer_id"),
                        voucher,
                        rs.getInt("payment_method_id"),
                        rs.getString("shipping_address"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("payment_status"),
                        rs.getString("status"),
                        rs.getTimestamp("created_at")
                );

                o.setCustomerName(rs.getString("full_name"));
                String pName = rs.getString("representative_product");
                int count = rs.getInt("total_items");
                String finalName = (pName != null) ? pName : "No products";
                if (count > 1) {
                    finalName += " (+" + (count - 1) + " items)";
                }
                o.setOrderName(finalName);

                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== READ BY CUSTOMER (for user order history) =====
    public List<Order> getOrdersByCustomerWithSummary(int customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, c.full_name, v.code as voucher_code, "
                // Tên sản phẩm đại diện: ưu tiên từ order_items, nếu đã xóa (đơn hủy) thì lấy từ cancelled_order_items
                + "COALESCE( "
                + "  (SELECT TOP 1 p.name FROM order_items oi "
                + "   JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "   JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "   JOIN products p ON pv.product_id = p.product_id "
                + "   WHERE oi.order_id = o.order_id), "
                + "  (SELECT TOP 1 p.name FROM cancelled_order_items coi "
                + "   JOIN inventory_items ii ON coi.inventory_id = ii.inventory_id "
                + "   JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "   JOIN products p ON pv.product_id = p.product_id "
                + "   WHERE coi.order_id = o.order_id) "
                + ") as representative_product, "
                // Ảnh đại diện: tương tự, ưu tiên từ order_items, fallback cancelled_order_items
                + "COALESCE( "
                + "  (SELECT TOP 1 pi.image_url FROM order_items oi "
                + "   JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "   JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "   JOIN products p ON pv.product_id = p.product_id "
                + "   LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "   WHERE oi.order_id = o.order_id), "
                + "  (SELECT TOP 1 pi.image_url FROM cancelled_order_items coi "
                + "   JOIN inventory_items ii ON coi.inventory_id = ii.inventory_id "
                + "   JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "   JOIN products p ON pv.product_id = p.product_id "
                + "   LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "   WHERE coi.order_id = o.order_id) "
                + ") as product_image_url, "
                // Tổng số items: đang còn trong order_items + đã snapshot ở cancelled_order_items
                + "((SELECT COUNT(*) FROM order_items WHERE order_id = o.order_id) "
                + " + (SELECT ISNULL(SUM(quantity), 0) FROM cancelled_order_items WHERE order_id = o.order_id)) as total_items "
                + "FROM orders o "
                + "JOIN customers c ON o.customer_id = c.customer_id "
                + "LEFT JOIN vouchers v ON o.voucher_id = v.voucher_id "
                + "WHERE o.customer_id = ? "
                + "ORDER BY o.created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                Voucher voucher = null;
                int vId = rs.getInt("voucher_id");
                if (!rs.wasNull()) {
                    voucher = new Voucher();
                    voucher.setVoucherId(vId);
                    voucher.setCode(rs.getString("voucher_code"));
                }

                Order o = new Order(
                        rs.getInt("order_id"),
                        rs.getInt("customer_id"),
                        voucher,
                        rs.getInt("payment_method_id"),
                        rs.getString("shipping_address"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("payment_status"),
                        rs.getString("status"),
                        rs.getTimestamp("created_at")
                );
                o.setCustomerName(rs.getString("full_name"));

                String pName = rs.getString("representative_product");
                int count = rs.getInt("total_items");

                String finalName = (pName != null) ? pName : "No products";
                if (count > 1) {
                    finalName += " (+" + (count - 1) + " items)";
                }

                o.setOrderName(finalName);
                o.setProductImageUrl(rs.getString("product_image_url"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== READ BY ID =====
    public Order getOrderById(int id) {
        String sql = "SELECT o.*, c.full_name, c.email, c.phone_number, pm.method_name "
                + "FROM orders o "
                + "JOIN customers c ON o.customer_id = c.customer_id "
                + "LEFT JOIN payment_methods pm ON o.payment_method_id = pm.method_id "
                + "WHERE o.order_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setCustomerId(rs.getInt("customer_id"));
                order.setShippingAddress(rs.getString("shipping_address"));
                order.setTotalAmount(rs.getBigDecimal("total_amount"));
                order.setStatus(rs.getString("status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setPaymentMethodName(rs.getString("method_name"));

                order.setCustomerName(rs.getNString("full_name"));
                order.setEmail(rs.getString("email"));
                order.setPhone(rs.getString("phone_number"));

                return order;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getCustomerIdByOrderId(int orderId) {
        String sql = "SELECT customer_id FROM orders WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("customer_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    //Get order detail with IMEI
    public List<Map<String, Object>> getOrderDetailsWithIMEI(int orderId) {
        List<Map<String, Object>> details = new ArrayList<>();
        String sql = "SELECT p.name, pv.sku, ii.imei, oi.selling_price, pi.image_url "
                + "FROM order_items oi "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE oi.order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("productName", rs.getString("name"));
                item.put("sku", rs.getString("sku"));
                item.put("imei", rs.getString("imei"));
                item.put("price", rs.getBigDecimal("selling_price"));
                item.put("imageUrl", rs.getString("image_url"));
                details.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    public List<Map<String, Object>> getOrderDetails(int orderId) {
        List<Map<String, Object>> details = new ArrayList<>();
        String sql = "SELECT p.name, pv.sku, COUNT(*) as quantity, "
                + "oi.selling_price, pi.image_url "
                + "FROM order_items oi "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE oi.order_id = ? "
                + "GROUP BY p.name, pv.sku, oi.selling_price, pi.image_url";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("productName", rs.getString("name"));
                item.put("sku", rs.getString("sku"));
                item.put("quantity", rs.getInt("quantity"));
                item.put("price", rs.getBigDecimal("selling_price"));
                item.put("imageUrl", rs.getString("image_url"));
                details.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    /**
     * Lấy chi tiết đơn hàng cho các đơn đã hủy, đọc từ bảng cancelled_order_items.
     */
    public List<Map<String, Object>> getCancelledOrderDetails(int orderId) {
        List<Map<String, Object>> details = new ArrayList<>();
        String sql = "SELECT p.name, pv.sku, SUM(coi.quantity) as quantity, "
                + "coi.unit_price, pi.image_url "
                + "FROM cancelled_order_items coi "
                + "JOIN inventory_items ii ON coi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE coi.order_id = ? "
                + "GROUP BY p.name, pv.sku, coi.unit_price, pi.image_url";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("productName", rs.getString("name"));
                item.put("sku", rs.getString("sku"));
                item.put("quantity", rs.getInt("quantity"));
                item.put("price", rs.getBigDecimal("unit_price"));
                item.put("imageUrl", rs.getString("image_url"));
                details.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    //get all order status
    public List<Map<String, String>> getAllOrderStatuses() {
        List<Map<String, String>> statusList = new ArrayList<>();
        String sql = "SELECT status_code, status_name, is_final FROM order_statuses ORDER BY step_order";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> status = new HashMap<>();
                status.put("code", rs.getString("status_code"));
                status.put("name", rs.getNString("status_name"));
                status.put("isFinal", String.valueOf(rs.getBoolean("is_final")));
                statusList.add(status);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return statusList;
    }
// Lấy status tiếp theo (step_order lớn hơn 1 bậc, không phải CANCELLED/final cancel)

    public String getNextStatus(String currentCode) {
        String sql = """
        SELECT TOP 1 status_code FROM order_statuses
        WHERE step_order > (SELECT step_order FROM order_statuses WHERE UPPER(status_code) = UPPER(?))
        AND UPPER(status_code) != 'CANCELLED'
        ORDER BY step_order ASC
    """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, currentCode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("status_code");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // null = đang ở final, không có next
    }

// Lấy code của status CANCELLED (hoặc is_final=true và là cancel)
    public String getCancelledStatusCode() {
        String sql = "SELECT TOP 1 status_code FROM order_statuses WHERE UPPER(status_code) = 'CANCELLED'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("status_code");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "CANCELLED";
    }

    // ===== Update Order =====
    public void updateOrderCurrentStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Update order
    public boolean updateOrderFull(int id, String address, String status, String paymentStatus) {
        String sql = "UPDATE orders SET shipping_address = ?, status = ?, payment_status = ? WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, address);
            ps.setString(2, status);
            ps.setString(3, paymentStatus);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    //==== Update order's payment status ====

    public void updateOrderPaymentStatus(int orderId, String paymentStatus) {
        String sql = "UPDATE orders SET payment_status = ? WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateInventoryStatusByOrderId(int orderId, String inventoryStatus) {
        String sql = """
        UPDATE inventory_items SET status = ?
        WHERE inventory_id IN (
            SELECT inventory_id FROM order_items WHERE order_id = ?
        )
    """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, inventoryStatus);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Hủy đơn chưa thanh toán (VNPay bỏ giữa chừng / thanh toán thất bại). Không xóa đơn: chỉ hoàn inventory, xóa order_items, set status = CANCELLED để vẫn "mò" được trong lịch sử.
     */
    public void cancelUnpaidOrder(int orderId) {
        // 1. Snapshot chi tiết đơn vào bảng lịch sử (giữ lại thông tin đơn đã hủy)
        String sqlSnapshot = """
            INSERT INTO cancelled_order_items (order_id, inventory_id, quantity, unit_price, snapshot_created_at)
            SELECT oi.order_id,
                   oi.inventory_id,
                   1 AS quantity,
                   oi.selling_price AS unit_price,
                   GETDATE()
            FROM order_items oi
            WHERE oi.order_id = ?
        """;

        // 2. Hoàn lại inventory về IN_STOCK
        String sqlInventory = """
        UPDATE inventory_items SET status = 'IN_STOCK'
        WHERE inventory_id IN (
            SELECT inventory_id FROM order_items WHERE order_id = ?
        )
    """;
        // 3. Xóa order_items (inventory đã hoàn về kho, chi tiết đã lưu ở bảng cancelled_order_items)
        String sqlItems = "DELETE FROM order_items WHERE order_id = ?";

        // 4. Cập nhật đơn thành CANCELLED
        String cancelledCode = getCancelledStatusCode();
        String sqlUpdateOrder = "UPDATE orders SET status = ? WHERE order_id = ?";

        try {
            PreparedStatement ps0 = conn.prepareStatement(sqlSnapshot);
            ps0.setInt(1, orderId);
            ps0.executeUpdate();

            PreparedStatement ps1 = conn.prepareStatement(sqlInventory);
            ps1.setInt(1, orderId);
            ps1.executeUpdate();

            PreparedStatement ps3 = conn.prepareStatement(sqlUpdateOrder);
            ps3.setString(1, cancelledCode);
            ps3.setInt(2, orderId);
            ps3.executeUpdate();

            PreparedStatement ps2 = conn.prepareStatement(sqlItems);
            ps2.setInt(1, orderId);
            ps2.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean cancelOrderByCustomer(int orderId, int customerId) {
        // Kiểm tra đơn thuộc customer (bỏ điều kiện step_order/payment_status để tránh khó hủy)
        String sqlCheck = """
        SELECT o.order_id FROM orders o
        WHERE o.order_id = ? AND o.customer_id = ?
    """;
        try {
            PreparedStatement ps = conn.prepareStatement(sqlCheck);
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                return false; // không hợp lệ
            }
            // 1. Snapshot chi tiết đơn vào bảng lịch sử (giữ lại thông tin đơn đã hủy)
            String sqlSnapshot = """
                INSERT INTO cancelled_order_items (order_id, inventory_id, quantity, unit_price, snapshot_created_at)
                SELECT oi.order_id,
                       oi.inventory_id,
                       1 AS quantity,
                       oi.selling_price AS unit_price,
                       GETDATE()
                FROM order_items oi
                WHERE oi.order_id = ?
            """;
            PreparedStatement psSnap = conn.prepareStatement(sqlSnapshot);
            psSnap.setInt(1, orderId);
            psSnap.executeUpdate();

            // 2. Hoàn inventory về IN_STOCK để kho dùng lại cho đơn khác
            String sqlInv = """
            UPDATE inventory_items SET status = 'IN_STOCK'
            WHERE inventory_id IN (
                SELECT inventory_id FROM order_items WHERE order_id = ?
            )
        """;
            PreparedStatement ps2 = conn.prepareStatement(sqlInv);
            ps2.setInt(1, orderId);
            ps2.executeUpdate();

            // 3. Xóa order_items của đơn hủy (chi tiết đã nằm ở cancelled_order_items)
            String sqlDeleteItems = "DELETE FROM order_items WHERE order_id = ?";
            PreparedStatement ps2b = conn.prepareStatement(sqlDeleteItems);
            ps2b.setInt(1, orderId);
            ps2b.executeUpdate();

            // Lấy status_code của CANCELLED
            String cancelledCode = getCancelledStatusCode();

            // Cập nhật status đơn thành CANCELLED
            String sqlUpdate = "UPDATE orders SET status = ? WHERE order_id = ?";
            PreparedStatement ps3 = conn.prepareStatement(sqlUpdate);
            ps3.setString(1, cancelledCode);
            ps3.setInt(2, orderId);
            ps3.executeUpdate();

            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    //Test
    public static void main(String[] args) {
        // OrderDAO dao = new OrderDAO();

        // ===== 1. INSERT ORDER =====
//        Order newOrder = new Order(
//                1, // customer_id (PHẢI TỒN TẠI)
//                null, // voucher_id (có thể null)
//                1, // payment_method_id (PHẢI TỒN TẠI)
//                "123 Nguyễn Văn A, Q1, HCM",
//                new BigDecimal("15000000")
//        );
//        dao.insertOrder(newOrder);
//        System.out.println(">>> Insert order OK");
        // ===== 2. GET ALL ORDERS =====
//        System.out.println(">>> Get all orders:");
//        List<Order> allOrders = dao.getAllOrders();
//        for (Order o : allOrders) {
//            System.out.println(o);
//        }
        // ===== 3. GET ORDER BY ID =====
//        System.out.println(">>> Get order by ID = 1");
//        Order order = dao.getOrderById(1);
//        System.out.println(order);
        // ===== 4. UPDATE ORDER STATUS =====
//        dao.updateOrderCurrentStatus(1, "APPROVED");
//        System.out.println(">>> Update order current status OK");
        // ===== 5. UPDATE PAYMENT STATUS =====
//        dao.updateOrderPaymentStatus(1, "PAID");
//        System.out.println(">>> Update payment status OK");
    }

}
