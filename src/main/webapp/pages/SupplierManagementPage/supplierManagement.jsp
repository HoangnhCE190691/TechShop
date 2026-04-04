<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  Danh sách nhà cung cấp: GET staffservlet?action=supplierManagement (tìm keyword).
  Thao tác CRUD / kích hoạt qua supplier?action=...
--%>
<c:if test="${not empty sessionScope.msg}">
    <%-- Flash sau redirect: servlet gán sessionScope.msg + msgType --%>
    <div id="supplier-toast"
         class="fixed top-6 left-1/2 -translate-x-1/2 z-[9999] w-[420px] max-w-[calc(100vw-2rem)] rounded-2xl border shadow-lg
         ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-gray-50 text-gray-800 border-emerald-200'}">
        <div class="px-5 py-4 pr-12 relative">
            <button type="button"
                    onclick="document.getElementById('supplier-toast').remove()"
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
                        ${sessionScope.msgType == 'danger' ? 'Failed' : 'Success'}
                    </p>
                    <p class="text-sm ${sessionScope.msgType == 'danger' ? 'text-red-700' : 'text-gray-500'}">
                        ${sessionScope.msg}
                    </p>
                </div>
            </div>
        </div>
    </div>
    <c:remove var="msg" scope="session" />
    <c:remove var="msgType" scope="session" />

    <script>
        /*
         * Toast một lần: servlet redirect xong set session msg rồi JSP render.
         * Tự ẩn sau vài giây để không che bảng / nút.
         */
        /** Gỡ phần tử toast khỏi DOM nếu vẫn còn (gọi bởi timer). */
        function removeSupplierFlashToastIfPresent() {
            var toast = document.getElementById('supplier-toast');
            if (toast) {
                toast.remove();
            }
        }
        /** Lên lịch ẩn toast flash sau 3500 ms. */
        function scheduleSupplierFlashToastAutoHide() {
            setTimeout(removeSupplierFlashToastIfPresent, 3500);
        }
        scheduleSupplierFlashToastAutoHide();
    </script>
</c:if>

<div class="bg-white rounded-xl shadow-lg p-5">
    <%-- Thanh tìm (staffservlet) + nút thêm (supplier?action=add) --%>
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">
        <form class="w-full md:w-1/3 md:max-w-[520px]" action="staffservlet" method="GET">
            <input type="hidden" name="action" value="supplierManagement">

            <div class="relative">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                </span>
                <input type="text"
                       name="keyword"
                       class="w-full pl-10 pr-10 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Search by name or phone..."
                       value="${param.keyword}">
                <c:if test="${not empty param.keyword}">
                    <a href="staffservlet?action=supplierManagement"
                       class="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                    </a>
                </c:if>
            </div>
        </form>

        <a href="supplier?action=add"
           class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors shadow-sm whitespace-nowrap text-center">
            + Add supplier
        </a>
    </div>

    <%-- Bảng: colgroup cố định % chiều rộng cột; hàng rỗng khi listSuppliers trống --%>
    <div class="overflow-x-auto rounded-xl border border-gray-200/90 bg-white shadow-sm ring-1 ring-gray-100/80">
        <table class="w-full table-fixed text-sm text-left text-gray-700">
            <colgroup>
                <col style="width:6%"/>
                <col style="width:34%"/>
                <col style="width:14%"/>
                <col style="width:16%"/>
                <col style="width:14%"/>
                <col style="width:16%"/>
            </colgroup>
            <thead>
                <tr class="border-b border-gray-200 bg-gradient-to-b from-slate-50 to-gray-50/90 text-[11px] uppercase tracking-wide text-slate-600">
                    <th scope="col" class="px-3 py-3.5 font-semibold">ID</th>
                    <th scope="col" class="px-3 py-3.5 font-semibold">Supplier name</th>
                    <th scope="col" class="px-3 py-3.5 font-semibold whitespace-nowrap">Phone</th>
                    <th scope="col" class="px-3 py-3.5 font-semibold whitespace-nowrap">Date added</th>
                    <th scope="col" class="px-2 py-3.5 font-semibold text-center">Status</th>
                    <th scope="col" class="px-2 py-3.5 font-semibold text-center">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                <c:forEach items="${listSuppliers != null ? listSuppliers : []}" var="s">
                    <tr class="align-middle odd:bg-white even:bg-slate-50/40 hover:bg-blue-50/40 transition-colors">
                        <td class="px-3 py-3 font-mono text-xs text-slate-600 tabular-nums">#${s.supplier_id}</td>
                        <td class="px-3 py-3 font-medium text-gray-900 min-w-0">
                            <span class="block truncate" title="<c:out value='${s.supplier_name}'/>"><c:out value="${s.supplier_name}"/></span>
                        </td>
                        <td class="px-3 py-3 whitespace-nowrap font-mono text-sm text-slate-700 tabular-nums">${s.phone}</td>
                        <td class="px-3 py-3 whitespace-nowrap text-sm text-slate-700 tabular-nums">
                            <c:choose>
                                <c:when test="${not empty s.createdAt}">
                                    <fmt:formatDate value="${s.createdAt}" pattern="dd/MM/yyyy" type="date" timeZone="Asia/Ho_Chi_Minh"/>
                                </c:when>
                                <c:otherwise><span class="text-gray-400">—</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-2 py-3 text-center">
                            <c:choose>
                                <c:when test="${s.is_active}">
                                    <span class="inline-flex items-center justify-center px-2.5 py-1 text-[11px] font-semibold rounded-full text-emerald-800 bg-emerald-100/90 border border-emerald-200/60 whitespace-nowrap">
                                        Active
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="inline-flex items-center justify-center px-2.5 py-1 text-[11px] font-semibold rounded-full text-red-800 bg-red-100/90 border border-red-200/60 whitespace-nowrap">
                                        Inactive
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-2 py-3 text-center">
                            <div class="inline-flex flex-wrap items-center justify-center gap-2">
                                <a href="supplier?action=view&id=${s.supplier_id}" title="View"
                                   class="inline-flex items-center justify-center rounded-lg p-2 text-blue-600 hover:bg-gray-100/90 transition-colors"
                                   aria-label="View">
                                    <svg class="w-[18px] h-[18px]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                                </a>
                                <a href="supplier?action=edit&id=${s.supplier_id}" title="Edit"
                                   class="inline-flex items-center justify-center rounded-lg p-2 text-orange-500 hover:bg-gray-100/90 transition-colors"
                                   aria-label="Edit">
                                    <svg class="w-[18px] h-[18px]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                                </a>
                                <c:choose>
                                    <c:when test="${s.is_active}">
                                        <a href="supplier?action=deactivate&id=${s.supplier_id}" title="Deactivate"
                                           class="inline-flex items-center justify-center rounded-lg p-2 text-amber-700 hover:bg-gray-100/90 transition-colors"
                                           aria-label="Deactivate">
                                            <svg class="w-[18px] h-[18px]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/></svg>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="supplier?action=restore&id=${s.supplier_id}" title="Restore"
                                           class="inline-flex items-center justify-center rounded-lg p-2 text-emerald-600 hover:bg-gray-100/90 transition-colors"
                                           aria-label="Restore">
                                            <svg class="w-[18px] h-[18px]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                                <a href="supplier?action=delete&id=${s.supplier_id}" title="Delete"
                                   onclick="return confirm('Delete supplier #${s.supplier_id}? Deletion will fail if this supplier is used on import receipts.');"
                                   class="inline-flex items-center justify-center rounded-lg p-2 text-red-600 hover:bg-gray-100/90 transition-colors"
                                   aria-label="Delete">
                                    <svg class="w-[18px] h-[18px]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty listSuppliers}">
                    <tr>
                        <td colspan="6" class="px-4 py-12 text-center text-gray-500 italic">
                            No suppliers yet.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>
