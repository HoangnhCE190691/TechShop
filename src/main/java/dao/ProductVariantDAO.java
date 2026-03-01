package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ProductVariant;
import utils.DBContext;

public class ProductVariantDAO extends DBContext {

    // 1. Lấy tất cả biến thể (JOIN với bảng products để lấy tên sản phẩm)
    public List<ProductVariant> getAllVariant() {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT pv.*, p.name AS product_name "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "ORDER BY pv.variant_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy biến thể theo ID
    public ProductVariant getVariantById(int id) {
        String sql = "SELECT pv.*, p.name AS product_name "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 2.1. Lấy danh sách biến thể theo ID sản phẩm
    public List<ProductVariant> getVariantsByProductId(int productId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT pv.*, p.name AS product_name "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.product_id = ? AND pv.is_active = 1 "
                + "ORDER BY pv.selling_price ASC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Thêm mới biến thể
    public void insertVariant(ProductVariant v) {
        String sql = "INSERT INTO product_variants (product_id, sku, selling_price, is_active) VALUES (?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, v.getProductId());
            ps.setString(2, v.getSku());
            ps.setLong(3, v.getSellingPrice());
            ps.setBoolean(4, v.isIsActive());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 4. Cập nhật biến thể
    public void updateVariant(ProductVariant v) {
        String sql = "UPDATE product_variants SET product_id = ?, sku = ?, selling_price = ?, is_active = ? WHERE variant_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, v.getProductId());
            ps.setString(2, v.getSku());
            ps.setLong(3, v.getSellingPrice());
            ps.setBoolean(4, v.isIsActive());
            ps.setInt(5, v.getVariantId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. Kiểm tra trùng SKU (Tương tự kiểm tra trùng tên sản phẩm)
    public boolean isSkuDuplicate(String sku, int excludeId) {
        String sql = "SELECT COUNT(*) FROM product_variants WHERE sku = ? AND variant_id <> ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, sku);
            ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 6. Kiểm tra tồn kho (Để quyết định xóa mềm hay cứng)
    public int countInventoryByVariantId(int variantId) {
        String sql = "SELECT COUNT(*) FROM inventory_items WHERE variant_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void deleteVariant(int id) {
        String sql = "DELETE FROM product_variants WHERE variant_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void softDeleteVariant(int id) {
        String sql = "UPDATE product_variants SET is_active = 0 WHERE variant_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private ProductVariant mapResultSet(ResultSet rs) throws Exception {
        ProductVariant v = new ProductVariant();
        v.setVariantId(rs.getInt("variant_id"));
        v.setProductId(rs.getInt("product_id"));
        v.setSku(rs.getString("sku"));
        v.setSellingPrice(rs.getLong("selling_price"));
        v.setIsActive(rs.getBoolean("is_active"));
        v.setProductName(rs.getString("product_name"));
        return v;
    }
}
