<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- TOAST NOTIFICATION --%>
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

<div class="p-6 bg-white rounded-xl shadow-sm">
    <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-gray-800">Order Status Categories</h2>
        <a href="orderStatusServlet?action=add" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition">
            + Add New Status
        </a>
    </div>

    <table class="w-full text-left border-collapse">
        <thead>
            <tr class="bg-gray-50 border-b">
                <th class="p-4 font-semibold text-gray-600">Step</th>
                <th class="p-4 font-semibold text-gray-600">Code</th>
                <th class="p-4 font-semibold text-gray-600">Name</th>
                <th class="p-4 font-semibold text-gray-600">Type</th>
                <th class="p-4 font-semibold text-gray-600">Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${listdata}" var="s">
                <tr class="border-b hover:bg-gray-50 transition">
                    <td class="p-4 font-bold text-blue-600">#${s.stepOrder}</td>
                    <td class="p-4 font-mono text-sm">${s.statusCode}</td>
                    <td class="p-4">${s.statusName}</td>
                    <td class="p-4">
                        <c:choose>
                            <c:when test="${s.isFinal}">
                                <span class="bg-green-100 text-green-700 px-2 py-1 rounded text-xs font-bold">FINAL STAGE</span>
                            </c:when>
                            <c:otherwise>
                                <span class="bg-gray-100 text-gray-600 px-2 py-1 rounded text-xs">Processing</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="p-4 text-blue-600 font-medium">
                        <a href="orderStatusServlet?action=edit&id=${s.statusId}" class="hover:underline">Edit</a>
                        <a href="orderStatusServlet?action=delete&id=${s.statusId}"
                           class="text-red-600 hover:text-red-800 font-medium">
                            Delete
                        </a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
