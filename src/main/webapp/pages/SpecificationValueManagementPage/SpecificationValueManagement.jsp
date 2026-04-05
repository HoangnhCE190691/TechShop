<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 1. THÔNG BÁO TOAST --%>
<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">
        <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 animate-bounce
             ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-green-50 text-green-800 border-green-200'}">
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
    <div class="flex justify-between items-center mb-6">
        <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">Product Specification Values</h2>
        <a href="specificationValueServlet?action=add" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-all flex items-center gap-2 shadow-md">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/></svg>
            Assign New Value
        </a>
    </div>

    <%-- 2. LAYOUT BỘ LỌC ĐA NĂNG --%>
    <div class="flex flex-col md:flex-row gap-3 mb-6 items-center bg-gray-50 p-3 rounded-xl border border-gray-100">
        <%-- Tìm kiếm sản phẩm --%>
        <div class="relative flex-1 w-full">
            <input type="text" id="prodSearch" oninput="filterValues()" placeholder="Search product name..." 
                   class="w-full pl-4 pr-4 py-2 text-sm border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 bg-white shadow-sm">
        </div>
        <%-- Lọc theo loại thông số (Dropdown) --%>
        <select id="specFilter" onchange="filterValues()" class="w-full md:w-64 px-3 py-2 text-sm border border-gray-300 rounded-lg outline-none bg-white cursor-pointer shadow-sm">
            <option value="">All Specifications</option>
            <c:forEach items="${specs}" var="s">
                <option value="${s.specName}">${s.specName}</option>
            </c:forEach>
        </select>
    </div>
    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-bold">
                <tr>
                    <th class="px-4 py-3 w-20 text-center">ID</th>
                    <th class="px-4 py-3 w-1/4">Product Name</th>
                    <th class="px-4 py-3 w-1/4">Specification</th>
                    <th class="px-4 py-3 w-1/4">Value</th>
                    <th class="px-4 py-3 text-center w-40">Actions</th>
                </tr>
            </thead>
            <tbody id="valueTableBody" class="divide-y divide-gray-200">
                <c:forEach items="${listdata}" var="v">
                    <tr class="value-row hover:bg-gray-50 transition-colors">
                        <td class="px-4 py-3 text-center font-medium text-gray-500">#${v.specId}</td>
                        <td class="px-4 py-3 font-bold text-gray-900 prod-name-cell">${v.productName}</td>
                        <td class="px-4 py-3 spec-name-cell">${v.specName}</td>
                        <td class="px-4 py-3">
                            <span class="px-2.5 py-1 bg-blue-50 text-blue-700 rounded border border-blue-100 font-medium">${v.specValue}</span>
                        </td>
                        <td class="px-4 py-3 text-center">
                            <div class="flex justify-center gap-4">
                                <a href="specificationValueServlet?action=detail&pid=${v.productId}&sid=${v.specId}" class="text-blue-500 hover:scale-110 transition-transform" title="View Detail">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                                </a>
                                <a href="specificationValueServlet?action=edit&pid=${v.productId}&sid=${v.specId}" class="text-orange-500 hover:scale-110 transition-transform" title="Edit">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                                </a>
                                <a href="specificationValueServlet?action=delete&pid=${v.productId}&sid=${v.specId}" class="text-red-500 hover:scale-110 transition-transform" title="Delete">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <tr id="noResults" style="display: none;">
                    <td colspan="5" class="py-12 text-center text-gray-400 italic bg-gray-50 rounded-b-lg">
                        <div class="flex flex-col items-center">
                            <svg class="w-12 h-12 mb-2 opacity-20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 9.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                            <span>No specification values match your search or filter.</span>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>


<script>
    function filterValues() {
        const prodVal = document.getElementById('prodSearch').value.toLowerCase();
        const specVal = document.getElementById('specFilter').value.toLowerCase();
        const rows = document.querySelectorAll('.value-row');
        let count = 0;

        rows.forEach(row => {
            const pName = row.querySelector('.prod-name-cell').innerText.toLowerCase();
            const sName = row.querySelector('.spec-name-cell').innerText.toLowerCase();

            const isVisible = pName.includes(prodVal) && (specVal === "" || sName === specVal);

            row.style.display = isVisible ? "" : "none";
            if (isVisible)
                count++;
        });

        document.getElementById('noResults').style.display = (count === 0 && rows.length > 0) ? "" : "none";
        document.getElementById('visibleCount').innerText = count;
    }
</script>