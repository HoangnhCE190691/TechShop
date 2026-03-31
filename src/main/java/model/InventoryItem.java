/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author LE HOANG NHAN
 */
public class InventoryItem {

    private int inventory_id;
    private int variant_id;
    private int receipt_item_id;
    private String serialId;
    private double import_price;
    private String status;
    private String productName;
    private String sku;
    private String receiptCode;
    private String buyerName;

    public InventoryItem() {
    }

    public InventoryItem(int inventory_id, int variant_id, int receipt_item_id, String serialId, double import_price, String status) {
        this.inventory_id = inventory_id;
        this.variant_id = variant_id;
        this.receipt_item_id = receipt_item_id;
        this.serialId = serialId;
        this.import_price = import_price;
        this.status = status;
    }

    public int getInventory_id() {
        return inventory_id;
    }

    public int getInventoryId() {
        return inventory_id;
    }

    public void setInventory_id(int inventory_id) {
        this.inventory_id = inventory_id;
    }

    public void setInventoryId(int inventoryId) {
        this.inventory_id = inventoryId;
    }

    public int getVariant_id() {
        return variant_id;
    }

    public int getVariantId() {
        return variant_id;
    }

    public void setVariant_id(int variant_id) {
        this.variant_id = variant_id;
    }

    public void setVariantId(int variantId) {
        this.variant_id = variantId;
    }

    public int getReceipt_item_id() {
        return receipt_item_id;
    }

    public int getReceiptItemId() {
        return receipt_item_id;
    }

    public void setReceipt_item_id(int receipt_item_id) {
        this.receipt_item_id = receipt_item_id;
    }

    public void setReceiptItemId(int receiptItemId) {
        this.receipt_item_id = receiptItemId;
    }

    public String getSerialId() {
        return serialId;
    }

    public void setSerialId(String serialId) {
        this.serialId = serialId;
    }

    // Backward-compatible aliases for old property name "imei"
    public String getImei() {
        return serialId;
    }

    public void setImei(String imei) {
        this.serialId = imei;
    }

    public double getImport_price() {
        return import_price;
    }

    public double getImportPrice() {
        return import_price;
    }

    public void setImport_price(double import_price) {
        this.import_price = import_price;
    }

    public void setImportPrice(double importPrice) {
        this.import_price = importPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getReceiptCode() {
        return receiptCode;
    }

    public void setReceiptCode(String receiptCode) {
        this.receiptCode = receiptCode;
    }

    public String getBuyerName() {
        return buyerName;
    }

    public void setBuyerName(String buyerName) {
        this.buyerName = buyerName;
    }

    @Override
    public String toString() {
        return "InventoryItem{" + "id=" + inventory_id + ", variant=" + variant_id + ", receipt_item=" + receipt_item_id + ", serialId=" + serialId + ", price=" + import_price + ", status=" + status + '}';
    }
}
