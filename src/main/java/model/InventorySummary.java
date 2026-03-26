package model;

/**
 * Summary of inventory by variant.
 * (imported / sold / reversed / in stock)
 *
 * reversed: inventory đã được gắn vào order_items nhưng chưa đủ điều kiện để coi là sold
 * (ví dụ đơn COD chưa SHIPPED).
 */
public class InventorySummary { 

    private int variantId;
    private String productName;
    private String sku;
    private int imported;
    private int sold;
    private int reversed;
    private int inStock;

    public InventorySummary(int variantId, String productName, String sku,
                            int imported, int sold, int reversed, int inStock) {
        this.variantId = variantId;
        this.productName = productName;
        this.sku = sku;
        this.imported = imported;
        this.sold = sold;
        this.reversed = reversed;
        this.inStock = inStock;
    }

    public int getVariantId() {
        return variantId;
    }

    public String getProductName() {
        return productName;
    }

    public String getSku() {
        return sku;
    }

    public int getImported() {
        return imported;
    }

    public int getSold() {
        return sold;
    }

    public int getReversed() {
        return reversed;
    }

    public int getInStock() {
        return inStock;
    }
}

