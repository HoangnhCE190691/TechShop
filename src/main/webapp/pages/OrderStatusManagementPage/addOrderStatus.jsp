<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- THÔNG BÁO TOAST --%>
<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">
        <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 animate-bounce
             ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-green-50 text-green-800 border-green-200'}">

            <div class="flex-shrink-0 mr-3">
                <c:choose>
                    <c:when test="${sessionScope.msgType == 'danger'}">
                        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                        </svg>
                    </c:when>
                    <c:otherwise>
                        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                        </svg>
                    </c:otherwise>
                </c:choose>
            </div>
            <span class="font-bold uppercase tracking-wider text-sm">${sessionScope.msg}</span>
        </div>
    </div>
    <c:remove var="msg" scope="session" />
    <c:remove var="msgType" scope="session" />
    <script>
        setTimeout(() => {
            const toast = document.getElementById('toast-notification');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translate(-50%, -20px)';
                setTimeout(() => toast.remove(), 500);
            }
        }, 3000);
    </script>
</c:if>
<div class="max-w-2xl mx-auto bg-white p-8 rounded-xl shadow-md">
    <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-gray-800">Add New Order Status</h2>
        <a href="adminservlet?action=orderStatusManagement" class="text-blue-600 hover:underline text-sm">← Back to list</a>
    </div>
    <div class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg text-sm text-blue-700">
        <p class="font-bold mb-1">💡 Suggested flow:</p>
        <p>(1) PENDING → (2) APPROVED → (3) SHIPPING → (4) SHIPPED <span class="text-green-600 font-semibold">[Final]</span> → (5) CANCELLED <span class="text-red-600 font-semibold">[Final]</span></p>
        <p class="mt-1 text-xs text-blue-500">Final stage statuses cannot be changed further. CANCELLED must use exactly the status code <span class="font-mono font-bold">CANCELLED</span>.</p>
    </div>

    <form action="orderStatusServlet" method="POST" class="space-y-5">
        <input type="hidden" name="action" value="add">

        <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1">Status Code</label>
            <input type="text" name="status_code" placeholder="e.g., PENDING, SHIPPING, SHIPPED, CANCELLED" 
                   required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
            <p class="text-xs text-gray-500 mt-1">Unique identifier for logic processing (uppercase recommended).</p>
        </div>

        <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1">Display Name</label>
            <input type="text" name="status_name" placeholder="e.g., PENDING, SHIPPING, SHIPPED, CANCELLED" 
                   required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
        </div>

        <div class="grid grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Step Order</label>
                <input type="number" name="step_order" value="1" min="1"
                       required class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
            </div>
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Status Type</label>
                <div class="mt-2">
                    <label class="inline-flex items-center cursor-pointer">
                        <input type="checkbox" name="is_final" value="1" class="sr-only peer">
                        <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        <span class="ml-3 text-sm font-medium text-gray-700">Is Final Stage?</span>
                    </label>
                </div>
            </div>
        </div>

        <div class="pt-4 border-t">
            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition duration-200 shadow-lg">
                Save Status Category
            </button>
        </div>
    </form>
</div>