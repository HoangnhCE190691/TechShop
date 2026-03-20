<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="bg-gray-50 min-h-screen p-6">
    <div class="max-w-4xl mx-auto bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gray-800 p-4 text-white flex justify-between items-center">
            <h2 class="text-xl font-bold">Order Detail #${order.orderId}</h2>
            <span class="px-3 py-1 rounded-full text-xs font-bold 
                  ${order.paymentStatus == 'PAID' ? 'bg-green-500 text-white' : 'bg-orange-500 text-white'}">
                <i class="fas fa-circle text-[8px] mr-1"></i> ${order.paymentStatus}
            </span>
            <span class="px-3 py-1 bg-blue-500 rounded-full text-xs">${order.status}</span>
        </div>

        <div class="p-6">

            <%-- ===== BANNER LÝ DO HỦY (chỉ hiện khi đơn CANCELLED) ===== --%>
            <c:if test="${order.status == 'CANCELLED'}">
                <div class="mb-6 rounded-xl border border-red-200 bg-red-50 p-4 flex gap-3">
                    <div class="flex-shrink-0 mt-0.5">
                        <svg class="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                  d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M12 3a9 9 0 100 18A9 9 0 0012 3z"/>
                        </svg>
                    </div>
                    <div>
                        <p class="text-sm font-bold text-red-600 mb-0.5">Order Cancelled</p>
                        <p class="text-sm text-red-500">
                            <c:choose>
                                <c:when test="${not empty order.cancelReason}">
                                    <span class="font-medium">Reason:</span> ${order.cancelReason}
                                </c:when>
                                <c:otherwise>
                                    <span class="italic text-red-400">No cancellation reason was provided.</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>
            </c:if>
            <%-- ========================================================= --%>

            <div class="grid grid-cols-2 gap-4 mb-8">
                <div>
                    <h3 class="text-gray-500 text-sm uppercase font-bold">Customer Information</h3>
                    <p class="font-semibold text-gray-800">Name:${order.customerName}</p>
                    <p class="text-sm text-gray-600">Email: ${order.email}</p>
                    <p class="text-sm text-gray-600">Phone: ${order.phone}</p>

                    <h3 class="text-gray-500 text-sm uppercase font-bold mt-4">Shipping To</h3>
                    <p class="text-gray-600">${order.shippingAddress}</p>
                </div>
                <div class="text-right space-y-4">
                    <div>
                        <h3 class="text-gray-500 text-sm uppercase font-bold">Order Date</h3>
                        <p class="text-gray-800 font-medium">${order.createdAt}</p>
                    </div>

                    <div>
                        <h3 class="text-gray-500 text-sm uppercase font-bold">Payment Method</h3>
                        <p class="text-gray-900 font-bold">${order.paymentMethodName != null ? order.paymentMethodName : 'N/A'}</p>
                    </div>
                </div>

            </div>

            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="border-b-2 border-gray-100">
                        <th class="py-3 font-bold text-gray-700">Product Image</th>  
                        <th class="py-3 font-bold text-gray-700">Product Name</th>
                        <th class="py-3 font-bold text-gray-700">IMEI / Serial</th>
                        <th class="py-3 text-right font-bold text-gray-700">Price</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${items}" var="item">
                        <tr class="border-b border-gray-50 hover:bg-gray-50">
                            <td class="py-4">
                                <img src="${item.imageUrl != null ? item.imageUrl : 'https://placehold.co/100x100'}" 
                                     alt="${item.productName}" class="w-[100px] h-[100px] object-cover rounded">
                            </td>
                            <td class="py-4">
                                <div class="font-medium">${item.productName}</div>
                                <div class="text-xs text-gray-400">SKU: ${item.sku}</div>
                            </td>
                            <td class="py-4 font-mono text-sm text-blue-600">
                                <c:choose>
                                    <c:when test="${not empty item.imei}">
                                        ${item.imei}
                                    </c:when>
                                    <c:when test="${not empty item.quantity}">
                                        x${item.quantity}
                                    </c:when>
                                    <c:otherwise>
                                        —
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="py-4 text-right font-bold text-red-500">
                                <fmt:formatNumber value="${item.price}" type="number" pattern="#,###"/>đ
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="mt-8 border-t pt-4 flex justify-end">
                <div class="text-right">
                    <span class="text-gray-500 mr-4">Total Amount:</span>
                    <span class="text-2xl font-bold text-gray-900">
                        <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,###"/>đ
                    </span>
                </div>
            </div>
        </div>

        <div class="bg-gray-50 p-4 border-t text-center">
            <a href="staffservlet?action=processOrderManagement" class="text-blue-600 hover:underline">
                ← Back to Order List
            </a>
        </div>
    </div>
</div>
