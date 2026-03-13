<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <script>
        function closeToastDetail() {
            var t = document.getElementById('toast-detail');
            if (!t) return;
            t.classList.add('opacity-0', '-translate-y-3');
            setTimeout(function () {
                t.remove();
            }, 300);
        }

        setTimeout(closeToastDetail, 3200);
    </script>
</c:if>

<div class="bg-white rounded-xl shadow-lg p-6">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">Inventory Receipt #${receipt.receipt_id}</h2>
        <div class="flex gap-2">
            <form action="${pageContext.request.contextPath}/staffservlet" method="post"
                  onsubmit="return confirm('Confirm this receipt and generate inventory from its items?');">
                <input type="hidden" name="action" value="inventoryReceiptConfirm"/>
                <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
                <button type="submit"
                        class="inline-flex items-center px-3 py-2 text-emerald-50 bg-emerald-600 rounded-lg hover:bg-emerald-700 font-medium">
                    Confirm & Generate Inventory
                </button>
            </form>
            <a href="${pageContext.request.contextPath}/staffservlet?action=inventoryReceiptEdit&id=${receipt.receipt_id}" class="inline-flex items-center px-3 py-2 text-amber-600 bg-amber-50 rounded-lg hover:bg-amber-100 font-medium">Edit</a>
            <a href="${pageContext.request.contextPath}/staffservlet?action=inventoryReceiptManagement" class="inline-flex items-center px-3 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 font-medium">← Receipt List</a>
        </div>
    </div>

    <c:set var="supplierName" value="—"/>
    <c:forEach items="${listSuppliers}" var="s"><c:if test="${s.supplier_id == receipt.supplier_id}"><c:set var="supplierName" value="${s.supplier_name}"/></c:if></c:forEach>
    <c:set var="empName" value="—"/>
    <c:forEach items="${listEmployees}" var="e"><c:if test="${e.employeeId == receipt.employee_id}"><c:set var="empName" value="${e.fullName}"/></c:if></c:forEach>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8 p-4 bg-gray-50 rounded-xl">
        <div><p class="text-xs font-semibold text-gray-500 uppercase">Supplier</p><p class="font-medium text-gray-900">${supplierName}</p></div>
        <div><p class="text-xs font-semibold text-gray-500 uppercase">Employee</p><p class="font-medium text-gray-900">${empName}</p></div>
        <div><p class="text-xs font-semibold text-gray-500 uppercase">Total Cost</p><p class="font-bold text-blue-600"><fmt:formatNumber value="${receipt.total_cost}" groupingUsed="true"/>₫</p></div>
    </div>

    <h3 class="text-lg font-bold text-gray-800 mb-3">Receipt Items</h3>
    <div class="overflow-x-auto rounded-lg border border-gray-200 mb-6">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-100 text-gray-700">
                <tr>
                    <th class="px-4 py-3">ID</th>
                    <th class="px-4 py-3">SKU / Product</th>
                    <th class="px-4 py-3 text-right">Import Price</th>
                    <th class="px-4 py-3 text-center">Quantity</th>
                    <th class="px-4 py-3 text-center">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                <c:forEach items="${receiptItems}" var="it">
                    <c:set var="variantSku" value="—"/>
                    <c:set var="variantProductName" value=""/>
                    <c:forEach items="${listVariants}" var="v"><c:if test="${v.variantId == it.variant_id}"><c:set var="variantSku" value="${v.sku}"/><c:set var="variantProductName" value="${v.productName}"/></c:if></c:forEach>
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 font-medium text-gray-500">#${it.receipt_item_id}</td>
                        <td class="px-4 py-3"><span class="font-medium text-red-600">${variantSku}</span><c:if test="${not empty variantProductName}"> <span class="text-gray-500">${variantProductName}</span></c:if></td>
                        <td class="px-4 py-3 text-right"><fmt:formatNumber value="${it.import_price}" groupingUsed="true"/>₫</td>
                        <td class="px-4 py-3 text-center">${it.quantity}</td>
                        <td class="px-4 py-3">
                            <a href="${pageContext.request.contextPath}/inventory?action=add&receipt_item_id=${it.receipt_item_id}"
                               class="text-blue-600 hover:underline mr-2">Create IMEI</a>
                            <a href="${pageContext.request.contextPath}/staffservlet?action=inventoryReceiptDetail&id=${receipt.receipt_id}&editItemId=${it.receipt_item_id}" class="text-amber-600 hover:underline mr-2">Edit</a>
                            <form action="${pageContext.request.contextPath}/staffservlet" method="post" class="inline" onsubmit="return confirm('Delete this item?');">
                                <input type="hidden" name="action" value="receiptItemDelete"/>
                                <input type="hidden" name="receipt_item_id" value="${it.receipt_item_id}"/>
                                <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
                                <button type="submit" class="text-red-600 hover:underline">Delete</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty receiptItems}">
                    <tr><td colspan="5" class="px-4 py-8 text-center text-gray-500">No items yet. Add one below.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <c:if test="${not empty param.editItemId}">
        <c:set var="editItem" value="${null}"/>
        <c:forEach items="${receiptItems}" var="it"><c:if test="${it.receipt_item_id == param.editItemId}"><c:set var="editItem" value="${it}"/></c:if></c:forEach>
        <c:if test="${not empty editItem}">
            <h3 class="text-lg font-bold text-gray-800 mb-3">Edit Item #${editItem.receipt_item_id}</h3>
            <form action="${pageContext.request.contextPath}/staffservlet" method="post" class="p-4 bg-amber-50 rounded-xl border border-amber-200 mb-6">
                <input type="hidden" name="action" value="receiptItemEdit"/>
                <input type="hidden" name="receipt_item_id" value="${editItem.receipt_item_id}"/>
                <input type="hidden" name="receipt_id" value="${receipt.receipt_id}"/>
                <div class="space-y-4" data-variant-picker data-selected-variant="${editItem.variant_id}">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-start">
                        <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Category</label>
                        <select data-category-select class="w-full px-4 py-2 border border-amber-200 rounded-lg bg-white">
                            <option value="">— Select category —</option>
                        </select>
                        </div>
                        <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Product</label>
                        <select data-product-select class="w-full px-4 py-2 border border-amber-200 rounded-lg bg-white" disabled>
                            <option value="">— Select product —</option>
                        </select>
                        </div>
                        <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">SKU / Variant</label>
                        <select name="variant_id" data-variant-select required class="w-full px-4 py-2 border border-amber-200 rounded-lg bg-white" disabled>
                            <option value="">— Chọn variant —</option>
                        </select>
                        <p data-variant-hint class="mt-1 text-xs text-amber-700">Choose a category to filter products.</p>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                        <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Import Price (₫)</label>
                        <input type="number" name="import_price" value="${editItem.import_price}" min="0" step="1000" required class="w-full px-4 py-2 border border-gray-200 rounded-lg"/>
                        </div>
                        <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Quantity</label>
                        <input type="number" name="quantity" value="${editItem.quantity}" min="1" required class="w-full px-4 py-2 border border-gray-200 rounded-lg"/>
                        </div>
                        <div class="flex gap-2">
                            <button type="submit" class="px-4 py-2 bg-amber-600 text-white rounded-lg hover:bg-amber-700 font-medium">Update</button>
                            <a href="${pageContext.request.contextPath}/staffservlet?action=inventoryReceiptDetail&id=${receipt.receipt_id}" class="px-4 py-2 bg-gray-200 rounded-lg font-medium">Cancel</a>
                        </div>
                    </div>
                </div>
            </form>
        </c:if>
    </c:if>

    <h3 class="text-lg font-bold text-gray-800 mb-3">Add Item to Receipt</h3>
    <form action="${pageContext.request.contextPath}/staffservlet" method="post" class="p-4 bg-gray-50 rounded-xl border border-gray-200">
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
                    <option value="">— Chọn variant —</option>
                </select>
                <p data-variant-hint class="mt-1 text-xs text-gray-500">Choose a category to filter products.</p>
                </div>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Import Price (₫)</label>
                <input type="number" name="import_price" value="0" min="0" step="1000" required class="w-full px-4 py-2 border border-gray-200 rounded-lg"/>
                </div>
                <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Quantity</label>
                <input type="number" name="quantity" value="1" min="1" required class="w-full px-4 py-2 border border-gray-200 rounded-lg"/>
                </div>
                <div>
                    <button type="submit" class="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium">Add Item</button>
                </div>
            </div>
        </div>
    </form>

    <select id="variant-master-data" class="hidden" aria-hidden="true" tabindex="-1">
        <c:forEach items="${listVariants}" var="v">
            <option value="${v.variantId}"
                    data-product-id="${v.productId}"
                    data-product-name="${v.productName}"
                    data-category-name="${v.categoryName}"
                    data-brand-name="${v.brandName}"
                    data-sku="${v.sku}"
                    data-is-active="${v.isActive}">
                ${v.sku} - ${v.productName}
            </option>
        </c:forEach>
    </select>

    <script>
        (function () {
            var masterOptions = Array.from(document.querySelectorAll('#variant-master-data option')).map(function (option) {
                return {
                    id: option.value,
                    productId: option.dataset.productId || '',
                    productName: option.dataset.productName || 'Unknown product',
                    categoryName: option.dataset.categoryName || 'Uncategorized',
                    brandName: option.dataset.brandName || '',
                    sku: option.dataset.sku || '',
                    isActive: option.dataset.isActive === 'true'
                };
            });

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

            function fillSelect(select, placeholder, items, valueKey, labelBuilder, selectedValue) {
                select.innerHTML = '';
                var placeholderOption = document.createElement('option');
                placeholderOption.value = '';
                placeholderOption.textContent = placeholder;
                select.appendChild(placeholderOption);

                items.forEach(function (item) {
                    var option = document.createElement('option');
                    option.value = item[valueKey];
                    option.textContent = labelBuilder(item);
                    if (String(item[valueKey]) === String(selectedValue)) {
                        option.selected = true;
                    }
                    select.appendChild(option);
                });

                select.disabled = items.length === 0;
            }

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
                    }, selectedId || '');

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

                categorySelect.addEventListener('change', function () {
                    refreshProducts('');
                    refreshVariants('');
                });

                productSelect.addEventListener('change', function () {
                    refreshVariants('');
                });

                if (selectedVariant) {
                    refreshProducts(selectedVariant.productId);
                    refreshVariants(selectedVariant.id);
                } else {
                    refreshProducts('');
                    refreshVariants('');
                }
            }

            Array.from(document.querySelectorAll('[data-variant-picker]')).forEach(initVariantPicker);
        })();
    </script>
</div>
