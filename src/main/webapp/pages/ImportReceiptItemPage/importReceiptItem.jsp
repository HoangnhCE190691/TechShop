<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="bg-white rounded-xl shadow-lg p-5">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">Import Receipt - Items</h2>
        <p class="text-sm text-gray-500">Danh sách tất cả biến thể (SKU) để chọn tạo phiếu nhập.</p>
    </div>

    <div class="flex flex-col md:flex-row gap-3 mb-6 items-center bg-gray-50 p-3 rounded-xl border border-gray-100">
        <div class="relative flex-1 w-full">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
            </span>
            <input type="text" id="productSearch" 
                   class="w-full pl-10 pr-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white shadow-sm" 
                   placeholder="Tìm theo tên sản phẩm hoặc SKU...">
        </div>
    </div>

    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-bold">
                <tr>
                    <th class="px-4 py-3 w-16 text-center">ID</th>
                    <th class="px-4 py-3">Product Name</th>
                    <th class="px-4 py-3 text-center">Category</th>
                    <th class="px-4 py-3 text-center">Brand</th>
                    <th class="px-4 py-3 text-center">SKU</th>
                    <th class="px-4 py-3 text-right">Selling Price</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200" id="importProductTableBody">
                <c:forEach items="${listdata}" var="v">
                    <tr class="import-product-row hover:bg-gray-50 transition-colors cursor-pointer">
                        <td class="px-4 py-3 text-center font-medium text-gray-500">#${v.variantId}</td>
                        <td class="px-4 py-3 font-bold text-gray-900 import-product-name">${v.productName}</td>
                        <td class="px-4 py-3 text-center">
                            <span class="inline-block px-2 py-1 text-xs font-medium bg-blue-50 text-blue-700 rounded border border-blue-100 uppercase tracking-tighter">
                                ${v.categoryName}
                            </span>
                        </td>
                        <td class="px-4 py-3 text-center">
                            <span class="inline-block px-2 py-1 text-xs font-medium bg-purple-50 text-purple-700 rounded border border-purple-100 uppercase tracking-tighter">
                                ${v.brandName}
                            </span>
                        </td>
                        <td class="px-4 py-3 text-center">
                            <span class="inline-block px-2 py-1 text-xs font-medium bg-red-50 text-red-700 rounded border border-red-150 uppercase tracking-tighter">
                                ${v.sku}
                            </span>
                        </td>
                        <td class="px-4 py-3 text-right font-bold text-blue-600">
                            <fmt:formatNumber value="${v.sellingPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                        </td>
                    </tr>
                </c:forEach>
                <tr id="noImportProductRow" style="display: none;">
                    <td colspan="6" class="px-4 py-10 text-center text-gray-400 italic bg-gray-50">
                        Không có sản phẩm nào phù hợp.
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="flex flex-col md:flex-row justify-between items-center gap-3 mt-5 text-sm text-gray-500">
        <p>Đang hiển thị <span id="importVisibleCount" class="font-bold text-gray-900">
                <c:out value="${listdata != null ? listdata.size() : 0}"/>
            </span> sản phẩm
        </p>
    </div>
</div>

<script>
    function filterImportProducts() {
        const searchVal = document.getElementById('productSearch').value.toLowerCase();
        const rows = document.querySelectorAll('#importProductTableBody .import-product-row');
        const noRow = document.getElementById('noImportProductRow');
        let visibleCount = 0;

        rows.forEach(row => {
            const nameText = row.querySelector('.import-product-name').innerText.toLowerCase();
            const isVisible = nameText.includes(searchVal);
            row.style.display = isVisible ? "" : "none";
            if (isVisible) visibleCount++;
        });

        noRow.style.display = (visibleCount === 0) ? "" : "none";
        const c = document.getElementById('importVisibleCount');
        if (c) c.innerText = visibleCount;
    }

    document.getElementById('productSearch').addEventListener('input', filterImportProducts);
</script>

