<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:if test="${not empty sessionScope.msg}">
    <div id="inventory-toast"
         class="fixed top-6 left-1/2 -translate-x-1/2 z-[9999] w-[420px] max-w-[calc(100vw-2rem)] rounded-2xl border shadow-lg
         ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-gray-50 text-gray-800 border-emerald-200'}">
        <div class="px-5 py-4 pr-12 relative">
            <button type="button"
                    onclick="document.getElementById('inventory-toast').remove()"
                    class="absolute top-3 right-3 text-gray-400 hover:text-gray-600 text-lg leading-none">&times;</button>

            <div class="flex items-start gap-3">
                <span class="mt-0.5 inline-flex items-center justify-center w-7 h-7 rounded-full
                      ${sessionScope.msgType == 'danger' ? 'bg-red-100 text-red-600 border border-red-200' : 'bg-emerald-100 text-emerald-600 border border-emerald-300'}">
                    <c:choose>
                        <c:when test="${sessionScope.msgType == 'danger'}">!</c:when>
                        <c:otherwise>&#10003;</c:otherwise>
                    </c:choose>
                </span>
                <div>
                    <p class="font-semibold ${sessionScope.msgType == 'danger' ? 'text-red-800' : 'text-gray-800'}">
                        ${sessionScope.msgType == 'danger' ? 'Action failed' : 'Action completed'}
                    </p>
                    <p class="text-sm ${sessionScope.msgType == 'danger' ? 'text-red-700' : 'text-gray-500'}">
                        ${sessionScope.msg}
                    </p>
                </div>
            </div>
        </div>
    </div>
    <c:remove var="msg" scope="session"/>
    <c:remove var="msgType" scope="session"/>

    <script>
        setTimeout(function () {
            var toast = document.getElementById('inventory-toast');
            if (toast) {
                toast.remove();
            }
        }, 3500);
    </script>
</c:if>

<div class="bg-white rounded-xl shadow-lg p-5">

    <!-- Search -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">

        <div class="w-full flex flex-col md:flex-row md:items-center gap-3">
            <form class="w-full md:w-1/3 md:max-w-[520px]" action="staffservlet" method="GET">
                <input type="hidden" name="action" value="inventoryManagement">

                <div class="relative">
                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                    </span>
                    <input type="text"
                           name="keyword"
                           class="w-full pl-10 pr-10 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                          placeholder="Search by product name..."
                           value="${param.keyword}">
                    <c:if test="${not empty param.keyword}">
                        <a href="staffservlet?action=inventoryManagement"
                           class="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                        </a>
                    </c:if>
                </div>
            </form>

            <button type="button"
                    id="btn-back-to-summary"
                    class="inline-flex items-center justify-center px-4 py-2 text-xs font-semibold rounded-lg border border-gray-300 bg-white text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-300 focus:ring-offset-1 transition-colors md:ml-auto hidden">
                ← Back to summary
            </button>
        </div>

    </div>

    <!-- Totals -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-5">
            <!-- Imported -->
            <div class="bg-gray-50 border border-gray-200 rounded-xl px-4 py-3">
                <p class="text-xs uppercase text-gray-500 font-semibold">Imported</p>
                <p class="mt-1 text-xl font-bold text-gray-900">
                    ${totalImported != null ? totalImported : 0}
                </p>
            </div>
            <!-- Sold -->
            <div class="bg-blue-50 border border-blue-200 rounded-xl px-4 py-3">
                <p class="text-xs uppercase text-blue-700 font-semibold">Sold</p>
                <p class="mt-1 text-xl font-bold text-blue-700">
                    ${totalSold != null ? totalSold : 0}
                </p>
            </div>
            <!-- Reserved -->
            <div class="bg-orange-50 border border-orange-200 rounded-xl px-4 py-3">
                <p class="text-xs uppercase text-orange-700 font-semibold">Reserved</p>
                <p class="mt-1 text-xl font-bold text-orange-700">
                    ${totalReversed != null ? totalReversed : 0}
                </p>
            </div>
            <!-- In stock -->
            <div class="bg-green-50 border border-green-200 rounded-xl px-4 py-3">
                <p class="text-xs uppercase text-green-700 font-semibold">In stock</p>
                <p class="mt-1 text-xl font-bold text-green-700">
                    ${totalInStock != null ? totalInStock : 0}
                </p>
            </div>
    </div>

    <!-- Summary table: per variant (imported / sold / in stock) -->
    <div id="inventory-summary-view" class="overflow-x-auto rounded-lg border border-gray-200">

            <table class="w-full text-sm text-left text-gray-600">

                <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-semibold">
                    <tr>
                        <th class="px-4 py-3">#</th>
                        <th class="px-4 py-3">Product name</th>
                        <th class="px-4 py-3">SKU / Variant</th>
                        <th class="px-4 py-3 text-right">Imported</th>
                        <th class="px-4 py-3 text-right">Sold</th>
                        <th class="px-4 py-3 text-right">Reserved</th>
                        <th class="px-4 py-3 text-right">In stock</th>
                        <th class="px-4 py-3 text-center">Actions</th>
                    </tr>
                </thead>

                <tbody class="divide-y divide-gray-200">

                    <c:forEach items="${inventorySummary}" var="s" varStatus="stt">
                        <tr class="hover:bg-gray-50 transition-colors">
                            <td class="px-4 py-3 font-mono text-gray-700">
                                #${stt.count}
                            </td>
                            <td class="px-4 py-3 font-medium text-gray-900"
                                data-col="product">
                                ${s.productName}
                            </td>
                            <td class="px-4 py-3 font-mono text-gray-700">
                                ${s.sku}
                            </td>
                            <td class="px-4 py-3 text-right font-semibold">
                                ${s.imported}
                            </td>
                            <td class="px-4 py-3 text-right font-semibold text-blue-700">
                                ${s.sold}
                            </td>
                            <td class="px-4 py-3 text-right font-semibold text-orange-700">
                                ${s.reversed}
                            </td>
                            <td class="px-4 py-3 text-right font-semibold text-green-700">
                                ${s.inStock}
                            </td>
                            <td class="px-4 py-3 text-center">
                                <button type="button"
                                        class="inline-flex items-center justify-center w-9 h-9 rounded-lg border border-blue-200 bg-blue-50 text-blue-600 shadow-sm hover:bg-blue-100 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-offset-1 transition-colors btn-summary-view-detail"
                                        data-variant-id="${s.variantId}"
                                        title="View detail"
                                        aria-label="View detail">
                                    <span class="sr-only">View detail</span>
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                              d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                              d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                    </svg>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty inventorySummary}">
                        <tr>
                            <td colspan="8" class="px-4 py-8 text-center text-gray-500 italic">
                                No summary data.
                            </td>
                        </tr>
                    </c:if>

                </tbody>
            </table>
    </div>

    <!-- Table: per inventory item -->
    <div id="inventory-detail-view"
         class="overflow-x-auto rounded-lg border border-gray-200 hidden">

        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-2">
            <div class="flex-1 text-center">
                <div id="detail-product-title"
                     class="text-lg md:text-xl font-extrabold text-gray-900 tracking-tight">
                    Inventory details
                </div>
                <div id="detail-product-subtitle" class="text-xs text-gray-500">
                    Grouped by import batch and import price
                </div>
            </div>
        </div>

        <table class="w-full text-sm text-left text-gray-600">

            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-semibold">
                <tr>
                    <th class="px-4 py-3">#</th>
                    <th class="px-4 py-3">Product Name</th>
                    <th class="px-4 py-3 text-right">Import Price</th>
                    <th class="px-4 py-3 text-center">Status</th>
                    <th class="px-4 py-3 text-center">Quantity</th>
                    <th class="px-4 py-3 text-center">Actions</th>
                </tr>
            </thead>

            <tbody id="inventory-detail-tbody" class="divide-y divide-gray-200">

                <c:forEach items="${listInventory}" var="it" varStatus="stt">
                    <tr class="hover:bg-gray-50 transition-colors"
                        data-inventory-id="${it.inventory_id}"
                        data-variant-id="${it.variant_id}"
                        data-receipt-item-id="${it.receipt_item_id}"
                        data-status="${it.status}"
                        data-product-name="${it.productName}"
                        data-import-price="${it.import_price}"
                        data-serial-id="${it.imei}"
                        data-sku="${it.sku}"
                        data-receipt-code="${it.receiptCode}">

                        <td class="px-4 py-3 font-mono text-gray-700">
                            #${stt.count}
                        </td>

                        <td class="px-4 py-3 font-medium text-gray-900">
                            <c:choose>
                                <c:when test="${not empty it.productName}">
                                    ${it.productName}
                                </c:when>
                                <c:otherwise>
                                    —
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class="px-4 py-3 text-right font-semibold">
                            <fmt:formatNumber value="${it.import_price}"
                                              type="number"
                                              groupingUsed="true"
                                              maxFractionDigits="0"/> ₫
                        </td>

                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${it.status == 'IN_STOCK'}">
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-green-700 bg-green-100">
                                        IN_STOCK
                                    </span>
                                </c:when>
                                <c:when test="${it.status == 'SOLD'}">
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-blue-700 bg-blue-100">
                                        SOLD
                                    </span>
                                </c:when>
                                <c:when test="${it.status == 'RESERVED' || it.status == 'REVERSED'}">
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-amber-700 bg-amber-100">
                                        RESERVED
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full text-gray-700 bg-gray-100">
                                        ${it.status}
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class="px-4 py-3 text-center">
                            <span class="inline-flex items-center px-2.5 py-1 text-xs font-bold rounded-full bg-gray-100 text-gray-700">
                                1
                            </span>
                        </td>

                        <td class="px-4 py-3 text-center">
                            <a href="inventory?action=view&id=${it.inventory_id}"
                               class="inline-flex items-center justify-center w-9 h-9 rounded-lg border border-blue-200 bg-blue-50 text-blue-600 shadow-sm hover:bg-blue-100 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-offset-1 transition-colors no-underline"
                               title="View"
                               aria-label="View detail">
                                <span class="sr-only">View</span>
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                          d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                          d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                </svg>
                            </a>
                        </td>

                    </tr>
                </c:forEach>

                <c:if test="${empty listInventory}">
                    <tr>
                        <td colspan="6" class="px-4 py-12 text-center text-gray-500 italic">
                            <c:choose>
                                <c:when test="${not empty param.keyword}">No results found for "${param.keyword}".</c:when>
                                <c:otherwise>No inventory data.</c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:if>

            </tbody>
        </table>
    </div>
</div>

<!-- Modal: grouped inventory items (compact table) -->
<div id="group-items-modal"
     class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 backdrop-blur-sm p-4"
     aria-hidden="true">
    <div class="w-full max-w-3xl max-h-[90vh] flex flex-col bg-white rounded-2xl shadow-2xl border border-gray-200 overflow-hidden">
        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100 shrink-0">
            <h3 id="group-items-modal-title" class="text-base font-bold text-gray-900">Grouped inventory items</h3>
            <button id="group-items-modal-close" type="button" class="text-gray-400 hover:text-gray-600 text-xl leading-none">&times;</button>
        </div>
        <div class="p-5 flex flex-col min-h-0 flex-1 overflow-hidden">
            <div id="group-items-modal-meta" class="text-xs text-gray-600 mb-3 shrink-0"></div>
            <div id="group-items-modal-list" class="min-h-0 flex-1 overflow-auto border border-gray-200 rounded-lg"></div>
        </div>
    </div>
</div>

<script>
    (function () {
        // Luồng màn hình:
        // 1) summaryView: bảng tổng theo variant.
        // 2) detailView: bảng nhóm theo lô nhập + giá + status sau khi bấm "View detail".
        // 3) modal: danh sách serial trong từng nhóm.
        const summaryView = document.getElementById('inventory-summary-view');
        const detailView = document.getElementById('inventory-detail-view');
        const detailTbody = document.getElementById('inventory-detail-tbody');
        const detailRows = detailView ? detailView.querySelectorAll('tbody tr[data-variant-id]') : null;
        const btnRowDetails = document.querySelectorAll('.btn-summary-view-detail');
        const btnBack = document.getElementById('btn-back-to-summary');
        const detailTitle = document.getElementById('detail-product-title');
        const groupItemsModal = document.getElementById('group-items-modal');
        const groupItemsModalTitle = document.getElementById('group-items-modal-title');
        const groupItemsModalMeta = document.getElementById('group-items-modal-meta');
        const groupItemsModalList = document.getElementById('group-items-modal-list');
        const groupItemsModalClose = document.getElementById('group-items-modal-close');
        let currentGroupedMap = {};

        if (!summaryView || !detailView) {
            return;
        }

        // Chụp dữ liệu gốc từ DOM 1 lần để render lại nhanh bằng JS (không gọi server thêm).
        const allItems = [];
        if (detailRows) {
            detailRows.forEach(function (row) {
                const ds = row.dataset || {};
                allItems.push({
                    inventoryId: ds.inventoryId,
                    variantId: ds.variantId,
                    receiptItemId: ds.receiptItemId,
                    status: ds.status,
                    productName: ds.productName || '',
                    importPrice: ds.importPrice,
                    serialId: ds.serialId || '',
                    sku: ds.sku || '',
                    receiptCode: ds.receiptCode || ''
                });
            });
        }

        var INV_ICON_EYE = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">'
                + '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>'
                + '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>'
                + '</svg>';

        function formatVND(value) {
            var n = Number(value || 0);
            try {
                return n.toLocaleString('vi-VN');
            } catch (e) {
                return String(value || 0);
            }
        }

        /** Same rules as modal: duplicate serial_id counts once; empty serial keeps each row. */
        function dedupeInventoryItemsBySerial(items) {
            var seenSerial = new Set();
            var out = [];
            (items || []).forEach(function (it) {
                var key = (it && it.serialId != null) ? String(it.serialId).trim().toUpperCase() : '';
                if (!key) {
                    out.push(it);
                    return;
                }
                if (seenSerial.has(key)) {
                    return;
                }
                seenSerial.add(key);
                out.push(it);
            });
            return out;
        }

        function renderGroupedRows(filterVariantId) {
            if (!detailTbody)
                return;
            currentGroupedMap = {};

            // Lọc theo variant khi đi từ summary -> detail.
            const items = allItems.filter(function (it) {
                if (!filterVariantId)
                    return true;
                return String(it.variantId) === String(filterVariantId);
            });

            // Group key: cùng receipt_item + giá nhập + status + product.
            const groups = new Map();
            items.forEach(function (it) {
                const key = [it.receiptItemId, it.importPrice, it.status, it.productName].join('|');
                if (!groups.has(key)) {
                    groups.set(key, {
                        groupKey: key,
                        productName: it.productName,
                        importPrice: it.importPrice,
                        status: it.status,
                        receiptItemId: it.receiptItemId,
                        sku: it.sku || '',
                        receiptCode: it.receiptCode || '',
                        quantity: 0,
                        firstInventoryId: it.inventoryId,
                        items: []
                    });
                }
                const g = groups.get(key);
                g.items.push({
                    inventoryId: it.inventoryId != null ? String(it.inventoryId) : '',
                    serialId: it.serialId || '',
                    importPrice: it.importPrice,
                    status: it.status || '',
                    sku: it.sku || '',
                    receiptCode: it.receiptCode || ''
                });
            });

            groups.forEach(function (g) {
                // Đồng bộ rule với modal: serial trùng chỉ tính 1 để tránh lệch Quantity.
                g.items = dedupeInventoryItemsBySerial(g.items);
                g.quantity = g.items.length;
                g.firstInventoryId = null;
                g.items.forEach(function (row) {
                    if (row.inventoryId == null || row.inventoryId === '') {
                        return;
                    }
                    var id = Number(row.inventoryId);
                    if (isNaN(id)) {
                        return;
                    }
                    if (g.firstInventoryId == null || id < Number(g.firstInventoryId)) {
                        g.firstInventoryId = row.inventoryId;
                    }
                });
            });

            const grouped = Array.from(groups.values()).sort(function (a, b) {
                // sort by receipt_item_id then import price then product name
                const ra = Number(a.receiptItemId || 0);
                const rb = Number(b.receiptItemId || 0);
                if (ra !== rb)
                    return ra - rb;
                const pa = Number(a.importPrice || 0);
                const pb = Number(b.importPrice || 0);
                if (pa !== pb)
                    return pa - pb;
                return String(a.productName || '').localeCompare(String(b.productName || ''));
            });

            // Render badge status thống nhất giữa detail table và modal.
            function statusBadge(status) {
                const s = String(status || '');
                if (s === 'IN_STOCK') {
                    return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-green-700 bg-green-100">IN_STOCK</span>';
                }
                if (s === 'SOLD') {
                    return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-blue-700 bg-blue-100">SOLD</span>';
                }
                if (s === 'RESERVED' || s === 'REVERSED') {
                    return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-amber-700 bg-amber-100">RESERVED</span>';
                }
                return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-gray-700 bg-gray-100">' + s + '</span>';
            }

            // Mỗi lần filter/group sẽ build lại tbody từ đầu để dữ liệu luôn nhất quán.
            detailTbody.innerHTML = '';
            if (grouped.length === 0) {
                detailTbody.innerHTML = '<tr><td colspan="6" class="px-4 py-12 text-center text-gray-500 italic">No inventory data.</td></tr>';
                return;
            }

            grouped.forEach(function (g, idx) {
                const safeName = (g.productName && g.productName.trim()) ? g.productName : '—';
                const groupId = 'group-' + idx;
                currentGroupedMap[groupId] = {
                    productName: safeName,
                    status: g.status,
                    importPrice: g.importPrice,
                    receiptItemId: g.receiptItemId,
                    sku: g.sku || '',
                    receiptCode: g.receiptCode || '',
                    items: g.items || []
                };
                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50 transition-colors';
                row.innerHTML = ''
                        + '<td class="px-4 py-3 font-mono text-gray-700">#' + (idx + 1) + '</td>'
                        + '<td class="px-4 py-3 font-medium text-gray-900">' + safeName + '</td>'
                        + '<td class="px-4 py-3 text-right font-semibold">' + formatVND(g.importPrice) + ' ₫</td>'
                        + '<td class="px-4 py-3 text-center">' + statusBadge(g.status) + '</td>'
                        + '<td class="px-4 py-3 text-center"><span class="inline-flex items-center px-2.5 py-1 text-xs font-bold rounded-full bg-gray-100 text-gray-700">' + g.quantity + '</span></td>'
                        + '<td class="px-4 py-3 text-center">'
                        + '<div class="inline-flex flex-wrap items-center justify-center">'
                        + ('<button type="button" class="inline-flex items-center justify-center w-9 h-9 rounded-lg border border-blue-200 bg-blue-50 text-blue-600 shadow-sm hover:bg-blue-100 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-offset-1 transition-colors btn-view-group-items" data-group-id="' + groupId + '" title="Serial list" aria-label="Serial list"><span class="sr-only">Serial list</span>' + INV_ICON_EYE + '</button>')
                        + '</div>'
                        + '</td>';
                detailTbody.appendChild(row);
            });
        }

        function escapeHtml(s) {
            return String(s == null ? '' : s)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');
        }

        function inventoryStatusBadgeHtml(status) {
            var s = String(status || '');
            if (s === 'IN_STOCK') {
                return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-green-700 bg-green-100">IN_STOCK</span>';
            }
            if (s === 'SOLD') {
                return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-blue-700 bg-blue-100">SOLD</span>';
            }
            if (s === 'RESERVED' || s === 'REVERSED') {
                return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-amber-700 bg-amber-100">RESERVED</span>';
            }
            return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-gray-700 bg-gray-100">' + escapeHtml(s) + '</span>';
        }

        function openGroupItemsModal(groupId) {
            if (!groupItemsModal || !groupItemsModalList) {
                return;
            }
            const data = currentGroupedMap[groupId];
            if (!data) {
                return;
            }
            const formatPrice = (typeof formatVND === 'function')
                    ? formatVND
                    : function (value) {
                        const n = Number(value || 0);
                        try {
                            return n.toLocaleString('vi-VN');
                        } catch (e) {
                            return String(value || 0);
                        }
                    };

            groupItemsModalTitle.textContent = data.productName || 'Grouped inventory';
            const items = data.items || [];
            // Safety layer: nếu DB còn dữ liệu cũ bị trùng serial thì modal chỉ hiển thị unique serial.
            const seenSerial = new Set();
            const uniqueItems = [];
            items.forEach(function (it) {
                const key = (it && it.serialId != null) ? String(it.serialId).trim().toUpperCase() : '';
                if (!key) {
                    uniqueItems.push(it);
                    return;
                }
                if (seenSerial.has(key)) {
                    return;
                }
                seenSerial.add(key);
                uniqueItems.push(it);
            });
            if (groupItemsModalMeta) {
                groupItemsModalMeta.innerHTML = '';
            }
            if (uniqueItems.length === 0) {
                if (groupItemsModalMeta) {
                    groupItemsModalMeta.textContent = '';
                }
                groupItemsModalList.innerHTML = '<div class="px-4 py-8 text-sm text-gray-500 text-center italic">No item data found for this group.</div>';
            } else {
                if (groupItemsModalMeta) {
                    var rc = data.receiptCode && String(data.receiptCode).trim() ? String(data.receiptCode).trim() : '';
                    var metaHtml = '<span class="font-medium text-gray-800">' + uniqueItems.length + ' item(s)</span>';
                    if (rc) {
                        metaHtml += '<span class="mx-2 text-gray-300">|</span>'
                                + '<span>Receipt: <span class="font-medium text-gray-800">' + escapeHtml(rc) + '</span></span>';
                    }
                    groupItemsModalMeta.innerHTML = metaHtml;
                }
                const thead = ''
                        + '<thead class="bg-gray-50 text-left text-xs font-semibold uppercase tracking-wide text-gray-600 sticky top-0 z-10 border-b border-gray-200">'
                        + '<tr>'
                        + '<th class="px-3 py-2 w-12 text-center">#</th>'
                        + '<th class="px-3 py-2">Serial</th>'
                        + '<th class="px-3 py-2">SKU</th>'
                        + '<th class="px-3 py-2 text-right">Price (₫)</th>'
                        + '<th class="px-3 py-2 text-center">Status</th>'
                        + '</tr>'
                        + '</thead>';
                const rows = uniqueItems.map(function (item, index) {
                    const serialId = item.serialId && String(item.serialId).trim() ? String(item.serialId).trim() : '—';
                    const skuRaw = item.sku != null && String(item.sku).trim() ? String(item.sku).trim() : (data.sku != null && String(data.sku).trim() ? String(data.sku).trim() : '');
                    const skuCell = skuRaw ? escapeHtml(skuRaw) : '—';
                    const priceVal = item.importPrice != null && item.importPrice !== '' ? item.importPrice : data.importPrice;
                    const priceCell = formatPrice(priceVal) + ' ₫';
                    const statusCell = inventoryStatusBadgeHtml(item.status != null && item.status !== '' ? item.status : data.status);
                    return '<tr class="border-b border-gray-100 hover:bg-gray-50/80">'
                            + '<td class="px-3 py-2 text-center text-gray-500 tabular-nums">' + (index + 1) + '</td>'
                            + '<td class="px-3 py-2 font-mono text-sm text-gray-800 break-all">' + escapeHtml(serialId) + '</td>'
                            + '<td class="px-3 py-2 font-mono text-sm text-gray-900">' + skuCell + '</td>'
                            + '<td class="px-3 py-2 text-right font-semibold text-gray-900 tabular-nums">' + priceCell + '</td>'
                            + '<td class="px-3 py-2 text-center">' + statusCell + '</td>'
                            + '</tr>';
                }).join('');
                groupItemsModalList.innerHTML = ''
                        + '<div class="overflow-x-auto">'
                        + '<table class="min-w-full text-sm">'
                        + thead
                        + '<tbody>' + rows + '</tbody>'
                        + '</table>'
                        + '</div>';
            }

            groupItemsModal.classList.remove('hidden');
            groupItemsModal.classList.add('flex');
            groupItemsModal.setAttribute('aria-hidden', 'false');
        }

        function closeGroupItemsModal() {
            if (!groupItemsModal) {
                return;
            }
            groupItemsModal.classList.add('hidden');
            groupItemsModal.classList.remove('flex');
            groupItemsModal.setAttribute('aria-hidden', 'true');
        }

        if (detailTbody) {
            detailTbody.addEventListener('click', function (e) {
                const btn = e.target.closest('.btn-view-group-items');
                if (!btn) {
                    return;
                }
                const groupId = btn.getAttribute('data-group-id');
                if (groupId) {
                    openGroupItemsModal(groupId);
                }
            });
        }

        if (groupItemsModalClose) {
            groupItemsModalClose.addEventListener('click', closeGroupItemsModal);
        }
        if (groupItemsModal) {
            groupItemsModal.addEventListener('click', function (e) {
                if (e.target === groupItemsModal) {
                    closeGroupItemsModal();
                }
            });
        }
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                closeGroupItemsModal();
            }
        });

        // Từ summary row, mở detail của đúng variant đang chọn.
        if (btnRowDetails) {
            btnRowDetails.forEach(function (btn) {
                btn.addEventListener('click', function () {
                    const variantId = btn.getAttribute('data-variant-id');
                    if (!variantId) {
                        return;
                    }

                    // Lấy product name từ dòng summary để làm tiêu đề detail.
                    const summaryRow = btn.closest('tr');
                    const productCell = summaryRow ? summaryRow.querySelector('td[data-col="product"]') : null;
                    const productName = productCell ? productCell.textContent.trim() : '';
                    if (detailTitle) {
                        detailTitle.textContent = productName ? productName : 'Inventory details';
                    }

                    // Chuyển từ summary sang detail view.
                    summaryView.classList.add('hidden');
                    detailView.classList.remove('hidden');

                    if (btnBack) {
                        btnBack.classList.remove('hidden');
                    }

                    // Render nhóm cho đúng variant vừa chọn.
                    renderGroupedRows(variantId);

                    // Scroll to detail table
                    detailView.scrollIntoView({behavior: 'smooth', block: 'start'});
                });
            });
        }

        // Quay lại summary list.
        if (btnBack) {
            btnBack.addEventListener('click', function () {
                // Show summary, hide detail
                summaryView.classList.remove('hidden');
                detailView.classList.add('hidden');

                // Reset title
                if (detailTitle) {
                    detailTitle.textContent = 'Inventory details';
                }
                if (btnBack) {
                    btnBack.classList.add('hidden');
                }

                summaryView.scrollIntoView({behavior: 'smooth', block: 'start'});
            });
        }

        // Initial render (search mode): show grouped table for all items
        // If the page is loaded with keyword search, the detail view is already visible.
        if (!detailView.classList.contains('hidden')) {
            renderGroupedRows(null);
        }
    })();
</script>