package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import utils.DBContext;

public class ProductDAO extends DBContext {

    // 1. Lấy tất cả sản phẩm
    // Trong ProductDAO.java
    public List<Product> getAllProduct() {
        List<Product> list = new ArrayList<>();
        // Thực hiện JOIN để lấy Category Name và Brand Name
        String sql = "SELECT p.*, c.category_name, b.brand_name "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "ORDER BY p.product_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = mapResultSetToProduct(rs);
                // Gán thêm tên từ kết quả JOIN
                p.setCategoryName(rs.getString("category_name"));
                p.setBrandName(rs.getString("brand_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy sản phẩm theo ID
    public Product getProductById(int id) {
        // SỬA: Phải JOIN với bảng categories và brands để lấy tên hiển thị
        String sql = "SELECT p.*, c.category_name, b.brand_name "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Product p = mapResultSetToProduct(rs);
                // QUAN TRỌNG: Phải gán thêm tên từ kết quả truy vấn vào object
                p.setCategoryName(rs.getString("category_name"));
                p.setBrandName(rs.getString("brand_name"));
                return p;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. Kiểm tra sản phẩm đã có trong đơn hàng chưa (Để quyết định xóa mềm/cứng)
    public int countProductInOrderDetails(int productId) {
        String sql = "SELECT COUNT(*) FROM order_items oi "
                + "JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "JOIN product_variants pv ON ii.variant_id = pv.variant_id "
                + "WHERE pv.product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 4. Kiểm tra trùng tên
    public boolean isProductDuplicate(String name, int categoryId, int brandId, int excludeId) {
        // Câu lệnh SQL kiểm tra trùng tên + danh mục + thương hiệu
        // nhưng bỏ qua bản ghi có ID hiện tại (dùng cho Update)
        String sql = "SELECT COUNT(*) FROM products "
                + "WHERE name = ? AND category_id = ? AND brand_id = ? AND product_id <> ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, categoryId);
            ps.setInt(3, brandId);
            ps.setInt(4, excludeId); // Nếu là Add, truyền vào số 0

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5. Thêm mới sản phẩm
    public int insertProduct(Product p) {
        String sql = "INSERT INTO products (name, category_id, brand_id, description, status, created_at, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, p.getName());
            ps.setInt(2, p.getCategoryId());
            ps.setInt(3, p.getBrandId());
            ps.setString(4, p.getDescription());
            ps.setString(5, p.getStatus());
            ps.setTimestamp(6, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setObject(7, p.getCreatedBy()); // ID của admin đang đăng nhập
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // 6. Cập nhật sản phẩm
    public void updateProduct(Product p) {
        String sql = "UPDATE products SET name=?, category_id=?, brand_id=?, description=?, status=?, updated_at=? WHERE product_id=?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, p.getName());
            ps.setInt(2, p.getCategoryId());
            ps.setInt(3, p.getBrandId());
            ps.setString(4, p.getDescription());
            ps.setString(5, p.getStatus());
            ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(7, p.getProductId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 7. Xóa cứng
    public void deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 9. Lấy sản phẩm theo Category (Có ảnh và giá)
    public List<Product> getProductsByCategoryId(int categoryId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, c.category_name, b.brand_name, "
                + "MIN(pv.selling_price) as min_price, "
                + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE p.category_id = ? AND p.status = 'ACTIVE' "
                + "GROUP BY p.product_id, p.name, p.category_id, p.brand_id, p.description, p.status, p.created_at, p.created_by, p.updated_by, p.updated_at, c.category_name, b.brand_name "
                + "ORDER BY p.product_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setInt(2, categoryId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = mapResultSetToProduct(rs);
                p.setCategoryName(rs.getString("category_name"));
                p.setBrandName(rs.getString("brand_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 10. Lấy sản phẩm theo Brand (Có ảnh và giá)
    public List<Product> getProductsByBrandId(int brandId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, c.category_name, b.brand_name, "
                + "MIN(pv.selling_price) as min_price, "
                + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE p.brand_id = ? AND p.status = 'ACTIVE' "
                + "GROUP BY p.product_id, p.name, p.category_id, p.brand_id, p.description, p.status, p.created_at, p.created_by, p.updated_by, p.updated_at, c.category_name, b.brand_name "
                + "ORDER BY p.product_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setInt(2, brandId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = mapResultSetToProduct(rs);
                p.setCategoryName(rs.getString("category_name"));
                p.setBrandName(rs.getString("brand_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 11. Lấy sản phẩm có Filter
    public List<Product> getFilteredProducts(String keyword, Integer categoryId, Integer brandId, Double minPrice,
            Double maxPrice) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, c.category_name, b.brand_name, "
                        + "MIN(pv.selling_price) as min_price, "
                        + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url "
                        + "FROM products p "
                        + "LEFT JOIN categories c ON p.category_id = c.category_id "
                        + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                        + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                        + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                        + "WHERE p.status = 'ACTIVE' ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND p.name LIKE ? ");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ? ");
        }
        if (brandId != null && brandId > 0) {
            sql.append(" AND p.brand_id = ? ");
        }

        sql.append(
                "GROUP BY p.product_id, p.name, p.category_id, p.brand_id, p.description, p.status, p.created_at, p.created_by, p.updated_by, p.updated_at, c.category_name, b.brand_name ");

        // HAVING để so sánh với min_price (do min_price được tạo ra từ GROUP BY nên
        // phải dùng HAVING)
        if (minPrice != null || maxPrice != null) {
            sql.append(" HAVING 1=1 ");
            if (minPrice != null) {
                sql.append(" AND MIN(pv.selling_price) >= ? ");
            }
            if (maxPrice != null) {
                sql.append(" AND MIN(pv.selling_price) <= ? ");
            }
        }

        sql.append(" ORDER BY p.product_id DESC");

        try {
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
            }
            if (categoryId != null && categoryId > 0) {
                ps.setInt(paramIndex++, categoryId);
            }
            if (brandId != null && brandId > 0) {
                ps.setInt(paramIndex++, brandId);
            }
            if (minPrice != null) {
                ps.setDouble(paramIndex++, minPrice);
            }
            if (maxPrice != null) {
                ps.setDouble(paramIndex++, maxPrice);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = mapResultSetToProduct(rs);
                p.setCategoryName(rs.getString("category_name"));
                p.setBrandName(rs.getString("brand_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 8. Xóa mềm (Chuyển Inactive)
    public void softDeleteProduct(int id) {
        String sql = "UPDATE products SET status = 'Inactive', updated_at = ? WHERE product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Product mapResultSetToProduct(ResultSet rs) throws Exception {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setName(rs.getString("name"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setBrandId(rs.getInt("brand_id"));
        p.setDescription(rs.getString("description"));
        p.setStatus(rs.getString("status"));
        Timestamp ct = rs.getTimestamp("created_at");
        if (ct != null) {
            p.setCreatedAt(ct.toLocalDateTime());
        }
        Timestamp ut = rs.getTimestamp("updated_at");
        if (ut != null) {
            p.setUpdatedAt(ut.toLocalDateTime());
        }

        // Map các cột UI dựa theo câu Query
        java.sql.ResultSetMetaData rsmd = rs.getMetaData();
        for (int i = 1; i <= rsmd.getColumnCount(); i++) {
            String colName = rsmd.getColumnName(i);
            if (colName.equalsIgnoreCase("min_price")) {
                p.setMinPrice(rs.getDouble("min_price"));
            }
            if (colName.equalsIgnoreCase("thumbnail_url")) {
                p.setThumbnailUrl(rs.getString("thumbnail_url"));
            }
        }

        return p;
    }
}
