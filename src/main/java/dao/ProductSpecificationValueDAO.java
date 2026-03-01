package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ProductSpecificationValues;
import utils.DBContext;

public class ProductSpecificationValueDAO extends DBContext {

    public List<ProductSpecificationValues> getAllProductSpecs() {
        List<ProductSpecificationValues> list = new ArrayList<>();
        String sql = "SELECT v.*, p.name as product_name, s.spec_name "
                + "FROM product_spec_values v "
                + "JOIN products p ON v.product_id = p.product_id "
                + "JOIN specification_definitions s ON v.spec_id = s.spec_id "
                + "ORDER BY p.product_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductSpecificationValues v = mapResultSet(rs);
                v.setProductName(rs.getString("product_name"));
                v.setSpecName(rs.getString("spec_name"));
                list.add(v);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ProductSpecificationValues getSpecValueById(int productId, int specId) {
        String sql = "SELECT v.*, p.name as product_name, s.spec_name "
                + "FROM product_spec_values v "
                + "JOIN products p ON v.product_id = p.product_id "
                + "JOIN specification_definitions s ON v.spec_id = s.spec_id "
                + "WHERE v.product_id = ? AND v.spec_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.setInt(2, specId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ProductSpecificationValues v = mapResultSet(rs);
                v.setProductName(rs.getString("product_name"));
                v.setSpecName(rs.getString("spec_name"));
                return v;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy tất cả thông số kỹ thuật của 1 sản phẩm
    public List<ProductSpecificationValues> getSpecsByProductId(int productId) {
        List<ProductSpecificationValues> list = new ArrayList<>();
        String sql = "SELECT v.*, p.name as product_name, s.spec_name "
                + "FROM product_spec_values v "
                + "JOIN products p ON v.product_id = p.product_id "
                + "JOIN specification_definitions s ON v.spec_id = s.spec_id "
                + "WHERE v.product_id = ? "
                + "ORDER BY s.spec_id ASC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductSpecificationValues v = mapResultSet(rs);
                v.setProductName(rs.getString("product_name"));
                v.setSpecName(rs.getString("spec_name"));
                list.add(v);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. THÊM MỚI
    public void insertProductSpec(ProductSpecificationValues v) {
        String sql = "INSERT INTO product_spec_values (product_id, spec_id, spec_value) VALUES (?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, v.getProductId());
            ps.setInt(2, v.getSpecId());
            ps.setString(3, v.getSpecValue());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 4. CẬP NHẬT
    public void updateProductSpec(ProductSpecificationValues v) {
        String sql = "UPDATE product_spec_values SET spec_value = ? WHERE product_id = ? AND spec_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, v.getSpecValue());
            ps.setInt(2, v.getProductId());
            ps.setInt(3, v.getSpecId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. XÓA CỨNG (Vì không có is_active nên xóa thẳng)
    public void deleteProductSpec(int productId, int specId) {
        String sql = "DELETE FROM product_spec_values WHERE product_id = ? AND spec_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.setInt(2, specId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 6. XÓA TẤT CẢ THÔNG SỐ CỦA 1 SẢN PHẨM (Dùng khi xóa Product)
    public void deleteAllSpecsByProduct(int productId) {
        String sql = "DELETE FROM product_spec_values WHERE product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private ProductSpecificationValues mapResultSet(ResultSet rs) throws Exception {
        ProductSpecificationValues v = new ProductSpecificationValues();
        v.setProductId(rs.getInt("product_id"));
        v.setSpecId(rs.getInt("spec_id"));
        v.setSpecValue(rs.getString("spec_value"));
        return v;
    }
}
