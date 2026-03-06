<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="bg-white rounded-xl shadow-lg p-5">

    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">
        <!-- Search -->
        <form action="customerservlet" method="get" class="w-full md:w-1/2">
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

        <!-- Add button -->
        <a href="customerservlet?action=add"
           class="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-300">
            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd"
                  d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
                  clip-rule="evenodd"/>
            </svg>
            New Customer
        </a>
    </div>
    <!-- Table -->
    <div class="overflow-x-auto">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-100 text-gray-700">
                <tr>
                    <th class="px-4 py-3">Name</th>
                    <th class="px-4 py-3">Email</th>
                    <th class="px-4 py-3">Phone</th>
                    <th class="px-4 py-3">Created At</th>
                    <th class="px-4 py-3">Status</th>
                    <th class="px-4 py-3 text-center">Action</th>
                </tr>
            </thead>
            <tbody class="divide-y">
                <%-- 'listdata' được gửi từ Servlet thông qua request.setAttribute --%>
                <c:forEach items="${listdata}" var="cus">
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 font-medium text-gray-900">
                            ${cus.fullname} <br/>
                            <span class="text-xs text-gray-400">@${cus.userName}</span>
                        </td>
                        <td class="px-4 py-3">${cus.email}</td>
                        <td class="px-4 py-3">${cus.phoneNumber}</td>
                        <td class="px-4 py-3 text-xs">${cus.createdAt}</td>
                        <td class="px-4 py-3">

                            <c:choose>
                                <c:when test="${cus.status eq 'Active' || cus.status eq 'Hoạt động' || cus.status eq 'ACTIVE'}">
                                    <span class="px-2 py-1 text-xs font-semibold text-green-700 bg-green-100 rounded-full">
                                        Active
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-xs font-semibold text-red-700 bg-red-100 rounded-full">
                                        Locked
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-4 py-3">
                            <div class="flex items-center justify-center space-x-3">
                                <a href="customerservlet?action=detail&id=${cus.customerID}" 
                                   class="inline-flex items-center p-1.5 text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-600 hover:text-white transition-all duration-200" 
                                   title="View Details">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span class="ml-1 text-xs font-bold uppercase hidden md:inline">Detail</span>
                                </a>

                                <a href="customerservlet?action=edit&id=${cus.customerID}" 
                                   class="inline-flex items-center p-1.5 text-amber-600 bg-amber-50 rounded-lg hover:bg-amber-500 hover:text-white transition-all duration-200" 
                                   title="Update Customer">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                    </svg>
                                    <span class="ml-1 text-xs font-bold uppercase hidden md:inline">Edit</span>
                                </a>

                                <a href="customerservlet?action=delete&id=${cus.customerID}" 
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

                <%-- Hiển thị thông báo nếu danh sách trống --%>
                <c:if test="${empty listdata}">
                    <tr>
                        <td colspan="6" class="px-4 py-10 text-center text-gray-500">
                            Không tìm thấy dữ liệu khách hàng nào.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="flex flex-col md:flex-row justify-between items-center gap-3 mt-5">
        <p class="text-sm text-gray-500">
            Hiển thị <span class="font-semibold text-gray-900">1–10</span> / 
            <span class="font-semibold text-gray-900">100</span> kết quả
        </p>

        <div class="inline-flex rounded-lg shadow-sm">
            <a href="#" class="px-3 py-2 text-sm border rounded-l-lg hover:bg-gray-100">Trước</a>
            <a href="#" class="px-3 py-2 text-sm border bg-blue-50 text-blue-600 font-semibold">1</a>
            <a href="#" class="px-3 py-2 text-sm border hover:bg-gray-100">2</a>
            <a href="#" class="px-3 py-2 text-sm border rounded-r-lg hover:bg-gray-100">Sau</a>
        </div>
    </div>
</div>

<c:if test="${not empty errorMessage}">
    <script>
        // Đợi 100ms để trình duyệt vẽ xong giao diện rồi mới hiện alert
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