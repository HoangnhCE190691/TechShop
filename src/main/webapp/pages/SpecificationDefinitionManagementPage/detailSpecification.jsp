<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="max-w-4xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-10">
    <%-- HEADER --%>
    <div class="flex justify-between items-start border-b pb-6 mb-8">
        <div>
            <h2 class="text-3xl font-extrabold text-gray-900 uppercase tracking-tight">Specification Detail</h2>
            <p class="text-gray-500 mt-1">ID: <span class="font-mono font-bold text-blue-600">#${spec.specId}</span></p>
        </div>
        <a href="specificationServlet?action=all" class="text-gray-500 hover:text-gray-700 flex items-center gap-2 text-sm font-medium transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            Back to List
        </a>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
        <%-- CỘT 1: THÔNG TIN CƠ BẢN --%>
        <div class="space-y-6">
            <h3 class="text-lg font-bold text-gray-800 border-l-4 border-blue-500 pl-3 uppercase tracking-wide">General Information</h3>

            <div class="bg-gray-50 p-6 rounded-xl space-y-4">
                <div>
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Specification Name</label>
                    <p class="text-xl font-bold text-gray-900 mt-1">${spec.specName}</p>
                </div>

                <div>
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Category</label>
                    <p class="text-lg font-medium text-gray-700 mt-1">${spec.categoryName}</p>
                </div>

                <div>
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Measurement Unit</label>
                    <p class="text-lg text-gray-600 mt-1">
                        <c:choose>
                            <c:when test="${not empty spec.unit and spec.unit != '-'}">
                                ${spec.unit}
                            </c:when>
                            <c:otherwise>
                                <span class="italic text-gray-400 font-normal">No unit (e.g. Color, Type)</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>
        </div>

        <%-- CỘT 2: TRẠNG THÁI & PHÂN LOẠI --%>
        <div class="space-y-6">
            <h3 class="text-lg font-bold text-gray-800 border-l-4 border-orange-500 pl-3 uppercase tracking-wide">Status & Classification</h3>

            <div class="bg-gray-50 p-6 rounded-xl space-y-6">
                <%-- SYSTEM STATUS --%>
                <div>
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest block mb-2">System Status</label>
                    <c:choose>
                        <c:when test="${spec.isActive}">
                            <span class="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-bold bg-green-100 text-green-700 border border-green-200">
                                <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                                ACTIVE
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-bold bg-red-100 text-red-700 border border-red-200">
                                <span class="w-2 h-2 bg-red-500 rounded-full mr-2"></span>
                                INACTIVE
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- SPEC TYPE (Added to match Edit screen) --%>
                <div>
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest block mb-2">Spec Type</label>
                    <c:choose>
                        <c:when test="${spec.isVariant}">
                            <div class="inline-flex items-center gap-2 p-2 px-3 bg-purple-50 border border-purple-100 rounded-lg">
                                <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>
                                <div>
                                    <p class="text-sm font-bold text-purple-700 leading-none">Variant Specification</p>
                                    <p class="text-[10px] text-purple-400 italic">Dùng để tạo biến thể sản phẩm</p>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="inline-flex items-center gap-2 p-2 px-3 bg-orange-50 border border-orange-100 rounded-lg">
                                <svg class="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                                <div>
                                    <p class="text-sm font-bold text-orange-700 leading-none">General Specification</p>
                                    <p class="text-[10px] text-orange-400 italic">Thông số kỹ thuật chung</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- PRODUCT IMPACT --%>
                <div>
                    <label class="text-xs font-bold text-gray-400 uppercase tracking-widest block mb-2">Product Impact</label>
                    <div class="flex items-baseline gap-2">
                        <span class="text-3xl font-black text-blue-600">${usageCount}</span>
                        <span class="text-sm font-medium text-gray-500 uppercase">Product items use this spec</span>
                    </div>
                    <p class="text-[10px] text-gray-400 mt-2 leading-tight">
                        * If usage count is greater than 0, this specification is protected to maintain data integrity.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <%-- ACTION BUTTONS --%>
    <div class="mt-12 pt-8 border-t flex justify-end gap-4">
        <c:if test="${usageCount == 0}">
            <a href="specificationServlet?action=delete&id=${spec.specId}" 
               onclick="return confirm('Are you sure you want to delete this specification?')"
               class="px-6 py-2.5 text-red-600 font-bold hover:bg-red-50 rounded-lg transition-all">
                Delete Spec
            </a>
        </c:if>
        <a href="specificationServlet?action=edit&id=${spec.specId}" class="px-8 py-2.5 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 shadow-lg flex items-center gap-2 transform hover:-translate-y-0.5 transition-all">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
            Edit Specification
        </a>
    </div>
</div>