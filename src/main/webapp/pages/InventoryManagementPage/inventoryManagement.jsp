<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!-- Toast message -->
<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification"
         class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">

        <c:choose>
            <c:when test="${sessionScope.msgType == 'danger'}">
                <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-red-50 text-red-800 border-red-200">
                    <span class="font-bold uppercase tracking-wider text-sm">
                        ${sessionScope.msg}
                    </span>
                </div>
            </c:when>
            <c:otherwise>
                <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 bg-green-50 text-green-800 border-green-200">
                    <span class="font-bold uppercase tracking-wider text-sm">
                        ${sessionScope.msg}
                    </span>
                </div>
            </c:otherwise>
        </c:choose>

    </div>

    <c:remove var="msg" scope="session"/>
    <c:remove var="msgType" scope="session"/>

    <script>
        setTimeout(function () {
            var toast = document.getElementById("toast-notification");
            if (toast) {
                toast.remove();
            }
        }, 3000);
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
                       placeholder="Search by product name, IMEI, status or ID..."
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
                    class="inline-flex items-center px-3 py-2 text-sm font-semibold rounded-lg bg-gray-100 text-gray-700 border border-gray-300 hover:bg-gray-200 md:ml-auto ${empty param.keyword ? 'hidden' : ''}">
                ← Back to summary
            </button>
        </div>

    </div>

    <!-- Totals (only show when not searching) -->
    <c:if test="${empty param.keyword}">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-5">
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
            <!-- In stock -->
            <div class="bg-green-50 border border-green-200 rounded-xl px-4 py-3">
                <p class="text-xs uppercase text-green-700 font-semibold">In stock</p>
                <p class="mt-1 text-xl font-bold text-green-700">
                    ${totalInStock != null ? totalInStock : 0}
                </p>
            </div>
        </div>
    </c:if>

    <!-- Summary table: per variant (imported / sold / in stock) -->
    <c:if test="${empty param.keyword}">
    <div id="inventory-summary-view" class="overflow-x-auto rounded-lg border border-gray-200">

        <table class="w-full text-sm text-left text-gray-600">

            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-semibold">
                <tr>
                    <th class="px-4 py-3">#</th>
                    <th class="px-4 py-3">Product name</th>
                    <th class="px-4 py-3">SKU / Variant</th>
                    <th class="px-4 py-3 text-right">Imported</th>
                    <th class="px-4 py-3 text-right">Sold</th>
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
                        <td class="px-4 py-3 text-right font-semibold text-green-700">
                            ${s.inStock}
                        </td>
                        <td class="px-4 py-3 text-center">
                            <button type="button"
                                    class="text-blue-600 hover:text-blue-800 font-medium hover:underline btn-summary-view-detail"
                                    data-variant-id="${s.variantId}">
                                View detail
                            </button>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty inventorySummary}">
                    <tr>
                        <td colspan="6" class="px-4 py-8 text-center text-gray-500 italic">
                            No summary data.
                        </td>
                    </tr>
                </c:if>

            </tbody>
        </table>
    </div>
    </c:if>

    <!-- Table: per inventory item (IMEI-level) -->
    <div id="inventory-detail-view"
         class="overflow-x-auto rounded-lg border border-gray-200 ${empty param.keyword ? 'hidden' : ''}">

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
                        data-import-price="${it.import_price}">

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
                               class="text-gray-600 hover:text-gray-800 font-medium hover:underline">
                                Details
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

<script>
    (function () {
        const summaryView = document.getElementById('inventory-summary-view');
        const detailView = document.getElementById('inventory-detail-view');
        const detailTbody = document.getElementById('inventory-detail-tbody');
        const detailRows = detailView ? detailView.querySelectorAll('tbody tr[data-variant-id]') : null;
        const btnRowDetails = document.querySelectorAll('.btn-summary-view-detail');
        const btnBack = document.getElementById('btn-back-to-summary');
        const detailTitle = document.getElementById('detail-product-title');

        if (!summaryView || !detailView) {
            return;
        }

        // Snapshot all inventory rows from DOM (keeps IMEI in DB, not shown here)
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
                    importPrice: ds.importPrice
                });
            });
        }

        function renderGroupedRows(filterVariantId) {
            if (!detailTbody) return;

            const items = allItems.filter(function (it) {
                if (!filterVariantId) return true;
                return String(it.variantId) === String(filterVariantId);
            });

            // Group key: same import batch (receipt_item_id) + same import price + same status + same product
            const groups = new Map();
            items.forEach(function (it) {
                const key = [it.receiptItemId, it.importPrice, it.status, it.productName].join('|');
                if (!groups.has(key)) {
                    groups.set(key, {
                        productName: it.productName,
                        importPrice: it.importPrice,
                        status: it.status,
                        receiptItemId: it.receiptItemId,
                        quantity: 0,
                        firstInventoryId: it.inventoryId
                    });
                }
                const g = groups.get(key);
                g.quantity += 1;
                // keep smallest inventoryId for stable Details link
                if (g.firstInventoryId == null || (it.inventoryId != null && Number(it.inventoryId) < Number(g.firstInventoryId))) {
                    g.firstInventoryId = it.inventoryId;
                }
            });

            const grouped = Array.from(groups.values()).sort(function (a, b) {
                // sort by receipt_item_id then import price then product name
                const ra = Number(a.receiptItemId || 0);
                const rb = Number(b.receiptItemId || 0);
                if (ra !== rb) return ra - rb;
                const pa = Number(a.importPrice || 0);
                const pb = Number(b.importPrice || 0);
                if (pa !== pb) return pa - pb;
                return String(a.productName || '').localeCompare(String(b.productName || ''));
            });

            // Helper: render status badge same style as before
            function statusBadge(status) {
                const s = String(status || '');
                if (s === 'IN_STOCK') {
                    return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-green-700 bg-green-100">IN_STOCK</span>';
                }
                if (s === 'SOLD') {
                    return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-blue-700 bg-blue-100">SOLD</span>';
                }
                return '<span class="px-2 py-1 text-xs font-semibold rounded-full text-gray-700 bg-gray-100">' + s + '</span>';
            }

            function formatVND(value) {
                const n = Number(value || 0);
                try {
                    return n.toLocaleString('vi-VN');
                } catch (e) {
                    return String(value || 0);
                }
            }

            // Rebuild tbody
            detailTbody.innerHTML = '';
            if (grouped.length === 0) {
                detailTbody.innerHTML = '<tr><td colspan="6" class="px-4 py-12 text-center text-gray-500 italic">No inventory data.</td></tr>';
                return;
            }

            grouped.forEach(function (g, idx) {
                const safeName = (g.productName && g.productName.trim()) ? g.productName : '—';
                const detailsHref = g.firstInventoryId ? ('inventory?action=view&id=' + encodeURIComponent(g.firstInventoryId)) : '#';
                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50 transition-colors';
                row.innerHTML = ''
                        + '<td class="px-4 py-3 font-mono text-gray-700">#' + (idx + 1) + '</td>'
                        + '<td class="px-4 py-3 font-medium text-gray-900">' + safeName + '</td>'
                        + '<td class="px-4 py-3 text-right font-semibold">' + formatVND(g.importPrice) + ' ₫</td>'
                        + '<td class="px-4 py-3 text-center">' + statusBadge(g.status) + '</td>'
                        + '<td class="px-4 py-3 text-center"><span class="inline-flex items-center px-2.5 py-1 text-xs font-bold rounded-full bg-gray-100 text-gray-700">' + g.quantity + '</span></td>'
                        + '<td class="px-4 py-3 text-center">'
                        + (g.firstInventoryId ? ('<a href="' + detailsHref + '" class="text-gray-600 hover:text-gray-800 font-medium hover:underline">Details</a>') : '—')
                        + '</td>';
                detailTbody.appendChild(row);
            });
        }

        // From summary row: view detail for a specific variant
        if (btnRowDetails) {
            btnRowDetails.forEach(function (btn) {
                btn.addEventListener('click', function () {
                    const variantId = btn.getAttribute('data-variant-id');
                    if (!variantId) {
                        return;
                    }

                    // Set big title from summary row product name
                    const summaryRow = btn.closest('tr');
                    const productCell = summaryRow ? summaryRow.querySelector('td[data-col="product"]') : null;
                    const productName = productCell ? productCell.textContent.trim() : '';
                    if (detailTitle) {
                        detailTitle.textContent = productName ? productName : 'Inventory details';
                    }

                    // Show detail view
                    summaryView.classList.add('hidden');
                    detailView.classList.remove('hidden');

                    if (btnBack) {
                        btnBack.classList.remove('hidden');
                    }

                    // Render grouped rows for this variant
                    renderGroupedRows(variantId);

                    // Scroll to detail table
                    detailView.scrollIntoView({behavior: 'smooth', block: 'start'});
                });
            });
        }

        // Back from detail to summary: show all summary + all detail rows
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
            if (btnBack) {
                btnBack.classList.remove('hidden');
            }
        }
    })();
</script>