<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:if test="${empty inventoryItem}">
    <div class="p-6 text-center text-red-600">
        Inventory item not found.
    </div>
    <div class="text-center">
        <a href="staffservlet?action=inventoryManagement" 
           class="text-blue-600 underline">Back to list</a>
    </div>
</c:if>

<c:if test="${not empty inventoryItem}">
    <div class="max-w-2xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-6">
        
        <h2 class="text-2xl font-bold mb-6 text-gray-800 uppercase tracking-wide">
            Inventory Item Detail
        </h2>

        <div class="space-y-6">

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                
                <div>
                    <label class="block mb-2 text-sm font-medium text-gray-700">
                        Inventory ID
                    </label>
                    <input type="text"
                           value="#${inventoryItem.inventory_id}"
                           class="w-full p-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed font-bold text-blue-600"
                           readonly>
                </div>

                <div>
                    <label class="block mb-2 text-sm font-medium text-gray-700">
                        Product
                    </label>

                    <c:if test="${not empty inventoryItem.productName}">
                        <input type="text"
                               value="${inventoryItem.productName}"
                               class="w-full p-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed font-medium"
                               readonly>
                    </c:if>

                    <c:if test="${empty inventoryItem.productName}">
                        <input type="text"
                               value="${inventoryItem.variant_id}"
                               class="w-full p-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed font-medium"
                               readonly>
                    </c:if>
                </div>

            </div>

            <div>
                <label class="block mb-2 text-sm font-medium text-gray-700">
                    IMEI
                </label>
                <input type="text"
                       value="${inventoryItem.imei}"
                       class="w-full p-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed font-mono"
                       readonly>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">

                <div>
                    <label class="block mb-2 text-sm font-medium text-gray-700">
                        Import price
                    </label>

                    <input type="text"
                           value="<fmt:formatNumber value='${inventoryItem.import_price}' type='number' groupingUsed='true' maxFractionDigits='0' /> ₫"
                           class="w-full p-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed font-semibold"
                           readonly>
                </div>

                <div>
                    <label class="block mb-2 text-sm font-medium text-gray-700">
                        Status
                    </label>

                    <c:if test="${not empty inventoryItem.status}">
                        <input type="text"
                               value="${inventoryItem.status}"
                               class="w-full p-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed font-medium"
                               readonly>
                    </c:if>

                    <c:if test="${empty inventoryItem.status}">
                        <input type="text"
                               value="N/A"
                               class="w-full p-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed font-medium"
                               readonly>
                    </c:if>
                </div>

            </div>

            <hr class="border-gray-100">

            <div class="flex justify-end gap-3 pt-2">

                <a href="javascript:history.back()"
                   class="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-full hover:bg-gray-200 font-medium border border-gray-200 text-sm no-underline">
                    Back
                </a>

            </div>

        </div>
    </div>
</c:if>