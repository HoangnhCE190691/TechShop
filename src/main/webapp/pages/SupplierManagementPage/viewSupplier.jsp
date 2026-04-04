<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- Chi tiết NCC: supplier?action=view&id=...; CSS .supplier-view-addr cho địa chỉ xuống dòng đẹp --%>
<style>
    .supplier-view-addr {
        height: auto !important;
        min-height: 0 !important;
        max-height: none !important;
    }
    .supplier-view-addr p {
        display: block !important;
        margin-bottom: 0 !important;
    }
</style>
<div class="w-full flex flex-col items-center px-2 sm:px-4">
    <c:if test="${empty supplier}">
        <div class="w-full max-w-2xl rounded-xl bg-white p-6 shadow-lg ring-1 ring-gray-100">
            <div class="text-red-700 font-medium mb-2">Supplier not found.</div>
            <a class="text-blue-600 hover:underline" href="staffservlet?action=supplierManagement">Back to list</a>
        </div>
    </c:if>

    <c:if test="${not empty supplier}">
        <div class="w-full max-w-2xl rounded-xl bg-white p-6 sm:p-8 shadow-lg ring-1 ring-gray-100">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-6">
                <div>
                    <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">
                        Supplier details
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

            <div class="space-y-3">
                <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 sm:gap-3">
                    <div class="min-w-0 rounded-lg border border-gray-200 bg-gray-50 px-3 py-2.5 text-left shadow-sm">
                        <p class="text-xs font-semibold uppercase tracking-wide text-gray-500">Name</p>
                        <p class="mt-1.5 text-sm font-medium leading-snug text-gray-900 break-words">${supplier.supplier_name}</p>
                    </div>
                    <div class="min-w-0 rounded-lg border border-gray-200 bg-gray-50 px-3 py-2.5 text-left shadow-sm">
                        <p class="text-xs font-semibold uppercase tracking-wide text-gray-500">Phone</p>
                        <p class="mt-1.5 text-sm font-mono font-semibold leading-snug text-gray-900">${supplier.phone}</p>
                    </div>
                </div>

                <div class="rounded-lg border border-gray-200 bg-gray-50 px-3 py-2.5 text-left shadow-sm">
                    <p class="text-xs font-semibold uppercase tracking-wide text-gray-500">Date added</p>
                    <p class="mt-1.5 text-sm font-medium leading-snug text-gray-900">
                        <c:choose>
                            <c:when test="${not empty supplier.createdAt}">
                                <fmt:formatDate value="${supplier.createdAt}" pattern="dd/MM/yyyy" type="date" timeZone="Asia/Ho_Chi_Minh"/>
                            </c:when>
                            <c:otherwise><span class="text-gray-400">—</span></c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <div class="rounded-lg border border-gray-200 bg-gray-50 px-3 py-2.5 text-left shadow-sm">
                    <p class="text-xs font-semibold uppercase tracking-wide text-gray-500">Email</p>
                    <p class="mt-1.5 text-sm leading-snug break-all text-gray-900">
                        <c:choose>
                            <c:when test="${not empty supplier.email}">${supplier.email}</c:when>
                            <c:otherwise><span class="text-gray-400">—</span></c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <div class="supplier-view-addr min-w-0 rounded-lg border border-gray-200 bg-gray-50 px-3 py-2.5 text-left shadow-sm">
                    <p class="text-xs font-semibold uppercase tracking-wide text-gray-500">Address</p>
                    <p class="mt-1.5 text-sm leading-snug text-gray-900 break-words whitespace-normal text-left">
                        <c:choose>
                            <c:when test="${not empty supplier.addressDisplaySingleLine}"><c:out value="${supplier.addressDisplaySingleLine}"/></c:when>
                            <c:otherwise><span class="text-gray-400">—</span></c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>

            <hr class="my-6 border-gray-100">

            <div class="flex flex-wrap justify-end gap-3">
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
</div>
