<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Form tạo phiếu nháp thủ công; dropdown Supplier chỉ NCC đang hoạt động (is_active). POST cũng kiểm tra lại. --%>
<div class="bg-white rounded-xl shadow-lg p-6 max-w-2xl mx-auto">
    <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight mb-6">New Inventory Receipt</h2>
    <form action="${pageContext.request.contextPath}/staffservlet"
          method="post">
        <input type="hidden" name="action" value="inventoryReceiptAdd"/>
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Receipt Code</label>
                <input type="text"
                       value="Created automatically when you save — e.g. PN-202603-0001"
                       disabled
                       class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-gray-50 text-gray-500"/>
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Supplier</label>
                <select name="supplier_id"
                        required
                        class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <option value="">— Select supplier —</option>
                    <c:forEach items="${listSuppliers}" var="s">
                        <option value="${s.supplier_id}">${s.supplier_name}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Status</label>
                <input type="text"
                       value="DRAFT"
                       disabled
                       class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-gray-50 text-gray-500"/>
                <input type="hidden" name="status" value="DRAFT"/>
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Note</label>
                <textarea name="note"
                          rows="3"
                          placeholder="Optional note for this receipt"
                          class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500"></textarea>
            </div>
        </div>
        <div class="flex gap-3 mt-6">
            <button type="submit"
                    class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium">
                Create Receipt
            </button>
            <a href="${pageContext.request.contextPath}/staffservlet?action=inventoryReceiptManagement"
               class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 font-medium">
                Cancel
            </a>
        </div>
    </form>
</div>
