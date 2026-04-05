<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="max-w-4xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-10">
    <%-- HEADER --%>
    <div class="flex justify-between items-start border-b pb-6 mb-8">
        <div>
            <h2 class="text-3xl font-extrabold text-gray-900 uppercase tracking-tight">Product Detail</h2>
            <p class="text-gray-500 mt-1">ID: <span
                    class="font-mono font-bold text-blue-600">#${product.productId}</span></p>
        </div>
        <a href="productServlet?action=all"
           class="text-gray-500 hover:text-gray-700 flex items-center gap-2 text-sm font-medium transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back to List
        </a>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
        <%-- THÔNG TIN CƠ BẢN --%>
        <div class="space-y-6">
            <h3 class="text-lg font-bold text-gray-800 border-l-4 border-blue-600 pl-3">Basic
                Information</h3>

            <div class="space-y-4">
                <div>
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product
                        Name</label>
                    <p class="text-lg font-semibold text-gray-900">${product.name}</p>
                </div>

                <div class="flex gap-10">
                    <div>
                        <label
                            class="text-xs font-bold text-gray-400 uppercase tracking-widest">Category</label>
                        <p class="mt-1">
                            <span
                                class="px-3 py-1 bg-blue-50 text-blue-700 rounded-lg font-bold text-sm border border-blue-100">
                                ${not empty product.categoryName ? product.categoryName :
                                  'Uncategorized'}
                            </span>
                        </p>
                    </div>
                    <div>
                        <label
                            class="text-xs font-bold text-gray-400 uppercase tracking-widest">Brand</label>
                        <p class="mt-1">
                            <span
                                class="px-3 py-1 bg-purple-50 text-purple-700 rounded-lg font-bold text-sm border border-purple-100">
                                ${not empty product.brandName ? product.brandName : 'No Brand'}
                            </span>
                        </p>
                    </div>
                </div>

                <div>
                    <label
                        class="text-xs font-bold text-gray-400 uppercase tracking-widest">Status</label>
                    <p class="mt-1">
                        <c:choose>
                            <c:when test="${product.status == 'Active'}">
                                <span
                                    class="px-3 py-1 bg-green-100 text-green-700 rounded-full font-bold text-xs uppercase">ACTIVE</span>
                            </c:when>
                            <c:otherwise>
                                <span
                                    class="px-3 py-1 bg-red-100 text-red-700 rounded-full font-bold text-xs uppercase">INACTIVE</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <%-- Product Images --%>
                <div class="pt-4 border-t border-gray-100">
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product
                        Images</label>
                        <c:choose>
                            <c:when test="${not empty images}">
                            <div class="mt-3">
                                <p class="text-xs font-bold text-gray-500 mb-2">Current Images:</p>
                                <div class="flex flex-wrap gap-4">
                                    <c:forEach var="img" items="${images}">
                                        <div class="relative group">
                                            <div
                                                class="h-24 w-24 bg-white border ${img.is_thumbnail == 1 ? 'border-blue-500 ring-2 ring-blue-100' : 'border-gray-200'} rounded-xl overflow-hidden p-2 shadow-sm flex-shrink-0">
                                                <img src="${pageContext.request.contextPath}/${img.imageUrl}"
                                                     alt="Product Image"
                                                     class="h-full w-full object-contain">
                                                <c:if test="${img.is_thumbnail == 1}">
                                                    <div
                                                        class="absolute -top-2 -right-2 bg-blue-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full shadow-md">
                                                        THUMBNAIL
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="mt-2 text-sm text-gray-500 italic">No images available for
                                this product.
                            </p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- THÔNG TIN HỆ THỐNG --%>
        <div class="bg-gray-50 p-6 rounded-xl space-y-6 border border-gray-100 shadow-inner">
            <h3 class="text-lg font-bold text-gray-800">System Information</h3>

            <div class="space-y-4">
                <div class="flex items-center gap-4">
                    <div
                        class="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-sm text-blue-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor"
                             viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                        </svg>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-gray-400 uppercase">Created At</p>
                        <p class="text-sm font-bold text-gray-700">
                            ${product.createdAt}
                            <span class="text-gray-400 font-normal ml-1">
                                by User #${not empty product.createdBy ? product.createdBy :
                                           'Admin'}
                            </span>
                        </p>
                    </div>
                </div>

                <div class="flex items-center gap-4 pt-4 border-t border-gray-200">
                    <div
                        class="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-sm text-orange-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor"
                             viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              stroke-width="2"
                              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                        </svg>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-gray-400 uppercase">Last Updated
                        </p>
                        <p class="text-sm font-bold text-gray-700">
                            <c:choose>
                                <c:when test="${not empty product.updatedAt}">
                                    ${product.updatedAt}
                                    <span class="text-gray-400 font-normal ml-1">
                                        by User #${not empty product.updatedBy ?
                                                   product.updatedBy :
                                                   'None'}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-gray-400 italic font-normal">None
                                        (Never
                                        updated)</span>
                                    </c:otherwise>
                                </c:choose>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- 2. MÔ TẢ SẢN PHẨM --%>         
    <div class="mt-10 pt-8 border-t">
        <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Description</label>
        <div class="mt-4 p-4 bg-gray-50 rounded-lg text-gray-600 leading-relaxed italic border-l-4 border-gray-200">
            ${not empty product.description ? product.description : 'No description provided.'}
        </div>
    </div>

    <%-- 3. ACTION BUTTONS --%>
    <div class="mt-10 flex justify-end">
        <a href="productServlet?action=edit&id=${product.productId}"
           class="w-fit inline-flex items-center gap-2 px-10 py-3 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 shadow-lg shadow-blue-200 transition-all transform hover:-translate-y-0.5 text-sm">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
            Edit Product
        </a>
    </div>
</div>