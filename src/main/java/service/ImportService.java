package service;

import dao.ImportReceiptItemDAO;
import dao.InventoryItemDAO;
import java.util.List;
import model.ImportReceiptItem;
import model.InventoryItem;

/**
 * Nghiệp vụ liên quan đến phiếu nhập & sinh tồn kho.
 */
public class ImportService {

    /**
     * Sinh bản ghi inventory_items từ tất cả dòng của một phiếu nhập.
     * Mỗi quantity sẽ tạo ra quantity record IN_STOCK gắn với receipt_item_id tương ứng.
     * IMEI ở đây được auto-generate đơn giản, nếu cần IMEI thật thì thay thế ở tầng controller/UI.
     */
    public int generateInventoryFromReceipt(int receiptId) {
        ImportReceiptItemDAO itemDao = new ImportReceiptItemDAO();
        InventoryItemDAO inventoryDao = new InventoryItemDAO();

        List<ImportReceiptItem> items = itemDao.getItemsByReceiptId(receiptId);
        int created = 0;
        long baseNano = System.nanoTime();

        for (ImportReceiptItem it : items) {
            int qty = it.getQuantity();
            for (int i = 0; i < qty; i++) {
                String imei = "AUTO-" + it.getReceipt_item_id() + "-" + (baseNano + i);
                InventoryItem inv = new InventoryItem(
                        0,
                        it.getVariant_id(),
                        it.getReceipt_item_id(),
                        imei,
                        it.getImport_price(),
                        "IN_STOCK"
                );
                if (inventoryDao.insertInventory(inv)) {
                    created++;
                }
            }
        }
        return created;
    }
}

