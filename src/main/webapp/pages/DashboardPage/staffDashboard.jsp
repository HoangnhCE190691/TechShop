<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="bg-gray-100 p-4 rounded-lg shadow-sm inline-block">
    <form action="staffservlet" method="GET" id="filterForm" class="flex items-center gap-3">
        <input name="action" value="searchByMonth" hidden="">
        <select name="month" id="month" 
                onchange="this.form.submit()"
                class="block w-40 px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm 
                focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm
                cursor-pointer hover:border-gray-400 transition-colors">

            <option value="0">Select</option>
            <option value="-1">All</option>
            <option value="1">Month 1</option>
            <option value="2">Month 2</option>
            <option value="3">Month 3</option>
            <option value="4">Month 4</option>
            <option value="5">Month 5</option>
            <option value="6">Month 6</option>
            <option value="7">Month 7</option>
            <option value="8">Month 8</option>
            <option value="9">Month 9</option>
            <option value="10">Month 10</option>
            <option value="11">Month 11</option>
            <option value="12">Month 12</option>
        </select>

        <button type="submit" class="hidden"></button>
    </form>
</div>
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">

    <div class="relative overflow-x-auto bg-white shadow-md rounded-lg border border-blue-200">
        <div class="bg-blue-600 px-4 py-3">
            <h3 class="font-bold text-white flex items-center">
                <span class="mr-2">👤</span> Order
            </h3>
        </div>
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-blue-50 text-blue-800 border-b">
                <tr>
                    <th class="px-4 py-3 font-semibold">Username</th>
                    <th class="px-4 py-3 font-semibold">Phone</th>
                    <th class="px-4 py-3 font-semibold text-center">Status</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                <c:forEach items="${listDataCustomer}" var="cus" end="4">
                    <tr class="hover:bg-blue-50 transition-colors">
                        <td class="px-4 py-3">
                            <div class="font-medium text-gray-900">@${cus.userName}</div>
                            <div class="text-xs text-gray-400">${cus.fullname}</div>
                        </td>
                        <td class="px-4 py-3">${cus.phoneNumber}</td>
                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${cus.status eq 'Active' || cus.status eq 'ACTIVE'}">
                                    <span class="px-2 py-1 text-[10px] font-bold text-green-700 bg-green-100 rounded-full border border-green-200">ACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-[10px] font-bold text-red-700 bg-red-100 rounded-full border border-red-200">LOCKED</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    <div class="relative overflow-x-auto bg-white shadow-md rounded-lg border border-red-200">
        <div class="bg-red-600 px-4 py-3">
            <h3 class="font-bold text-white flex items-center">
                <span class="mr-2">🏭</span> Suppliers
            </h3>
        </div>
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-red-50 text-red-800 border-b">
                <tr>
                    <th class="px-4 py-3 font-semibold">Supplier</th>
                    <th class="px-4 py-3 font-semibold text-center">Status</th>
                    <th class="px-4 py-3 font-semibold text-center whitespace-nowrap">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                <c:if test="${empty listSuppliers}">
                    <tr>
                        <td colspan="3" class="px-4 py-10 text-center text-gray-500 italic">No supplier data.</td>
                    </tr>
                </c:if>

                <c:forEach items="${listSuppliers != null ? listSuppliers : []}" var="s" end="4">
                    <tr class="hover:bg-red-50 transition-colors">
                        <td class="px-4 py-3">
                            <div class="font-medium text-gray-900">${s.supplier_name}</div>
                            <div class="text-xs text-gray-500 break-words">
                                <c:choose>
                                    <c:when test="${not empty s.phone}">
                                        ${s.phone}
                                    </c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${s.is_active}">
                                    <span class="px-2 py-1 text-[10px] font-bold text-green-700 bg-green-100 rounded-full">ACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-[10px] font-bold text-red-700 bg-red-100 rounded-full">LOCKED</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-4 py-3 text-center whitespace-nowrap">
                            <a href="supplier?action=view&id=${s.supplier_id}" class="text-blue-600 hover:text-blue-900 font-bold text-xs uppercase">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <div class="relative overflow-x-auto bg-white shadow-md rounded-lg border border-orange-200 w-full">
        <div class="bg-orange-500 px-4 py-3 w-full">
            <h3 class="font-bold text-white flex items-center">
                <span class="mr-2">📦</span> Inventory receipts
            </h3>
        </div>
        <table class="w-full min-w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-orange-50 text-orange-800 border-b">
                <tr>
                    <th class="px-4 py-3 font-semibold">Receipt</th>
                    <th class="px-4 py-3 font-semibold">Supplier</th>
                    <th class="px-4 py-3 font-semibold text-center">Total</th>
                    <th class="px-4 py-3 font-semibold text-center whitespace-nowrap">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                <c:if test="${empty listImportReceipts}">
                    <tr>
                        <td colspan="4" class="px-4 py-10 text-center text-gray-500 italic">No inventory receipt data.</td>
                    </tr>
                </c:if>

                <c:forEach items="${listImportReceipts != null ? listImportReceipts : []}" var="r" varStatus="st" end="4">
                    <c:set var="supplierName" value="—"/>
                    <c:forEach items="${listSuppliers != null ? listSuppliers : []}" var="s">
                        <c:if test="${s.supplier_id == r.supplier_id}">
                            <c:set var="supplierName" value="${s.supplier_name}"/>
                        </c:if>
                    </c:forEach>

                    <tr class="hover:bg-orange-50 transition-colors">
                        <td class="px-4 py-3">
                            <div class="font-medium text-gray-900">#${st.count}</div>
                                <div class="text-xs text-gray-500 whitespace-nowrap overflow-hidden text-ellipsis">
                                <fmt:formatDate value="${r.import_date}" pattern="yyyy-MM-dd"/>
                            </div>
                        </td>
                        <td class="px-4 py-3">${supplierName}</td>
                        <td class="px-4 py-3 text-center font-semibold">
                            <span class="whitespace-nowrap">
                                <fmt:formatNumber value="${r.total_cost}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                            </span>
                        </td>
                        <td class="px-4 py-3 text-center whitespace-nowrap">
                            <a href="staffservlet?action=inventoryReceiptDetail&id=${r.receipt_id}"
                               class="text-orange-700 hover:text-orange-900 font-bold text-xs uppercase">Detail</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="bg-white border border-gray-200 rounded-xl shadow-sm flex flex-col overflow-hidden">
        <div class="p-6 pb-0">
            <div class="flex justify-between items-center mb-4">
                <h5 class="text-xl font-bold text-gray-900">FeedBack</h5>

            </div>
        </div>
        <div id="pie-chart-voucher" class="mt-auto"></div>
        <div class="grid grid-cols-2 border-t border-gray-100 bg-gray-50/50">
            <div class="text-center py-3 border-r border-gray-100">
                <p class="text-xs text-gray-500 uppercase font-semibold">Active</p>
                <p class="font-bold text-gray-900">${activeV != null ? activeV : 0}</p>
            </div>
            <div class="text-center py-3">
                <p class="text-xs text-gray-500 uppercase font-semibold">Locked/Expired</p>
                <p class="font-bold text-gray-900">${(lockedV != null ? lockedV : 0) + (expiredV != null ? expiredV : 0)}</p>
            </div>
        </div>
    </div>

    <div class="bg-white border border-gray-200 rounded-xl shadow-sm flex flex-col overflow-hidden">
        <div class="p-6 pb-0">
            <div class="flex justify-between items-center mb-4">
                <h5 class="text-xl font-bold text-gray-900">Inventory</h5>
            </div>
        </div>
        <div id="pie-chart-inventory" class="mt-auto"></div>
        <div class="grid grid-cols-3 border-t border-gray-100 bg-gray-50/50">
            <div class="text-center py-3 border-r border-gray-100">
                <p class="text-xs text-gray-500 uppercase font-semibold">Imported</p>
                <p class="font-bold text-gray-900">${inventoryImportedTotal != null ? inventoryImportedTotal : 0}</p>
            </div>
            <div class="text-center py-3 border-r border-gray-100">
                <p class="text-xs text-gray-500 uppercase font-semibold">Sold</p>
                <p class="font-bold text-gray-900">${inventorySoldTotal != null ? inventorySoldTotal : 0}</p>
            </div>
            <div class="text-center py-3">
                <p class="text-xs text-gray-500 uppercase font-semibold">In Stock</p>
                <p class="font-bold text-gray-900">${inventoryInStockTotal != null ? inventoryInStockTotal : 0}</p>
            </div>
        </div>
    </div>

</div>

<div id="staffDashboardStats"
     data-active-v="${activeV != null ? activeV : 0}"
     data-locked-v="${lockedV != null ? lockedV : 0}"
     data-expired-v="${expiredV != null ? expiredV : 0}"
     data-pending-count="${pendingCount != null ? pendingCount : 0}"
     data-approved-count="${approvedCount != null ? approvedCount : 0}"
     data-shipping-count="${shippingCount != null ? shippingCount : 0}"
     data-shipped-count="${shippedCount != null ? shippedCount : 0}"
     data-cancelled-count="${cancelledCount != null ? cancelledCount : 0}"
     data-inventory-imported-total="${inventoryImportedTotal != null ? inventoryImportedTotal : 0}"
     data-inventory-sold-total="${inventorySoldTotal != null ? inventorySoldTotal : 0}"
     data-inventory-in-stock-total="${inventoryInStockTotal != null ? inventoryInStockTotal : 0}"
     class="hidden">
</div>

<script>
    window.addEventListener('load', function () {
        const statsEl = document.getElementById('staffDashboardStats');
        const getNum = (key) => {
            if (!statsEl) return 0;
            const raw = statsEl.dataset[key];
            return Number(raw || 0);
        };

        // --- BIỂU ĐỒ 1: VOUCHER STATUS ---
        const voucherEl = document.getElementById("pie-chart-voucher");
        if (voucherEl) {
            const voucherOptions = {
                series: [
                    getNum('activeV'),
                    getNum('lockedV'),
                    getNum('expiredV')
                ],
                chart: {type: 'donut', height: 260},
                labels: ['Active', 'Locked', 'Expired'],
                colors: ['#10B981', '#EF4444', '#9CA3AF'],
                legend: {position: 'bottom'},
                plotOptions: {
                    pie: {
                        donut: {
                            size: '70%',
                            labels: {
                                show: true,
                                total: {
                                    show: true,
                                    label: 'Total',
                                    formatter: function (w) {
                                        return w.globals.seriesTotals.reduce((a, b) => a + b, 0)
                                    }
                                }
                            }
                        }
                    }
                }
            };
            new ApexCharts(voucherEl, voucherOptions).render();
        }

        // --- BIỂU ĐỒ 3: INVENTORY SUMMARY ---
        const inventoryEl = document.getElementById("pie-chart-inventory");
        if (inventoryEl) {
            const inventoryOptions = {
                series: [
                    getNum('inventoryImportedTotal'),
                    getNum('inventorySoldTotal'),
                    getNum('inventoryInStockTotal')
                ],
                chart: {type: 'donut', height: 260},
                labels: ['Imported', 'Sold', 'In Stock'],
                colors: ['#1A56DB', '#10B981', '#F59E0B'],
                legend: {position: 'bottom'},
                plotOptions: {
                    pie: {
                        donut: {
                            size: '70%',
                            labels: {
                                show: true,
                                total: {
                                    show: true,
                                    label: 'Total',
                                    formatter: function (w) {
                                        return w.globals.seriesTotals.reduce((a, b) => a + b, 0)
                                    }
                                }
                            }
                        }
                    }
                }
            };
            new ApexCharts(inventoryEl, inventoryOptions).render();
        }

        // --- BIỂU ĐỒ SPARKLINE (DÙNG CHUNG HELPER) ---
        const sparklineOptions = (data, color) => ({
                series: [{name: 'Doanh thu', data: data}],
                chart: {type: 'area', height: 100, sparkline: {enabled: true}},
                stroke: {curve: 'smooth', width: 2},
                fill: {opacity: 0.3},
                colors: [color]
            });

        if (document.getElementById("chart-week")) {
            new ApexCharts(document.getElementById("chart-week"), sparklineOptions([30, 40, 35, 50, 49, 60, 70], '#1A56DB')).render();
        }

    }); // Kết thúc sự kiện load duy nhất
</script>