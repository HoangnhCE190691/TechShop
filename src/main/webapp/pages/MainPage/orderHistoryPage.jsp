<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="bg-gray-50 min-h-screen pb-12 font-sans text-gray-800">
    <div class="max-w-[1000px] mx-auto px-4 py-8 md:py-12">

        <div class="mb-8">
            <h1 class="text-2xl md:text-3xl font-extrabold text-gray-900 tracking-tight mb-2">Order History</h1>
            <p class="text-sm text-gray-500">Manage and track the status of your orders.</p>
        </div>

        <c:set var="currentStatus" value="${empty currentStatus ? 'ALL' : currentStatus}"/>
        <div class="bg-white rounded-2xl p-4 mb-6 shadow-sm border border-gray-100">
            <div class="relative flex-1">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                </span>
                <input type="text" id="searchInput"
                       class="w-full pl-10 pr-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500"
                       placeholder="Search ordered products...">
            </div>
        </div>
        <div class="bg-white rounded-2xl p-2 mb-6 flex overflow-x-auto shadow-sm border border-gray-100 snap-x hide-scrollbar">
            <a href="orderhistorypageservlet"
               class="snap-center flex-shrink-0 px-6 py-2.5 rounded-xl text-sm transition-colors
               ${currentStatus == 'ALL' ? 'font-bold text-red-600 bg-red-50' : 'font-semibold text-gray-600 hover:bg-gray-50 hover:text-gray-900'}">
                All Orders
            </a>
            <c:forEach var="status" items="${statusList}">
                <a href="orderhistorypageservlet?status=${status.statusCode}"
                   class="snap-center flex-shrink-0 px-6 py-2.5 rounded-xl text-sm transition-colors
                   ${currentStatus == status.statusCode ? 'font-bold text-red-600 bg-red-50' : 'font-semibold text-gray-600 hover:bg-gray-50 hover:text-gray-900'}">
                    ${status.statusName}
                </a>
            </c:forEach>
        </div>

        <div class="space-y-6">

            <c:if test="${empty orders}">
                <div class="bg-white rounded-2xl border border-dashed border-gray-200 p-8 text-center text-gray-500">
                    You currently have no orders.
                </div>
            </c:if>

            <c:forEach var="order" items="${orders}">
                <c:set var="statusCode" value="${order.status}"/>
                <c:set var="badgeClass"
                       value="px-3 py-1 bg-yellow-100 text-yellow-700 text-xs font-bold rounded-lg flex items-center gap-1.5 uppercase tracking-wide"/>
                <c:set var="badgeText" value="Processing"/>

                <c:choose>
                    <c:when test="${statusCode == 'CREATED' || statusCode == 'PENDING'}">
                        <c:set var="badgeText" value="Awaiting Confirmation"/>
                    </c:when>
                    <c:when test="${statusCode == 'APPROVED'}">
                        <c:set var="badgeClass"
                               value="px-3 py-1 bg-purple-100 text-purple-700 text-xs font-bold rounded-lg flex items-center gap-1.5 uppercase tracking-wide"/>
                        <c:set var="badgeText" value="Approved"/>
                    </c:when>
                    <c:when test="${statusCode == 'SHIPPING' || statusCode == 'DELIVERING'}">
                        <c:set var="badgeClass"
                               value="px-3 py-1 bg-blue-100 text-blue-700 text-xs font-bold rounded-lg flex items-center gap-1.5 uppercase tracking-wide"/>
                        <c:set var="badgeText" value="In Transit"/>
                    </c:when>
                    <c:when test="${statusCode == 'SHIPPED' || statusCode == 'DELIVERED'}">
                        <c:set var="badgeClass"
                               value="px-3 py-1 bg-green-100 text-green-700 text-xs font-bold rounded-lg flex items-center gap-1.5 uppercase tracking-wide"/>
                        <c:set var="badgeText" value="Delivered Successfully"/>
                    </c:when>
                    <c:when test="${statusCode == 'CANCELLED'}">
                        <c:set var="badgeClass"
                               value="px-3 py-1 bg-gray-200 text-gray-600 text-xs font-bold rounded-lg flex items-center gap-1.5 uppercase tracking-wide"/>
                        <c:set var="badgeText" value="Cancelled"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="badgeText" value="${statusCode}"/>
                    </c:otherwise>
                </c:choose>

                <div class="order-card bg-white border border-gray-100 rounded-3xl p-6 shadow-sm hover:shadow-md transition-shadow">
                    <div class="flex flex-wrap items-center justify-between border-b border-gray-100 pb-4 mb-4 gap-4">
                        <div class="flex items-center gap-3">
                            <span class="order-id font-bold text-gray-900">Order ID: #${order.orderId}</span>
                            <span class="w-1.5 h-1.5 rounded-full bg-gray-300"></span>
                            <span class="text-sm text-gray-500">
                                <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                        </div>
                        <span class="${badgeClass}">
                            ${badgeText}
                        </span>
                        <c:if test="${order.status == 'SHIPPED' && not empty order.shippedDate}">
                            <p class="text-xs text-gray-500 mt-1">
                                <i class="fas fa-clock mr-1"></i> 
                                <span class="countdown-shipped" data-shipped="${order.shippedDate}"></span>
                            </p>
                        </c:if>
                    </div>

                    <div class="space-y-4 mb-6">
                        <div class="flex gap-4 items-center">
                            <div class="w-[150px] h-[150px] flex-shrink-0 bg-gray-50 rounded-xl border border-gray-100 p-2">
                                <img src="${order.productImageUrl != null && order.productImageUrl != '' ? order.productImageUrl : 'https://placehold.co/200x200/ffffff/555555?text=Order'}" 
                                     alt="Product" class="w-full h-full object-contain mix-blend-multiply">
                            </div>
                            <div class="flex-1">
                                <c:choose>
                                    <c:when test="${not empty order.productId && order.productId > 0}">
                                        <a href="${pageContext.request.contextPath}/detailservlet?productId=${order.productId}" class="block">
                                            <h3 class="order-name font-bold text-gray-900 text-base line-clamp-1 hover:text-red-600 cursor-pointer transition-colors">
                                                ${order.orderName}
                                            </h3>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <h3 class="order-name font-bold text-gray-900 text-base line-clamp-1 cursor-default text-gray-400">
                                            ${order.orderName}
                                        </h3>
                                    </c:otherwise>
                                </c:choose>
                                <p class="text-sm text-gray-500 mt-1">${order.shippingAddress}</p>
                            </div>
                            <div class="text-right">
                                <p class="font-bold text-red-600">
                                    <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,###"/>đ
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="flex flex-wrap items-center justify-between pt-4 border-t border-gray-100 gap-4">
                        <div class="flex items-baseline gap-2">
                            <span class="text-gray-600 text-sm font-medium">Total:</span>
                            <span class="text-2xl font-black text-red-600">
                                <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,###"/>đ
                            </span>
                        </div>

                        <div class="flex gap-3">
                            <%-- 1. QUAN TRỌNG: Reset flag canCancel về false cho mỗi đơn hàng mới --%>
                            <c:set var="canCancel" value="false"/>

                            <%-- 2. Kiểm tra xem status hiện tại có phải là bước đầu tiên (stepOrder == 1) không --%>
                            <c:forEach var="s" items="${statusList}">
                                <c:if test="${s.statusCode == order.status && s.stepOrder == 1}">
                                    <c:set var="canCancel" value="true"/>
                                </c:if>
                            </c:forEach>

                            <%-- 3. Hiển thị nút dựa trên flag đã reset và status thực tế --%>
                            <c:choose>
                                <%-- Điều kiện: được phép hủy (step 1) VÀ chưa thanh toán VÀ trạng thái hiện tại khác CANCELLED --%>
                                <c:when test="${canCancel && order.paymentStatus != 'PAID' && order.status != 'CANCELLED'}">
                                    <button type="button"
                                            onclick="openCancelModal(${order.orderId})"
                                            class="px-5 py-2.5 rounded-xl border border-red-200 text-red-500 font-bold text-sm hover:bg-red-50 transition-colors">
                                        Cancel Order
                                    </button>
                                </c:when>

                                <c:otherwise>
                                    <%-- Nút bị Disable --%>
                                    <button disabled
                                            class="px-5 py-2.5 rounded-xl border border-gray-200 text-gray-400 font-bold text-sm cursor-not-allowed">
                                        <c:choose>
                                            <c:when test="${order.status == 'CANCELLED'}">Already Cancelled</c:when>
                                            <c:when test="${order.paymentStatus == 'PAID'}">Paid (No Cancel)</c:when>
                                            <c:otherwise>Cancel Order</c:otherwise>
                                        </c:choose>
                                    </button>
                                </c:otherwise>
                            </c:choose>

                            <button class="px-5 py-2.5 rounded-xl bg-red-50 text-red-600 font-bold text-sm hover:bg-red-100 transition-colors">
                                <a href="orderhistorypageservlet?action=orderDetail&id=${order.orderId}" class="block">View Details</a>
                            </button>
                            <c:if test="${order.status == 'SHIPPED'}">
                                <form action="orderhistorypageservlet" method="GET" class="inline">
                                    <input type="hidden" name="action" value="confirmReceived">
                                    <input type="hidden" name="id" value="${order.orderId}">
                                    <button type="submit" 
                                            class="px-5 py-2.5 bg-green-600 text-white text-sm font-bold rounded-xl hover:bg-green-700 transition-colors shadow-sm"
                                            onclick="return confirm('Confirm received order #${order.orderId}?');">
                                        <i class="fas fa-check-circle mr-1"></i> Order received
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<%-- ===================== MODAL HỦY ĐƠN HÀNG ===================== --%>
<div id="cancelModal"
     class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm hidden"
     onclick="handleModalBackdropClick(event)">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 p-6 animate-fade-in">
        <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M12 9v2m0 4h.01M10.293 5.293a1 1 0 011.414 0L12 6l.293-.293a1 1 0 011.414 1.414L12 8.414l-1.707-1.707a1 1 0 010-1.414zM4.929 19.071A10 10 0 1019.07 4.93 10 10 0 004.93 19.07z"/>
                </svg>
            </div>
            <div>
                <h2 class="text-lg font-extrabold text-gray-900">Cancel Order</h2>
                <p class="text-sm text-gray-500">Order #<span id="modalOrderId"></span></p>
            </div>
        </div>

        <p class="text-sm text-gray-600 mb-3">Please select or enter a reason for cancellation:</p>

        <div class="flex flex-wrap gap-2 mb-3" id="quickReasons">
            <button type="button" onclick="selectQuickReason(this)"
                    class="quick-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Changed my mind
            </button>
            <button type="button" onclick="selectQuickReason(this)"
                    class="quick-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Found a better price
            </button>
            <button type="button" onclick="selectQuickReason(this)"
                    class="quick-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Ordered by mistake
            </button>
            <button type="button" onclick="selectQuickReason(this)"
                    class="quick-reason-btn px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:border-red-300 hover:text-red-600 transition-colors">
                Want to apply another voucher
            </button>
        </div>

        <textarea id="cancelReasonInput"
                  rows="3"
                  maxlength="500"
                  placeholder="Or type your own reason... "
                  class="w-full border border-gray-300 rounded-xl px-4 py-2.5 text-sm resize-none focus:ring-2 focus:ring-red-400 focus:outline-none mb-1"></textarea>
        <p class="text-xs text-gray-400 text-right mb-4"><span id="charCount">0</span>/500</p>
        <p id="cancelReasonError" class="text-xs text-red-500 font-semibold mb-3 hidden">
            Please select or enter a reason before confirming.
        </p>

        <form id="cancelOrderForm" method="post" action="orderhistorypageservlet">
            <input type="hidden" name="action" value="cancelOrder">
            <input type="hidden" name="orderId" id="cancelOrderIdInput">
            <input type="hidden" name="cancelReason" id="cancelReasonHidden">
        </form>

        <div class="flex gap-3 justify-end">
            <button type="button" onclick="closeCancelModal()"
                    class="px-5 py-2.5 rounded-xl border border-gray-200 text-gray-600 font-semibold text-sm hover:bg-gray-50 transition-colors">
                Go Back
            </button>
            <button type="button" onclick="submitCancelOrder()"
                    class="px-5 py-2.5 rounded-xl bg-red-500 text-white font-bold text-sm hover:bg-red-600 transition-colors">
                Confirm Cancellation
            </button>
        </div>
    </div>
</div>
<%-- ============================================================== --%>

<style>
    .hide-scrollbar::-webkit-scrollbar {
        display: none;
    }
    .hide-scrollbar {
        -ms-overflow-style: none;
        scrollbar-width: none;
    }
    .quick-reason-btn.selected {
        border-color: #ef4444;
        color: #ef4444;
        background-color: #fef2f2;
        font-weight: 600;
    }
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: scale(0.97);
        }
        to   {
            opacity: 1;
            transform: scale(1);
        }
    }
    .animate-fade-in {
        animation: fadeIn 0.18s ease-out;
    }
</style>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        // Search
        const searchInput = document.getElementById('searchInput');
        const orderRows = document.querySelectorAll('.order-card');
        searchInput.addEventListener('keyup', function () {
            const searchTerm = searchInput.value.toLowerCase();
            orderRows.forEach(function (row) {
                const orderName = row.querySelector('.order-name')?.textContent.toLowerCase() || '';
                const orderId = row.querySelector('.order-id')?.textContent.toLowerCase() || '';
                const shippingAddress = row.textContent.toLowerCase();
                row.style.display = (orderName.includes(searchTerm) || orderId.includes(searchTerm) || shippingAddress.includes(searchTerm)) ? '' : 'none';
            });
        });

        // Char counter textarea
        document.getElementById('cancelReasonInput').addEventListener('input', function () {
            document.getElementById('charCount').textContent = this.value.length;
            document.querySelectorAll('.quick-reason-btn').forEach(b => b.classList.remove('selected'));
            if (this.value.trim()) {
                document.getElementById('cancelReasonError').classList.add('hidden');
                this.classList.remove('border-red-400');
            }
        });
    });

    function openCancelModal(orderId) {
        document.getElementById('modalOrderId').textContent = orderId;
        document.getElementById('cancelOrderIdInput').value = orderId;
        document.getElementById('cancelReasonInput').value = '';
        document.getElementById('charCount').textContent = '0';
        document.querySelectorAll('.quick-reason-btn').forEach(b => b.classList.remove('selected'));
        document.getElementById('cancelModal').classList.remove('hidden');
    }

    function closeCancelModal() {
        document.getElementById('cancelModal').classList.add('hidden');
    }

    function handleModalBackdropClick(event) {
        if (event.target === document.getElementById('cancelModal'))
            closeCancelModal();
    }

    function selectQuickReason(btn) {
        const isSelected = btn.classList.contains('selected');
        document.querySelectorAll('.quick-reason-btn').forEach(b => b.classList.remove('selected'));
        if (!isSelected) {
            btn.classList.add('selected');
            document.getElementById('cancelReasonError').classList.add('hidden');
            document.getElementById('cancelReasonInput').classList.remove('border-red-400');
            document.getElementById('cancelReasonInput').value = btn.textContent.trim();
            document.getElementById('charCount').textContent = btn.textContent.trim().length;
        } else {
            document.getElementById('cancelReasonInput').value = '';
            document.getElementById('charCount').textContent = '0';
        }
    }

    function submitCancelOrder() {
        const reason = document.getElementById('cancelReasonInput').value.trim();
        const errorEl = document.getElementById('cancelReasonError');
        if (!reason) {
            errorEl.classList.remove('hidden');
            document.getElementById('cancelReasonInput').classList.add('border-red-400');
            return;
        }
        errorEl.classList.add('hidden');
        document.getElementById('cancelReasonHidden').value = reason;
        document.getElementById('cancelOrderForm').submit();
    }
    document.addEventListener('DOMContentLoaded', function () {
        const countdowns = document.querySelectorAll('.countdown-shipped');
        const thresholdDays = 5;

        countdowns.forEach(function (el) {
            const shippedStr = el.getAttribute('data-shipped');
            if (!shippedStr)
                return;

            const shippedDate = new Date(shippedStr);
            const now = new Date();
            const diffTime = now - shippedDate;
            const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
            const daysLeft = thresholdDays - diffDays;

            if (daysLeft > 0) {
                el.textContent = 'Remain ' + daysLeft + ' days to confirm order';
                el.style.color = '#f59e0b';
            } else if (daysLeft === 0) {
                el.textContent = 'Today is the deadline for confirmation!';
                el.style.color = '#ef4444';
            } else {
                el.textContent = 'Overdue - will automatically complete';
                el.style.color = '#6b7280';
            }
        });
    });
</script>