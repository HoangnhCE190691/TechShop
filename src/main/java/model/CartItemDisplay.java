/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author LE HOANG NHAN
 */
public class CartItemDisplay {

    private int cartItemId;
    private int variantId;
    private String productName;
    private String sku;
    private long sellingPrice;
    private int quantity;

    public CartItemDisplay() {
    }

    public CartItemDisplay(int cartItemId, int variantId, String productName, String sku, long sellingPrice, int quantity) {
        this.cartItemId = cartItemId;
        this.variantId = variantId;
        this.productName = productName;
        this.sku = sku;
        this.sellingPrice = sellingPrice;
        this.quantity = quantity;
    }

    public int getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(int cartItemId) {
        this.cartItemId = cartItemId;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
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

    public long getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(long sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    /**
     * Subtotal = price * quantity
     */
    public long getSubtotal() {
        return sellingPrice * quantity;
    }
}
