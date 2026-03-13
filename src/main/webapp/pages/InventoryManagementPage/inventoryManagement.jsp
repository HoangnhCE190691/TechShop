<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!-- Toast message -->
<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification"
         class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">

        <c:choose>
            <c:when test="${sessionScope.msgType == 'danger'}">
                <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-red-50 text-red-800 border-red-200">
                    <span class="font-bold uppercase tracking-wider text-sm">
                        ${sessionScope.msg}
                    </span>
                </div>
            </c:when>
            <c:otherwise>
                <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-green-50 text-green-800 border-green-200">
                    <span class="font-bold uppercase tracking-wider text-sm">
                        ${sessionScope.msg}
                    </span>
                </div>
            </c:otherwise>
        </c:choose>

    </div>

    <c:remove var="msg" scope="session"/>
    <c:remove var="msgType" scope="session"/>

    <script>
        setTimeout(function () {
            var toast = document.getElementById("toast-notification");
            if (toast) {
                toast.remove();
            }
        }, 3000);
    </script>
</c:if>

<div class="bg-white rounded-xl shadow-lg p-5">

    <!-- Search -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">

        <form class="w-full md:w-1/2" action="staffservlet" method="GET">
            <input type="hidden" name="action" value="inventoryManagement">

            <div class="relative">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                </span>
                <input type="text"
                       name="keyword"
                       class="w-full pl-10 pr-10 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Search by product name, IMEI, status or ID..."
                       value="${param.keyword}">
                <c:if test="${not empty param.keyword}">
                    <a href="staffservlet?action=inventoryManagement"
                       class="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                    </a>
                </c:if>
            </div>
        </form>

    </div>

    <!-- Table -->
    <div class="overflow-x-auto rounded-lg border border-gray-200">

        <table class="w-full text-sm text-left text-gray-600">

            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-semibold">
                <tr>
                    <th class="px-4 py-3">ID</th>
                    <th class="px-4 py-3">Product Name</th>
                    <th class="px-4 py-3">IMEI</th>
                    <th class="px-4 py-3 text-right">Import Price</th>
                    <th class="px-4 py-3 text-center">Status</th>
                    <th class="px-4 py-3 text-center">Actions</th>
                </tr>
            </thead>

            <tbody class="divide-y divide-gray-200">

                <c:forEach items="${listInventory}" var="it" varStatus="stt">
                    <tr class="hover:bg-gray-50 transition-colors">

                        <td class="px-4 py-3 font-mono text-gray-700">
                            #${stt.count}
                        </td>

                        <td class="px-4 py-3 font-medium text-gray-900">
                            <c:choose>
                                <c:when test="${not empty it.productName}">
                                    ${it.productName}
                                </c:when>
                                <c:otherwise>
                                    —
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class="px-4 py-3 font-mono">
                            ${it.imei}
                        </td>

                        <td class="px-4 py-3 text-right font-semibold">
                            <fmt:formatNumber value="${it.import_price}"
                                              type="number"
                                              groupingUsed="true"
                                              maxFractionDigits="0"/>
                            ₫
                        </td>

                        <td class="px-4 py-3 text-center">

                            <c:choose>
                                <c:when test="${it.status == 'IN_STOCK'}">
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-green-700 bg-green-100">
                                        IN_STOCK
                                    </span>
                                </c:when>

                                <c:when test="${it.status == 'SOLD'}">
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-blue-700 bg-blue-100">
                                        SOLD
                                    </span>
                                </c:when>

                                <c:otherwise>
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-gray-700 bg-gray-100">
                                        ${it.status}
                                    </span>
                                </c:otherwise>
                            </c:choose>

                        </td>

                        <td class="px-4 py-3 text-center space-x-2">
                            <a href="inventory?action=edit&id=${it.inventory_id}"
                               class="text-blue-600 hover:text-blue-800 font-medium hover:underline">
                                Edit
                            </a>

                            <a href="inventory?action=delete&id=${it.inventory_id}"
                               onclick="return confirm('Delete inventory item #${it.inventory_id}?')"
                               class="text-red-600 hover:text-red-800 font-medium hover:underline">
                                Delete
                            </a>

                            <a href="inventory?action=view&id=${it.inventory_id}"
                               class="text-gray-600 hover:text-gray-800 font-medium hover:underline">
                                Details
                            </a>
                        </td>

                    </tr>
                </c:forEach>

                <c:if test="${empty listInventory}">
                    <tr>
                        <td colspan="6" class="px-4 py-12 text-center text-gray-500 italic">
                            <c:choose>
                                <c:when test="${not empty param.keyword}">No results found for "${param.keyword}".</c:when>
                                <c:otherwise>No inventory data.</c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:if>

            </tbody>
        </table>
    </div>
</div>