<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Sửa nhà cung cấp: POST supplier?action=update; cần supplier_id ẩn --%>
<div class="w-full flex flex-col items-center">
    <c:if test="${not empty sessionScope.msg}">
        <div class="mb-4 w-full max-w-xl">
            <div class="px-4 py-3 rounded-lg
                 ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 ring-1 ring-red-200/60' : 'bg-green-50 text-green-800 ring-1 ring-emerald-200/60'}">
                ${sessionScope.msg}
            </div>
        </div>
        <c:remove var="msg" scope="session"/>
        <c:remove var="msgType" scope="session"/>
    </c:if>

    <c:if test="${empty supplier}">
        <div class="w-full max-w-xl rounded-xl bg-white p-6 shadow-lg ring-1 ring-gray-100">
            <div class="text-red-700 font-medium mb-2">Supplier not found.</div>
            <a class="text-blue-600 hover:underline" href="staffservlet?action=supplierManagement">Back to list</a>
        </div>
    </c:if>

    <c:if test="${not empty supplier}">
        <div class="w-full max-w-xl rounded-xl bg-white p-6 sm:p-8 shadow-lg ring-1 ring-gray-100">
            <h2 class="text-xl font-bold mb-4">Edit supplier (#${supplier.supplier_id})</h2>

            <form action="supplier" method="POST" id="editSupplierForm"
                  onsubmit="return validateEditSupplierForm();">
                <input type="hidden" name="action" value="update"/>
                <input type="hidden" name="supplier_id" value="${supplier.supplier_id}"/>

                <div class="mb-3">
                    <label class="block mb-1 font-medium" for="editSupplierName">Supplier name *</label>
                    <input id="editSupplierName" type="text" name="supplier_name" required maxlength="100"
                           value="<c:out value='${supplier.supplier_name}'/>"
                           class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200" placeholder="Supplier name..."
                           title="Letters, digits, Vietnamese, spaces, &, . and -"
                           autocomplete="organization"
                           oninput="filterSupplierNameInput(this)">
                </div>

                <div class="mb-3">
                    <label class="block mb-1 font-medium" for="editSupplierPhone">Phone *</label>
                    <input id="editSupplierPhone" type="tel" name="phone" required maxlength="10" pattern="[0-9]{10}"
                           inputmode="numeric" title="Exactly 10 digits"
                           value="${supplier.phone}"
                           class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200" placeholder="10 digits"
                           oninput="this.value=this.value.replace(/[^0-9]/g,'')">
                </div>

                <div class="mb-3">
                    <label class="block mb-1 font-medium" for="editSupplierEmail">Email</label>
                    <input id="editSupplierEmail" type="email" name="email" maxlength="255"
                           value="<c:out value='${supplier.email}'/>"
                           class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200" placeholder="Email (optional)"
                           autocomplete="email"
                           onblur="if (this.value)
                                       this.value = this.value.trim().toLowerCase()">
                </div>

                <div class="mb-3">
                    <label class="block mb-1 font-medium" for="editSupplierAddress">Address *</label>
                    <textarea id="editSupplierAddress" name="address" rows="1" maxlength="500" required
                              class="supplier-address-textarea block w-full px-3 py-2 border rounded-lg text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-200 resize-none break-words"
                              placeholder="Warehouse / office address"
                              oninput="autoResizeAddress(this)"><c:out value="${supplier.address}"/></textarea>
                </div>

                <div class="mb-4">
                    <label class="inline-flex items-center gap-2">
                        <input type="checkbox" name="is_active" value="1" <c:if test="${supplier.is_active}">checked</c:if> class="w-4 h-4">
                            <span>Active</span>
                        </label>
                    </div>

                    <div class="flex flex-wrap gap-3 pt-1">
                        <button type="submit" class="px-5 py-2.5 rounded-lg bg-blue-600 text-white hover:bg-blue-700 border-0 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-1">
                            Save
                        </button>
                        <a href="staffservlet?action=supplierManagement" class="inline-flex items-center px-5 py-2.5 rounded-lg bg-gray-100 text-gray-800 hover:bg-gray-200 border-0 transition-colors">Cancel</a>
                    </div>
                </form>
            </div>
    </c:if>
</div>
<style>
    textarea.supplier-address-textarea {
        resize: none !important;
        min-height: 2.5rem;
        max-height: 12rem;
        overflow-y: hidden;
        line-height: 1.5;
    }
    textarea.supplier-address-textarea::-webkit-resizer {
        display: none;
    }
</style>
<script>
    /*
     * Form sửa nhà cung cấp: cùng logic resize địa chỉ và lọc/validate tên như form thêm.
     */
    /** Tự điều chỉnh chiều cao ô địa chỉ theo nội dung (có giới hạn tối đa). */
    function autoResizeAddress(el) {
        if (!el)
            return;
        var cap = 192;
        el.style.height = 'auto';
        el.style.overflowY = 'hidden';
        var sh = el.scrollHeight;
        if (sh > cap) {
            el.style.height = cap + 'px';
            el.style.overflowY = 'auto';
        } else {
            var h = sh < 40 ? 40 : sh;
            el.style.height = h + 'px';
        }
    }

    /** Sau khi trang load: căn chiều cao textarea địa chỉ (form edit thường có nội dung dài). */
    function initEditSupplierAddressOnLoad() {
        var ta = document.getElementById('editSupplierAddress');
        if (ta)
            autoResizeAddress(ta);
    }
    document.addEventListener('DOMContentLoaded', initEditSupplierAddressOnLoad);

    /** Loại bỏ ký tự không hợp lệ trong tên khi đang gõ (đồng bộ servlet). */
    function filterSupplierNameInput(el) {
        if (!el)
            return;
        try {
            el.value = el.value.replace(/[^a-zA-Z0-9À-ỹ\s&.-]/g, '');
        } catch (e) {
            el.value = el.value.replace(/[^a-zA-Z0-9À-ỹ\s&.-]/g, '');
        }
    }

    /** Kiểm tra tên trước submit: không rỗng, đúng bộ ký tự; báo lỗi bằng API hợp lệ của trình duyệt. */
    function validateSupplierNameField(el) {
        if (!el)
            return true;
        var v = el.value.replace(/^\s+|\s+$/g, '');
        el.value = v;
        if (!v.length) {
            el.setCustomValidity('Please enter supplier name.');
            el.reportValidity();
            return false;
        }
        var ok;
        try {
            ok = /^[a-zA-Z0-9À-ỹ\s&.-]+$/.test(v);
        } catch (e) {
            ok = /^[a-zA-Z0-9À-ỹ\s&.-]+$/.test(v);
        }
        if (!ok) {
            el.setCustomValidity('Invalid name. Letters, digits, Vietnamese, spaces, &, . and - only.');
            el.reportValidity();
            return false;
        }
        el.setCustomValidity('');
        return true;
    }

    function validateSupplierPhoneField(el) {
        if (!el)
            return false;
        var p = (el.value || '').replace(/\D/g, '');
        el.value = p;
        if (p.length !== 10 || !/^[0-9]{10}$/.test(p)) {
            el.setCustomValidity('Phone must be exactly 10 digits.');
            el.reportValidity();
            return false;
        }
        el.setCustomValidity('');
        return true;
    }

    function validateSupplierAddressField(el) {
        if (!el)
            return false;
        if (!(el.value || '').trim().length) {
            el.setCustomValidity('Please enter address.');
            el.reportValidity();
            return false;
        }
        el.setCustomValidity('');
        return true;
    }

    function validateEditSupplierForm() {
        if (!validateSupplierNameField(document.getElementById('editSupplierName')))
            return false;
        if (!validateSupplierPhoneField(document.getElementById('editSupplierPhone')))
            return false;
        if (!validateSupplierAddressField(document.getElementById('editSupplierAddress')))
            return false;
        var emailEl = document.getElementById('editSupplierEmail');
        if (emailEl && emailEl.value.replace(/^\s+|\s+$/g, '').length > 0) {
            emailEl.value = emailEl.value.trim().toLowerCase();
            if (!emailEl.checkValidity()) {
                emailEl.reportValidity();
                return false;
            }
        }
        return true;
    }
</script>