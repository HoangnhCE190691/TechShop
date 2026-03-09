package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.VariantSpecValue;
import utils.DBContext;

public class VariantSpecValueDAO extends DBContext {

    /**
     * Lấy tất cả variant spec values của một sản phẩm
     * JOIN variant_spec_values + specification_definitions + product_variants
     */
    public List<VariantSpecValue> getSpecsByProductId(int productId) {
        List<VariantSpecValue> list = new ArrayList<>();
        String sql = "SELECT vsv.variant_id, vsv.spec_id, vsv.spec_value, sd.spec_name "
                + "FROM variant_spec_values vsv "
                + "JOIN specification_definitions sd ON vsv.spec_id = sd.spec_id "
                + "JOIN product_variants pv ON vsv.variant_id = pv.variant_id "
                + "WHERE pv.product_id = ? AND pv.is_active = 1 "
                + "ORDER BY pv.selling_price ASC, sd.spec_id ASC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                VariantSpecValue v = new VariantSpecValue();
                v.setVariantId(rs.getInt("variant_id"));
                v.setSpecId(rs.getInt("spec_id"));
                v.setSpecValue(rs.getString("spec_value"));
                v.setSpecName(rs.getString("spec_name"));
                list.add(v);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy spec values của một variant cụ thể
     */
    public List<VariantSpecValue> getSpecsByVariantId(int variantId) {
        List<VariantSpecValue> list = new ArrayList<>();
        String sql = "SELECT vsv.variant_id, vsv.spec_id, vsv.spec_value, sd.spec_name "
                + "FROM variant_spec_values vsv "
                + "JOIN specification_definitions sd ON vsv.spec_id = sd.spec_id "
                + "WHERE vsv.variant_id = ? "
                + "ORDER BY sd.spec_id ASC";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, variantId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                VariantSpecValue v = new VariantSpecValue();
                v.setVariantId(rs.getInt("variant_id"));
                v.setSpecId(rs.getInt("spec_id"));
                v.setSpecValue(rs.getString("spec_value"));
                v.setSpecName(rs.getString("spec_name"));
                list.add(v);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Xóa tất cả spec values của một variant (dùng khi update variant)
     */
    public void deleteByVariantId(int variantId) {
        String sql = "DELETE FROM variant_spec_values WHERE variant_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, variantId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Insert một spec value cho variant
     */
    public void insertVariantSpec(int variantId, int specId, String specValue) {
        String sql = "INSERT INTO variant_spec_values (variant_id, spec_id, spec_value) VALUES (?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, variantId);
            ps.setInt(2, specId);
            ps.setString(3, specValue);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
