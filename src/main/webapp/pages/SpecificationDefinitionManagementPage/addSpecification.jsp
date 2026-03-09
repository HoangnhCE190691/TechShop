<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="max-w-3xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-10">
    <div class="flex justify-between items-center border-b pb-6 mb-8">
        <h2 class="text-2xl font-bold text-gray-900 uppercase">Add New Specification</h2>
        <a href="specificationServlet?action=all" class="text-gray-500 hover:text-gray-700 flex items-center gap-2 text-sm">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            Back
        </a>
    </div>

    <form action="specificationServlet" method="POST" class="space-y-6">
        <input type="hidden" name="action" value="add">
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <%-- Tên thông số --%>
            <div class="space-y-2">
                <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Spec Name</label>
                <input type="text" name="specName" required placeholder="e.g. RAM, Screen Size"
                       class="w-full p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
            </div>

            <%-- Đơn vị đo --%>
            <div class="space-y-2">
                <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Unit (Optional)</label>
                <input type="text" name="unit" placeholder="e.g. GB, inch, Hz"
                       class="w-full p-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
            </div>

            <%-- Chọn danh mục --%>
            <div class="space-y-2">
                <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Apply to Category</label>
                <select name="categoryId" required class="w-full p-3 bg-gray-50 border border-gray-200 rounded-lg outline-none cursor-pointer">
                    <option value="">-- Select Category --</option>
                    <c:forEach items="${categories}" var="cat">
                        <option value="${cat.categoryId}">${cat.categoryName}</option>
                    </c:forEach>
                </select>
            </div>

            <%-- Loại thông số: General hay Variant --%>
            <div class="space-y-2">
                <label class="text-xs font-bold text-gray-400 uppercase tracking-widest">Spec Type</label>
                <div class="flex gap-6 mt-2">
                    <label class="flex items-center gap-2 cursor-pointer group">
                        <input type="radio" name="isVariant" value="0" checked class="w-5 h-5 text-blue-600 focus:ring-blue-400">
                        <div class="flex flex-col">
                            <span class="text-sm font-bold text-gray-700 group-hover:text-blue-600 transition-colors">General Spec</span>
                            <span class="text-[10px] text-gray-400 font-medium italic">Thông số kỹ thuật chung</span>
                        </div>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer group border-l pl-6 border-gray-100">
                        <input type="radio" name="isVariant" value="1" class="w-5 h-5 text-purple-600 focus:ring-purple-400">
                        <div class="flex flex-col">
                            <span class="text-sm font-bold text-gray-700 group-hover:text-purple-600 transition-colors">Variant Spec</span>
                            <span class="text-[10px] text-gray-400 font-medium italic">Dùng để tạo biến thể</span>
                        </div>
                    </label>
                </div>
            </div>
        </div>

        <div class="pt-8 border-t flex justify-end gap-4">
            <button type="reset" class="px-6 py-2.5 text-gray-500 font-bold hover:bg-gray-100 rounded-lg">Reset</button>
            <button type="submit" class="px-10 py-2.5 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 shadow-lg transform hover:-translate-y-0.5 transition-all">
                Save Specification
            </button>
        </div>
    </form>
</div>