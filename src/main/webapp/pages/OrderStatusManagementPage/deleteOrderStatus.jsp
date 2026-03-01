<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 1. TOAST NOTIFICATION --%>
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

<%-- 2. CONFIRM DELETE LAYOUT --%>
<div class="max-w-2xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-20">

    <%-- WARNING / BLOCKED ICON --%>
    <div class="flex justify-center mb-6">
        <div class="w-20 h-20 rounded-full flex items-center justify-center animate-pulse
             ${orderCount > 0 ? 'bg-red-50 text-red-500' : 'bg-red-50 text-red-500'}">
            <c:choose>
                <c:when test="${orderCount > 0}">
                    <%-- Icon khóa: bị chặn --%>
                    <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/>
                    </svg>
                </c:when>
                <c:otherwise>
                    <%-- Icon cảnh báo: cho phép xóa --%>
                    <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    </svg>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="text-center space-y-4">
        <h2 class="text-2xl font-extrabold text-gray-900 uppercase tracking-tight">
            <c:choose>
                <c:when test="${orderCount > 0}">Delete Blocked</c:when>
                <c:otherwise>Confirm Delete</c:otherwise>
            </c:choose>
        </h2>
        <p class="text-gray-500">Please review the order status information before proceeding.</p>

        <%-- BANNER --%>
        <div class="mt-6">
            <c:choose>
                <c:when test="${orderCount > 0}">
                    <%-- CHẶN: hiển thị lý do, không cho xóa --%>
                    <div class="p-4 bg-red-50 border-l-4 border-red-500 text-red-700 text-left text-sm">
                        <p class="font-bold text-base mb-1">🚫 Cannot Delete</p>
                        This order status is currently linked to <strong>${orderCount} order(s)</strong>.
                        Deleting it would break existing order records. Please reassign or remove all linked orders before deleting this status.
                    </div>
                </c:when>
                <c:otherwise>
                    <%-- CHO PHÉP: không có order liên kết --%>
                    <div class="p-4 bg-red-50 border-l-4 border-red-500 text-red-700 text-left text-sm">
                        <p class="font-bold text-base mb-1">🗑️ Permanent Delete</p>
                        This order status has no linked orders. Confirming this will <strong>permanently remove</strong> it from the database.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- INFO GRID --%>
        <div class="grid grid-cols-12 gap-4 p-5 bg-gray-50 rounded-xl border border-gray-100 text-left">
            <div class="col-span-2">
                <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">ID</p>
                <p class="text-lg font-bold text-blue-600">#${status.statusId}</p>
            </div>
            <div class="col-span-3">
                <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Code</p>
                <p class="text-lg font-bold text-gray-700 font-mono">${status.statusCode}</p>
            </div>
            <div class="col-span-4">
                <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Name</p>
                <p class="text-lg font-bold text-gray-800">${status.statusName}</p>
            </div>
            <div class="col-span-3 border-l border-gray-200 pl-4">
                <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Linked Orders</p>
                <p class="text-lg font-extrabold ${orderCount > 0 ? 'text-red-600' : 'text-green-600'}">${orderCount} Orders</p>
            </div>
        </div>
    </div>

    <%-- ACTION BUTTONS --%>
    <div class="mt-10 flex justify-end gap-4">
        <a href="orderStatusServlet?action=all"
           class="px-6 py-2.5 text-gray-500 font-bold hover:bg-gray-100 rounded-lg transition-all border border-gray-200 flex items-center gap-2">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
            </svg>
            Cancel
        </a>

        <c:choose>
            <c:when test="${orderCount > 0}">
                <%-- Nút bị disable, không submit được --%>
                <button type="button" disabled
                        class="px-8 py-2.5 text-white font-bold rounded-lg bg-gray-400 cursor-not-allowed flex items-center gap-2 opacity-60">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/>
                    </svg>
                    Delete Blocked
                </button>
            </c:when>
            <c:otherwise>
                <%-- Cho phép xóa --%>
                <form action="orderStatusServlet" method="POST">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="status_id" value="${status.statusId}">
                    <button type="submit"
                            class="px-8 py-2.5 text-white font-bold rounded-lg shadow-lg bg-red-600 hover:bg-red-700 shadow-red-100 transition-all transform hover:-translate-y-0.5 flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                        </svg>
                        Delete Permanently
                    </button>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</div>
