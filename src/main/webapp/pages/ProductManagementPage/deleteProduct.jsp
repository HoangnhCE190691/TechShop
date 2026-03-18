<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 1. HỆ THỐNG THÔNG BÁO TOAST --%>
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

            <span class="font-bold uppercase tracking-wider text-sm">
                ${sessionScope.msg}
            </span>
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

<%-- 2. LAYOUT XÁC NHẬN XÓA --%>
<div class="max-w-2xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-20">
    
    <%-- ICON CẢNH BÁO --%>
    <div class="flex justify-center mb-6">
        <div class="w-20 h-20 rounded-full flex items-center justify-center animate-pulse
             ${orderCount > 0 ? 'bg-orange-50 text-orange-500' : 'bg-red-50 text-red-500'}">
            <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
            </svg>
        </div>
    </div>

    <%-- NỘI DUNG --%>
    <div class="text-center space-y-4">
        <h2 class="text-2xl font-extrabold text-gray-900 uppercase">Confirm Action</h2>
        <p class="text-gray-600">Are you sure you want to proceed with this product?</p>

        <%-- THÔNG TIN SẢN PHẨM --%>
        <div class="grid grid-cols-12 gap-4 p-5 bg-gray-50 rounded-xl border border-gray-100 text-left">
            <div class="col-span-4">
                <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product ID</p>
                <p class="text-lg font-bold text-blue-600">#${product.productId}</p>
            </div>
            <div class="col-span-8">
                <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product Name</p>
                <p class="text-lg font-bold text-gray-800">${product.name}</p>
            </div>
        </div>

        <%-- THÔNG BÁO LOGIC XÓA --%>
        <div class="mt-6">
            <c:choose>
                <c:when test="${orderCount > 0 || inventoryCount > 0}">
                    <div class="p-4 bg-orange-50 border-l-4 border-orange-500 text-orange-700 text-sm text-left">
                        <p class="font-bold mb-1 text-base">⚠️ System Note:</p>
                        This product has <strong>${orderCount} orders</strong>, <strong>${inventoryCount} items</strong> in the system. 
                        To protect data integrity, it will be <strong>hidden (Set to INACTIVE)</strong> instead of permanent deletion.
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="p-4 bg-red-50 border-l-4 border-red-500 text-red-700 text-sm text-left">
                        <p class="font-bold mb-1 text-base">🗑️ Safe to Delete:</p>
                        This product has no related orders. It will be <strong>permanently removed</strong> from the database.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%-- NÚT BẤM --%>
    <form action="productServlet" method="POST" class="mt-10 flex justify-center gap-4">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="productId" value="${product.productId}">

        <a href="productServlet?action=all" class="px-6 py-2.5 text-gray-500 font-bold hover:bg-gray-100 rounded-lg transition-all border border-gray-200">
            Cancel
        </a>

        <c:choose>
            <c:when test="${orderCount > 0 || inventoryCount > 0}">
                <button type="submit" class="px-10 py-2.5 bg-orange-600 text-white font-bold rounded-lg hover:bg-orange-700 shadow-lg shadow-orange-100 transition-all transform hover:-translate-y-0.5 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Deactivate Product
                </button>
            </c:when>
            <c:otherwise>
                <button type="submit" class="px-10 py-2.5 bg-red-600 text-white font-bold rounded-lg hover:bg-red-700 shadow-lg shadow-red-100 transition-all transform hover:-translate-y-0.5 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Delete Permanently
                </button>
            </c:otherwise>
        </c:choose>
    </form>
</div>