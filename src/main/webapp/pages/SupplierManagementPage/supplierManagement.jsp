<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty sessionScope.msg}">
    <div id="supplier-toast"
         class="fixed top-6 left-1/2 -translate-x-1/2 z-[9999] w-[420px] max-w-[calc(100vw-2rem)] rounded-2xl border shadow-lg
         ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-gray-50 text-gray-800 border-emerald-200'}">
        <div class="px-5 py-4 pr-12 relative">
            <button type="button"
                    onclick="document.getElementById('supplier-toast').remove()"
                    class="absolute top-3 right-3 text-gray-400 hover:text-gray-600 text-lg leading-none">&times;</button>

            <div class="flex items-start gap-3">
                <span class="mt-0.5 inline-flex items-center justify-center w-7 h-7 rounded-full
                      ${sessionScope.msgType == 'danger' ? 'bg-red-100 text-red-600 border border-red-200' : 'bg-emerald-100 text-emerald-600 border border-emerald-300'}">
                    <c:choose>
                        <c:when test="${sessionScope.msgType == 'danger'}">!</c:when>
                        <c:otherwise>&#10003;</c:otherwise>
                    </c:choose>
                </span>
                <div>
                    <p class="font-semibold ${sessionScope.msgType == 'danger' ? 'text-red-800' : 'text-gray-800'}">
                        ${sessionScope.msgType == 'danger' ? 'Action failed' : 'Action completed'}
                    </p>
                    <p class="text-sm ${sessionScope.msgType == 'danger' ? 'text-red-700' : 'text-gray-500'}">
                        ${sessionScope.msg}
                    </p>
                </div>
            </div>
        </div>
    </div>
    <c:remove var="msg" scope="session" />
    <c:remove var="msgType" scope="session" />

    <script>
        setTimeout(function () {
            var toast = document.getElementById('supplier-toast');
            if (toast) {
                toast.remove();
            }
        }, 3500);
    </script>
</c:if>

<div class="bg-white rounded-xl shadow-lg p-5">

    <!-- Search + Add (giống Inventory) -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">
        <form class="w-full md:w-1/3 md:max-w-[520px]" action="staffservlet" method="GET">
            <input type="hidden" name="action" value="supplierManagement">

            <div class="relative">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                </span>
                <input type="text"
                       name="keyword"
                       class="w-full pl-10 pr-10 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Search suppliers by name or phone..."
                       value="${param.keyword}">
                <c:if test="${not empty param.keyword}">
                    <a href="staffservlet?action=supplierManagement"
                       class="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                  d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                    </a>
                </c:if>
            </div>
        </form>

        <a href="supplier?action=add"
           class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors shadow-sm whitespace-nowrap text-center">
            + Add supplier
        </a>
    </div>

    <!-- Table (giống Inventory) -->
    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-semibold">
                <tr>
                    <th class="px-4 py-3 w-[90px]">ID</th>
                    <th class="px-4 py-3">Supplier name</th>
                    <th class="px-4 py-3 w-[170px]">Phone</th>
                    <th class="px-4 py-3 text-center w-[140px]">Status</th>
                    <th class="px-4 py-3 text-center w-[260px]">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                <c:forEach items="${listSuppliers != null ? listSuppliers : []}" var="s">
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-4 py-3 font-mono text-gray-700">#${s.supplier_id}</td>
                        <td class="px-4 py-3 font-medium text-gray-900">${s.supplier_name}</td>
                        <td class="px-4 py-3 whitespace-nowrap">${s.phone}</td>
                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${s.is_active}">
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-green-700 bg-green-100">
                                        Active
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-red-700 bg-red-100">
                                        Inactive
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-4 py-3 text-center whitespace-nowrap">
                            <a href="supplier?action=view&id=${s.supplier_id}"
                               class="text-gray-600 hover:text-gray-800 font-medium hover:underline">View</a>
                            <span class="text-gray-300 mx-1">|</span>
                            <a href="supplier?action=edit&id=${s.supplier_id}"
                               class="text-blue-600 hover:text-blue-800 font-medium hover:underline">Edit</a>
                            <span class="text-gray-300 mx-1">|</span>
                            <c:choose>
                                <c:when test="${s.is_active}">
                                    <a href="supplier?action=deactivate&id=${s.supplier_id}"
                                       class="text-amber-600 hover:text-amber-800 font-medium hover:underline">Deactivate</a>
                                </c:when>
                                <c:otherwise>
                                    <a href="supplier?action=restore&id=${s.supplier_id}"
                                       class="text-emerald-600 hover:text-emerald-800 font-medium hover:underline">Restore</a>
                                </c:otherwise>
                            </c:choose>
                            <span class="text-gray-300 mx-1">|</span>
                            <a href="supplier?action=delete&id=${s.supplier_id}"
                               onclick="return confirm('Are you sure you want to delete supplier #${s.supplier_id}? If this supplier is used in any import receipt, deletion will fail.');"
                               class="text-red-600 hover:text-red-800 font-medium hover:underline">Delete</a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty listSuppliers}">
                    <tr>
                        <td colspan="5" class="px-4 py-12 text-center text-gray-500 italic">
                            No supplier data.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>
