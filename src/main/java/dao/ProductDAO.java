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
    public List<Product> getAllProduct() {
        List<Product> list = new ArrayList<>();
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
                p.setCategoryName(rs.getString("category_name"));
                p.setBrandName(rs.getString("brand_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả sản phẩm kèm tổng tồn kho hiện tại (IN_STOCK) để dùng cho màn
     * Import Receipt Item.
     */
    public List<Product> getAllProductWithStock() {
        List<Product> list = new ArrayList<>();
        String sql = """
            SELECT p.*,
                   c.category_name,
                   b.brand_name,
                   COUNT(CASE WHEN ii.status = 'IN_STOCK' THEN 1 END) AS stock_quantity
            FROM products p
            LEFT JOIN categories c      ON p.category_id = c.category_id
            LEFT JOIN brands b          ON p.brand_id = b.brand_id
            LEFT JOIN product_variants pv ON p.product_id = pv.product_id
            LEFT JOIN inventory_items ii  ON pv.variant_id = ii.variant_id
            GROUP BY p.product_id, p.name, p.category_id, p.brand_id, p.description, p.status,
                     p.created_at, p.created_by, p.updated_by, p.updated_at,
                     c.category_name, b.brand_name
            ORDER BY p.product_id DESC
            """;
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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

    // 2. Lấy sản phẩm theo ID
    public Product getProductById(int id) {
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
        String sql = "SELECT COUNT(*) FROM products "
                + "WHERE name = ? AND category_id = ? AND brand_id = ? AND product_id <> ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, categoryId);
            ps.setInt(3, brandId);
            ps.setInt(4, excludeId);

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
            ps.setObject(7, p.getCreatedBy()); 
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
    public boolean deleteProduct(int id) {
        try {
            conn.setAutoCommit(false);

            // 1. Xóa ảnh sản phẩm
            String sqlImg = "DELETE FROM product_images WHERE product_id = ?";
            PreparedStatement psImg = conn.prepareStatement(sqlImg);
            psImg.setInt(1, id);
            psImg.executeUpdate();

            // 2. Xóa thông số kỹ thuật
            String sqlSpec = "DELETE FROM product_spec_values WHERE product_id = ?";
            PreparedStatement psSpec = conn.prepareStatement(sqlSpec);
            psSpec.setInt(1, id);
            psSpec.executeUpdate();

            // 3. Xóa các biến thể (Variants)
            // Lưu ý: bảng variant_spec_values của bạn đã có ON DELETE CASCADE nên nó sẽ tự mất theo variant
            String sqlVar = "DELETE FROM product_variants WHERE product_id = ?";
            PreparedStatement psVar = conn.prepareStatement(sqlVar);
            psVar.setInt(1, id);
            psVar.executeUpdate();

            // 4. Cuối cùng mới xóa sản phẩm chính
            String sqlProd = "DELETE FROM products WHERE product_id = ?";
            PreparedStatement psProd = conn.prepareStatement(sqlProd);
            psProd.setInt(1, id);
            int result = psProd.executeUpdate();

            conn.commit();
            return result > 0;
        } catch (Exception e) {
            try {
                conn.rollback();
            } catch (Exception ex) {
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (Exception ex) {
            }
        }
    }

    // 9. Lấy sản phẩm theo Category (Có ảnh và giá)
    public List<Product> getProductsByCategoryId(int categoryId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, c.category_name, b.brand_name, "
                + "MIN(pv.selling_price) as min_price, "
                + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url, "
                + "(SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as avg_rating, "
                + "(SELECT COUNT(*) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as review_count "
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

    public List<Product> getNewProducts(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, c.category_name, b.brand_name, "
                + "MIN(pv.selling_price) as min_price, "
                + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url, "
                + "(SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as avg_rating, "
                + "(SELECT COUNT(*) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as review_count "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE p.status = 'ACTIVE' "
                + "GROUP BY p.product_id, p.name, p.category_id, p.brand_id, p.description, p.status, p.created_at, p.created_by, p.updated_by, p.updated_at, c.category_name, b.brand_name "
                + "ORDER BY p.product_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
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
                + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url, "
                + "(SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as avg_rating, "
                + "(SELECT COUNT(*) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as review_count "
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

    public int countProductInInventory(int productId) {
        String sql = "SELECT COUNT(*) FROM inventory_items ii "
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
            if (colName.equalsIgnoreCase("stock_quantity")) {
                p.setStockQuantity(rs.getInt("stock_quantity"));
            }
            if (colName.equalsIgnoreCase("avg_rating")) {
                p.setAverageRating(rs.getDouble("avg_rating"));
            }
            if (colName.equalsIgnoreCase("review_count")) {
                p.setReviewCount(rs.getInt("review_count"));
            }
        }

        return p;
    }

    public List<Product> getFilteredProductsWithPaging(String keyword, Integer categoryId, Integer brandId,
            Double minPrice, Double maxPrice, String sortOrder, int pageIndex, int pageSize) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, c.category_name, b.brand_name, "
                + "MIN(pv.selling_price) as min_price, "
                + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url, "
                + "(SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as avg_rating, "
                + "(SELECT COUNT(*) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as review_count "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE p.status = 'ACTIVE' ");

        // Thêm các điều kiện lọc
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND p.name LIKE ? ");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ? ");
        }
        if (brandId != null && brandId > 0) {
            sql.append(" AND p.brand_id = ? ");
        }

        sql.append("GROUP BY p.product_id, p.name, p.category_id, p.brand_id, p.description, p.status, p.created_at, p.created_by, p.updated_by, p.updated_at, c.category_name, b.brand_name ");

        if (minPrice != null || maxPrice != null) {
            sql.append(" HAVING 1=1 ");
            if (minPrice != null) {
                sql.append(" AND MIN(pv.selling_price) >= ? ");
            }
            if (maxPrice != null) {
                sql.append(" AND MIN(pv.selling_price) <= ? ");
            }
        }

        // Sắp xếp
        if (sortOrder != null) {
            if (sortOrder.equals("priceAsc")) {
                sql.append(" ORDER BY MIN(pv.selling_price) ASC ");
            } else if (sortOrder.equals("priceDesc")) {
                sql.append(" ORDER BY MIN(pv.selling_price) DESC ");
            } else {
                sql.append(" ORDER BY p.product_id DESC ");
            }
        } else {
            sql.append(" ORDER BY p.product_id DESC ");
        }

        // PHÂN TRANG
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

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

            // Tham số cho OFFSET và FETCH
            ps.setInt(paramIndex++, (pageIndex - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);

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

    /**
     * Đếm tổng số sản phẩm thỏa mãn điều kiện lọc để tính tổng số trang.
     */
    public int getTotalFilteredProducts(String keyword, Integer categoryId, Integer brandId, Double minPrice, Double maxPrice) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM ( "
                + "SELECT p.product_id FROM products p "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
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

        sql.append(" GROUP BY p.product_id ");

        if (minPrice != null || maxPrice != null) {
            sql.append(" HAVING 1=1 ");
            if (minPrice != null) {
                sql.append(" AND MIN(pv.selling_price) >= ? ");
            }
            if (maxPrice != null) {
                sql.append(" AND MIN(pv.selling_price) <= ? ");
            }
        }
        sql.append(") as t");

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
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Product> getProductsByBrandName(String brandName, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, c.category_name, b.brand_name, "
                + "MIN(pv.selling_price) as min_price, "
                + "MAX(CAST(CASE WHEN pi.is_thumbnail = 1 THEN pi.image_url ELSE NULL END AS VARCHAR(255))) as thumbnail_url, "
                + "(SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as avg_rating, "
                + "(SELECT COUNT(*) FROM reviews r "
                + "  JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "  JOIN inventory_items ii ON oi.inventory_id = ii.inventory_id "
                + "  JOIN product_variants pv2 ON ii.variant_id = pv2.variant_id "
                + "  WHERE pv2.product_id = p.product_id AND r.status = 'VISIBLE') as review_count "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE LOWER(LTRIM(RTRIM(b.brand_name))) = LOWER(LTRIM(RTRIM(?))) "
                + "AND p.status = 'ACTIVE' "
                + "GROUP BY p.product_id, p.name, p.category_id, p.brand_id, p.description, p.status, "
                + "p.created_at, p.created_by, p.updated_by, p.updated_at, c.category_name, b.brand_name "
                + "ORDER BY p.product_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setString(2, brandName);
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

    public static void main(String[] args) {
        ProductDAO a = new ProductDAO();

        List<Product> list = a.getProductsByBrandId(1, 1);

        for (Product product : list) {
            System.out.println(product.toString());
        }

    }
}
