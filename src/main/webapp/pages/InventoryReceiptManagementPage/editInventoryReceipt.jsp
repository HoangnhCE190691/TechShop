<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="bg-white rounded-xl shadow-lg p-6 max-w-2xl">
    <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight mb-6">Edit Inventory Receipt #${receipt.receipt_id}</h2>
    <form action="${pageContext.request.contextPath}/staffservlet" method="post">
        <input type="hidden" name="action" value="inventoryReceiptEdit"/>
        <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Supplier</label>
                <select name="supplier_id" required class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <c:forEach items="${listSuppliers}" var="s">
                        <option value="${s.supplier_id}" ${s.supplier_id == receipt.supplier_id ? 'selected' : ''}>${s.supplier_name}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Employee</label>
                <select name="employee_id" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <c:forEach items="${listEmployees}" var="e">
                        <option value="${e.employeeId}" ${e.employeeId == receipt.employee_id ? 'selected' : ''}>${e.fullName}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Total Cost (₫)</label>
                <input type="number" name="total_cost" value="${receipt.total_cost}" min="0" step="1000" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500"/>
            </div>
        </div>
        <div class="flex gap-3 mt-6">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium">Update</button>
            <a href="${pageContext.request.contextPath}/staffservlet?action=inventoryReceiptDetail&id=${receipt.receipt_id}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 font-medium">View Receipt</a>
        </div>
    </form>
</div>
