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

        <div class="grid grid-cols-2 gap-4">
            <div>
                <label class="block text-xs font-bold text-gray-500 uppercase">Customer</label>
                <p class="font-semibold">${order.customerName}</p>
            </div>
            <div>
                <label class="block text-xs font-bold text-gray-500 uppercase">Total Amount</label>
                <p class="font-bold text-red-500">
                    <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,###"/>đ
                </p>
            </div>
        </div>

        <div>
            <label class="block text-sm font-bold text-gray-700">Shipping Address</label>
            <textarea name="shippingAddress" rows="2" class="w-full mt-1 p-2 border rounded-lg focus:ring-2 focus:ring-blue-500">${order.shippingAddress}</textarea>
        </div>

        <div class="grid grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-bold text-gray-700">Order Status</label>
                <select name="status" class="w-full mt-1 p-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    <c:forEach items="${statusList}" var="st">
                        <option value="${st.code}" ${order.status == st.code ? 'selected' : ''}>
                            ${st.name}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-sm font-bold text-gray-700">Payment Status</label>
                <select name="paymentStatus" class="w-full mt-1 p-2 border rounded-lg focus:ring-2 focus:ring-blue-500">
                    <option value="UNPAID" ${order.paymentStatus == 'UNPAID' ? 'selected' : ''}>UNPAID</option>
                    <option value="PAID" ${order.paymentStatus == 'PAID' ? 'selected' : ''}>PAID</option>
                </select>
            </div>
        </div>

        <div class="flex justify-end gap-3 pt-4 border-t border-gray-100">
            <a href="orderStaffServlet?action=all" class="px-4 py-2 text-gray-500 hover:text-gray-700 text-sm font-medium">Cancel</a>
            <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded-lg font-bold hover:bg-blue-700 shadow-md transition">
                Save Changes
            </button>
        </div>
    </form>
</div>