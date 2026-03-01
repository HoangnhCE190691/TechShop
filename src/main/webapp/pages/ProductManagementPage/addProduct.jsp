<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
            <h2 class="text-3xl font-extrabold text-gray-900 uppercase tracking-tight">Add New Product</h2>
            <p class="text-gray-500 mt-1">Fill in the information below to create a new product</p>
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
        <input type="hidden" name="action" value="add">

        <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
            <%-- THÔNG TIN CƠ BẢN --%>
            <div class="space-y-6">
                <h3 class="text-lg font-bold text-gray-800 border-l-4 border-blue-600 pl-3">Basic
                    Information</h3>

                <div class="space-y-4">
                    <%-- Product Name --%>
                    <div>
                        <label
                            class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product
                            Name</label>
                        <input type="text" name="name" required
                               class="w-full mt-1 p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                               placeholder="Enter product name...">
                    </div>

                    <%-- Category & Brand --%>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label
                                class="text-xs font-bold text-gray-400 uppercase tracking-widest">Category</label>
                            <select name="categoryId" required
                                    class="w-full mt-1 p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer">
                                <%-- Thêm dòng Select mặc định --%>
                                <option value="" disabled selected>Select Category</option>
                                <c:forEach items="${categories}" var="cat">
                                    <option value="${cat.categoryId}">${cat.categoryName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label
                                class="text-xs font-bold text-gray-400 uppercase tracking-widest">Brand</label>
                            <select name="brandId" required
                                    class="w-full mt-1 p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 outline-none cursor-pointer">
                                <option value="" disabled selected>Select Brand</option>
                                <c:forEach items="${brands}" var="brand">
                                    <option value="${brand.brandId}">${brand.brandName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <%-- Status --%>
                    <div>
                        <label
                            class="text-xs font-bold text-gray-400 uppercase tracking-widest">Initial
                            Status</label>
                        <div class="mt-2 flex gap-4">
                            <label class="flex items-center gap-2 cursor-pointer group">
                                <input type="radio" name="status" value="Active" checked
                                       class="w-4 h-4 text-blue-600 focus:ring-blue-500">
                                <span
                                    class="text-sm font-bold text-green-600 bg-green-50 px-3 py-0.5 rounded-full border border-green-100">ACTIVE</span>
                            </label>
                            <label class="flex items-center gap-2 cursor-pointer group">
                                <input type="radio" name="status" value="Inactive"
                                       class="w-4 h-4 text-red-600 focus:ring-red-500">
                                <span
                                    class="text-sm font-bold text-red-600 bg-red-50 px-3 py-0.5 rounded-full border border-red-100">INACTIVE</span>
                            </label>
                        </div>
                    </div>

                    <%-- Product Images --%>
                    <div>
                        <label
                            class="text-xs font-bold text-gray-400 uppercase tracking-widest">Product
                            Images</label>
                        <input type="file" name="productImage" accept="image/*" multiple
                               required
                               class="w-full mt-1 p-2 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition-all">
                        <p class="text-[10px] text-gray-400 mt-1 italic">* You can
                            select multiple images. The first image will be set as
                            thumbnail.</p>
                    </div>
                </div>
            </div>

            <%-- MÔ TẢ --%>
            <div class="space-y-6">
                <h3 class="text-lg font-bold text-gray-800 border-l-4 border-orange-500 pl-3">
                    Additional Details</h3>
                <div>
                    <label
                        class="text-xs font-bold text-gray-400 uppercase tracking-widest">Description</label>
                    <textarea name="description" rows="6"
                              class="w-full mt-1 p-4 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-500 outline-none transition-all resize-none"
                              placeholder="Describe the product features..."></textarea>
                </div>
            </div>
        </div>

        <%-- BUTTONS --%>
        <div class="pt-8 border-t flex justify-end gap-4">
            <button type="reset"
                    class="px-6 py-2.5 text-gray-500 font-bold hover:bg-gray-100 rounded-lg transition-all">
                Reset
            </button>
            <button type="submit"
                    class="px-8 py-2.5 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 shadow-lg shadow-blue-100 transition-all flex items-center gap-2 transform hover:-translate-y-0.5">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Create Product
            </button>
        </div>
    </form>
</div>