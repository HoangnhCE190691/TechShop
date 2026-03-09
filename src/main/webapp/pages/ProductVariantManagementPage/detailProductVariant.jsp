<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <div class="max-w-4xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-10">
                <div class="flex justify-between items-start border-b-2 border-gray-50 pb-6 mb-8">
                    <div>
                        <h2 class="text-3xl font-black text-gray-900 uppercase tracking-tighter">Variant Details</h2>
                        <p class="text-gray-500 mt-1">ID: <span
                                class="font-mono font-bold text-blue-600">#${variant.variantId}</span></p>
                    </div>
                    <a href="variantServlet?action=all"
                        class="text-gray-500 hover:text-gray-700 flex items-center gap-2 text-sm font-bold transition-colors">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                        </svg>
                        Back to List
                    </a>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
                    <div class="space-y-8">
                        <h3 class="text-lg font-black text-gray-800 border-l-4 border-blue-600 pl-3 uppercase">General
                            Info</h3>
                        <div class="space-y-6">
                            <div>
                                <label class="text-xs font-black text-gray-400 uppercase tracking-widest">Parent
                                    Product</label>
                                <p class="text-xl font-black text-gray-900 uppercase mt-1">${variant.productName}</p>
                            </div>
                            <div>
                                <label class="text-xs font-black text-gray-400 uppercase tracking-widest">SKU
                                    Identifier</label>
                                <p class="text-lg font-bold text-blue-600 font-mono mt-1">${variant.sku}</p>
                            </div>
                        </div>
                    </div>

                    <div class="bg-gray-50 p-8 rounded-2xl space-y-8 border-2 border-gray-100 shadow-inner">
                        <h3 class="text-lg font-black text-gray-800 uppercase">Market Value & Status</h3>
                        <div class="space-y-6">
                            <div>
                                <label class="text-xs font-black text-gray-400 uppercase tracking-widest">Selling
                                    Price</label>
                                <p class="text-3xl font-black text-green-600 mt-1">
                                    <fmt:formatNumber value="${variant.sellingPrice}" type="currency" currencySymbol="₫"
                                        maxFractionDigits="0" />
                                </p>
                            </div>
                            <div>
                                <label class="text-xs font-black text-gray-400 uppercase tracking-widest">Status</label>
                                <p class="mt-2">
                                    <c:choose>
                                        <c:when test="${variant.isActive}">
                                            <span
                                                class="px-4 py-1.5 bg-green-100 text-green-700 rounded-full font-black text-xs uppercase border-2 border-green-200">ACTIVE</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span
                                                class="px-4 py-1.5 bg-red-100 text-red-700 rounded-full font-black text-xs uppercase border-2 border-red-200">INACTIVE</span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <%--=====VARIANT SPECIFICATIONS=====--%>
                    <c:if test="${not empty detailVariantSpecs}">
                        <div class="mt-8 border-t-2 border-gray-100 pt-8">
                            <h3
                                class="text-lg font-black text-gray-800 border-l-4 border-purple-500 pl-3 uppercase mb-6">
                                Variant Specifications</h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <c:forEach items="${detailVariantSpecs}" var="vs">
                                    <div
                                        class="flex items-center gap-3 bg-purple-50 border-2 border-purple-100 rounded-xl px-5 py-4">
                                        <div class="flex-shrink-0">
                                            <span
                                                class="inline-flex items-center justify-center w-10 h-10 bg-purple-200 text-purple-700 rounded-lg font-black text-sm">
                                                <c:choose>
                                                    <c:when
                                                        test="${vs.specName.toLowerCase().contains('màu') || vs.specName.toLowerCase().contains('color')}">
                                                        🎨</c:when>
                                                    <c:when
                                                        test="${vs.specName.toLowerCase().contains('dung') || vs.specName.toLowerCase().contains('storage') || vs.specName.toLowerCase().contains('ram')}">
                                                        💾</c:when>
                                                    <c:otherwise>📋</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div>
                                            <p class="text-xs font-black text-purple-400 uppercase tracking-widest">
                                                ${vs.specName}</p>
                                            <p class="text-lg font-black text-purple-800 mt-0.5">${vs.specValue}</p>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <div class="mt-10 pt-8 border-t-2 border-gray-50 flex justify-end">
                        <a href="variantServlet?action=edit&id=${variant.variantId}"
                            class="px-8 py-3 bg-blue-600 text-white font-black rounded-xl hover:bg-blue-700 shadow-lg shadow-blue-200 transition-all uppercase text-sm">
                            Edit Variant
                        </a>
                    </div>
            </div>