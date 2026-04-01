<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="max-w-2xl mx-auto bg-white rounded-xl shadow-md overflow-hidden mt-10 border border-gray-200">
    <div class="bg-gray-800 p-4 text-white font-bold text-lg">
        Edit Order #${order.orderId}
    </div>
    <form action="orderStaffServlet" method="POST" class="p-6 space-y-6" id="editOrderForm">
        <input type="hidden" name="action" value="updateOrder">
        <input type="hidden" name="orderId" value="${order.orderId}">
        <input type="hidden" name="status" id="selectedStatus" value="${order.status}">
        <%-- cancelReason: only has value when staff selects Cancel --%>
        <input type="hidden" name="cancelReason" id="selectedCancelReason" value="">

        <div class="grid grid-cols-2 gap-4">
            <div>
                <label class="block text-xs font-bold text-gray-500 uppercase">Customer</label>
                <p class="font-semibold">${order.customerName}</p>
            </div>
            <div>
                <label class="block text-xs font-bold text-gray-500 uppercase">Total Amount</label>
                <p class="font-bold text-red-500">
                    <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,###"/>d
                </p>
            </div>

            <c:if test="${not empty order.shippedDate}">
                <div>
                    <label class="block text-xs font-bold text-gray-500 uppercase">Shipped Date</label>
                    <p class="font-semibold text-blue-600">${order.shippedDate}</p>
                    <p class="text-xs text-gray-400 mt-1">
                        (Auto-complete after 5 days from the date of successful delivery.)
                    </p>
                </div>
            </c:if>
        </div>

        <div>
            <label class="block text-sm font-bold text-gray-700">Shipping Address</label>
            <textarea name="shippingAddress" rows="2" readonly
                      class="w-full mt-1 p-2 border rounded-lg bg-gray-100 text-gray-600 cursor-not-allowed focus:outline-none pointer-events-none"
                      >${order.shippingAddress}</textarea>
        </div>

        <%-- ============================================================ --%>
        <%-- PRODUCT ALLOCATION FROM WAREHOUSE --%>
        <%-- Displayed when order is APPROVED and preparing for SHIPPING --%>
        <c:if test="${showAllocation}">
            <div class="mt-4 p-4 bg-blue-50 rounded-xl border border-blue-200">
                <h3 class="text-sm font-bold text-blue-800 mb-3 flex items-center">
                    <i class="fas fa-barcode mr-2"></i> Product allocation from warehouse before SHIPPING
                    <span class="ml-2 text-xs text-red-500 font-normal">(*Required)</span>
                </h3>

                <c:choose>
                    <c:when test="${empty orderItems}">
                        <div class="p-3 rounded-lg bg-yellow-50 border border-yellow-200 text-yellow-700 text-sm">
                            No products available to allocate for this order.
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="space-y-3">
                            <c:forEach var="item" items="${orderItems}">
                                <c:set var="availableList" value="${odao.getAvailableInventoryByVariant(item.variantId)}"/>
                                <c:set var="availableCount" value="${availableList.size()}"/>

                                <div class="flex items-center justify-between bg-white p-3 rounded-lg border border-blue-100 shadow-sm">
                                    <div class="flex-1">
                                        <p class="text-xs font-bold text-gray-700">
                                            ${item.variantName}
                                        </p>
                                        <p class="text-[11px] text-gray-500">
                                            Variant ID: ${item.variantId}
                                        </p>
                                        <c:choose>
                                            <c:when test="${availableCount == 0}">
                                                <span class="text-xs text-red-500 font-semibold mt-1 inline-block">
                                                    <i class="fas fa-exclamation-triangle"></i> Out of stock!
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-xs text-green-600 mt-1 inline-block">
                                                    <i class="fas fa-check-circle"></i> ${availableCount} items available in stock
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="flex-1 ml-4">
                                        <select name="assign_inv_${item.orderItemId}"
                                                class="w-full text-xs p-1.5 border rounded bg-gray-50
                                                ${availableCount == 0 ? 'border-red-300 bg-red-50' : ''}"
                                                required="${availableCount == 0 ? 'false' : 'true'}">
                                            <option value="">-- Select SerialId --</option>
                                            <c:forEach var="inv" items="${availableList}">
                                                <option value="${inv.inventory_id}" data-import="${inv.import_price}">
                                                    ${inv.serialId} - Import price: <fmt:formatNumber value="${inv.import_price}" type="number" pattern="#,###"/>d
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="mt-3 p-2 bg-blue-100 rounded-lg text-xs text-blue-700">
                            <i class="fas fa-info-circle"></i> 
                            Please select a Serial for ALL products to proceed to SHIPPING status.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="mt-4 p-4 bg-gray-50 rounded-xl border-t border-blue-100 grid grid-cols-2 gap-4">
                <div class="border-r border-gray-200">
                    <p class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Total Import Cost (Capital)</p>
                    <p id="totalImportPrice" class="text-lg font-bold text-gray-700">0d</p>
                </div>
                <div class="pl-2">
                    <p class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Estimated Profit</p>
                    <p id="estimatedProfit" class="text-lg font-bold text-blue-600">0d</p>
                </div>
            </div>
        </c:if>
        <%-- ============================================================ --%>

        <div class="grid grid-cols-2 gap-4">

            <%-- ORDER STATUS --%>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">Order Status</label>
                <div class="mb-3 px-3 py-2 bg-gray-100 rounded-lg text-sm font-semibold text-gray-700 border border-gray-200">
                    Current: <span class="text-blue-600">${order.status}</span>
                </div>
                <c:choose>
                    <c:when test="${empty nextStatus && order.status == cancelledCode}">
                        <p class="text-xs text-gray-400 italic">This order was cancelled.</p>
                        <%-- Display cancel reason if available --%>
                        <c:if test="${not empty order.cancelReason}">
                            <div class="mt-2 p-2 bg-red-50 border border-red-100 rounded-lg">
                                <p class="text-xs font-bold text-red-500 uppercase mb-0.5">Cancel Reason</p>
                                <p class="text-xs text-red-600">${order.cancelReason}</p>
                            </div>
                        </c:if>
                    </c:when>
                    <c:when test="${empty nextStatus}">
                        <p class="text-xs text-gray-400 italic">This order is completed. No further status changes.</p>
                    </c:when>
                    <c:otherwise>
                        <c:if test="${nextStatus != 'COMPLETED'}">
                            <div class="flex gap-2">
                                <button type="button"
                                        onclick="setStatus('${nextStatus}')"
                                        class="flex-1 px-3 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700 transition">
                                    Next: ${nextStatus}
                                </button>
                                <c:if test="${order.status != cancelledCode}">
                                    <button type="button"
                                            onclick="openStaffCancelModal()"
                                            class="px-3 py-2 bg-red-100 text-red-600 text-sm font-bold rounded-lg hover:bg-red-200 transition">
                                        Cancel
                                    </button>
                                </c:if>
                            </div>
                        </c:if>
                        <%-- Thông báo cho staff biết --%>
                        <c:if test="${nextStatus == 'COMPLETED'}">
                            <div class="p-3 bg-blue-50 border border-blue-200 rounded-lg">
                                <p class="text-sm text-blue-700 font-medium">
                                    <i class="fas fa-info-circle mr-1"></i>
                                    Waiting for customer confirmation of receipt.
                                </p>
                            </div>
                        </c:if>
                        <p id="statusPreview" class="mt-2 text-xs text-gray-400">
                            No change selected - will keep current status.
                        </p>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- PAYMENT STATUS --%>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">Payment Status</label>

                <%-- autoPayment: prioritize actual DB, then calculate by status --%>
                <c:choose>
                    <c:when test="${order.paymentStatus == 'PAID'}">
                        <c:set var="autoPayment" value="PAID"/>
                    </c:when>
                    <c:when test="${empty nextStatus && order.status != cancelledCode}">
                        <c:set var="autoPayment" value="PAID"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="autoPayment" value="UNPAID"/>
                    </c:otherwise>
                </c:choose>

                <input type="hidden" name="paymentStatus" id="selectedPayment" value="${autoPayment}">
                <div id="paymentDisplay"
                     class="px-3 py-2 rounded-lg text-sm font-bold border cursor-not-allowed
                     ${autoPayment == 'PAID' ? 'bg-green-50 text-green-700 border-green-200' : 'bg-gray-100 text-gray-500 border-gray-200'}">
                    ${autoPayment}
                </div>
                
                <p id="paymentPreview" class="mt-1 text-xs font-semibold"></p>
            </div>

        </div>
        <div class="flex justify-end gap-3 pt-4 border-t border-gray-100">
            <a href="orderStaffServlet?action=all"
               class="px-4 py-2 text-gray-500 hover:text-gray-700 text-sm font-medium">Back</a>
            <button type="submit"
                    class="px-6 py-2 bg-blue-600 text-white rounded-lg font-bold hover:bg-blue-700 shadow-md transition">
                Save Changes
            </button>
        </div>
    </form>
</div>

<%-- ============= CANCEL REASON MODAL (for Staff) ============= --%>
<div id="staffCancelModal"
     class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm hidden"
     onclick="handleStaffModalBackdrop(event)">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 p-6 animate-staff-fade">
        <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M12 9v2m0 4h.01M10.293 5.293a1 1 0 011.414 0L12 6l.293-.293a1 1 0 011.414 1.414L12 8.414l-1.707-1.707a1 1 0 010-1.414zM4.929 19.071A10 10 0 1019.07 4.93 10 10 0 004.93 19.07z"/>
                </svg>
            </div>
            <div>
                <h2 class="text-lg font-extrabold text-gray-900">Cancel Order #${order.orderId}</h2>
                <p class="text-xs text-gray-400">Staff action — this will be logged.</p>
            </div>
        </div>

        <p class="text-sm text-gray-600 mb-3">Select or enter a reason for cancelling this order:</p>

        <%-- Quick reasons for staff --%>
        <div class="flex flex-wrap gap-2 mb-3">
            <button type="button" onclick="staffSelectReason(this)"
                    class="staff-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Customer requested
            </button>
            <button type="button" onclick="staffSelectReason(this)"
                    class="staff-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Out of stock
            </button>
            <button type="button" onclick="staffSelectReason(this)"
                    class="staff-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Fraudulent order
            </button>
            <button type="button" onclick="staffSelectReason(this)"
                    class="staff-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Payment failed
            </button>
        </div>

        <textarea id="staffCancelReasonInput"
                  rows="3"
                  maxlength="500"
                  required
                  placeholder="Or type a custom reason... (optional)"
                  class="w-full border border-gray-300 rounded-xl px-4 py-2.5 text-sm resize-none focus:ring-2 focus:ring-red-400 focus:outline-none mb-1"></textarea>
        <p class="text-xs text-gray-400 text-right mb-4"><span id="staffCharCount">0</span>/500</p>

        <div class="flex gap-3 justify-end">
            <button type="button" onclick="closeStaffCancelModal()"
                    class="px-5 py-2.5 rounded-xl border border-gray-200 text-gray-600 font-semibold text-sm hover:bg-gray-50 transition-colors">
                Go Back
            </button>
            <button type="button" onclick="confirmStaffCancel()"
                    class="px-5 py-2.5 rounded-xl bg-red-500 text-white font-bold text-sm hover:bg-red-600 transition-colors">
                Confirm Cancel
            </button>
        </div>
    </div>
</div>
<%-- =================================================================== --%>

<style>
    .staff-reason-btn.selected {
        border-color: #ef4444;
        color: #ef4444;
        background-color: #fef2f2;
        font-weight: 600;
    }
    @keyframes staffFade {
        from {
            opacity: 0;
            transform: scale(0.97);
        }
        to   {
            opacity: 1;
            transform: scale(1);
        }
    }
    .animate-staff-fade {
        animation: staffFade 0.18s ease-out;
    }
</style>

<script>
    const CANCELLED_CODE = '${cancelledCode}';
    const NEXT_STATUS = '${nextStatus}';
    const NEXT_OF_NEXT = '${nextOfNext}';

    function setStatus(code) {
        // 1. VALIDATION FIRST
        // If clicking to SHIPPING
        if (code === NEXT_STATUS && code === 'SHIPPING') {
            const selects = document.querySelectorAll('select[name^="assign_inv_"]');
            let isValid = true;

            for (let s of selects) {
                if (s.value === "") {
                    isValid = false;
                    s.style.borderColor = "red"; // Highlight unselected box
                } else {
                    s.style.borderColor = "";
                }
            }

            if (!isValid) {
                alert("Please select a Serial for all products from stock before switching to Shipping!");
                return; // Stop here
            }
        }

        // 2. UPDATE STATUS
        document.getElementById('selectedStatus').value = code;
        document.getElementById('statusPreview').textContent = 'Will update status to: ' + code;
        document.getElementById('statusPreview').className = 'mt-2 text-xs text-blue-600 font-semibold';

        // 3. PAYMENT STATUS LOGIC
        const alreadyPaid = '${order.paymentStatus}' === 'PAID';
        if (alreadyPaid)
            return;

        const paymentInput = document.getElementById('selectedPayment');
        const paymentDisplay = document.getElementById('paymentDisplay');
        const paymentPreview = document.getElementById('paymentPreview');

        let newPayment, bgClass, textClass, borderClass;

        if (code === CANCELLED_CODE) {
            newPayment = 'UNPAID';
            bgClass = 'bg-gray-100';
            textClass = 'text-gray-500';
            borderClass = 'border-gray-200';
        } else if (code === NEXT_STATUS && NEXT_OF_NEXT === '') {
            newPayment = 'PAID';
            bgClass = 'bg-green-50';
            textClass = 'text-green-700';
            borderClass = 'border-green-200';
        } else {
            newPayment = 'UNPAID';
            bgClass = 'bg-gray-100';
            textClass = 'text-gray-500';
            borderClass = 'border-gray-200';
        }

        paymentInput.value = newPayment;
        paymentDisplay.textContent = newPayment;
        paymentDisplay.className =
                'px-3 py-2 rounded-lg text-sm font-bold border cursor-not-allowed '
                + bgClass + ' ' + textClass + ' ' + borderClass;


        paymentPreview.className = 'mt-1 text-xs font-semibold '
                + (newPayment === 'PAID' ? 'text-green-600' : 'text-gray-500');
    }

    // ===== Staff Cancel Modal =====
    function openStaffCancelModal() {
        document.getElementById('staffCancelReasonInput').value = '';
        document.getElementById('staffCharCount').textContent = '0';
        document.querySelectorAll('.staff-reason-btn').forEach(b => b.classList.remove('selected'));
        document.getElementById('staffCancelModal').classList.remove('hidden');
    }

    function closeStaffCancelModal() {
        document.getElementById('staffCancelModal').classList.add('hidden');
    }

    function handleStaffModalBackdrop(e) {
        if (e.target === document.getElementById('staffCancelModal'))
            closeStaffCancelModal();
    }

    function staffSelectReason(btn) {
        const isSelected = btn.classList.contains('selected');
        document.querySelectorAll('.staff-reason-btn').forEach(b => b.classList.remove('selected'));
        if (!isSelected) {
            btn.classList.add('selected');
            document.getElementById('staffCancelReasonInput').value = btn.textContent.trim();
            document.getElementById('staffCharCount').textContent = btn.textContent.trim().length;
        } else {
            document.getElementById('staffCancelReasonInput').value = '';
            document.getElementById('staffCharCount').textContent = '0';
        }
    }

    function confirmStaffCancel() {
        const reasonInput = document.getElementById('staffCancelReasonInput');
        const reason = reasonInput.value.trim();

        if (reason === "") {
            alert("Cancel reason is required!");
            reasonInput.focus();
            reasonInput.style.borderColor = "red";
            return;
        }

        document.getElementById('selectedCancelReason').value = reason;
        setStatus(CANCELLED_CODE);
        document.getElementById('editOrderForm').submit();
    }

    // Char counter
    document.addEventListener('DOMContentLoaded', function () {
        const input = document.getElementById('staffCancelReasonInput');
        if (input) {
            input.addEventListener('input', function () {
                document.getElementById('staffCharCount').textContent = this.value.length;
                document.querySelectorAll('.staff-reason-btn').forEach(b => b.classList.remove('selected'));
            });
        }
    });

    function updateProfitEstimation() {
        const revenue = parseFloat('${order.totalAmount}');
        let totalCost = 0;

        const selects = document.querySelectorAll('select[name^="assign_inv_"]');

        selects.forEach(select => {
            const selectedOption = select.options[select.selectedIndex];
            if (selectedOption && selectedOption.dataset.import) {
                totalCost += parseFloat(selectedOption.dataset.import);
            }
        });

        const profit = revenue - totalCost;


        document.getElementById('totalImportPrice').textContent = totalCost.toLocaleString('en-US') + 'd';
        document.getElementById('estimatedProfit').textContent = profit.toLocaleString('en-US') + 'd';

        const profitEl = document.getElementById('estimatedProfit');
        if (profit < 0) {
            profitEl.className = 'text-lg font-bold text-red-600';
        } else {
            profitEl.className = 'text-lg font-bold text-green-600';
        }
    }

    document.addEventListener('change', function (e) {
        if (e.target && e.target.name && e.target.name.startsWith('assign_inv_')) {
            updateProfitEstimation();
        }
    });

    document.addEventListener('DOMContentLoaded', updateProfitEstimation);
</script>