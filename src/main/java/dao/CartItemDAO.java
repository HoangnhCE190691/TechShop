/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.CartItemDisplay;
import utils.DBContext;

/**
 *
 * @author LE HOANG NHAN
 */
public class CartItemDAO extends DBContext {

    // 1. GET ALL (Lấy toàn bộ - Dùng cho Admin xem chơi thôi)
    public List<CartItem> getAllCartItems() {
        List<CartItem> list = new ArrayList<>();
        String sql = "SELECT * FROM cart_items";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new CartItem(
                        rs.getInt("cart_item_id"),
                        rs.getInt("customer_id"),
                        rs.getInt("variant_id"),
                        rs.getInt("quantity"),
                        rs.getTimestamp("created_at")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. GET BY CUSTOMER ID (Quan trọng: Lấy giỏ hàng của 1 khách)
    public List<CartItem> getCartByCustomerId(int customerId) {
        List<CartItem> list = new ArrayList<>();
        String sql = "SELECT * FROM cart_items WHERE customer_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new CartItem(
                        rs.getInt("cart_item_id"),
                        rs.getInt("customer_id"),
                        rs.getInt("variant_id"),
                        rs.getInt("quantity"),
                        rs.getTimestamp("created_at")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. GET BY ID (Lấy 1 dòng cụ thể)
    public CartItem getCartItemById(int id) {
        String sql = "SELECT * FROM cart_items WHERE cart_item_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new CartItem(
                        rs.getInt("cart_item_id"),
                        rs.getInt("customer_id"),
                        rs.getInt("variant_id"),
                        rs.getInt("quantity"),
                        rs.getTimestamp("created_at")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. INSERT (Thêm vào giỏ)
    // Lưu ý: customer_id và variant_id không được trùng cặp đã có
    public void insertCartItem(CartItem item) {
        String sql = "INSERT INTO cart_items (customer_id, variant_id, quantity) VALUES (?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, item.getCustomer_id());
            ps.setInt(2, item.getVariant_id());
            ps.setInt(3, item.getQuantity());
            // created_at tự động lấy GETDATE() bên SQL
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. UPDATE (Sửa số lượng)
    public void updateCartItem(CartItem item) {
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, item.getQuantity());
            ps.setInt(2, item.getCart_item_id());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 6. DELETE (Xóa khỏi giỏ)
    public void deleteCartItem(int id) {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 7. Lấy 1 dòng giỏ theo customer + variant (để add: nếu có thì update quantity)
    public CartItem getByCustomerAndVariant(int customerId, int variantId) {
        String sql = "SELECT * FROM cart_items WHERE customer_id = ? AND variant_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, customerId);
            ps.setInt(2, variantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new CartItem(
                        rs.getInt("cart_item_id"),
                        rs.getInt("customer_id"),
                        rs.getInt("variant_id"),
                        rs.getInt("quantity"),
                        rs.getTimestamp("created_at")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 8. Lấy giỏ của 1 khách kèm tên SP, SKU, giá (để hiển thị trang cart)
    public List<CartItemDisplay> getCartDisplayByCustomerId(int customerId) {
        List<CartItemDisplay> list = new ArrayList<>();
        String sql = "SELECT c.cart_item_id, c.variant_id, c.quantity, p.name AS product_name, pv.sku, pv.selling_price "
                + "FROM cart_items c "
                + "JOIN product_variants pv ON c.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE c.customer_id = ? "
                + "ORDER BY c.created_at DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new CartItemDisplay(
                        rs.getInt("cart_item_id"),
                        rs.getInt("variant_id"),
                        rs.getString("product_name"),
                        rs.getString("sku"),
                        rs.getLong("selling_price"),
                        rs.getInt("quantity")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- MAIN TEST ---
    public static void main(String[] args) {
        CartItemDAO dao = new CartItemDAO();

        // 1. List All
        System.out.println("--- LIST ALL ---");
        List<CartItem> list = dao.getAllCartItems();
        for (CartItem c : list) {
            System.out.println(c);
        }

        // 2. Insert Test
        // YÊU CẦU: Phải có Customer ID = 1 và Variant ID = 1 trong DB trước
        System.out.println("--- INSERT ---");
        // Giả sử khách hàng ID 1 mua sản phẩm ID 1, số lượng 2
        CartItem newItem = new CartItem(0, 1, 2, 2, null);
        dao.insertCartItem(newItem);
        System.out.println("Da them vao gio hang.");

        // 3. Update Test (Sửa số lượng)
        // Giả sử item vừa thêm có ID là 1 (bạn cần thay ID thực tế)
        // CartItem itemToUpdate = dao.getCartItemById(1);
        // if(itemToUpdate != null) {
        //     itemToUpdate.setQuantity(5); // Tăng lên 5 cái
        //     dao.updateCartItem(itemToUpdate);
        //     System.out.println("Da update so luong thanh 5.");
        // }
        // 4. Delete Test
        // dao.deleteCartItem(1);
        // System.out.println("Da xoa khoi gio hang.");
    }
}
