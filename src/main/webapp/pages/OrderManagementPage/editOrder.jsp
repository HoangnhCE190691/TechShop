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
        <%-- cancelReason: chỉ có giá trị khi staff chọn Cancel --%>
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
        </div>

        <div>
            <label class="block text-sm font-bold text-gray-700">Shipping Address</label>
            <textarea name="shippingAddress" rows="2" readonly
                      class="w-full mt-1 p-2 border rounded-lg bg-gray-100 text-gray-600 cursor-not-allowed focus:outline-none pointer-events-none"
                      >${order.shippingAddress}</textarea>
        </div>

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
                        <%-- Hiển thị lý do hủy nếu có --%>
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
                        <div class="flex gap-2">
                            <button type="button"
                                    onclick="setStatus('${nextStatus}')"
                                    class="flex-1 px-3 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700 transition">
                                Next: ${nextStatus}
                            </button>
                            <c:if test="${order.status != cancelledCode}">
                                <%-- Nút Cancel mở modal thay vì submit thẳng --%>
                                <button type="button"
                                        onclick="openStaffCancelModal()"
                                        class="px-3 py-2 bg-red-100 text-red-600 text-sm font-bold rounded-lg hover:bg-red-200 transition">
                                    Cancel
                                </button>
                            </c:if>
                        </div>
                        <p id="statusPreview" class="mt-2 text-xs text-gray-400">
                            No change selected - will keep current status.
                        </p>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- PAYMENT STATUS --%>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">Payment Status</label>

                <%-- autoPayment: ưu tiên DB thực tế, sau đó mới tính theo status --%>
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
                <p class="mt-1 text-xs text-gray-400 italic">Auto-set based on order status.</p>
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

<%-- ============= MODAL NHẬP LÝ DO HỦY (dành cho Staff) ============= --%>
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

        <%-- Quick reasons cho staff --%>
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
        from { opacity: 0; transform: scale(0.97); }
        to   { opacity: 1; transform: scale(1); }
    }
    .animate-staff-fade { animation: staffFade 0.18s ease-out; }
</style>

<script>
    const CANCELLED_CODE = '${cancelledCode}';
    const NEXT_STATUS    = '${nextStatus}';
    const NEXT_OF_NEXT   = '${nextOfNext}';

    function setStatus(code) {
        document.getElementById('selectedStatus').value = code;
        document.getElementById('statusPreview').textContent = 'Will update status to: ' + code;
        document.getElementById('statusPreview').className = 'mt-2 text-xs text-blue-600 font-semibold';

        const alreadyPaid = '${order.paymentStatus}' === 'PAID';
        if (alreadyPaid) return;

        const paymentInput   = document.getElementById('selectedPayment');
        const paymentDisplay = document.getElementById('paymentDisplay');
        const paymentPreview = document.getElementById('paymentPreview');

        let newPayment, bgClass, textClass, borderClass;

        if (code === CANCELLED_CODE) {
            newPayment  = 'UNPAID';
            bgClass     = 'bg-gray-100';
            textClass   = 'text-gray-500';
            borderClass = 'border-gray-200';
        } else if (code === NEXT_STATUS && NEXT_OF_NEXT === '') {
            newPayment  = 'PAID';
            bgClass     = 'bg-green-50';
            textClass   = 'text-green-700';
            borderClass = 'border-green-200';
        } else {
            newPayment  = 'UNPAID';
            bgClass     = 'bg-gray-100';
            textClass   = 'text-gray-500';
            borderClass = 'border-gray-200';
        }

        paymentInput.value        = newPayment;
        paymentDisplay.textContent = newPayment;
        paymentDisplay.className  =
            'px-3 py-2 rounded-lg text-sm font-bold border cursor-not-allowed '
            + bgClass + ' ' + textClass + ' ' + borderClass;

        paymentPreview.textContent = 'Will update to: ' + newPayment;
        paymentPreview.className   = 'mt-1 text-xs font-semibold '
            + (newPayment === 'PAID' ? 'text-green-600' : 'text-gray-500');
    }

    // ===== Staff Cancel Modal =====
    function openStaffCancelModal() {
        document.getElementById('staffCancelReasonInput').value = '';
        document.getElementById('staffCharCount').textContent   = '0';
        document.querySelectorAll('.staff-reason-btn').forEach(b => b.classList.remove('selected'));
        document.getElementById('staffCancelModal').classList.remove('hidden');
    }

    function closeStaffCancelModal() {
        document.getElementById('staffCancelModal').classList.add('hidden');
    }

    function handleStaffModalBackdrop(e) {
        if (e.target === document.getElementById('staffCancelModal')) closeStaffCancelModal();
    }

    function staffSelectReason(btn) {
        const isSelected = btn.classList.contains('selected');
        document.querySelectorAll('.staff-reason-btn').forEach(b => b.classList.remove('selected'));
        if (!isSelected) {
            btn.classList.add('selected');
            document.getElementById('staffCancelReasonInput').value = btn.textContent.trim();
            document.getElementById('staffCharCount').textContent   = btn.textContent.trim().length;
        } else {
            document.getElementById('staffCancelReasonInput').value = '';
            document.getElementById('staffCharCount').textContent   = '0';
        }
    }

    function confirmStaffCancel() {
        const reason = document.getElementById('staffCancelReasonInput').value.trim();
        document.getElementById('selectedCancelReason').value = reason;
        // Cập nhật status về CANCELLED rồi submit form
        setStatus(CANCELLED_CODE);
        document.getElementById('editOrderForm').submit();
    }

    // Char counter
    document.addEventListener('DOMContentLoaded', function () {
        document.getElementById('staffCancelReasonInput').addEventListener('input', function () {
            document.getElementById('staffCharCount').textContent = this.value.length;
            document.querySelectorAll('.staff-reason-btn').forEach(b => b.classList.remove('selected'));
        });
    });
</script>
