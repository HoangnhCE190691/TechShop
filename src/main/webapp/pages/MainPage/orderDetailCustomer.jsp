<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="bg-gray-50 min-h-screen p-6">
    <div class="max-w-4xl mx-auto bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gray-800 p-4 text-white flex justify-between items-center">
            <h2 class="text-xl font-bold">Order Details #${order.orderId}</h2>
            <span class="px-3 py-1 rounded-full text-xs font-bold 
                  ${order.paymentStatus == 'PAID' ? 'bg-green-500 text-white' : 'bg-orange-500 text-white'}">
                <i class="fas fa-circle text-[8px] mr-1"></i> ${order.paymentStatus}
            </span>
            <span class="px-3 py-1 bg-blue-500 rounded-full text-xs">${order.status}</span>
            <button onclick="openHistoryModal()" 
                    class="px-3 py-1 bg-slate-400 hover:bg-slate-500 rounded-full text-sm text-white flex items-center gap-1 transition-colors">
                <i class="fas fa-clock"></i> Order status history
            </button>
        </div>

        <div class="p-6">
            <div class="grid grid-cols-2 gap-4 mb-8">
                <div>
                    <h3 class="text-gray-500 text-sm uppercase font-bold">Customer Information</h3>
                    <p class="font-semibold text-gray-800">Name: ${order.customerName}</p>
                    <p class="text-sm text-gray-600">Email: ${order.email}</p>
                    <p class="text-sm text-gray-600">Phone: ${order.phone}</p>

                    <h3 class="text-gray-500 text-sm uppercase font-bold mt-4">Shipping Address</h3>
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
                        <th class="py-3 text-center font-bold text-gray-700">Quantity</th>
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
                            <td class="py-4" >
                                <a href="detailservlet?productId=${item.productId}">
                                    <div class="font-medium hover:text-red-600 cursor-pointer transition-colors" >${item.productName}</div>
                                </a>
                                <div class="text-xs text-gray-400">SKU: ${item.sku}</div>
                            </td>
                            <td class="py-4 text-center font-bold text-gray-700">
                                x${item.quantity}
                            </td>
                            <td class="py-4 text-right font-bold text-red-500">
                                <fmt:formatNumber value="${item.price * item.quantity}" type="number" pattern="#,###"/>đ
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="mt-8 border-t pt-4 flex justify-end">
                <div class="text-right space-y-2">
                    <%-- Tính giá gốc từ items (có quantity) --%>
                    <c:set var="originalAmount" value="0"/>
                    <c:forEach items="${items}" var="item">
                        <c:set var="originalAmount" value="${originalAmount + item.price * item.quantity}"/>
                    </c:forEach>

                    <%-- Giá gốc --%>
                    <div class="flex justify-between gap-16 text-sm text-gray-600">
                        <span>Original Price:</span>
                        <span><fmt:formatNumber value="${originalAmount}" type="number" pattern="#,###"/>đ</span>
                    </div>

                    <%-- Giảm giá (voucher) — chỉ hiện nếu có --%>
                    <c:set var="discount" value="${originalAmount - order.totalAmount}"/>
                    <c:if test="${discount > 0}">
                        <div class="flex justify-between gap-16 text-sm text-green-600">
                            <span>Discount:</span>
                            <span>- <fmt:formatNumber value="${discount}" type="number" pattern="#,###"/>đ</span>
                        </div>
                    </c:if>

                    <%-- Phí ship --%>
                    <div class="flex justify-between gap-16 text-sm text-gray-600">
                        <span>Shipping:</span>
                        <c:choose>
                            <c:when test="${order.totalAmount >= 500000}">
                                <span class="text-green-600 font-medium">Free</span>
                            </c:when>
                            <c:otherwise>
                                <span>30,000đ</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <%-- Tổng --%>
                    <div class="border-t border-gray-200 pt-2 flex justify-between gap-16">
                        <span class="text-gray-500 font-medium">Total Amount:</span>
                        <c:choose>
                            <c:when test="${order.totalAmount >= 500000}">
                                <span class="text-2xl font-black text-red-600">
                                    <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,###"/>đ
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="text-2xl font-black text-red-600">
                                    <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,###"/>đ
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-gray-50 p-4 border-t text-center">
            <a href="orderhistorypageservlet" class="text-blue-600 hover:underline">
                ← Back to Order History
            </a>
        </div>
    </div>
    <!-- Modal Trạng thái đơn hàng -->
    <div id="historyModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-xl shadow-xl max-w-lg w-full mx-4 max-h-[80vh] overflow-hidden">
            <div class="bg-slate-500 p-4 text-white flex justify-between items-center">
                <h3 class="font-bold text-lg">Order status</h3>
                <button onclick="closeHistoryModal()" class="hover:bg-slate-600 px-2 py-1 rounded">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="p-4 overflow-y-auto max-h-[60vh]">
                <c:choose>
                    <c:when test="${not empty statusHistory}">
                        <table class="w-full text-left">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="py-2 px-2 text-sm font-bold text-gray-600">Status</th>
                                    <th class="py-2 px-2 text-sm font-bold text-gray-600">Date time</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${statusHistory}" var="h">
                                    <tr class="border-b border-gray-100 hover:bg-gray-50">
                                        <td class="py-3 px-2">
                                            <span class="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-medium">
                                                ${h.statusName}
                                            </span>
                                        </td>
                                        <td class="py-3 px-2 text-sm text-gray-500">
                                            <fmt:formatDate value="${h.changedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p class="text-center text-gray-500 py-8">No recorded</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
<script>
    function openHistoryModal() {
        document.getElementById('historyModal').classList.remove('hidden');
    }
    function closeHistoryModal() {
        document.getElementById('historyModal').classList.add('hidden');
    }
    document.getElementById('historyModal').addEventListener('click', function (e) {
        if (e.target === this)
            closeHistoryModal();
    });
</script>