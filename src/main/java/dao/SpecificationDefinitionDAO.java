package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.SpecificationDefinition;
import utils.DBContext;

/**
 *
 * @author CaoTram
 */
public class SpecificationDefinitionDAO extends DBContext {

    // 1. LẤY TẤT CẢ ĐỊNH NGHĨA
    public List<SpecificationDefinition> getAllSpecs() {
        List<SpecificationDefinition> list = new ArrayList<>();
        String sql = "SELECT s.*, c.category_name FROM specification_definitions s " +
                "JOIN categories c ON s.category_id = c.category_id " +
                "ORDER BY s.spec_id DESC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SpecificationDefinition s = mapResultSet(rs);
                s.setCategoryName(rs.getString("category_name"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. LẤY THEO ID
    public SpecificationDefinition getSpecById(int id) {
        String sql = "SELECT s.*, c.category_name FROM specification_definitions s " +
                "JOIN categories c ON s.category_id = c.category_id WHERE s.spec_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                SpecificationDefinition s = mapResultSet(rs);
                s.setCategoryName(rs.getString("category_name"));
                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. KIỂM TRA XÓA MỀM: Đếm số lượng giá trị sản phẩm đang dùng spec này
    public int countSpecUsedInProducts(int specId) {
        String sql = "SELECT COUNT(*) FROM product_specification_values WHERE spec_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, specId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 4. THỰC HIỆN XÓA MỀM (DEACTIVATE)
    public void softDeleteSpec(int id) {
        String sql = "UPDATE specification_definitions SET is_active = 0 WHERE spec_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. THỰC HIỆN XÓA CỨNG
    public void deleteSpec(int id) {
        String sql = "DELETE FROM specification_definitions WHERE spec_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 6. THÊM MỚI
    public void insertSpec(SpecificationDefinition s) {
        String sql = "INSERT INTO specification_definitions (category_id, spec_name, unit, is_active, is_variant) VALUES (?, ?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, s.getCategoryId());
            ps.setString(2, s.getSpecName());
            ps.setString(3, s.getUnit());
            ps.setBoolean(4, s.isIsActive());
            ps.setBoolean(5, s.isIsVariant());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 7. CẬP NHẬT
    public void updateSpec(SpecificationDefinition s) {
        String sql = "UPDATE specification_definitions SET category_id=?, spec_name=?, unit=?, is_active=?, is_variant=? WHERE spec_id=?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, s.getCategoryId());
            ps.setString(2, s.getSpecName());
            ps.setString(3, s.getUnit());
            ps.setBoolean(4, s.isIsActive());
            ps.setBoolean(5, s.isIsVariant());
            ps.setInt(6, s.getSpecId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private SpecificationDefinition mapResultSet(ResultSet rs) throws Exception {
        SpecificationDefinition s = new SpecificationDefinition();
        s.setSpecId(rs.getInt("spec_id"));
        s.setCategoryId(rs.getInt("category_id"));
        s.setSpecName(rs.getString("spec_name"));
        s.setUnit(rs.getString("unit"));
        s.setIsActive(rs.getBoolean("is_active"));
        try {
            s.setIsVariant(rs.getBoolean("is_variant"));
        } catch (Exception e) {
        }
        return s;
    }

    /**
     * Lấy danh sách spec definitions có is_variant=1 theo category_id
     * Dùng để hiển thị dropdown Dung lượng / Màu sắc khi edit variant
     */
    public List<SpecificationDefinition> getVariantSpecsByCategoryId(int categoryId) {
        List<SpecificationDefinition> list = new ArrayList<>();
        String sql = "SELECT s.*, c.category_name FROM specification_definitions s " +
                "JOIN categories c ON s.category_id = c.category_id " +
                "WHERE s.category_id = ? AND s.is_variant = 1 AND s.is_active = 1 " +
                "ORDER BY s.spec_id ASC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, categoryId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SpecificationDefinition s = mapResultSet(rs);
                s.setCategoryName(rs.getString("category_name"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả variant specs (is_variant=1) active
     */
    public List<SpecificationDefinition> getAllVariantSpecs() {
        List<SpecificationDefinition> list = new ArrayList<>();
        String sql = "SELECT s.*, c.category_name FROM specification_definitions s " +
                "JOIN categories c ON s.category_id = c.category_id " +
                "WHERE s.is_variant = 1 AND s.is_active = 1 " +
                "ORDER BY s.category_id, s.spec_id ASC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SpecificationDefinition s = mapResultSet(rs);
                s.setCategoryName(rs.getString("category_name"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}