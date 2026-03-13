<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="listCart" value="${requestScope.listCart != null ? requestScope.listCart : []}"/>
<c:set var="totalAmount" value="0"/>
<c:forEach var="item" items="${listCart}">
    <c:set var="totalAmount" value="${totalAmount + item.subtotal}"/>
</c:forEach>

<c:if test="${not empty sessionScope.msg}">
    <div id="toast-cart" class="fixed top-4 right-4 z-[9999] min-w-[280px] max-w-sm animate-fade-in">
        <c:choose>
            <c:when test="${sessionScope.msgType == 'danger'}">
                <div class="flex items-center gap-3 p-4 rounded-xl shadow-lg border border-red-200 bg-red-50 text-red-800">
                    <span class="flex-shrink-0 text-red-500">!</span>
                    <span class="font-medium text-sm">${sessionScope.msg}</span>
                </div>
            </c:when>
            <c:otherwise>
                <div class="flex items-center gap-3 p-4 rounded-xl shadow-lg border border-green-200 bg-green-50 text-green-800">
                    <svg class="w-5 h-5 flex-shrink-0 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                    <span class="font-medium text-sm">${sessionScope.msg}</span>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <c:remove var="msg" scope="session"/>
    <c:remove var="msgType" scope="session"/>
    <script>setTimeout(function () {
            var t = document.getElementById('toast-cart');
            if (t)
                t.remove();
        }, 3000);</script>
</c:if>

<c:if test="${not empty requestScope.cartErrorMsg}">
    <div class="max-w-[1200px] mx-auto px-4 mt-4">
        <div class="mb-4 flex items-start gap-3 bg-red-50 border border-red-200 text-red-700 rounded-2xl px-5 py-4">
            <svg class="w-5 h-5 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
            </svg>
            <div>
                <p class="font-bold text-sm">Đặt hàng thất bại — Sản phẩm hết hàng</p>
                <p class="text-sm mt-0.5">${requestScope.cartErrorMsg}</p>
            </div>
        </div>
    </div>
</c:if>

<div class="bg-gray-50 min-h-screen pb-12">
    <div class="max-w-[1200px] mx-auto px-4 py-8 md:py-12 font-sans text-gray-800">

        <h1 class="text-2xl md:text-3xl font-extrabold text-gray-900 mb-8 tracking-tight">
            Giỏ hàng của bạn <span class="text-gray-400 font-medium text-lg ml-2" id="cartCount">(<c:out value="${listCart.size()}"/> sản phẩm)</span>
        </h1>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10">

            <div class="lg:col-span-8 flex flex-col gap-5" id="cartItemsContainer">

                <c:choose>
                    <c:when test="${empty listCart}">
                        <div class="text-center py-12 bg-white rounded-3xl border border-gray-100">
                            <p class="text-gray-500 mb-4">Giỏ hàng của bạn đang trống.</p>
                            <a href="${pageContext.request.contextPath}/productpageservlet" class="text-red-600 font-bold hover:underline">Tiếp tục mua sắm</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="item" items="${listCart}">
                            <div class="cart-item flex flex-col sm:flex-row items-start sm:items-center gap-4 md:gap-6 bg-white p-5 rounded-3xl border border-gray-100 shadow-sm relative transition-all hover:shadow-md">
                                <form action="${pageContext.request.contextPath}/cartservlet" method="post" class="absolute top-4 right-4 sm:static sm:order-last" onsubmit="return confirm('Bạn có chắc muốn bỏ sản phẩm này khỏi giỏ hàng?');">
                                    <input type="hidden" name="action" value="remove"/>
                                    <input type="hidden" name="cart_item_id" value="${item.cartItemId}"/>
                                    <button type="submit" class="text-gray-400 hover:text-red-500 transition-colors p-2 rounded-full hover:bg-red-50">
                                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                    </button>
                                </form>

                                <div class="w-24 h-24 md:w-32 md:h-32 flex-shrink-0 bg-gray-50 rounded-2xl border border-gray-100 p-2 flex items-center justify-center overflow-hidden">
                                    <c:choose>
                                        <c:when test="${not empty item.thumbnailUrl}">
                                            <img src="${pageContext.request.contextPath}/${item.thumbnailUrl}"
                                                 alt="${item.productName}"
                                                 class="w-full h-full object-contain">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/assets/img/product/iphone-15-blue.jpg"
                                                 alt="${item.productName}"
                                                 class="w-full h-full object-contain opacity-70">
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="flex-1 w-full">
                                    <h3 class="font-bold text-gray-900 text-lg lg:text-xl mb-1 line-clamp-2 pr-8 sm:pr-0"><c:out value="${item.productName}"/></h3>
                                    <p class="text-sm text-gray-500 mb-3 font-medium">Phân loại: <c:out value="${item.sku}"/></p>

                                    <div class="flex flex-wrap items-center justify-between gap-4 mt-2">
                                        <div class="flex flex-col">
                                            <span class="font-black text-red-600 text-lg"><fmt:formatNumber value="${item.sellingPrice}" groupingUsed="true"/>đ</span>
                                            <span class="text-sm text-gray-500 mt-0.5">Thành tiền: <span class="item-subtotal font-bold text-red-600"><fmt:formatNumber value="${item.subtotal}" groupingUsed="true"/>đ</span></span>
                                        </div>

                                        <form action="${pageContext.request.contextPath}/cartservlet" method="post" class="cart-qty-form flex items-center border border-gray-200 rounded-xl h-10 bg-gray-50 p-1 w-fit" data-unit-price="${item.sellingPrice}">
                                            <input type="hidden" name="action" value="update"/>
                                            <input type="hidden" name="cart_item_id" value="${item.cartItemId}"/>
                                            <input type="hidden" name="quantity" value="<c:out value='${item.quantity}' default='1'/>"/>
                                            <button type="submit" name="change" value="-1" class="cart-qty-minus w-8 h-full flex items-center justify-center text-gray-500 hover:bg-white hover:shadow-sm rounded-lg transition-all text-lg font-medium">−</button>
                                            <span class="cart-qty-display w-10 h-full flex items-center justify-center text-gray-900 font-bold text-sm"><c:out value="${item.quantity}" default="1"/></span>
                                            <button type="submit" name="change" value="1" class="cart-qty-plus w-8 h-full flex items-center justify-center text-gray-500 hover:bg-white hover:shadow-sm rounded-lg transition-all text-lg font-medium">+</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>

                <div class="mt-4">
                    <a href="${pageContext.request.contextPath}/productpageservlet" class="inline-flex items-center gap-2 text-blue-600 font-medium hover:text-blue-800 transition-colors">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
                        Tiếp tục mua sắm
                    </a>
                </div>

            </div>

            <div class="lg:col-span-4" id="cartOrderSummary">
                <div class="bg-white p-6 md:p-8 rounded-3xl border border-gray-100 shadow-sm sticky top-6">
                    <h2 class="text-xl font-bold text-gray-900 mb-6 border-b border-gray-100 pb-4">Tóm tắt đơn hàng</h2>

                    <div class="space-y-4 text-sm text-gray-600 mb-6 border-b border-gray-100 pb-6">
                        <div class="flex justify-between items-center">
                            <span>Tạm tính:</span>
                            <span id="cartSubtotal" class="cart-summary-subtotal font-semibold text-gray-900 text-base"><fmt:formatNumber value="${totalAmount}" groupingUsed="true"/>đ</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span>Phí vận chuyển:</span>
                            <span class="font-semibold text-gray-900 text-base">Miễn phí</span>
                        </div>
                    </div>

                    <div class="flex justify-between items-end mb-8">
                        <span class="font-bold text-gray-900 text-lg">Tổng cộng:</span>
                        <div class="text-right">
                            <span id="cartTotal" class="cart-summary-total block font-black text-red-600 text-3xl tracking-tight"><fmt:formatNumber value="${totalAmount}" groupingUsed="true"/>đ</span>
                            <span class="text-xs text-gray-400 font-medium">(Đã bao gồm VAT nếu có)</span>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty listCart}">
                            <a href="${pageContext.request.contextPath}/productpageservlet" class="w-full flex justify-center items-center gap-2 bg-gray-400 text-white h-14 rounded-xl font-bold text-lg cursor-not-allowed">
                                Tiến hành thanh toán
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/orderpageservlet" class="w-full flex justify-center items-center gap-2 bg-red-600 text-white h-14 rounded-xl font-bold text-lg hover:bg-red-700 shadow-md hover:shadow-lg transition-all">
                                Tiến hành thanh toán
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
    (function () {
        var container = document.getElementById('cartItemsContainer');
        if (!container) return;

        function formatVnd(num) {
            return Number(num).toLocaleString('vi-VN') + 'đ';
        }

        function showCartErrorBanner(message) {
            if (!message) return;
            var wrap = document.querySelector('.max-w-[1200px]');
            if (!wrap) return;
            var existing = document.getElementById('cart-error-banner');
            if (existing) {
                existing.querySelector('.cart-error-text').textContent = message;
                existing.classList.remove('hidden');
                return;
            }
            var html = ''
                + '<div id="cart-error-banner" class="mb-6 flex items-start gap-3 bg-red-50 border border-red-200 text-red-700 rounded-2xl px-5 py-4">'
                + '  <svg class="w-5 h-5 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">'
                + '    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>'
                + '  </svg>'
                + '  <div>'
                + '    <p class="font-bold text-sm">Đặt hàng thất bại — Sản phẩm hết hàng</p>'
                + '    <p class="text-sm mt-0.5 cart-error-text"></p>'
                + '  </div>'
                + '</div>';
            wrap.insertAdjacentHTML('afterbegin', html);
            var textEl = document.querySelector('#cart-error-banner .cart-error-text');
            if (textEl) textEl.textContent = message;
        }

        function submitCartQtyAjax(form, newQty, oldQty) {
            var url = form.getAttribute('action');
            url = url + (url.indexOf('?') >= 0 ? '&' : '?') + 'ajax=1';
            var params = new URLSearchParams();
            params.append('action', 'update');
            params.append('cart_item_id', form.querySelector('input[name="cart_item_id"]').value);
            params.append('quantity', String(newQty));
            params.append('ajax', '1');

            var unitPrice = parseFloat(form.getAttribute('data-unit-price')) || 0;
            var row = form.closest('.cart-item');
            var subtotalEl = row ? row.querySelector('.item-subtotal') : null;

            form.classList.add('opacity-60', 'pointer-events-none');
            fetch(url, {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params.toString()
            }).then(function (r) {
                if (!r.ok) throw new Error('HTTP ' + r.status);
                var ct = (r.headers.get('content-type') || '').toLowerCase();
                if (ct.indexOf('application/json') === -1) {
                    form.classList.remove('opacity-60', 'pointer-events-none');
                    return;
                }
                return r.json();
            }).then(function (data) {
                form.classList.remove('opacity-60', 'pointer-events-none');
                if (!data) return;
                if (data.success !== true) {
                    // revert UI
                    var qtyInput = form.querySelector('input[name="quantity"]');
                    var displayEl = form.querySelector('.cart-qty-display');
                    if (qtyInput) qtyInput.value = oldQty;
                    if (displayEl) displayEl.textContent = oldQty;
                    if (data.message) showCartErrorBanner(data.message);
                    return;
                }
                // update subtotal & totals
                if (subtotalEl && unitPrice > 0) {
                    subtotalEl.textContent = formatVnd(unitPrice * newQty);
                }
                if (typeof data.totalAmount === 'number') {
                    var subEl = document.getElementById('cartSubtotal');
                    var totalEl = document.getElementById('cartTotal');
                    if (subEl) subEl.textContent = formatVnd(data.totalAmount);
                    if (totalEl) totalEl.textContent = formatVnd(data.totalAmount);
                }
                var badge = document.getElementById('navbarCartCount');
                if (badge && typeof data.cartCount === 'number') {
                    badge.textContent = data.cartCount;
                    if (data.cartCount > 0) badge.classList.remove('hidden');
                    else badge.classList.add('hidden');
                }
            }).catch(function () {
                form.classList.remove('opacity-60', 'pointer-events-none');
            });
        }

        // Gán click listener trực tiếp cho nút +/-
        container.addEventListener('click', function (e) {
            var btn = e.target.closest('.cart-qty-minus, .cart-qty-plus');
            if (!btn) return;
            e.preventDefault();
            var form = btn.closest('form');
            if (!form || !form.classList.contains('cart-qty-form')) return;

            var qtyInput = form.querySelector('input[name="quantity"]');
            var displayEl = form.querySelector('.cart-qty-display');
            if (!qtyInput) return;

            var cur = parseInt(qtyInput.value, 10) || 1;
            var delta = btn.classList.contains('cart-qty-minus') ? -1 : 1;
            var newQty = cur + delta;
            if (newQty < 1) newQty = 1;

            // Update UI ngay lập tức
            qtyInput.value = newQty;
            if (displayEl) displayEl.textContent = newQty;

            // Gửi AJAX để sync với server / kiểm tra kho
            submitCartQtyAjax(form, newQty, cur);
        });
    })();
</script>
