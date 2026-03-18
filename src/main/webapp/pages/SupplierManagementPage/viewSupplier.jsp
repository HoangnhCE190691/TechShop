<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${empty supplier}">
    <div class="p-4 bg-white rounded border">
        <div class="text-red-700 font-medium mb-2">Supplier not found.</div>
        <a class="text-blue-600 hover:underline" href="staffservlet?action=supplierManagement">Back to list</a>
    </div>
</c:if>

<c:if test="${not empty supplier}">
    <div class="bg-white rounded-xl shadow-lg p-6 max-w-2xl">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-6">
            <div>
                <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">
                    Supplier Details
                </h2>
                <p class="text-sm text-gray-500 mt-1">
                    Supplier ID: <span class="font-mono font-semibold text-gray-700">#${supplier.supplier_id}</span>
                </p>
            </div>

            <c:choose>
                <c:when test="${supplier.is_active}">
                    <span class="inline-flex items-center px-3 py-1 text-xs font-semibold rounded-full text-green-700 bg-green-100">
                        Active
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="inline-flex items-center px-3 py-1 text-xs font-semibold rounded-full text-red-700 bg-red-100">
                        Inactive
                    </span>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="bg-gray-50 border border-gray-200 rounded-xl p-4">
                <p class="text-xs uppercase text-gray-500 font-semibold">Name</p>
                <p class="mt-1 font-medium text-gray-900 break-words">${supplier.supplier_name}</p>
            </div>

            <div class="bg-gray-50 border border-gray-200 rounded-xl p-4">
                <p class="text-xs uppercase text-gray-500 font-semibold">Phone</p>
                <p class="mt-1 font-mono font-semibold text-gray-900">${supplier.phone}</p>
            </div>
        </div>

        <hr class="my-6 border-gray-100">

        <div class="flex justify-end gap-3">
            <a href="staffservlet?action=supplierManagement"
               class="px-4 py-2 rounded-lg border bg-gray-50 hover:bg-gray-100 font-medium">
               Back to list
            </a>
            <a href="supplier?action=edit&id=${supplier.supplier_id}"
               class="px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700 shadow-sm font-medium">
                Edit
            </a>
        </div>
    </div>

</c:if>