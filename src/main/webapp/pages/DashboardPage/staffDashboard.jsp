<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
    <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-5">
        <div class="flex justify-between items-start mb-4">
            <div>
                <h5 class="text-sm font-medium text-gray-500 uppercase">Doanh thu Tuần</h5>
                <h3 class="text-2xl font-bold text-gray-900 mt-1">24.5M VNĐ</h3>
            </div>
            <span class="bg-green-100 text-green-800 text-xs font-semibold px-2.5 py-0.5 rounded">+12%</span>
        </div>
        <div id="chart-week"></div>
    </div>

    <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-5">
        <div class="flex justify-between items-start mb-4">
            <div>
                <h5 class="text-sm font-medium text-gray-500 uppercase">Doanh thu Tháng</h5>
                <h3 class="text-2xl font-bold text-gray-900 mt-1">185.0M VNĐ</h3>
            </div>
            <span class="bg-green-100 text-green-800 text-xs font-semibold px-2.5 py-0.5 rounded">+5.4%</span>
        </div>
        <div id="chart-month"></div>
    </div>

    <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-5">
        <div class="flex justify-between items-start mb-4">
            <div>
                <h5 class="text-sm font-medium text-gray-500 uppercase">Doanh thu Năm</h5>
                <h3 class="text-2xl font-bold text-gray-900 mt-1">2.1B VNĐ</h3>
            </div>
            <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-0.5 rounded">2026</span>
        </div>
        <div id="chart-year"></div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    
    <div class="bg-white border border-gray-200 rounded-xl shadow-sm flex flex-col overflow-hidden">
        <div class="p-6 pb-0"> <div class="flex justify-between pb-4 mb-2 border-b border-gray-100">
                <div class="flex items-center">
                    <div class="w-12 h-12 bg-blue-50 border border-blue-100 flex items-center justify-center rounded-full me-3 text-blue-600">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
                    </div>
                    <div>
                        <h5 class="text-2xl font-bold text-gray-900">3.4k</h5>
                        <p class="text-sm text-gray-500">Khách hàng tiềm năng / tuần</p>
                    </div>
                </div>
                <span class="bg-green-100 text-green-800 text-xs font-medium px-2 py-1 rounded-lg self-start">↑ 42.5%</span>
            </div>
        </div>
        <div id="column-chart" class="mt-auto"></div>
    </div>

    <div class="bg-white border border-gray-200 rounded-xl shadow-sm flex flex-col overflow-hidden">
        <div class="p-6 pb-0">
            <div class="flex justify-between items-center mb-4">
                <h5 class="text-xl font-bold text-gray-900">Nguồn truy cập</h5>
                <button class="text-blue-600 text-sm hover:underline font-medium">Xem báo cáo</button>
            </div>
        </div>
        <div id="pie-chart" class="mt-auto"></div>
        
        <div class="grid grid-cols-2 border-t border-gray-100 bg-gray-50/50">
            <div class="text-center py-3 border-r border-gray-100">
                <p class="text-xs text-gray-500 uppercase font-semibold">Trực tiếp</p>
                <p class="font-bold text-gray-900">1.2k</p>
            </div>
            <div class="text-center py-3">
                <p class="text-xs text-gray-500 uppercase font-semibold">Mạng xã hội</p>
                <p class="font-bold text-gray-900">2.2k</p>
            </div>
        </div>
    </div>
</div>

<script>
    window.addEventListener('load', function() {
        // --- 1. BIỂU ĐỒ HÀNG TRÊN (SPARKLINE) ---
        const sparklineOptions = (data, color) => ({
            series: [{ name: 'Doanh thu', data: data }],
            chart: { type: 'area', height: 100, sparkline: { enabled: true } },
            stroke: { curve: 'smooth', width: 2 },
            fill: { opacity: 0.3 },
            colors: [color]
        });

        new ApexCharts(document.getElementById("chart-week"), sparklineOptions([30, 40, 35, 50, 49, 60, 70], '#1A56DB')).render();
        new ApexCharts(document.getElementById("chart-month"), sparklineOptions([150, 230, 195, 260, 210, 280, 350], '#10B981')).render();
        new ApexCharts(document.getElementById("chart-year"), sparklineOptions([1200, 1500, 1100, 1800, 2100, 1900, 2500], '#7E3AF2')).render();

        // --- 2. BIỂU ĐỒ CỘT (LEADS) ---
        const columnOptions = {
            series: [{ name: 'Leads', data: [44, 55, 57, 56, 61, 58, 63] }],
            chart: { type: 'bar', height: 200, toolbar: {show: false} },
            plotOptions: { bar: { columnWidth: '50%', borderRadius: 4 } },
            colors: ['#1A56DB'],
            xaxis: { categories: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'] }
        };
        new ApexCharts(document.getElementById("column-chart"), columnOptions).render();

        // --- 3. BIỂU ĐỒ TRÒN (TRAFFIC) ---
        const pieOptions = {
            series: [35, 45, 20],
            chart: { type: 'donut', height: 260 },
            labels: ['Direct', 'Social', 'Email'],
            colors: ['#1A56DB', '#10B981', '#F59E0B'],
            legend: { position: 'bottom' },
            plotOptions: { pie: { donut: { size: '70%' } } }
        };
        new ApexCharts(document.getElementById("pie-chart"), pieOptions).render();
    });
</script>