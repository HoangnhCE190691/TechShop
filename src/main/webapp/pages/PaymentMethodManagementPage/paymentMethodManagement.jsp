<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 1. THÔNG BÁO TOAST --%>
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

<div class="bg-white rounded-xl shadow-lg p-5">
    <%-- 2. TIÊU ĐỀ & NÚT THÊM --%>
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">Payment Method Management</h2>
        <a href="paymentMethodServlet?action=add"
           class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 shadow-md transition-all transform hover:-translate-y-0.5">
            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd"/>
            </svg>
            Add New Method
        </a>
    </div>

    <%-- 3. BỘ LỌC --%>
    <div class="flex flex-col md:flex-row gap-3 mb-6 items-center bg-gray-50 p-3 rounded-xl border border-gray-100">
        <div class="relative flex-1 w-full">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
            </span>
            <input type="text" id="searchInput"
                   class="w-full pl-10 pr-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white shadow-sm"
                   placeholder="Search payment method by name...">
        </div>

        <select id="statusFilter" class="w-full md:w-44 px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white cursor-pointer shadow-sm">
            <option value="all">All Status</option>
            <option value="active">Active Only</option>
            <option value="inactive">Inactive Only</option>
        </select>
    </div>

    <%-- 4. BẢNG DỮ LIỆU --%>
    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-bold">
                <tr>
                    <th class="px-4 py-3 w-16 text-center">ID</th>
                    <th class="px-6 py-3">Method Name</th>
                    <th class="px-6 py-3 text-center">Status</th>
                    <th class="px-6 py-3 text-center w-44">Actions</th>
                </tr>
            </thead>
            <tbody id="paymentTableBody" class="divide-y divide-gray-200">
                <c:forEach items="${listdata}" var="pm">
                    <tr class="payment-row hover:bg-gray-50 transition-colors" data-status="${pm.is_active ? 'active' : 'inactive'}">
                        <td class="px-4 py-3 text-center font-medium text-gray-500">#${pm.method_id}</td>
                        <td class="px-6 py-4 font-bold text-gray-900 method-name">${pm.method_name}</td>
                        <td class="px-6 py-4 text-center">
                            <c:choose>
                                <c:when test="${pm.is_active}">
                                    <span class="inline-block px-2.5 py-0.5 text-xs font-bold text-green-700 bg-green-100 rounded-full border border-green-200 uppercase text-center min-w-[80px]">ACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="inline-block px-2.5 py-0.5 text-xs font-bold text-red-700 bg-red-100 rounded-full border border-red-200 uppercase text-center min-w-[80px]">INACTIVE</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-6 py-4 text-center">
                            <div class="flex items-center justify-center gap-4">
                                <%-- Edit --%>
                                <a href="paymentMethodServlet?action=edit&id=${pm.method_id}" class="text-orange-500 hover:text-orange-700 transition-transform hover:scale-110">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                    </svg>
                                </a>
                                <%-- Delete: redirect sang trang confirm, không dùng onclick --%>
                                <a href="paymentMethodServlet?action=delete&id=${pm.method_id}" class="text-red-500 hover:text-red-700 transition-transform hover:scale-110">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                    </svg>
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        <c:if test="${empty listdata}">
            <div id="noDataRow" class="px-4 py-10 text-center text-gray-400 italic bg-gray-50">No payment methods found.</div>
        </c:if>
    </div>

    <%-- 5. PHÂN TRANG --%>
    <div class="flex flex-col md:flex-row justify-between items-center gap-3 mt-5 text-sm text-gray-500">
        <p>Showing <span id="visibleCount" class="font-bold text-gray-900">${listdata.size()}</span> methods</p>
        <nav class="inline-flex rounded-lg shadow-sm border overflow-hidden">
            <button class="px-3 py-2 bg-gray-50 text-gray-400 border-r cursor-not-allowed">Prev</button>
            <button class="px-4 py-2 bg-blue-600 text-white font-bold">1</button>
            <button class="px-3 py-2 bg-gray-50 text-gray-400 border-l cursor-not-allowed">Next</button>
        </nav>
    </div>
</div>

<%-- 6. LIVE FILTER LOGIC --%>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const searchInput = document.getElementById('searchInput');
        const statusFilter = document.getElementById('statusFilter');
        const tableBody = document.getElementById('paymentTableBody');
        const rows = tableBody.getElementsByClassName('payment-row');

        function filterTable() {
            const searchText = searchInput.value.toLowerCase();
            const filterStatus = statusFilter.value;
            let visibleCount = 0;

            for (let i = 0; i < rows.length; i++) {
                const nameText = rows[i].querySelector('.method-name').innerText.toLowerCase();
                const rowStatus = rows[i].getAttribute('data-status');

                const matchesSearch = nameText.includes(searchText);
                const matchesStatus = (filterStatus === 'all' || rowStatus === filterStatus);

                if (matchesSearch && matchesStatus) {
                    rows[i].style.display = "";
                    visibleCount++;
                } else {
                    rows[i].style.display = "none";
                }
            }

            const countDisplay = document.getElementById('visibleCount');
            if (countDisplay) countDisplay.innerText = visibleCount;
        }

        searchInput.addEventListener('keyup', filterTable);
        statusFilter.addEventListener('change', filterTable);
    });
</script>
