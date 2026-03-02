<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="bg-white rounded-xl shadow-lg p-5">

    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">
        <form action="voucherservlet" method="get" class="w-full md:w-1/2">
            <div class="relative">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd"
                          d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                          clip-rule="evenodd"/>
                    </svg>
                </span>
                <input name="action" value="search" hidden>
                <input type="text" name="name" 
                       class="w-full pl-10 pr-4 py-2 text-sm border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Tìm kiếm theo tên">
            </div>
            <button type="submit" class="hidden"></button>
        </form>

        <a href="voucherservlet?action=add" class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors shadow-sm">
            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd"/></svg>
            Create New Voucher
        </a>
    </div>

    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-semibold">
                <tr>
                    <th class="px-4 py-3">Code</th>
                    <th class="px-4 py-3">Discount</th>
                    <th class="px-4 py-3 text-center">Usage</th>
                    <th class="px-4 py-3">Validity Period</th>
                    <th class="px-4 py-3 text-center">Status</th>
                    <th class="px-4 py-3 text-center">Actions</th>
                </tr>
            </thead>

            <tbody class="divide-y divide-gray-200">
                <c:forEach items="${listdata}" var="v">
                    <tr class="hover:bg-gray-50 transition-colors group">

                        <td class="px-4 py-3 font-medium text-gray-900">
                            <span class="font-mono text-blue-600 bg-blue-50 px-2 py-0.5 rounded border border-blue-100">${v.code}</span>
                            <div class="text-xs text-gray-500 mt-1">
                                Min order: <span class="font-semibold"><fmt:formatNumber value="${v.minOrderValue}" type="currency" currencySymbol="₫"/></span>
                            </div>
                        </td>

                        <td class="px-4 py-3">
                            <div class="flex items-center">
                                <span class="text-green-600 font-bold text-lg mr-1">${v.discountPercent}%</span>
                                <span class="text-xs text-gray-400 font-normal">OFF</span>
                            </div>
                            <c:if test="${v.maxDiscountAmount > 0}">
                                <div class="text-xs text-gray-500">
                                    Max: <fmt:formatNumber value="${v.maxDiscountAmount}" type="number"/>đ
                                </div>
                            </c:if>
                        </td>

                        <td class="px-4 py-3 text-center align-middle" style="min-width: 120px;">
                            <div class="flex justify-between text-xs mb-1">
                                <span class="font-semibold text-gray-700">${v.usedQuantity}</span>
                                <span class="text-gray-400">/ ${v.totalQuantity}</span>
                            </div>
                            <c:set var="percent" value="${(v.totalQuantity > 0) ? (v.usedQuantity * 100 / v.totalQuantity) : 0}" />
                            <div class="w-full bg-gray-200 rounded-full h-1.5">
                                <div class="h-1.5 rounded-full ${percent >= 100 ? 'bg-red-500' : (percent >= 80 ? 'bg-yellow-400' : 'bg-blue-600')}" 
                                     style="width: ${percent}%"></div>
                            </div>
                        </td>

                        <td class="px-4 py-3 text-xs">
                            <div class="flex flex-col space-y-1">
                                <span class="text-gray-500">
                                    From: <span class="text-gray-900 font-medium">
                                        ${v.validFrom.dayOfMonth}/${v.validFrom.monthValue}/${v.validFrom.year} 
                                        ${v.validFrom.hour}:${v.validFrom.minute}
                                    </span>
                                </span>
                                <span class="text-gray-500">
                                    To: <span class="text-gray-900 font-medium">
                                        ${v.validTo.dayOfMonth}/${v.validTo.monthValue}/${v.validTo.year} 
                                        ${v.validTo.hour}:${v.validTo.minute}
                                    </span>
                                </span>
                            </div>
                        </td>

                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${v.status == 'LOCKED'}">
                                    <span class="px-2.5 py-1 text-xs font-semibold text-red-700 bg-red-100 rounded-full border border-red-200">
                                        Locked
                                    </span>
                                </c:when>
                                <c:when test="${v.status == 'EXPIRED'}">
                                    <span class="px-2.5 py-1 text-xs font-semibold text-gray-700 bg-gray-200 rounded-full border border-gray-300">
                                        Expired
                                    </span>
                                </c:when>
                                <c:when test="${v.usedQuantity >= v.totalQuantity}">
                                    <span class="px-2.5 py-1 text-xs font-semibold text-yellow-700 bg-yellow-100 rounded-full border border-yellow-200">
                                        Sold Out
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2.5 py-1 text-xs font-semibold text-green-700 bg-green-100 rounded-full border border-green-200">
                                        Active
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>


                        <td class="px-4 py-3">
                            <div class="flex items-center justify-center space-x-3">
                                <a href="voucherservlet?action=detail&id=${v.voucherId}" 
                                   class="inline-flex items-center p-1.5 text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-600 hover:text-white transition-all duration-200" 
                                   title="View Details">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span class="ml-1 text-xs font-bold uppercase hidden md:inline">Detail</span>
                                </a>

                                <a href="voucherservlet?action=edit&id=${v.voucherId}" 
                                   class="inline-flex items-center p-1.5 text-amber-600 bg-amber-50 rounded-lg hover:bg-amber-500 hover:text-white transition-all duration-200" 
                                   title="Update Customer">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                    </svg>
                                    <span class="ml-1 text-xs font-bold uppercase hidden md:inline">Edit</span>
                                </a>

                                <a href="voucherservlet?action=delete&id=${v.voucherId}" 
                                   onclick="return confirm('Are you sure you want to delete this customer?')"
                                   class="inline-flex items-center p-1.5 text-red-600 bg-red-50 rounded-lg hover:bg-red-600 hover:text-white transition-all duration-200" 
                                   title="Delete Customer">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                    </svg>
                                    <span class="ml-1 text-xs font-bold uppercase hidden md:inline">Delete</span>
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty listdata}">
                    <tr>
                        <td colspan="6" class="px-4 py-12 text-center">
                            <div class="flex flex-col items-center justify-center">
                                <svg class="w-12 h-12 text-gray-300 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                                <span class="text-gray-500 font-medium">No vouchers found.</span>
                                <a href="voucher?action=add" class="mt-2 text-blue-600 hover:underline text-sm">Create a new voucher now</a>
                            </div>
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>
<div class="flex flex-col md:flex-row justify-between items-center gap-3 mt-5">
    <p class="text-sm text-gray-500">
        voucher
    </p>

    <nav class="inline-flex rounded-lg shadow-sm isolate">
        <a href="#" class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-l-lg hover:bg-gray-50">Trước</a>
        <a href="#" class="px-3 py-2 text-sm font-medium text-blue-600 bg-blue-50 border border-gray-300">1</a>
        <a href="#" class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-r-lg hover:bg-gray-50">Sau</a>
    </nav>
</div>
</div>


<c:if test="${not empty errorMessage}">
    <script>
        setTimeout(function () {
            alert("${errorMessage}");
        }, 100);
    </script>
</c:if>

<c:if test="${not empty successMessage}">
    <script>
        setTimeout(function () {
            alert("${successMessage}");
        }, 100);
    </script>
</c:if>

<script>


    function confirmDelete(id) {
        if (confirm("Are you sure you want to delete Voucher ID #" + id + "?\nThis action cannot be undone.")) {
            window.location.href = "voucher?action=delete&id=" + id;
        }
    }
</script>