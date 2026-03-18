<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">

        <!-- Danger -->
        <c:if test="${sessionScope.msgType == 'danger'}">
            <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-red-50 text-red-800 border-red-200">
                <span class="font-bold uppercase tracking-wider text-sm">
                    ${sessionScope.msg}
                </span>
            </div>
        </c:if>

        <!-- Success -->
        <c:if test="${sessionScope.msgType != 'danger'}">
            <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-green-50 text-green-800 border-green-200">
                <span class="font-bold uppercase tracking-wider text-sm">
                    ${sessionScope.msg}
                </span>
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


<c:if test="${empty inventoryItem}">
    <div class="p-6 text-center text-red-600">
        Inventory item not found.
    </div>
    <div class="text-center">
        <a href="staffservlet?action=inventoryManagement" class="text-blue-600 underline">
            Back to list
        </a>
    </div>
</c:if>


<c:if test="${not empty inventoryItem}">
    <div class="max-w-2xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-6">

        <div class="flex justify-between items-start border-b pb-6 mb-8">
            <div>
                <h2 class="text-2xl font-extrabold text-gray-900 uppercase tracking-tight">
                    Edit Inventory Item
                </h2>
                <p class="text-gray-500 mt-1">
                    ID:
                    <span class="font-mono font-bold text-blue-600">
                        #${inventoryItem.inventory_id}
                    </span>
                </p>
            </div>

            <a href="staffservlet?action=inventoryManagement"
               class="text-gray-500 hover:text-gray-700 flex items-center gap-2 text-sm font-medium">
                Back to List
            </a>
        </div>

        <form id="editInventoryForm" action="inventory" method="POST" class="space-y-5" onsubmit="return confirmSoldToInStock(event);">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="inventory_id" value="${inventoryItem.inventory_id}">
            <input type="hidden" id="originalStatus" value="${inventoryItem.status}">

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">
                    Product <span class="text-red-500">*</span>
                </label>

                <input type="text" id="variantSearch"
                       placeholder="Search by name or SKU..."
                       class="w-full px-3 py-2 mb-1 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-sm">

                <select name="variant_id" id="variantSelect" required
                        class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
                    <option value="">-- Select product variant --</option>

                    <c:if test="${not empty listVariants}">
                        <c:forEach items="${listVariants}" var="v">

                            <c:if test="${inventoryItem.variant_id == v.variantId}">
                                <option value="${v.variantId}"
                                        data-text="${v.productName} ${v.sku} #${v.variantId}"
                                        selected>
                                    ${v.productName} – ${v.sku}
                                </option>
                            </c:if>

                            <c:if test="${inventoryItem.variant_id != v.variantId}">
                                <option value="${v.variantId}"
                                        data-text="${v.productName} ${v.sku} #${v.variantId}">
                                    ${v.productName} – ${v.sku}
                                </option>
                            </c:if>

                        </c:forEach>
                    </c:if>

                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">
                    IMEI <span class="text-red-500">*</span>
                </label>
                <input type="text"
                       name="imei"
                       required
                       maxlength="100"
                       value="${inventoryItem.imei}"
                       class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none font-mono">
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">
                        Import price (₫) <span class="text-red-500">*</span>
                    </label>
                    <input type="number"
                           name="import_price"
                           required
                           min="0"
                           step="1000"
                           value="${inventoryItem.import_price}"
                           class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">
                        Status
                    </label>

                    <select name="status" id="statusSelect"
                            class="w-full px-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">

                        <option value="IN_STOCK"
                                <c:if test="${inventoryItem.status == 'IN_STOCK'}">selected</c:if>>
                                    IN_STOCK
                                </option>

                                <option value="SOLD"
                                <c:if test="${inventoryItem.status == 'SOLD'}">selected</c:if>>
                                    SOLD
                                </option>

                                <option value="RESERVED"
                                <c:if test="${inventoryItem.status == 'RESERVED'}">selected</c:if>>
                                    RESERVED
                                </option>

                                <option value="DEFECTIVE"
                                <c:if test="${inventoryItem.status == 'DEFECTIVE'}">selected</c:if>>
                                    DEFECTIVE
                                </option>

                                <option value="RETURNED"
                                <c:if test="${inventoryItem.status == 'RETURNED'}">selected</c:if>>
                                    RETURNED
                                </option>

                        </select>
                    </div>
                </div>

                <script>
                    function confirmSoldToInStock(event) {
                        var original = document.getElementById("originalStatus");
                        var statusSelect = document.getElementById("statusSelect");
                        if (!original || !statusSelect)
                            return true;
                        var origVal = (original.value || "").toUpperCase();
                        var newVal = (statusSelect.value || "").toUpperCase();
                        if (origVal === "SOLD" && newVal === "IN_STOCK") {
                            var msg = "This item may be linked to an order. Normally use Order Cancel to revert stock. Continue anyway?";
                            if (!confirm(msg)) {
                                event.preventDefault();
                                return false;
                            }
                        }
                        return true;
                    }

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

                <div class="flex gap-3 pt-2">
                    <button type="submit"
                            class="inline-flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium text-sm">
                        Update
                    </button>

                    <a href="staffservlet?action=inventoryManagement"
                       class="inline-flex items-center gap-2 px-5 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-medium text-sm">
                        Cancel
                    </a>
                </div>

            </form>
        </div>
</c:if>