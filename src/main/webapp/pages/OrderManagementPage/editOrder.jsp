<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="max-w-2xl mx-auto bg-white rounded-xl shadow-md overflow-hidden mt-10 border border-gray-200">
    <div class="bg-gray-800 p-4 text-white font-bold text-lg">
        Edit Order #${order.orderId}
    </div>
    <form action="orderStaffServlet" method="POST" class="p-6 space-y-6">
        <input type="hidden" name="action" value="updateOrder">
        <input type="hidden" name="orderId" value="${order.orderId}">
        <input type="hidden" name="status" id="selectedStatus" value="${order.status}">

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
                                <button type="button"
                                        onclick="setStatus('${cancelledCode}')"
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

<script>
    const CANCELLED_CODE = '${cancelledCode}';
    const NEXT_STATUS = '${nextStatus}';   // next cua status HIEN TAI (vd: SHIPPING)
    const NEXT_OF_NEXT = '${nextOfNext}';   // next cua NEXT_STATUS (vd: next cua SHIPPED = '')

    function setStatus(code) {
        document.getElementById('selectedStatus').value = code;
        document.getElementById('statusPreview').textContent = 'Will update status to: ' + code;
        document.getElementById('statusPreview').className = 'mt-2 text-xs text-blue-600 font-semibold';

        const alreadyPaid = '${order.paymentStatus}' === 'PAID';
        if (alreadyPaid)
            return;

        const paymentInput = document.getElementById('selectedPayment');
        const paymentDisplay = document.getElementById('paymentDisplay');
        const paymentPreview = document.getElementById('paymentPreview');

        let newPayment, bgClass, textClass, borderClass;

        if (code === CANCELLED_CODE) {
            // Cancelled -> UNPAID
            newPayment = 'UNPAID';
            bgClass = 'bg-gray-100';
            textClass = 'text-gray-500';
            borderClass = 'border-gray-200';
        } else if (code === NEXT_STATUS && NEXT_OF_NEXT === '') {
            // Bam Next va status do la final (khong con next nua) -> PAID
            newPayment = 'PAID';
            bgClass = 'bg-green-50';
            textClass = 'text-green-700';
            borderClass = 'border-green-200';
        } else {
            // Van con buoc tiep -> UNPAID
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

        paymentPreview.textContent = 'Will update to: ' + newPayment;
        paymentPreview.className = 'mt-1 text-xs font-semibold '
                + (newPayment === 'PAID' ? 'text-green-600' : 'text-gray-500');
    }
</script>
