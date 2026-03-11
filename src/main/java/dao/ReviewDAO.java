package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.Review;
import utils.DBContext;

public class ReviewDAO extends DBContext {

    // 1. Lấy tất cả đánh giá
    public List<Review> getAllReviews() {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, c.full_name as customer_name, p.name as product_name "
                + "FROM reviews r "
                + "JOIN customers c ON r.customer_id = c.customer_id "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "ORDER BY r.created_at DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Timestamp ts = rs.getTimestamp("created_at");
                LocalDateTime ldt = (ts != null) ? ts.toLocalDateTime() : null;

                Review r = new Review(
                        rs.getInt("review_id"),
                        rs.getInt("customer_id"),
                        rs.getInt("order_item_id"),
                        rs.getInt("rating"),
                        rs.getString("comment"),
                        ldt
                );
                r.setCustomerName(rs.getString("customer_name"));
                r.setProductName(rs.getString("product_name"));
                r.setStatus(rs.getString("status")); // Thêm dòng này
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void toggleReviewStatus(int id, String newStatus) {
        String sql = "UPDATE reviews SET status = ? WHERE review_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus); // Truyền status mới vào (VISIBLE hoặc HIDDEN)
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 3. Lấy chi tiết một đánh giá
    public Review getReviewById(int id) {
        String sql = "SELECT r.*, c.full_name as customer_name, p.name as product_name "
                + "FROM reviews r "
                + "JOIN customers c ON r.customer_id = c.customer_id "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE r.review_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Review r = mapResultSet(rs);
                r.setCustomerName(rs.getString("customer_name"));
                r.setProductName(rs.getString("product_name"));
                return r;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<String> getReviewedProductNames() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT p.name FROM reviews r "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countTotalReviews() {
        String sql = "SELECT COUNT(*) FROM reviews";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
// 5. Lấy đánh giá của một sản phẩm

    public List<Review> getReviewsByProductId(int productId) {
        List<Review> list = new ArrayList<>();
        // Thêm điều kiện lọc status ở mệnh đề WHERE
        String sql = "SELECT r.*, c.full_name as customer_name, p.name as product_name "
                + "FROM reviews r "
                + "JOIN customers c ON r.customer_id = c.customer_id "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE p.product_id = ? AND r.status = 'VISIBLE' " // Chỉ lấy review công khai 
                + "ORDER BY r.created_at DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Review r = mapResultSet(rs);
                r.setCustomerName(rs.getString("customer_name"));
                r.setProductName(rs.getString("product_name"));
                r.setStatus(rs.getString("status"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. Lấy đánh giá của một User cho một sản phẩm (để User xem/sửa đánh giá của
    // mình)
    public Review getReviewByCustomerAndProduct(int customerId, int productId) {
        String sql = "SELECT r.*, c.full_name as customer_name, p.name as product_name "
                + "FROM reviews r "
                + "JOIN customers c ON r.customer_id = c.customer_id "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE r.customer_id = ? AND p.product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Review r = mapResultSet(rs);
                r.setCustomerName(rs.getString("customer_name"));
                r.setProductName(rs.getString("product_name"));
                return r;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 7. Kiểm tra User có mua sản phẩm này chưa, và trả về order_item_id đầu tiên
    // chưa được review
    public int getUnreviewedOrderItemId(int customerId, int productId) {
        String sql = "SELECT TOP 1 oi.order_item_id "
                + "FROM order_items oi "
                + "JOIN orders o ON oi.order_id = o.order_id "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "WHERE o.customer_id = ? AND pv.product_id = ? "
                + "  AND (o.status = 'COMPLETED' OR o.status = 'DELIVERED') "
                + "  AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.order_item_id = oi.order_item_id)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("order_item_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1; // Không tìm thấy (chưa mua hoặc đã review hết)
    }

    // 8. User Thêm đánh giá mới
    public void addReview(Review r) {
        String sql = "INSERT INTO reviews (customer_id, order_item_id, rating, comment) VALUES (?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, r.getCustomerId());
            ps.setInt(2, r.getOrderItemId());
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getComment());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 9. User Sửa đánh giá
    public void updateReview(Review r) {
        String sql = "UPDATE reviews SET rating = ?, comment = ? WHERE review_id = ? AND customer_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, r.getRating());
            ps.setString(2, r.getComment());
            ps.setInt(3, r.getReviewId());
            ps.setInt(4, r.getCustomerId()); // Đảm bảo chỉ tự sửa đánh giá của mình
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Review mapResultSet(ResultSet rs) throws Exception {
        Review r = new Review();
        r.setReviewId(rs.getInt("review_id"));
        r.setCustomerId(rs.getInt("customer_id"));
        r.setOrderItemId(rs.getInt("order_item_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setStatus(rs.getString("status")); // Thêm dòng này
        java.sql.Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            r.setCreatedAt(ts.toLocalDateTime());
        }
        return r;
    }
}
