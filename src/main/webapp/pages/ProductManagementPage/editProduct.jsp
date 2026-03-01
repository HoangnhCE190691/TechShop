<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 1. THÔNG BÁO TOAST --%>
<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification"
         class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">
        <div
            class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 animate-bounce
            ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-green-50 text-green-800 border-green-200'}">

            <div class="flex-shrink-0 mr-3">
                <c:choose>
                    <c:when test="${sessionScope.msgType == 'danger'}">
                        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd"
                              d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                              clip-rule="evenodd"></path>
                        </svg>
                    </c:when>
                    <c:otherwise>
                        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd"
                              d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                              clip-rule="evenodd"></path>
                        </svg>
                    </c:otherwise>
                </c:choose>
            </div>

            <span class="font-bold uppercase tracking-wider text-sm">
                ${sessionScope.msg}
            </span>
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

<div class="max-w-4xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-10">
    <%-- HEADER --%>
    <div class="flex justify-between items-start border-b pb-6 mb-8">
        <div>
            <h2 class="text-3xl font-extrabold text-gray-900 uppercase tracking-tight">Edit Product</h2>
            <p class="text-gray-500 mt-1">Editing ID: <span
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

    <form action="productServlet" method="POST" enctype="multipart/form-data" class="space-y-8">
        <%-- Hidden fields để gửi dữ liệu về Servlet --%>
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="productId" value="${product.productId}">

        <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
            <%-- THÔNG TIN CƠ BẢN --%>
            <div class="space-y-6">
                <h3 class="text-lg font-bold text-gray-800 border-l-4 border-blue-600 pl-3">
                    Basic Information</h3>

                <div class="space-y-4">
                    <%-- Product Name --%>
                    <div>
                        <label
                            class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product
                            Name</label>
                        <input type="text" name="name" value="${product.name}" required
                               class="w-full mt-1 p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition-all font-semibold">
                    </div>

                    <%-- Category & Brand --%>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label
                                class="text-xs font-bold text-gray-400 uppercase tracking-widest">Category</label>
                            <select name="categoryId" required
                                    class="w-full mt-1 p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer">
                                <c:forEach items="${categories}" var="cat">
                                    <option value="${cat.categoryId}"
                                            ${cat.categoryId==product.categoryId
                                              ? 'selected' : '' }>
                                                ${cat.categoryName}
                                            </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label
                                    class="text-xs font-bold text-gray-400 uppercase tracking-widest">Brand</label>
                                <select name="brandId" required
                                        class="w-full mt-1 p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 outline-none cursor-pointer">
                                    <c:forEach items="${brands}" var="brand">
                                        <option value="${brand.brandId}"
                                                ${brand.brandId==product.brandId ? 'selected'
                                                  : '' }>
                                                    ${brand.brandName}
                                                </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <%-- Status --%>
                            <div>
                                <label
                                    class="text-xs font-bold text-gray-400 uppercase tracking-widest">Status</label>
                                <div class="mt-2 flex gap-4">
                                    <%-- Lựa chọn Active --%>
                                    <label
                                        class="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="status" value="Active"
                                               ${product.status=='Active' ? 'checked' : ''
                                               } class="w-4 h-4 text-blue-600">
                                        <span
                                            class="text-sm font-bold text-green-600 bg-green-50 px-3 py-0.5 rounded-full border border-green-100 uppercase">ACTIVE</span>
                                    </label>

                                    <%-- Lựa chọn Inactive --%>
                                    <label
                                        class="flex items-center gap-2 cursor-pointer">
                                        <input type="radio" name="status"
                                               value="Inactive"
                                               ${product.status=='Inactive' ? 'checked'
                                                 : '' } class="w-4 h-4 text-red-600">
                                        <span
                                            class="text-sm font-bold text-red-600 bg-red-50 px-3 py-0.5 rounded-full border border-red-100 uppercase">INACTIVE</span>
                                    </label>
                                </div>
                            </div>

                            <%-- Product Images --%>
                            <div class="pt-4 border-t border-gray-100">
                                <label
                                    class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product
                                    Images</label>

                                <%-- Show current images if any --%>
                                <c:if test="${not empty images}">
                                    <div class="mt-3 mb-4">
                                        <p
                                            class="text-xs font-bold text-gray-500 mb-2">
                                            Current Images:</p>
                                        <div class="flex flex-wrap gap-4">
                                            <c:forEach var="img" items="${images}">
                                                <div class="relative group">
                                                    <div
                                                        class="h-24 w-24 bg-white border ${img.is_thumbnail == 1 ? 'border-blue-500 ring-2 ring-blue-100' : 'border-gray-200'} rounded-xl overflow-hidden p-2 shadow-sm flex-shrink-0">
                                                        <img src="${pageContext.request.contextPath}/${img.imageUrl}"
                                                             alt="Product Image"
                                                             class="h-full w-full object-contain">
                                                        <c:if
                                                            test="${img.is_thumbnail == 1}">
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
                                </c:if>

                                <div class="mt-2">
                                    <input type="file" name="productImage"
                                           accept="image/*" multiple
                                           class="w-full p-2 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition-all text-sm text-gray-600 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 cursor-pointer">
                                    <p
                                        class="text-[10px] text-gray-400 mt-1 italic">
                                        * You can select multiple images to
                                        OVERWRITE current images. The first image
                                        will be set as thumbnail.</p>
                                    <p
                                        class="text-xs text-orange-500 mt-2 font-medium italic">
                                        * Leave this empty if you want to keep the
                                        current images.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- THÔNG TIN HỆ THỐNG (READ-ONLY) --%>
                    <div
                        class="bg-gray-50 p-6 rounded-xl space-y-6 border border-gray-100 shadow-inner">
                        <h3 class="text-lg font-bold text-gray-800">History Log</h3>

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
                                    <p class="text-xs font-bold text-gray-400 uppercase">Originally
                                        Created</p>
                                    <p class="text-sm font-bold text-gray-700">
                                        ${product.createdAt}
                                        <span class="text-gray-400 font-normal">by User #${not empty
                                                                                           product.createdBy ? product.createdBy : 'Admin'}</span>
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
                                    <p class="text-xs font-bold text-gray-400 uppercase">Last
                                        Updated</p>
                                    <p class="text-sm font-bold text-gray-700">
                                        <c:choose>
                                            <c:when test="${not empty product.updatedAt}">
                                                ${product.updatedAt} <span
                                                    class="text-gray-400 font-normal ml-1">by User
                                                    #${not empty product.updatedBy ?
                                                       product.updatedBy : 'None'}</span>
                                                </c:when>
                                                <c:otherwise><span
                                                    class="text-gray-400 italic font-normal">None</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- MÔ TẢ --%>
                <div class="mt-10 pt-8 border-t">
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product
                        Description</label>
                    <textarea name="description" rows="5"
                              class="w-full mt-2 p-4 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-500 outline-none transition-all resize-none font-medium italic text-gray-600">${product.description}</textarea>
                </div>

                <%-- BUTTONS --%>
                <div class="mt-10 flex justify-end gap-4">
                    <button type="button" onclick="window.history.back()"
                            class="px-6 py-2.5 text-gray-500 font-bold hover:bg-gray-100 rounded-lg transition-all">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-10 py-2.5 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 shadow-lg shadow-blue-200 transition-all flex items-center gap-2 transform hover:-translate-y-0.5">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
                        </svg>
                        Save Changes
                    </button>
                </div>
            </form>
        </div>