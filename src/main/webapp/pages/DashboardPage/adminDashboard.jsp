<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="bg-gray-100 p-4 rounded-lg shadow-sm inline-block">
    <form action="adminservlet" method="GET" id="filterForm" class="flex items-center gap-3">
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
                <span class="mr-2">👤</span> Recent Customers
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
            <span class="mr-2">🛡️</span> Administrator List
        </h3>
    </div>
    <table class="w-full text-sm text-left text-gray-600">
        <thead class="text-xs uppercase bg-red-50 text-red-800 border-b">
            <tr>
                <th class="px-4 py-3 font-semibold">Admin Info</th>
                <th class="px-4 py-3 font-semibold text-center">Status</th>
                <th class="px-4 py-3 font-semibold text-center">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
            <c:forEach items="${listDataEmployee}" var="emp">
                <%-- Check if role is Admin --%>
                <c:if test="${emp.role.role_name eq 'Admin' || emp.role.role_name eq 'ADMIN'}">
                    <tr class="hover:bg-red-50 transition-colors">
                        <td class="px-4 py-3">
                            <div class="font-medium text-gray-900">${emp.fullName}</div>
                            <div class="text-xs text-gray-400">@${emp.username}</div>
                        </td>
                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${emp.status eq 'Active' || emp.status eq 'ACTIVE'}">
                                    <span class="px-2 py-1 text-[10px] font-bold text-green-700 bg-green-100 rounded-full">ACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-[10px] font-bold text-red-700 bg-red-100 rounded-full">LOCKED</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-4 py-3 text-center">
                             <a href="employeeservlet?action=detail&id=${emp.employeeId}" class="text-blue-600 hover:text-blue-900 font-bold text-xs uppercase">Detail</a>
                        </td>
                    </tr>
                </c:if>
            </c:forEach>
        </tbody>
    </table>
</div>

   <div class="relative overflow-x-auto bg-white shadow-md rounded-lg border border-orange-200">
    <div class="bg-orange-500 px-4 py-3">
        <h3 class="font-bold text-white flex items-center">
            <span class="mr-2">💼</span> Staff Members
        </h3>
    </div>
    <table class="w-full text-sm text-left text-gray-600">
        <thead class="text-xs uppercase bg-orange-50 text-orange-800 border-b">
            <tr>
                <th class="px-4 py-3 font-semibold">Staff Info</th>
                <th class="px-4 py-3 font-semibold">Contact</th>
                <th class="px-4 py-3 font-semibold text-center">Status</th>
                <th class="px-4 py-3 font-semibold text-center">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
            <c:forEach items="${listDataEmployee}" var="emp">
                <%-- Check if role is Staff --%>
                <c:if test="${emp.role.role_name eq 'Staff' || emp.role.role_name eq 'STAFF'}">
                    <tr class="hover:bg-orange-50 transition-colors">
                        <td class="px-4 py-3 font-medium text-gray-900">
                            ${emp.fullName}<br>
                            <span class="text-xs text-gray-400">@${emp.username}</span>
                        </td>
                        <td class="px-4 py-3 text-xs text-gray-500">
                            ${emp.email}<br>${emp.phoneNumber}
                        </td>
                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${emp.status eq 'Active' || emp.status eq 'ACTIVE'}">
                                    <span class="px-2 py-1 text-[10px] font-bold text-green-700 bg-green-100 rounded-full">ACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-[10px] font-bold text-red-700 bg-red-100 rounded-full">LOCKED</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-4 py-3 text-center">
                             <a href="employeeservlet?action=edit&id=${emp.employeeId}" class="text-orange-600 hover:text-orange-900 font-bold text-xs uppercase">Edit</a>
                        </td>
                    </tr>
                </c:if>
            </c:forEach>
        </tbody>
    </table>
</div>

</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="bg-white border border-gray-200 rounded-xl shadow-sm flex flex-col overflow-hidden">
        <div class="p-6 pb-0">
            <div class="flex justify-between items-center mb-4">
                <h5 class="text-xl font-bold text-gray-900">Voucher Status</h5>
                <button class="text-blue-600 text-sm hover:underline font-medium">Report</button>
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
                <h5 class="text-xl font-bold text-gray-900">Nguồn truy cập B</h5>
                <button class="text-blue-600 text-sm hover:underline font-medium">Xem báo cáo</button>
            </div>
        </div>
        <div id="pie-chart-2" class="mt-auto"></div>
        <div class="grid grid-cols-2 border-t border-gray-100 bg-gray-50/50">
            <div class="text-center py-3 border-r border-gray-100">
                <p class="text-xs text-gray-500 uppercase font-semibold">Trực tiếp</p>
                <p class="font-bold text-gray-900">5.8k</p>
            </div>
            <div class="text-center py-3">
                <p class="text-xs text-gray-500 uppercase font-semibold">Mạng xã hội</p>
                <p class="font-bold text-gray-900">0.5k</p>
            </div>
        </div>
    </div>
</div>
<script>
    window.addEventListener('load', function () {
        // --- BIỂU ĐỒ 1: VOUCHER STATUS ---
        const voucherEl = document.getElementById("pie-chart-voucher");
        if (voucherEl) {
            const voucherOptions = {
                series: [
                    ${activeV != null ? activeV : 0}, 
                    ${lockedV != null ? lockedV : 0}, 
                    ${expiredV != null ? expiredV : 0}
                ], 
                chart: { type: 'donut', height: 260 },
                labels: ['Active', 'Locked', 'Expired'],
                colors: ['#10B981', '#EF4444', '#9CA3AF'], 
                legend: { position: 'bottom' },
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

        // --- BIỂU ĐỒ 2: NGUỒN TRUY CẬP (Sửa lại ID và render đúng) ---
        const pie2El = document.getElementById("pie-chart-2");
        if (pie2El) {
            const pieOptions2 = {
                series: [60, 25, 15],
                chart: { type: 'donut', height: 260 },
                labels: ['Search', 'Referral', 'Organic'],
                colors: ['#7E3AF2', '#3F83F8', '#9CA3AF'],
                legend: { position: 'bottom' },
                plotOptions: { pie: { donut: { size: '70%' } } }
            };
            new ApexCharts(pie2El, pieOptions2).render();
        }

        // --- BIỂU ĐỒ SPARKLINE (DÙNG CHUNG HELPER) ---
        const sparklineOptions = (data, color) => ({
            series: [{name: 'Doanh thu', data: data}],
            chart: {type: 'area', height: 100, sparkline: {enabled: true}},
            stroke: {curve: 'smooth', width: 2},
            fill: {opacity: 0.3},
            colors: [color]
        });

        if(document.getElementById("chart-week")) {
            new ApexCharts(document.getElementById("chart-week"), sparklineOptions([30, 40, 35, 50, 49, 60, 70], '#1A56DB')).render();
        }
        
    }); // Kết thúc sự kiện load duy nhất
</script>