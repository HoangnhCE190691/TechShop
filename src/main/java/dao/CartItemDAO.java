/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.CartItemDisplay;
import utils.DBContext;

/**
 * @author LE HOANG NHAN
 */
public class CartItemDAO extends DBContext {

    // Đọc một dòng bảng giỏ hàng thành đối tượng trong chương trình (chưa ghép tên sản phẩm hay ảnh).
    private CartItem mapCartItem(ResultSet rs) throws SQLException {
        return new CartItem(
                rs.getInt("cart_item_id"),
                rs.getInt("customer_id"),
                rs.getInt("variant_id"),
                rs.getInt("quantity"),
                rs.getTimestamp("created_at")
        );
    }

    // Lấy toàn bộ dòng trong bảng giỏ (thường chỉ dùng khi kiểm thử hoặc gỡ lỗi).
    public List<CartItem> getAllCartItems() {
        List<CartItem> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT cart_item_id, customer_id, variant_id, quantity, created_at FROM cart_items";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCartItem(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy giỏ của một khách dưới dạng danh sách đơn giản; giao diện thường dùng hàm có đủ tên sản phẩm và ảnh.
    public List<CartItem> getCartByCustomerId(int customerId) {
        List<CartItem> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT cart_item_id, customer_id, variant_id, quantity, created_at FROM cart_items WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCartItem(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy một dòng giỏ theo mã dòng; trước khi sửa hoặc xóa nên kiểm tra đúng khách đang đăng nhập.
    public CartItem getCartItemById(int id) {
        if (conn == null) {
            return null;
        }
        String sql = "SELECT cart_item_id, customer_id, variant_id, quantity, created_at FROM cart_items WHERE cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCartItem(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm dòng mới vào giỏ khi chưa có cùng khách và cùng biến thể; nếu đã có thì thường chỉ cập nhật số lượng.
    public boolean insertCartItem(CartItem item) {
        if (conn == null || item == null) {
            return false;
        }
        String sql = "INSERT INTO cart_items (customer_id, variant_id, quantity) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getCustomer_id());
            ps.setInt(2, item.getVariant_id());
            ps.setInt(3, item.getQuantity());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Chỉ đổi số lượng trên dòng có sẵn; đổi sang sản phẩm khác thì tầng trên phải xóa dòng cũ hoặc thêm dòng mới.
    public boolean updateCartItem(CartItem item) {
        if (conn == null || item == null) {
            return false;
        }
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getQuantity());
            ps.setInt(2, item.getCart_item_id());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa một dòng khỏi giỏ hàng.
    public void deleteCartItem(int id) {
        if (conn == null) {
            return;
        }
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Sau khi thanh toán thành công, xóa sạch giỏ của khách đó.
    public void deleteCartByCustomerId(int customerId) {
        if (conn == null) {
            return;
        }
        String sql = "DELETE FROM cart_items WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Tìm dòng giỏ theo khách và biến thể sản phẩm; có sẵn thì cộng số lượng thay vì thêm dòng mới.
    public CartItem getByCustomerAndVariant(int customerId, int variantId) {
        if (conn == null) {
            return null;
        }
        String sql = "SELECT cart_item_id, customer_id, variant_id, quantity, created_at FROM cart_items WHERE customer_id = ? AND variant_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCartItem(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy giỏ để hiển thị: tên sản phẩm, mã biến thể, giá bán, ảnh đại diện (một ảnh làm mặt cho sản phẩm).
    public List<CartItemDisplay> getCartDisplayByCustomerId(int customerId) {
        List<CartItemDisplay> list = new ArrayList<>();
        if (conn == null) {
            return list;
        }
        String sql = "SELECT c.cart_item_id, c.variant_id, c.quantity, "
                + "p.name AS product_name, pv.sku, pv.selling_price, "
                + "(SELECT TOP 1 pi.image_url "
                + " FROM product_images pi "
                + " WHERE pi.product_id = p.product_id AND pi.is_thumbnail = 1) AS thumbnail_url "
                + "FROM cart_items c "
                + "JOIN product_variants pv ON c.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE c.customer_id = ? "
                + "ORDER BY c.created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CartItemDisplay(
                            rs.getInt("cart_item_id"),
                            rs.getInt("variant_id"),
                            rs.getString("product_name"),
                            rs.getString("sku"),
                            rs.getLong("selling_price"),
                            rs.getInt("quantity"),
                            rs.getString("thumbnail_url")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tổng số lượng món trong giỏ (ví dụ hai áo cộng một tai nghe bằng ba món).
    public int getCartTotalQuantityByCustomerId(int customerId) {
        if (conn == null) {
            return 0;
        }
        String sql = "SELECT COALESCE(SUM(quantity), 0) FROM cart_items WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Số dòng trong giỏ (mỗi biến thể một dòng), dùng hiển thị kiểu “ba loại hàng trong giỏ”.
    public int getCartItemCountByCustomerId(int customerId) {
        if (conn == null) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM cart_items WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
