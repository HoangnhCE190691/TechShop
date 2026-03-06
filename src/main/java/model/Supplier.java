/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author LE HOANG NHAN
 */
public class Supplier {

    private int supplier_id;
    private String supplier_name;
    private String phone;
    private boolean is_active;

    public Supplier() {
    }

    public Supplier(int supplier_id, String supplier_name, String phone, boolean is_active) {
        this.supplier_id = supplier_id;
        this.supplier_name = supplier_name;
        this.phone = phone;
        this.is_active = is_active;
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

    public boolean Is_active() {
        return is_active;
    }

    /**
     * Cho EL trong JSP: ${s.is_active}
     */
    public boolean getIs_active() {
        return is_active;
    }

    public void setIs_active(boolean is_active) {
        this.is_active = is_active;
    }

    @Override
    public String toString() {
        return "Supplier{" + "supplier_id=" + supplier_id + ", supplier_name=" + supplier_name + ", phone=" + phone + ", is_active=" + is_active + '}';
    }

}
