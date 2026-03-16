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
                    </div>

                    <div class="space-y-4 mb-6">
                        <div class="flex gap-4 items-center">
                            <div class="w-[150px] h-[150px] flex-shrink-0 bg-gray-50 rounded-xl border border-gray-100 p-2">
                                <img src="${order.productImageUrl != null && order.productImageUrl != '' ? order.productImageUrl : 'https://placehold.co/200x200/ffffff/555555?text=Order'}" 
                                     alt="Product" class="w-full h-full object-contain mix-blend-multiply">
                            </div>
                            <div class="flex-1">
                                <h3 class="order-name font-bold text-gray-900 text-base line-clamp-1 hover:text-red-600 cursor-pointer transition-colors">
                                    ${order.orderName}
                                </h3>
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
                            <%-- Chỉ cho hủy khi là bước đầu (PENDING) và chưa PAID --%>
                            <c:forEach var="s" items="${statusList}">
                                <c:if test="${s.statusCode == order.status && s.stepOrder == 1}">
                                    <c:set var="canCancel" value="true"/>
                                </c:if>
                            </c:forEach>

                            <c:choose>
                                <c:when test="${canCancel && order.paymentStatus != 'PAID'}">
                                    <form method="post" action="orderhistorypageservlet"
                                          onsubmit="return confirm('Are you sure you want to cancel order #${order.orderId}?')">
                                        <input type="hidden" name="action" value="cancelOrder">
                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                        <button type="submit"
                                                class="px-5 py-2.5 rounded-xl border border-red-200 text-red-500 font-bold text-sm hover:bg-red-50 transition-colors">
                                            Cancel Order
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <button disabled
                                            class="px-5 py-2.5 rounded-xl border border-gray-200 text-gray-400 font-bold text-sm cursor-not-allowed">
                                        Cancel Order
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <button class="px-5 py-2.5 rounded-xl bg-red-50 text-red-600 font-bold text-sm hover:bg-red-100 transition-colors">
                                <a href="orderhistorypageservlet?action=orderDetail&id=${order.orderId}" class="block">View Details</a>
                            </button>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<style>
    .hide-scrollbar::-webkit-scrollbar {
        display: none;
    }
    .hide-scrollbar {
        -ms-overflow-style: none;
        scrollbar-width: none;
    }
</style>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const searchInput = document.getElementById('searchInput');
        const orderRows = document.querySelectorAll('.order-card');

        searchInput.addEventListener('keyup', function () {
            const searchTerm = searchInput.value.toLowerCase();

            orderRows.forEach(function (row) {
                const orderName = row.querySelector('.order-name')?.textContent.toLowerCase() || '';
                const orderId = row.querySelector('.order-id')?.textContent.toLowerCase() || '';
                const shippingAddress = row.textContent.toLowerCase();

                if (orderName.includes(searchTerm) || orderId.includes(searchTerm) || shippingAddress.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    });
</script>