<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<div class="bg-white rounded-xl shadow-lg p-5">
    <div class="flex flex-col gap-4 mb-6">
        <div class="flex justify-between items-center">
            <h1 class="text-2xl font-bold text-gray-800">Order Management</h1>

        </div>

        <div class="flex flex-col md:flex-row md:items-center gap-4">
            <div class="relative flex-1">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                </span>
                <input type="text" id="searchInput"
                       class="w-full pl-10 pr-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                       placeholder="Search by ID, Customer, or Order Name...">
            </div>

            <div class="flex flex-wrap gap-2">
                <select id="paymentFilter" class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500">
                    <option value="all">All Payment</option>
                    <option value="PAID">PAID Only</option>
                    <option value="UNPAID">UNPAID Only</option>
                </select>

                <select id="statusFilter" class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500">
                    <option value="all">All Status</option>
                    <c:forEach items="${statusList}" var="st">
                        <option value="${st.code}">${st.name}</option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <div class="flex flex-wrap items-center gap-3 bg-gray-50 p-3 rounded-lg border border-gray-200">
            <span class="text-xs font-bold text-gray-500 uppercase">Amount Range:</span>
            <input type="number" id="minAmount" placeholder="Min" class="w-24 px-2 py-1 text-sm border border-gray-300 rounded">
            <span class="text-gray-400">-</span>
            <input type="number" id="maxAmount" placeholder="Max" class="w-24 px-2 py-1 text-sm border border-gray-300 rounded">
            <button id="resetFilters" class="text-xs text-blue-600 hover:underline ml-auto">Reset Filters</button>
        </div>
    </div>

    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-100 text-gray-700 font-bold">
                <tr>
                    <th class="px-6 py-4 text-center">ID</th>
                    <th class="px-6 py-4">Details</th>
                    <th class="px-6 py-4 text-center">Total Amount</th>
                    <th class="px-6 py-4 text-center">Payment</th>
                    <th class="px-6 py-4 text-center">Status</th>
                    <th class="px-6 py-4 text-center w-32">Actions</th>
                </tr>
            </thead>
            <tbody id="orderTableBody">
                <c:forEach items="${orderList}" var="o">
                    <tr class="order-row border-b hover:bg-gray-50 transition-colors"
                        data-payment="${o.paymentStatus}"
                        data-status="${o.status}"
                        data-amount="${o.totalAmount}">

                        <td class="px-6 py-4 text-center font-medium text-blue-600 order-id">#${o.orderId}</td>
                        <td class="px-6 py-4">
                            <div class="font-bold text-blue-700 text-sm uppercase order-name">${o.orderName}</div>
                            <div class="font-semibold text-gray-800 customer-name">${o.customerName}</div>
                            <div class="text-xs text-gray-400">${o.createdAt}</div>
                        </td>
                        <td class="px-6 py-4 text-center font-bold text-red-500">
                            <fmt:formatNumber value="${o.totalAmount}" type="number" pattern="#,###"/>đ
                        </td>
                        <td class="px-6 py-4 text-center">
                            <span class="px-3 py-1 rounded-full text-xs font-medium border
                                  ${o.paymentStatus == 'PAID' ? 'bg-green-100 text-green-700 border-green-200' : 'bg-red-100 text-red-700 border-red-200'}">
                                ${o.paymentStatus}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-center">
                            <%-- Lookup status name + color tu statusList --%>
                            <c:set var="badgeClass" value="px-3 py-1 rounded-full text-xs font-bold uppercase bg-yellow-100 text-yellow-700 border border-yellow-200"/>
                            <c:set var="badgeName" value="${o.status}"/>
                            <c:forEach items="${statusList}" var="st">
                                <c:if test="${st.code == o.status}">
                                    <c:set var="badgeName" value="${st.name}"/>
                                    <c:choose>
                                        <c:when test="${st.code == 'CANCELLED'}">
                                            <c:set var="badgeClass" value="px-3 py-1 rounded-full text-xs font-bold uppercase bg-gray-100 text-gray-600 border border-gray-200"/>
                                        </c:when>
                                        <c:when test="${st.isFinal == 'true'}">
                                            <c:set var="badgeClass" value="px-3 py-1 rounded-full text-xs font-bold uppercase bg-green-100 text-green-700 border border-green-200"/>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="badgeClass" value="px-3 py-1 rounded-full text-xs font-bold uppercase bg-blue-100 text-blue-700 border border-blue-200"/>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </c:forEach>
                            <span class="${badgeClass}">${badgeName}</span>
                        </td>
                        <td class="px-6 py-4 text-center space-y-1">
                            <a href="orderStaffServlet?action=orderDetail&id=${o.orderId}" class="block bg-gray-800 text-white text-[10px] py-1 rounded hover:bg-black transition">View</a>
                            <a href="orderStaffServlet?action=editOrderPage&id=${o.orderId}" class="block bg-blue-600 text-white text-[10px] py-1 rounded hover:bg-blue-700 transition">Edit</a>
                        </td>
                    </tr>
                </c:forEach>
                <%-- Empty state khi khong co don nao --%>
                <c:if test="${empty orderList}">
                    <tr>
                        <td colspan="6" class="px-6 py-10 text-center text-gray-400 italic font-medium">
                            No orders found.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <%-- Pagination --%>
    <div class="flex items-center justify-between mt-4 px-1">
        <div class="text-sm text-gray-500">
            Showing <span id="pageFrom">1</span>–<span id="pageTo">10</span>
            of <span id="visibleCount">${orderList.size()}</span> orders
        </div>
        <div class="flex gap-1" id="paginationControls"></div>
    </div>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const searchInput = document.getElementById('searchInput');
            const paymentFilter = document.getElementById('paymentFilter');
            const statusFilter = document.getElementById('statusFilter');
            const minAmountInput = document.getElementById('minAmount');
            const maxAmountInput = document.getElementById('maxAmount');
            const resetBtn = document.getElementById('resetFilters');
            const tableBody = document.getElementById('orderTableBody');
            const rows = tableBody.getElementsByClassName('order-row');
            const visibleCount = document.getElementById('visibleCount');
            const PAGE_SIZE = 10;
            let currentPage = 1;
            let filteredRows = [];
            function filterTable() {
                const searchText = searchInput.value.toLowerCase();
                const fPayment = paymentFilter.value;
                const fStatus = statusFilter.value;
                const minAmt = parseFloat(minAmountInput.value) || 0;
                const maxAmt = parseFloat(maxAmountInput.value) || Infinity;
                filteredRows = [];
                for (let i = 0; i < rows.length; i++) {
                    const idText = rows[i].querySelector('.order-id').innerText.toLowerCase();
                    const nameText = rows[i].querySelector('.order-name').innerText.toLowerCase();
                    const customerText = rows[i].querySelector('.customer-name').innerText.toLowerCase();
                    const rowPayment = rows[i].getAttribute('data-payment');
                    const rowStatus = rows[i].getAttribute('data-status');
                    const rowAmount = parseFloat(rows[i].getAttribute('data-amount')) || 0;
                    const matchesSearch = idText.includes(searchText) || nameText.includes(searchText) || customerText.includes(searchText);
                    const matchesPayment = (fPayment === 'all' || rowPayment === fPayment);
                    const matchesStatus = (fStatus === 'all' || rowStatus === fStatus);
                    const matchesAmount = (rowAmount >= minAmt && rowAmount <= maxAmt);
                    rows[i].style.display = 'none'; // ẩn hết trước
                    if (matchesSearch && matchesPayment && matchesStatus && matchesAmount) {
                        filteredRows.push(rows[i]);
                    }
                }

                currentPage = 1;
                renderPage();
                renderPagination();
            }

            function renderPage() {
                const start = (currentPage - 1) * PAGE_SIZE;
                const end = start + PAGE_SIZE;
                filteredRows.forEach((row, idx) => {
                    row.style.display = (idx >= start && idx < end) ? '' : 'none';
                });
                document.getElementById('pageFrom').textContent = filteredRows.length === 0 ? 0 : start + 1;
                document.getElementById('pageTo').textContent = Math.min(end, filteredRows.length);
                document.getElementById('visibleCount').textContent = filteredRows.length;
                let noResultRow = document.getElementById('noResultRow');
                if (filteredRows.length === 0) {
                    if (!noResultRow) {
                        noResultRow = document.createElement('tr');
                        noResultRow.id = 'noResultRow';
                        noResultRow.innerHTML = '<td colspan="6" class="px-6 py-10 text-center text-gray-400 italic font-medium">No orders found matching your criteria.</td>';
                        tableBody.appendChild(noResultRow);
                    }
                } else if (noResultRow) {
                    noResultRow.remove();
                }
            }

            function renderPagination() {
                const totalPages = Math.ceil(filteredRows.length / PAGE_SIZE);
                const controls = document.getElementById('paginationControls');
                controls.innerHTML = '';
                if (totalPages <= 1)
                    return;
                const btnClass = 'px-3 py-1 rounded text-sm font-medium border transition-colors ';
                const activeClass = 'bg-blue-600 text-white border-blue-600';
                const inactiveClass = 'bg-white text-gray-600 border-gray-300 hover:bg-gray-50';
                // Prev
                const prev = document.createElement('button');
                prev.textContent = '←';
                prev.className = btnClass + (currentPage === 1 ? 'opacity-40 cursor-not-allowed ' + inactiveClass : inactiveClass);
                prev.disabled = currentPage === 1;
                prev.onclick = () => {
                    currentPage--;
                    renderPage();
                    renderPagination();
                };
                controls.appendChild(prev);
                // Page numbers
                for (let i = 1; i <= totalPages; i++) {
                    const btn = document.createElement('button');
                    btn.textContent = i;
                    btn.className = btnClass + (i === currentPage ? activeClass : inactiveClass);
                    btn.onclick = (function (p) {
                        return function () {
                            currentPage = p;
                            renderPage();
                            renderPagination();
                        };
                    })(i);
                    controls.appendChild(btn);
                }

                // Next
                const next = document.createElement('button');
                next.textContent = '→';
                next.className = btnClass + (currentPage === totalPages ? 'opacity-40 cursor-not-allowed ' + inactiveClass : inactiveClass);
                next.disabled = currentPage === totalPages;
                next.onclick = () => {
                    currentPage++;
                    renderPage();
                    renderPagination();
                };
                controls.appendChild(next);
            }
            filterTable();


            // Gán sự kiện (keyup cho input, change cho select)
            [searchInput, minAmountInput, maxAmountInput].forEach(el => el.addEventListener('keyup', filterTable));
            [paymentFilter, statusFilter].forEach(el => el.addEventListener('change', filterTable));

            // Nút Reset
            resetBtn.addEventListener('click', () => {
                searchInput.value = '';
                paymentFilter.value = 'all';
                statusFilter.value = 'all';
                minAmountInput.value = '';
                maxAmountInput.value = '';
                filterTable();
            });
        }
        );
    </script>
</div>