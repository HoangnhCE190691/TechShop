<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">

        <!-- Danger -->
        <c:if test="${sessionScope.msgType == 'danger'}">
            <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-red-50 text-red-800 border-red-200">
                <span class="font-bold uppercase tracking-wider text-sm">${sessionScope.msg}</span>
            </div>
        </c:if>

        <!-- Success -->
        <c:if test="${sessionScope.msgType != 'danger'}">
            <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-green-50 text-green-800 border-green-200">
                <span class="font-bold uppercase tracking-wider text-sm">${sessionScope.msg}</span>
            </div>
        </c:if>

    </div>

    <c:remove var="msg" scope="session" />
    <c:remove var="msgType" scope="session" />

    <script>
        window.onload = function () {
            setTimeout(function () {
                var toast = document.getElementById("toast-notification");
                if (toast != null) {
                    toast.parentNode.removeChild(toast);
                }
            }, 3000);
        };
    </script>
</c:if>

<div class="max-w-xl mx-auto bg-white p-6 sm:p-8 rounded-2xl shadow-lg border border-gray-100 mt-4">
    <div class="flex justify-between items-center border-b border-gray-200 pb-4 mb-6">
        <h2 class="text-xl font-bold text-gray-800">
            <c:choose>
                <c:when test="${not empty receiptItem}">
                    Add Inventory Item from Receipt #${receiptItem.receipt_id}
                </c:when>
                <c:otherwise>
                    Add Inventory Item
                </c:otherwise>
            </c:choose>
        </h2>
        <a href="staffservlet?action=inventoryManagement" class="text-sm text-blue-600 hover:text-blue-800 font-medium flex items-center gap-1">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                  d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
            </svg>
            Back
        </a>
    </div>

    <form action="inventory" method="POST" class="space-y-5">
        <input type="hidden" name="action" value="add">

        <c:choose>
            <c:when test="${not empty receiptItem}">
                <input type="hidden" name="receipt_item_id" value="${receiptItem.receipt_item_id}">
                <input type="hidden" name="variant_id" value="${receiptItem.variant_id}">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">
                        Product (from receipt)
                    </label>
                    <p class="px-3 py-2.5 border border-gray-200 rounded-lg bg-gray-50 text-sm">
                        Variant ID: <span class="font-semibold">#${receiptItem.variant_id}</span> – 
                        Receipt Item ID: <span class="font-semibold">#${receiptItem.receipt_item_id}</span>
                    </p>
                </div>
            </c:when>
            <c:otherwise>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">
                        Product <span class="text-red-500">*</span>
                    </label>

                    <input type="text" id="variantSearch" placeholder="Search by name or SKU..."
                           class="w-full px-3 py-2 mb-1 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-sm">

                    <select name="variant_id" id="variantSelect" required
                            class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
                        <option value="">-- Select product variant --</option>

                        <c:if test="${not empty listVariants}">
                            <c:forEach items="${listVariants}" var="v">
                                <option value="${v.variantId}" 
                                        data-text="${v.productName} ${v.sku} #${v.variantId}">
                                    ${v.productName} – ${v.sku}
                                </option>
                            </c:forEach>
                        </c:if>

                    </select>
                </div>
            </c:otherwise>
        </c:choose>

        <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1">
                IMEI <span class="text-red-500">*</span>
            </label>
            <input type="text" name="imei" required maxlength="100"
                   class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none font-mono"
                   placeholder="e.g. 357888000001">
            <p class="text-xs text-gray-500 mt-0.5">Must be unique.</p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">
                    Import price (₫) <span class="text-red-500">*</span>
                </label>
                <input type="number" name="import_price" required min="0" step="1000"
                       class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                       placeholder="15000000"
                       value="<c:out value='${not empty receiptItem ? receiptItem.import_price : ""}'/>">
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">
                    Status
                </label>
                <select name="status"
                        class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
                    <option value="IN_STOCK" selected>IN_STOCK</option>
                    <option value="SOLD">SOLD</option>
                    <option value="RESERVED">RESERVED</option>
                    <option value="DEFECTIVE">DEFECTIVE</option>
                    <option value="RETURNED">RETURNED</option>
                </select>
            </div>
        </div>

        <div class="flex gap-3 pt-2">
            <button type="submit"
                    class="inline-flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium text-sm">
                Add
            </button>

            <a href="staffservlet?action=inventoryManagement"
               class="inline-flex items-center gap-2 px-5 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-medium text-sm">
                Cancel
            </a>
        </div>
    </form>
</div>

<script>
    window.onload = function () {
        var search = document.getElementById("variantSearch");
        var select = document.getElementById("variantSelect");

        if (search != null && select != null) {
            search.onkeyup = function () {
                var q = this.value.toLowerCase();
                var options = select.getElementsByTagName("option");

                for (var i = 0; i < options.length; i++) {
                    var text = options[i].getAttribute("data-text");
                    if (text != null) {
                        text = text.toLowerCase();
                        if (q == "" || text.indexOf(q) >= 0) {
                            options[i].style.display = "";
                        } else {
                            options[i].style.display = "none";
                        }
                    }
                }
            };
        }
    };
</script>