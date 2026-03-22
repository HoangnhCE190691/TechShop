<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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

<div class="max-w-4xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-10">
    <%-- HEADER --%>
    <div class="flex justify-between items-start border-b-2 border-gray-100 pb-6 mb-8">
        <div>
            <h2 class="text-3xl font-black text-gray-900 uppercase tracking-tighter">Edit Variant
            </h2>
            <p class="text-gray-500 mt-1 font-medium">Updating ID: <span
                    class="font-mono font-bold text-blue-600">#${variant.variantId}</span></p>
        </div>
        <a href="variantServlet?action=all"
           class="text-gray-500 hover:text-blue-600 flex items-center gap-2 text-sm font-bold transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back to List
        </a>
    </div>

    <form action="variantServlet" method="POST" class="space-y-8">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="variantId" value="${variant.variantId}">

        <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
            <div class="space-y-6">
                <h3
                    class="text-lg font-black text-gray-800 border-l-4 border-blue-600 pl-3 uppercase">
                    Identification</h3>
                <div class="space-y-5">
                    <div>
                        <label
                            class="text-xs font-black text-gray-400 uppercase tracking-widest">Product
                            Parent</label>
                        <select name="productId" required
                                class="w-full mt-2 p-3 bg-gray-50 border-2 border-gray-200 rounded-xl font-bold">
                            <c:forEach items="${products}" var="p">
                                <option value="${p.productId}" ${p.productId==variant.productId
                                                 ? 'selected' : '' }>
                                            ${p.name}
                                        </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label
                                class="text-xs font-black text-gray-400 uppercase tracking-widest">SKU
                                Code</label>
                            <input type="text" name="sku" value="${variant.sku}" required
                                   class="w-full mt-2 p-3 bg-gray-50 border-2 border-gray-200 rounded-xl font-black text-gray-900 uppercase">
                        </div>
                    </div>
                </div>

                <div class="space-y-6">
                    <h3
                        class="text-lg font-black text-gray-800 border-l-4 border-green-500 pl-3 uppercase">
                        Pricing & Status</h3>
                    <div class="space-y-5">
                        <div>
                            <label
                                class="text-xs font-black text-gray-400 uppercase tracking-widest">Selling
                                Price (₫)</label>
                            <input type="number" name="sellingPrice" value="${variant.sellingPrice}"
                                   required
                                   class="w-full mt-2 p-3 bg-gray-50 border-2 border-gray-200 rounded-xl font-black text-blue-700 text-xl">
                        </div>
                        <div>
                            <label
                                class="text-xs font-black text-gray-400 uppercase tracking-widest">Status</label>
                            <div class="mt-3 flex gap-6">
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="radio" name="isActive" value="1" ${variant.isActive
                                                                                    ? 'checked' : '' } class="w-5 h-5 text-blue-600">
                                    <span
                                        class="text-sm font-black text-green-700 bg-green-50 px-4 py-1 rounded-full border-2 border-green-100 uppercase">ACTIVE</span>
                                </label>
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="radio" name="isActive" value="0" ${!variant.isActive
                                                                                    ? 'checked' : '' } class="w-5 h-5 text-red-600">
                                    <span
                                        class="text-sm font-black text-red-700 bg-red-50 px-4 py-1 rounded-full border-2 border-red-100 uppercase">INACTIVE</span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%--=====VARIANT SPECIFICATIONS (Dung lượng, Màu sắc)=====--%>
            <c:if test="${not empty variantSpecDefs}">
                <div class="border-t-2 border-gray-100 pt-8">
                    <h3
                        class="text-lg font-black text-gray-800 border-l-4 border-purple-500 pl-3 uppercase mb-6">
                        Variant Specifications</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <c:forEach items="${variantSpecDefs}" var="specDef">
                            <div>
                                <label
                                    class="text-xs font-black text-gray-400 uppercase tracking-widest">${specDef.specName}</label>
                                <%-- Tìm giá trị hiện tại --%>
                                <c:set var="currentVal" value="" />
                                <c:forEach items="${currentVariantSpecs}" var="cvs">
                                    <c:if test="${cvs.specId == specDef.specId}">
                                        <c:set var="currentVal" value="${cvs.specValue}" />
                                    </c:if>
                                </c:forEach>
                                <input type="text" name="specValue_${specDef.specId}"
                                       value="${currentVal}"
                                       placeholder="Nhập ${specDef.specName}..."
                                       class="w-full mt-2 p-3 bg-purple-50 border-2 border-purple-200 rounded-xl font-bold text-purple-800 placeholder-purple-300 focus:border-purple-500 focus:ring-2 focus:ring-purple-100 transition-all">
                            </div>
                        </c:forEach>
                    </div>
                    <p class="text-xs text-gray-400 mt-3 italic">
                        💡  Enter parameter values ​​for this variant (e.g., Capacity = "256GB", Color = "Black")
                    </p>
                </div>
            </c:if>

            <c:if test="${empty variantSpecDefs}">
                <div class="border-t-2 border-gray-100 pt-6">
                    <p class="text-sm text-gray-400 italic text-center py-4 bg-gray-50 rounded-xl">
                        ⚠ ️No spec definitions variant found for this product category..
                    </p>
                </div>
            </c:if>

            <div class="pt-8 border-t-2 border-gray-50 flex justify-end gap-4">
                <button type="button" onclick="window.history.back()"
                        class="px-8 py-3 text-gray-500 font-black hover:bg-gray-100 rounded-xl uppercase text-sm">Cancel</button>
                <button type="submit"
                        class="px-10 py-3 bg-blue-600 text-white font-black rounded-xl hover:bg-blue-700 shadow-xl shadow-blue-200 transition-all uppercase text-sm">Save
                    Changes</button>
            </div>
        </form>
    </div>