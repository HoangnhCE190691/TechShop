/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author LE HOANG NHAN
 */
public class Supplier {

    private int supplier_id;
    private String supplier_name;
    private String phone;
    private String email;
    private String address;
    private boolean is_active;
    private Timestamp createdAt;

    public Supplier() {
    }

    public Supplier(int supplier_id, String supplier_name, String phone, boolean is_active) {
        this(supplier_id, supplier_name, phone, null, null, is_active, null);
    }

    public Supplier(int supplier_id, String supplier_name, String phone, String email, String address, boolean is_active) {
        this(supplier_id, supplier_name, phone, email, address, is_active, null);
    }

    public Supplier(int supplier_id, String supplier_name, String phone, String email, String address, boolean is_active, Timestamp createdAt) {
        this.supplier_id = supplier_id;
        this.supplier_name = supplier_name;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.is_active = is_active;
        this.createdAt = createdAt;
    }

    public int getSupplier_id() {
        return supplier_id;
    }

    public void setSupplier_id(int supplier_id) {
        this.supplier_id = supplier_id;
    }

    public String getSupplier_name() {
        return supplier_name;
    }

    public void setSupplier_name(String supplier_name) {
        this.supplier_name = supplier_name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getAddressDisplay() {
        if (address == null) {
            return "";
        }
        String s = address.trim();
        if (s.isEmpty()) {
            return "";
        }
        s = s.replace("\r\n", "\n").replace("\r", "\n");
        while (s.contains("\n\n\n")) {
            s = s.replace("\n\n\n", "\n\n");
        }
        return s;
    }

    // gộp whitespace - hiển thị ô địa chỉ gọn
    public String getAddressDisplaySingleLine() {
        String s = getAddressDisplay();
        if (s.isEmpty()) {
            return "";
        }
        return s.replaceAll("\\s+", " ").trim();
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean Is_active() {
        return is_active;
    }

    // Cho EL trong JSP: ${s.is_active}
    public boolean getIs_active() {
        return is_active;
    }

    public void setIs_active(boolean is_active) {
        this.is_active = is_active;
    }

    @Override
    public String toString() {
        return "Supplier{" + "supplier_id=" + supplier_id + ", supplier_name=" + supplier_name + ", phone=" + phone
                + ", email=" + email + ", address=" + address + ", is_active=" + is_active + ", createdAt=" + createdAt + '}';
    }

}
