<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--
  Trang chi tiết phiếu nhập kho (staff).
  Dữ liệu: receipt, receiptItems, listVariants, listSuppliers, listEmployees, inventoryByReceiptItemId, serialDraftMap.
  Chế độ param.mode = add cho phép thêm dòng / sửa header / nhập seri / xác nhận đưa hàng vào tồn kho; CONFIRMED chỉ xem.
--%>
<c:if test="${not empty sessionScope.msg}">
    <c:set var="isDangerToast" value="${sessionScope.msgType == 'danger'}"/>
    <div id="toast-detail"
         class="fixed top-6 left-1/2 z-[9999] w-[calc(100%-2rem)] max-w-md -translate-x-1/2 transition-all duration-300 ease-out">
        <div class="relative flex items-start gap-3 rounded-2xl border px-4 py-3 shadow-xl backdrop-blur-sm
             ${isDangerToast
               ? 'bg-white/95 border-red-100 text-red-700'
               : 'bg-white/95 border-emerald-100 text-emerald-700'}">
            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full
                 ${isDangerToast ? 'bg-red-100 text-red-600' : 'bg-emerald-100 text-emerald-600'}">
                <c:choose>
                    <c:when test="${isDangerToast}">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M12 9v3m0 4h.01M10.29 3.86l-7.5 13A1 1 0 003.66 18h16.68a1 1 0 00.87-1.5l-7.5-13a1 1 0 00-1.74 0z"/>
                        </svg>
                    </c:when>
                    <c:otherwise>
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M9 12l2 2 4-4m5 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="min-w-0 flex-1 pr-2">
                <p class="text-sm font-semibold text-gray-900">
                    ${isDangerToast ? 'Action failed' : 'Action completed'}
                </p>
                <p class="mt-1 text-sm leading-5 text-gray-600 break-words">
                    ${sessionScope.msg}
                </p>
            </div>
            <button type="button"
                    onclick="closeToastDetail()"
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-gray-400 transition hover:bg-gray-100 hover:text-gray-600">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M6 18L18 6M6 6l12 12"/>
                </svg>
            </button>
        </div>
    </div>
    <c:remove var="msg" scope="session"/>
    <c:remove var="msgType" scope="session"/>
    <%-- Toast flash: servlet ghi sessionScope.msg rồi redirect về đây --%>
    <script>
        /** Ẩn và xóa hộp thông báo góc màn hình (nút đóng hoặc hết giờ). */
        function closeToastDetail() {
            var t = document.getElementById('toast-detail');
            if (!t)
                return;
            t.classList.add('opacity-0', '-translate-y-3');
            setTimeout(function () {
                t.remove();
            }, 300);
        }

        setTimeout(closeToastDetail, 3200);
    </script>
</c:if>

<%-- Phần đầu phiếu: mã, tổng tiền, NCC, trạng thái; nút Confirm gắn validate seri + hộp thoại xác nhận --%>
<div id="receipt-top" class="bg-white rounded-xl shadow-lg p-6">
    <c:set var="hasReceiptItems" value="${not empty receiptItems}"/>
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">Inventory Receipt #${receipt.receipt_id}</h2>
        <div class="flex gap-2">
            <c:if test="${param.mode == 'add' && !isConfirmedReceipt}">
                <form id="confirm-receipt-form" action="${pageContext.request.contextPath}/staffservlet" method="post"
                      onsubmit="return validateManualSerialBeforeConfirm() && confirm('Confirm this receipt and add items to inventory? Serials must be SN- followed by 9 digits (e.g. SN-123456789).');">
                    <input type="hidden" name="action" value="inventoryReceiptConfirm"/>
                    <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
                    <button type="submit"
                            <c:if test="${!hasReceiptItems}">disabled</c:if>
                            title="${hasReceiptItems ? 'Confirm receipt' : 'Add at least one product before confirming'}"
                            class="inline-flex items-center px-3 py-2 rounded-lg font-medium ${hasReceiptItems ? 'text-emerald-50 bg-emerald-600 hover:bg-emerald-700' : 'text-gray-400 bg-gray-200 cursor-not-allowed'}">
                        Confirm & Add to Inventory
                    </button>
                </form>
            </c:if>
            <a href="${pageContext.request.contextPath}/staffservlet?action=inventoryReceiptManagement"
               class="inline-flex items-center px-3 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 font-medium">
                ← Receipt List
            </a>
        </div>
    </div>

    <c:set var="supplierName" value="—"/>
    <c:forEach items="${listSuppliers}" var="s">
        <c:if test="${s.supplier_id == receipt.supplier_id}">
            <c:set var="supplierName" value="${s.supplier_name}"/>
        </c:if>
    </c:forEach>
    <c:set var="empName" value="—"/>
    <c:forEach items="${listEmployees}" var="e">
        <c:if test="${e.employeeId == receipt.employee_id}">
            <c:set var="empName" value="${e.fullName}"/>
        </c:if>
    </c:forEach>
    <c:set var="createdByName" value="—"/>
    <c:forEach items="${listEmployees}" var="e">
        <c:if test="${e.employeeId == receipt.created_by}">
            <c:set var="createdByName" value="${e.fullName}"/>
        </c:if>
    </c:forEach>
    <c:if test="${createdByName == '—' && not empty empName}">
        <c:set var="createdByName" value="${empName}"/>
    </c:if>
    <c:set var="displayReceiptCode" value="${empty receipt.receipt_code ? 'IR-' : receipt.receipt_code}"/>
    <c:if test="${empty receipt.receipt_code}">
        <c:set var="displayReceiptCode" value="IR-${receipt.receipt_id}"/>
    </c:if>
    <c:set var="displayCreatedAt" value="${receipt.created_at != null ? receipt.created_at : receipt.import_date}"/>
    <c:set var="displayNote" value="${empty receipt.note ? 'No note yet.' : receipt.note}"/>
    <c:set var="isConfirmedReceipt" value="${not empty receipt.status and fn:toUpperCase(fn:trim(receipt.status)) == 'CONFIRMED'}"/>
    <c:set var="hideReceiptItems" value="false"/>
    <c:set var="formattedCreatedAt" value="—"/>
    <c:if test="${displayCreatedAt != null}">
        <fmt:formatDate value="${displayCreatedAt}" pattern="yyyy-MM-dd HH:mm:ss" var="formattedCreatedAt"/>
    </c:if>
    <c:set var="formattedImportDate" value="—"/>
    <c:if test="${receipt.import_date != null}">
        <fmt:formatDate value="${receipt.import_date}" pattern="yyyy-MM-dd HH:mm:ss" var="formattedImportDate"/>
    </c:if>

    <c:set var="calculatedTotalCost" value="${0}"/>
    <c:forEach items="${receiptItems}" var="it">
        <c:set var="calculatedTotalCost" value="${calculatedTotalCost + (it.import_price * it.quantity)}"/>
    </c:forEach>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 md:gap-8 mb-8 p-4 bg-gray-50 rounded-xl">
        <div class="flex flex-col gap-4">
            <div>
                <p class="text-xs font-semibold text-gray-500 uppercase">Receipt Code</p>
                <p class="font-medium text-gray-900">${displayReceiptCode}</p>
            </div>
            <div>
                <p class="text-xs font-semibold text-gray-500 uppercase">Total Cost</p>
                <p class="font-bold text-blue-600">
                    <fmt:formatNumber value="${calculatedTotalCost}" groupingUsed="true"/>₫
                </p>
            </div>
        </div>
        <div class="flex flex-col gap-4">
            <div>
                <p class="text-xs font-semibold text-gray-500 uppercase">Created At</p>
                <p class="font-medium text-gray-900">${formattedCreatedAt}</p>
            </div>
            <div>
                <p class="text-xs font-semibold text-gray-500 uppercase">Import Date</p>
                <p class="font-medium text-gray-900">${formattedImportDate}</p>
            </div>
        </div>
        <div class="flex flex-col gap-4">
            <div>
                <p class="text-xs font-semibold text-gray-500 uppercase">Supplier</p>
                <p class="font-medium text-gray-900">${supplierName}</p>
            </div>
            <div>
                <p class="text-xs font-semibold text-gray-500 uppercase">Status</p>
                <span class="inline-flex items-center px-2 py-1 rounded-md text-xs font-semibold
                      ${receipt.status == 'CONFIRMED' ? 'bg-emerald-100 text-emerald-700'
                        : (receipt.status == 'CANCELLED' ? 'bg-red-100 text-red-700' : 'bg-amber-100 text-amber-700')}">
                    ${empty receipt.status ? 'DRAFT' : receipt.status}
                </span>
            </div>
        </div>
        <div class="flex flex-col gap-4">
            <div>
                <p class="text-xs font-semibold text-gray-500 uppercase">Employee</p>
                <p class="font-medium text-gray-900">${empName}</p>
            </div>
        </div>
    </div>
    <div class="mb-8 p-4 bg-gray-50 rounded-xl">
        <p class="text-xs font-semibold text-gray-500 uppercase mb-1">Note</p>
        <p class="text-gray-700 whitespace-pre-wrap">${displayNote}</p>
    </div>

    <%-- Bảng nhập seri bắt buộc trước khi bấm Confirm: mỗi ô = một thiết bị, định dạng SN- + 9 số --%>
    <c:if test="${param.mode == 'add' && !isConfirmedReceipt}">
        <div id="manual-serial-panel" class="hidden mb-8 p-4 bg-blue-50 border border-blue-200 rounded-xl">
            <p class="text-sm font-semibold text-blue-800 mb-2">Serial numbers (required)</p>
            <p class="text-xs text-blue-700 mb-3 leading-relaxed">
                For each line below you get <strong>one box per unit</strong> — fill every box, each box is <strong>one device</strong>.
                Type <strong>SN-</strong> then exactly <strong>9 digits</strong>, no spaces. Example: <strong>SN-123456789</strong>.
            </p>
            <div class="space-y-3 max-h-72 overflow-y-auto pr-1">
                <c:forEach items="${receiptItems}" var="it" varStatus="st">
                    <c:set var="variantSkuMs" value="—"/>
                    <c:set var="variantProductNameMs" value=""/>
                    <c:forEach items="${listVariants}" var="v">
                        <c:if test="${v.variantId == it.variant_id}">
                            <c:set var="variantSkuMs" value="${v.sku}"/>
                            <c:set var="variantProductNameMs" value="${v.productName}"/>
                        </c:if>
                    </c:forEach>
                    <div class="p-3 rounded-lg bg-white border border-blue-100">
                        <p class="text-xs text-gray-700 mb-2">
                            #${st.count} <strong>${variantSkuMs}</strong>
                            <c:if test="${not empty variantProductNameMs}"> - ${variantProductNameMs}</c:if>
                            | Qty: <strong>${it.quantity}</strong> — enter <strong>${it.quantity}</strong> serials
                        </p>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-2">
                            <c:forEach begin="1" end="${it.quantity}" var="serialIdx">
                                <c:set var="serialDraftKey" value="${it.receipt_item_id}_${serialIdx}"/>
                                <input id="serial-input-${it.receipt_item_id}-${serialIdx}"
                                       type="text"
                                       name="serials_${it.receipt_item_id}_${serialIdx}"
                                       form="confirm-receipt-form"
                                       data-serial-input="true"
                                       data-item-id="${it.receipt_item_id}"
                                       data-item-label="${variantSkuMs}"
                                       value="${serialDraftMap[serialDraftKey]}"
                                       placeholder="Unit ${serialIdx}: SN-123456789"
                                       class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm"/>
                            </c:forEach>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <div id="receipt-header-edit-panel" class="hidden mb-8 p-4 bg-blue-50 border border-blue-200 rounded-xl">
        <h3 class="text-lg font-bold text-blue-900 mb-3">Edit Receipt Info</h3>
        <form action="${pageContext.request.contextPath}/staffservlet" method="post" class="space-y-4">
            <input type="hidden" name="action" value="inventoryReceiptEdit"/>
            <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
            <input type="hidden" name="mode" value="${param.mode}"/>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Receipt Code</label>
                    <input type="text" value="${displayReceiptCode}" disabled
                           class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-gray-50 text-gray-500"/>
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Supplier</label>
                    <%-- Chỉ NCC đang hoạt động; nếu phiếu gắn NCC đã ngưng thì vẫn hiện đúng 1 dòng đó (listSuppliersForReceiptSelect) --%>
                    <select name="supplier_id" class="w-full px-4 py-2 border border-gray-200 rounded-lg">
                        <c:forEach items="${listSuppliersForReceiptSelect}" var="s">
                            <option value="${s.supplier_id}" <c:if test="${s.supplier_id == receipt.supplier_id}">selected</c:if>>
                                ${s.supplier_name}<c:if test="${!s.is_active}"> (inactive)</c:if>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Status</label>
                    <select name="status" class="w-full px-4 py-2 border border-gray-200 rounded-lg">
                        <option value="DRAFT" <c:if test="${receipt.status == 'DRAFT'}">selected</c:if>>DRAFT</option>
                        <option value="CONFIRMED" <c:if test="${receipt.status == 'CONFIRMED'}">selected</c:if>>CONFIRMED</option>
                        <option value="CANCELLED" <c:if test="${receipt.status == 'CANCELLED'}">selected</c:if>>CANCELLED</option>
                    </select>
                </div>
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Note</label>
                <textarea name="note" rows="3" class="w-full px-4 py-2 border border-gray-200 rounded-lg">${receipt.note}</textarea>
            </div>
            <div class="flex items-center gap-2">
                <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium">Save</button>
                <button type="button" onclick="toggleReceiptHeaderEdit(false)" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 font-medium">Cancel</button>
            </div>
        </form>
    </div>

    <%-- Bảng các dòng hàng trên phiếu; cột thao tác (seri / sửa) chỉ khi đang nháp và mode add --%>
    <h3 class="text-lg font-bold text-gray-800 mb-3">Receipt Items</h3>
    <div class="overflow-x-auto rounded-lg border border-gray-200 mb-6">
            <table class="w-full text-sm text-left text-gray-600">
                <thead class="text-xs uppercase bg-gray-100 text-gray-700">
                    <tr>
                        <th class="px-4 py-3 w-14">ID</th>
                        <th class="px-4 py-3 min-w-[10rem]">SKU / Product</th>
                        <th class="px-4 py-3 text-right whitespace-nowrap">Import Price</th>
                        <th class="px-4 py-3 text-right whitespace-nowrap">Quantity</th>
                        <c:if test="${param.mode == 'add' && !isConfirmedReceipt}">
                            <th class="px-4 py-3 text-center">Action</th>
                        </c:if>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    <c:if test="${not hideReceiptItems}">
                    <c:forEach items="${receiptItems}" var="it" varStatus="st">
                        <c:set var="variantSku" value="—"/>
                        <c:set var="variantProductName" value=""/>
                        <c:forEach items="${listVariants}" var="v">
                            <c:if test="${v.variantId == it.variant_id}">
                                <c:set var="variantSku" value="${v.sku}"/>
                                <c:set var="variantProductName" value="${v.productName}"/>
                            </c:if>
                        </c:forEach>
                        <tr class="hover:bg-gray-50">
                            <td class="px-4 py-3 font-medium text-gray-500">#${st.count}</td>
                            <td class="px-4 py-3">
                                <span class="font-medium text-red-600">${variantSku}</span>
                                <c:if test="${not empty variantProductName}">
                                    <span class="text-gray-900"> ${variantProductName}</span>
                                </c:if>
                            </td>
                            <td class="px-4 py-3 text-right tabular-nums">
                                <fmt:formatNumber value="${it.import_price}" groupingUsed="true"/>₫
                            </td>
                            <td class="px-4 py-3 text-right tabular-nums">${it.quantity}</td>
                            <c:if test="${param.mode == 'add' && !isConfirmedReceipt}">
                                <td class="px-4 py-3 text-center">
                                    <div class="inline-flex items-center gap-2">
                                        <button type="button"
                                                class="inline-flex items-center text-blue-500 hover:text-blue-700"
                                                title="Open serial entry for this line"
                                                onclick="openManualSerialForItem('${it.receipt_item_id}')">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6M9 16h6M9 8h6M7 3h10a2 2 0 012 2v14a2 2 0 01-2 2H7a2 2 0 01-2-2V5a2 2 0 012-2z"/>
                                            </svg>
                                        </button>
                                        <button type="button"
                                                class="inline-flex items-center text-blue-700 hover:text-blue-900"
                                                title="Edit"
                                                onclick="editReceiptItem('${it.receipt_item_id}', '${it.variant_id}', '${it.import_price}', '${it.quantity}', '${receipt.receipt_id}')">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M16.862 3.487a1.875 1.875 0 112.652 2.652L10.5 15.153l-3.75 1.098 1.098-3.75 9.014-9.014z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5V19.125A1.875 1.875 0 0117.625 21H4.875A1.875 1.875 0 013 19.125V6.375A1.875 1.875 0 014.875 4.5H13.5"/>
                                            </svg>
                                        </button>
                                    </div>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                    </c:if>
                    <c:if test="${empty receiptItems}">
                        <tr>
                            <td colspan="${param.mode == 'add' && !isConfirmedReceipt ? 5 : 4}" class="px-4 py-8 text-center text-gray-500">
                                No items yet.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

    <c:if test="${param.mode == 'add' && !isConfirmedReceipt}">
        <div id="edit-item-panel" class="hidden mb-6 p-4 bg-blue-50 border border-blue-200 rounded-xl">
            <h3 id="edit-item-title" class="text-lg font-bold text-blue-900 mb-3">Edit Item</h3>
            <form action="${pageContext.request.contextPath}/staffservlet" method="post" class="space-y-4"
                  onsubmit="return validateEditReceiptItemForm();">
                <input type="hidden" name="action" value="receiptItemEdit"/>
                <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
                <input type="hidden" id="edit-receipt-item-id" name="receipt_item_id" value=""/>
                <div id="edit-serial-drafts-holder"></div>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-start">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Category</label>
                        <select id="edit-category-select" class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-white">
                            <option value="">— Select category —</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Product</label>
                        <select id="edit-product-select" class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-white" disabled>
                            <option value="">— Select product —</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">SKU / Variant</label>
                        <select id="edit-variant-select" name="variant_id" required class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-white" disabled>
                            <option value="">— Select variant —</option>
                        </select>
                        <p id="edit-variant-hint" class="mt-1 text-xs text-gray-500">Choose a category to filter products.</p>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Import Price (₫)</label>
                        <input id="edit-import-price" type="number" name="import_price" min="1" step="any" required class="w-full px-4 py-2 border border-gray-200 rounded-lg"/>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Quantity</label>
                        <input id="edit-quantity" type="number" name="quantity" min="1" required class="w-full px-4 py-2 border border-gray-200 rounded-lg"/>
                    </div>
                    <div class="md:col-span-2 flex items-center gap-2">
                        <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium">Update</button>
                        <button type="button" onclick="closeEditPanel()" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 font-medium">Cancel</button>
                    </div>
                </div>
            </form>
        </div>

        <h3 id="add-item-form" class="text-lg font-bold text-gray-800 mb-3">Add Item to Receipt</h3>
        <form id="add-item-receipt-form"
              action="${pageContext.request.contextPath}/staffservlet"
              method="post"
              onsubmit="return validateAddReceiptItemForm(this) && preventAddSpamSubmit(this)"
              class="p-4 bg-blue-50 rounded-xl border border-blue-200">
            <input type="hidden" name="action" value="receiptItemAdd"/>
            <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
            <div class="space-y-4" data-variant-picker data-selected-variant="">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-start">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Category</label>
                        <select data-category-select class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-white">
                            <option value="">— Select category —</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Product</label>
                        <select data-product-select class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-white" disabled>
                            <option value="">— Select product —</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">SKU / Variant</label>
                        <select name="variant_id" data-variant-select required class="w-full px-4 py-2 border border-gray-200 rounded-lg bg-white" disabled>
                            <option value="">— Select variant —</option>
                        </select>
                        <p data-variant-hint class="mt-1 text-xs text-gray-500">Choose a category to filter products.</p>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Import Price (₫)</label>
                        <input type="number" name="import_price" min="1" step="any" required placeholder="e.g. 1000" class="w-full px-4 py-2 border border-gray-200 rounded-lg import-price-input"/>
                        <p class="text-xs text-gray-500 mt-1 import-price-hint" data-default-class="text-xs text-gray-500 mt-1 import-price-hint"></p>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Quantity</label>
                        <input type="number" name="quantity" value="1" min="1" required class="w-full px-4 py-2 border border-gray-200 rounded-lg"/>
                    </div>
                    <div>
                        <button type="submit" data-add-submit-btn
                                class="w-full inline-flex items-center justify-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium">
                            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                            </svg>
                            Add
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </c:if>
    <c:if test="${param.mode == 'add' && isConfirmedReceipt}">
        <div class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-xl text-blue-900">
            This receipt is <strong>CONFIRMED</strong>. You can only view details; you cannot add, edit, or remove items.
        </div>
    </c:if>

    <%-- Nguồn dữ liệu ẩn: toàn bộ biến thể để JavaScript lọc cascade danh mục → sản phẩm → SKU --%>
    <select id="variant-master-data" class="hidden" aria-hidden="true" tabindex="-1">
        <c:forEach items="${listVariants}" var="v">
            <option value="${v.variantId}"
                    data-product-id="${v.productId}"
                    data-product-name="${v.productName}"
                    data-category-name="${v.categoryName}"
                    data-brand-name="${v.brandName}"
                    data-sku="${v.sku}"
                    data-selling-price="${v.sellingPrice}"
                    data-is-active="${v.isActive}">
                ${v.sku} - ${v.productName}
            </option>
        </c:forEach>
    </select>

    <script>
        /*
         * Script trang chi tiết phiếu nhập:
         * - Kiểm tra giá nhập / chống double-submit khi thêm dòng
         * - Panel seri tay + validate trước khi submit form xác nhận phiếu
         * - Form sửa dòng: cascade danh mục / sản phẩm / biến thể (thêm mới + sửa)
         * - Giữ bản nháp seri trong hidden khi submit sửa dòng (gửi serialDraft lên servlet)
         */
        /** Kiểm tra giá nhập > 0 trước khi gửi form thêm dòng hàng. */
        function validateAddReceiptItemForm(formEl) {
            var inp = formEl.querySelector('input.import-price-input[name="import_price"]')
                    || formEl.querySelector('input[name="import_price"]');
            if (!inp) {
                return true;
            }
            var v = Number(inp.value);
            if (!isFinite(v) || v <= 0) {
                alert('Import price must be greater than 0.');
                inp.focus();
                return false;
            }
            return true;
        }

        /** Khóa nút Add và đổi chữ sau lần bấm đầu để tránh gửi form trùng liên tiếp. */
        function preventAddSpamSubmit(formEl) {
            var btn = formEl.querySelector('button[data-add-submit-btn]');
            if (!btn) {
                return true;
            }
            if (btn.dataset.submitting === '1') {
                return false;
            }
            btn.dataset.submitting = '1';
            btn.disabled = true;
            btn.classList.add('opacity-70', 'cursor-not-allowed');
            btn.textContent = 'Adding...';
            return true;
        }

        /** Hiện/ẩn khối nhập seri và cuộn tới khối đó. */
        function toggleManualSerialPanel() {
            var panel = document.getElementById('manual-serial-panel');
            if (!panel) {
                return;
            }
            panel.classList.toggle('hidden');
            if (!panel.classList.contains('hidden')) {
                panel.scrollIntoView({behavior: 'smooth', block: 'center'});
            }
        }

        /**
         * Gọi trước khi submit "Confirm": duyệt mọi ô input[data-serial-input].
         * Kiểm tra không rỗng, đúng mẫu SN-9số, không trùng trong một dòng và không trùng giữa các dòng.
         */
        function validateManualSerialBeforeConfirm() {
            var inputs = Array.from(document.querySelectorAll('input[data-serial-input="true"]'));
            var allSet = new Set();
            var localSetsByItem = {};
            for (var i = 0; i < inputs.length; i++) {
                var input = inputs[i];
                var itemId = input.getAttribute('data-item-id') || '';
                var itemLabel = input.getAttribute('data-item-label') || 'SKU';
                var s = (input.value || '').trim().toUpperCase();

                if (!s) {
                    alert('Line SKU ' + itemLabel + ': some serials are empty. Please fill all boxes.');
                    input.focus();
                    return false;
                }
                if (!/^SN-\d{9}$/.test(s)) {
                    alert('Line SKU ' + itemLabel + ': "' + s + '" is not valid. Use SN- plus 9 digits, e.g. SN-123456789.');
                    input.focus();
                    return false;
                }
                if (!localSetsByItem[itemId]) {
                    localSetsByItem[itemId] = new Set();
                }
                if (localSetsByItem[itemId].has(s)) {
                    alert('Line SKU ' + itemLabel + ': serial "' + s + '" is duplicated on this line.');
                    input.focus();
                    return false;
                }
                if (allSet.has(s)) {
                    alert('Serial "' + s + '" is already used on another line. Each unit needs a unique serial.');
                    input.focus();
                    return false;
                }
                localSetsByItem[itemId].add(s);
                allSet.add(s);
            }
            return true;
        }

        /** Mở panel seri và focus ô đầu tiên của một dòng phiếu (khi redirect kèm serialItem). */
        function openManualSerialForItem(receiptItemId) {
            var panel = document.getElementById('manual-serial-panel');
            if (!panel) {
                return;
            }
            panel.classList.remove('hidden');
            panel.scrollIntoView({behavior: 'smooth', block: 'center'});
            var input = document.getElementById('serial-input-' + receiptItemId + '-1');
            if (input) {
                input.focus();
            }
        }

        /**
         * Trước khi gửi form sửa dòng: bắt buộc đủ danh mục / sản phẩm / biến thể, giá > 0, số lượng nguyên dương.
         * Đồng thời đổ giá trị seri đang nhập vào các input hidden serialDraft để servlet lưu bản nháp trong phiên.
         */
        function validateEditReceiptItemForm() {
            var categorySelect = document.getElementById('edit-category-select');
            var productSelect = document.getElementById('edit-product-select');
            var variantSelect = document.getElementById('edit-variant-select');
            var priceInput = document.getElementById('edit-import-price');
            var qtyInput = document.getElementById('edit-quantity');

            if (!categorySelect || !productSelect || !variantSelect || !priceInput || !qtyInput) {
                return true;
            }

            var categoryVal = (categorySelect.value || '').trim();
            var productVal = (productSelect.value || '').trim();
            var variantVal = (variantSelect.value || '').trim();
            var priceVal = Number(priceInput.value || 0);
            var qtyVal = Number(qtyInput.value || 0);

            if (!categoryVal) {
                alert('Please select a category before updating.');
                categorySelect.focus();
                return false;
            }
            if (!productVal) {
                alert('Please select a product before updating.');
                productSelect.focus();
                return false;
            }
            if (!variantVal) {
                alert('Please select a SKU/variant before updating.');
                variantSelect.focus();
                return false;
            }
            if (!isFinite(priceVal) || priceVal <= 0) {
                alert('Import price must be greater than 0.');
                priceInput.focus();
                return false;
            }
            if (!Number.isInteger(qtyVal) || qtyVal <= 0) {
                alert('Quantity must be a valid integer greater than 0.');
                qtyInput.focus();
                return false;
            }

            var holder = document.getElementById('edit-serial-drafts-holder');
            if (holder) {
                holder.innerHTML = '';
                var serialInputs = Array.from(document.querySelectorAll('input[data-serial-input="true"]'));
                for (var i = 0; i < serialInputs.length; i++) {
                    var input = serialInputs[i];
                    var itemId = input.getAttribute('data-item-id') || '';
                    var inputId = input.id || '';
                    var m = inputId.match(/-(\d+)$/);
                    var idx = m ? m[1] : '';
                    if (!itemId || !idx) {
                        continue;
                    }
                    var hidden = document.createElement('input');
                    hidden.type = 'hidden';
                    hidden.name = 'serialDraft';
                    hidden.value = itemId + '|' + idx + '|' + (input.value || '');
                    holder.appendChild(hidden);
                }
            }
            return true;
        }

        /** Hiện hoặc ẩn panel sửa phần đầu phiếu (NCC, ghi chú...). */
        function toggleReceiptHeaderEdit(show) {
            var panel = document.getElementById('receipt-header-edit-panel');
            if (!panel) {
                return;
            }
            if (show) {
                panel.classList.remove('hidden');
                panel.scrollIntoView({behavior: 'smooth', block: 'center'});
            } else {
                panel.classList.add('hidden');
            }
        }

        /** Đóng panel sửa một dòng hàng (không lưu). */
        function closeEditPanel() {
            var panel = document.getElementById('edit-item-panel');
            if (panel) {
                panel.classList.add('hidden');
            }
        }

        /** Lọc mảng theo khóa do hàm getKey trả về, giữ phần tử đầu tiên mỗi khóa. */
        function uniqueBy(items, getKey) {
            var map = new Map();
            items.forEach(function (item) {
                var key = getKey(item);
                if (!map.has(key)) {
                    map.set(key, item);
                }
            });
            return Array.from(map.values());
        }

        /**
         * Xây lại thẻ select: option rỗng + danh sách items; valueKey là tên thuộc tính làm value;
         * labelBuilder(item) tạo chữ hiển thị; onOptionBuilt tùy chọn để gắn data-* lên option.
         */
        function fillSelect(select, placeholder, items, valueKey, labelBuilder, selectedValue, onOptionBuilt) {
            select.innerHTML = '';
            var placeholderOption = document.createElement('option');
            placeholderOption.value = '';
            placeholderOption.textContent = placeholder;
            select.appendChild(placeholderOption);

            items.forEach(function (item) {
                var option = document.createElement('option');
                option.value = item[valueKey];
                option.textContent = labelBuilder(item);
                if (onOptionBuilt) {
                    onOptionBuilt(option, item);
                }
                if (String(item[valueKey]) === String(selectedValue)) {
                    option.selected = true;
                }
                select.appendChild(option);
            });

            select.disabled = items.length === 0;
        }

        (function () {
            /* --- Khối khởi tạo: đọc masterOptions từ #variant-master-data, gắn picker thêm dòng và panel sửa dòng --- */
            var masterOptions = Array.from(document.querySelectorAll('#variant-master-data option')).map(function (option) {
                var sp = parseFloat(option.dataset.sellingPrice);
                return {
                    id: option.value,
                    productId: option.dataset.productId || '',
                    productName: option.dataset.productName || 'Unknown product',
                    categoryName: option.dataset.categoryName || 'Uncategorized',
                    brandName: option.dataset.brandName || '',
                    sku: option.dataset.sku || '',
                    sellingPrice: isNaN(sp) ? 0 : sp,
                    isActive: option.dataset.isActive === 'true'
                };
            });
            var editVariants = masterOptions.filter(function (variant) {
                return variant.isActive;
            });

            /** Khi đổi danh mục ở form sửa dòng: lọc sản phẩm rồi gọi refresh biến thể. */
            function refreshEditProductsByCategory(categorySelect, productSelect, variantSelect, hint, selectedProductId, selectedVariantId) {
                var categoryName = categorySelect.value;
                var products = uniqueBy(editVariants.filter(function (variant) {
                    return variant.categoryName === categoryName;
                }), function (variant) {
                    return variant.productId;
                }).sort(function (a, b) {
                    return a.productName.localeCompare(b.productName);
                });

                fillSelect(productSelect, '— Select product —', products, 'productId', function (item) {
                    return item.productName + (item.brandName ? ' - ' + item.brandName : '');
                }, selectedProductId || '');

                if (!categoryName) {
                    productSelect.disabled = true;
                }

                refreshEditVariantsByProduct(categorySelect, productSelect, variantSelect, hint, selectedVariantId);
            }

            /** Sau khi chọn sản phẩm ở form sửa: đổ danh sách SKU và cập nhật dòng gợi ý. */
            function refreshEditVariantsByProduct(categorySelect, productSelect, variantSelect, hint, selectedVariantId) {
                var categoryName = categorySelect.value;
                var productId = productSelect.value;
                var variants = editVariants.filter(function (variant) {
                    return variant.categoryName === categoryName && String(variant.productId) === String(productId);
                }).sort(function (a, b) {
                    return a.sku.localeCompare(b.sku);
                });

                fillSelect(variantSelect, '— Select variant —', variants, 'id', function (item) {
                    return item.sku + ' - ' + item.productName;
                }, selectedVariantId || '');

                if (!categoryName || !productId) {
                    variantSelect.disabled = true;
                }

                if (!categoryName) {
                    hint.textContent = 'Choose a category to filter products.';
                } else if (!productId) {
                    hint.textContent = 'Choose a product to see matching SKUs.';
                } else if (variants.length === 0) {
                    hint.textContent = 'No active variants are available for this product.';
                } else {
                    hint.textContent = 'Showing ' + variants.length + ' variant(s) for the selected product.';
                }
            }

            /**
             * Mở panel sửa dòng phiếu: điền id dòng, giá, số lượng; chọn sẵn danh mục/sản phẩm/SKU theo variantId hiện tại.
             * Gắn sự kiện đổi danh mục / sản phẩm để lọc lại select.
             */
            window.editReceiptItem = function (itemId, variantId, oldPrice, oldQty) {
                var panel = document.getElementById('edit-item-panel');
                var title = document.getElementById('edit-item-title');
                var idInput = document.getElementById('edit-receipt-item-id');
                var priceInput = document.getElementById('edit-import-price');
                var qtyInput = document.getElementById('edit-quantity');
                var categorySelect = document.getElementById('edit-category-select');
                var productSelect = document.getElementById('edit-product-select');
                var variantSelect = document.getElementById('edit-variant-select');
                var hint = document.getElementById('edit-variant-hint');

                if (!panel || !idInput || !priceInput || !qtyInput || !categorySelect || !productSelect || !variantSelect || !hint) {
                    return;
                }

                idInput.value = itemId;
                priceInput.value = oldPrice;
                qtyInput.value = oldQty;
                title.textContent = 'Edit Item #' + itemId;

                var selectedVariant = editVariants.find(function (variant) {
                    return String(variant.id) === String(variantId);
                });

                var categories = uniqueBy(editVariants, function (variant) {
                    return variant.categoryName;
                }).sort(function (a, b) {
                    return a.categoryName.localeCompare(b.categoryName);
                });

                fillSelect(categorySelect, '— Select category —', categories, 'categoryName', function (item) {
                    return item.categoryName;
                }, selectedVariant ? selectedVariant.categoryName : '');

                refreshEditProductsByCategory(
                        categorySelect,
                        productSelect,
                        variantSelect,
                        hint,
                        selectedVariant ? selectedVariant.productId : '',
                        selectedVariant ? selectedVariant.id : ''
                        );

                categorySelect.onchange = function () {
                    refreshEditProductsByCategory(categorySelect, productSelect, variantSelect, hint, '', '');
                };
                productSelect.onchange = function () {
                    refreshEditVariantsByProduct(categorySelect, productSelect, variantSelect, hint, '');
                };

                panel.classList.remove('hidden');
                panel.scrollIntoView({behavior: 'smooth', block: 'center'});
            };

            /**
             * Khởi tạo một khối form có data-variant-picker: cascade category → product → variant,
             * đồng bộ gợi ý giá bán (tham chiếu) dưới ô giá nhập.
             */
            function initVariantPicker(container) {
                var categorySelect = container.querySelector('[data-category-select]');
                var productSelect = container.querySelector('[data-product-select]');
                var variantSelect = container.querySelector('[data-variant-select]');
                var hint = container.querySelector('[data-variant-hint]');
                var selectedVariantId = container.dataset.selectedVariant || '';

                var availableVariants = masterOptions.filter(function (variant) {
                    return variant.isActive || String(variant.id) === String(selectedVariantId);
                });

                var selectedVariant = availableVariants.find(function (variant) {
                    return String(variant.id) === String(selectedVariantId);
                });

                var categories = uniqueBy(availableVariants, function (variant) {
                    return variant.categoryName;
                }).sort(function (a, b) {
                    return a.categoryName.localeCompare(b.categoryName);
                });

                fillSelect(categorySelect, '— Select category —', categories, 'categoryName', function (item) {
                    return item.categoryName;
                }, selectedVariant ? selectedVariant.categoryName : '');

                /** Lọc sản phẩm theo danh mục đang chọn trong picker thêm dòng. */
                function refreshProducts(selectedProductId) {
                    var categoryName = categorySelect.value;
                    var products = uniqueBy(availableVariants.filter(function (variant) {
                        return variant.categoryName === categoryName;
                    }), function (variant) {
                        return variant.productId;
                    }).sort(function (a, b) {
                        return a.productName.localeCompare(b.productName);
                    });

                    fillSelect(productSelect, '— Select product —', products, 'productId', function (item) {
                        return item.productName + (item.brandName ? ' - ' + item.brandName : '');
                    }, selectedProductId || '');

                    if (!categoryName) {
                        productSelect.disabled = true;
                    }
                }

                /** Cập nhật dòng gợi ý giá bán lẻ theo biến thể đang chọn (chỉ tham khảo, không khóa max cứng). */
                function syncImportPriceLimit() {
                    var inp = container.querySelector('input.import-price-input[name="import_price"]');
                    var hintPrice = container.querySelector('.import-price-hint');
                    if (!inp) {
                        return;
                    }
                    var opt = variantSelect.options[variantSelect.selectedIndex];
                    var sp = (opt && opt.value && opt.dataset.sellingPrice !== undefined)
                            ? parseFloat(opt.dataset.sellingPrice) : NaN;
                    if (!isNaN(sp) && sp >= 0 && opt && opt.value) {
                        inp.removeAttribute('max');
                        inp.title = '';
                        if (hintPrice) {
                            hintPrice.textContent = 'Selling price reference: ' + Math.floor(sp).toLocaleString('vi-VN') + ' ₫';
                            hintPrice.className = 'text-xs text-gray-500 mt-1 import-price-hint';
                        }
                    } else {
                        inp.removeAttribute('max');
                        inp.title = '';
                        if (hintPrice) {
                            hintPrice.textContent = '';
                            hintPrice.className = hintPrice.getAttribute('data-default-class') || 'text-xs text-gray-500 mt-1 import-price-hint';
                        }
                    }
                }

                /** Lọc danh sách SKU theo danh mục + sản phẩm; gọi syncImportPriceLimit sau khi vẽ option. */
                function refreshVariants(selectedId) {
                    var categoryName = categorySelect.value;
                    var productId = productSelect.value;
                    var variants = availableVariants.filter(function (variant) {
                        return variant.categoryName === categoryName && String(variant.productId) === String(productId);
                    }).sort(function (a, b) {
                        return a.sku.localeCompare(b.sku);
                    });

                    fillSelect(variantSelect, '— Select variant —', variants, 'id', function (item) {
                        return item.sku + ' - ' + item.productName;
                    }, selectedId || '', function (option, item) {
                        option.dataset.sellingPrice = String(item.sellingPrice != null ? item.sellingPrice : 0);
                    });

                    if (!categoryName || !productId) {
                        variantSelect.disabled = true;
                    }

                    if (!categoryName) {
                        hint.textContent = 'Choose a category to filter products.';
                    } else if (!productId) {
                        hint.textContent = 'Choose a product to see matching SKUs.';
                    } else if (variants.length === 0) {
                        hint.textContent = 'No active variants are available for this product.';
                    } else {
                        hint.textContent = 'Showing ' + variants.length + ' variant(s) for the selected product.';
                    }
                    syncImportPriceLimit();
                }

                categorySelect.addEventListener('change', function () {
                    refreshProducts('');
                    refreshVariants('');
                });

                productSelect.addEventListener('change', function () {
                    refreshVariants('');
                });

                variantSelect.addEventListener('change', function () {
                    syncImportPriceLimit();
                });

                if (selectedVariant) {
                    refreshProducts(selectedVariant.productId);
                    refreshVariants(selectedVariant.id);
                } else {
                    refreshProducts('');
                    refreshVariants('');
                }
            }

            /* Mỗi form thêm dòng (có data-variant-picker) được khởi tạo cascade riêng */
            Array.from(document.querySelectorAll('[data-variant-picker]')).forEach(initVariantPicker);

            var serialItem = '${param.serialItem}';
            if (serialItem) {
                openManualSerialForItem(serialItem);
            }
        })();
    </script>
</div>
