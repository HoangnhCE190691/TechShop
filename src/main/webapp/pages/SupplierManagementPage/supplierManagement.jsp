<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Toast notification sau CRUD --%>
<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">
        <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2
            ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-green-50 text-green-800 border-green-200'}">
            <span class="font-bold uppercase tracking-wider text-sm">${sessionScope.msg}</span>
        </div>
    </div>
    <c:remove var="msg" scope="session" />
    <c:remove var="msgType" scope="session" />
    <script>setTimeout(() => document.getElementById('toast-notification')?.remove(), 3000);</script>
</c:if>

<!-- ===== STATISTICS ===== -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">

    <c:set var="total" value="${listSuppliers != null ? listSuppliers.size() : 0}" />
    <c:set var="activeCount" value="0" />

    <c:forEach items="${listSuppliers != null ? listSuppliers : []}" var="s">
        <c:if test="${s.is_active}">
            <c:set var="activeCount" value="${activeCount + 1}" />
        </c:if>
    </c:forEach>

    <div class="bg-white rounded-xl shadow-sm p-4 border-l-4 border-blue-500">
        <p class="text-gray-500 text-sm">Tổng NCC</p>
        <h3 class="text-2xl font-bold text-blue-600">${total}</h3>
    </div>

    <div class="bg-white rounded-xl shadow-sm p-4 border-l-4 border-green-500">
        <p class="text-gray-500 text-sm">Đang Hợp Tác</p>
        <h3 class="text-2xl font-bold text-green-600">${activeCount}</h3>
    </div>

    <div class="bg-white rounded-xl shadow-sm p-4 border-l-4 border-red-500">
        <p class="text-gray-500 text-sm">Ngừng Hợp Tác</p>
        <h3 class="text-2xl font-bold text-red-600">${total - activeCount}</h3>
    </div>
</div>

<!-- ===== SEARCH + ADD ===== -->
<div class="bg-white rounded-xl shadow-lg p-5">

    <div class="flex justify-between mb-5">

        <form class="w-1/2" action="staffservlet" method="GET">
            <input type="hidden" name="action" value="supplierManagement">
            <input type="text" name="keyword"
                   class="w-full px-4 py-2 border rounded-lg"
                   placeholder="Tìm nhà cung cấp theo tên hoặc số điện thoại..."
                   value="${param.keyword}">
        </form>

        <a href="supplier?action=add"
           class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors shadow-sm">
           + Thêm Nhà Cung Cấp
        </a>
    </div>

    <!-- ===== HEADER ROW (đều cột) ===== -->
    <div class="grid grid-cols-[60px_1fr_140px_140px_180px] gap-4 py-3 px-4 bg-gray-100 rounded-t-lg border border-gray-200 border-b-0 font-bold text-gray-700 items-center">
        <div>ID</div>
        <div>SUPPLIER</div>
        <div>PHONE</div>
        <div>STATUS</div>
        <div class="text-right">ACTION</div>
    </div>

    <!-- ===== LIST ===== -->
    <div class="border border-gray-200 border-t-0 rounded-b-lg divide-y divide-gray-200">
        <c:forEach items="${listSuppliers != null ? listSuppliers : []}" var="s">
            <div class="grid grid-cols-[60px_1fr_140px_140px_180px] gap-4 py-4 px-4 items-center hover:bg-gray-50/50">
                <div class="font-mono text-gray-600">#${s.supplier_id}</div>
                <div>
                    <p class="font-bold text-gray-900">${s.supplier_name}</p>
                </div>
                <div class="text-gray-700 font-medium">${s.phone}</div>
                <div>
                    <c:choose>
                        <c:when test="${s.is_active}">
                            <span class="inline-block px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">Đang hợp tác</span>
                        </c:when>
                        <c:otherwise>
                            <span class="inline-block px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">Ngừng hợp tác</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="flex gap-3 justify-end text-sm">
                    <a href="supplier?action=view&id=${s.supplier_id}"
                       class="text-gray-600 hover:text-gray-800 font-medium underline">Xem</a>
                    <span class="text-gray-300">|</span>
                    <a href="supplier?action=edit&id=${s.supplier_id}"
                       class="text-blue-600 hover:text-blue-800 font-medium underline">Sửa</a>
                    <span class="text-gray-300">|</span>
                    <c:choose>
                        <c:when test="${s.is_active}">
                            <a href="supplier?action=deactivate&id=${s.supplier_id}"
                               class="text-amber-600 hover:text-amber-800 font-medium underline">Dừng</a>
                        </c:when>
                        <c:otherwise>
                            <a href="supplier?action=restore&id=${s.supplier_id}"
                               class="text-emerald-600 hover:text-emerald-800 font-medium underline">Mở lại</a>
                        </c:otherwise>
                    </c:choose>
                    <span class="text-gray-300">|</span>
                    <a href="supplier?action=delete&id=${s.supplier_id}"
                       onclick="return confirm('Xóa nhà cung cấp #${s.supplier_id}? Nếu đang được dùng trong phiếu nhập sẽ không xóa được.');"
                       class="text-red-600 hover:text-red-800 font-medium underline">Xóa</a>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty listSuppliers}">
            <div class="py-12 text-center text-gray-500">
                Không tìm thấy dữ liệu nhà cung cấp nào.
            </div>
        </c:if>
    </div>
</div>
