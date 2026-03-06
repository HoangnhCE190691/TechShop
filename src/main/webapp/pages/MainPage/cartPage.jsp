<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="listCart" value="${requestScope.listCart != null ? requestScope.listCart : []}"/>
<c:set var="totalAmount" value="0"/>
<c:forEach var="item" items="${listCart}">
    <c:set var="totalAmount" value="${totalAmount + item.subtotal}"/>
</c:forEach>

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

                                <div class="w-24 h-24 md:w-32 md:h-32 flex-shrink-0 bg-gray-50 rounded-2xl border border-gray-100 p-2 flex items-center justify-center">
                                    <span class="text-gray-400 text-sm font-medium text-center px-2"><c:out value="${item.productName}"/></span>
                                </div>

                                <div class="flex-1 w-full">
                                    <h3 class="font-bold text-gray-900 text-lg lg:text-xl mb-1 line-clamp-2 pr-8 sm:pr-0"><c:out value="${item.productName}"/></h3>
                                    <p class="text-sm text-gray-500 mb-3 font-medium">Phân loại: <c:out value="${item.sku}"/></p>

                                    <div class="flex flex-wrap items-center justify-between gap-4 mt-2">
                                        <div class="flex flex-col">
                                            <span class="font-black text-red-600 text-lg"><fmt:formatNumber value="${item.sellingPrice}" groupingUsed="true"/>đ</span>
                                            <span class="text-sm text-gray-500 mt-0.5">Thành tiền: <span class="item-subtotal font-bold text-red-600"><fmt:formatNumber value="${item.subtotal}" groupingUsed="true"/>đ</span></span>
                                        </div>

                                        <div class="cart-qty-box flex items-center border border-gray-200 rounded-xl h-10 bg-gray-50 p-1" data-cart-item-id="${item.cartItemId}" data-cart-url="${pageContext.request.contextPath}/cartservlet" data-unit-price="${item.sellingPrice}">
                                            <button type="button" class="cart-qty-minus w-8 h-full flex items-center justify-center text-gray-500 hover:bg-white hover:shadow-sm rounded-lg transition-all text-lg font-medium" onclick="typeof cartQtyChange === 'function' && cartQtyChange(this, -1)">−</button>
                                            <input type="text" value="<c:out value='${item.quantity}' default='1'/>" class="item-qty w-10 h-full text-center border-none bg-transparent focus:ring-0 text-gray-900 font-bold text-sm pointer-events-none" readonly>
                                            <button type="button" class="cart-qty-plus w-8 h-full flex items-center justify-center text-gray-500 hover:bg-white hover:shadow-sm rounded-lg transition-all text-lg font-medium" onclick="typeof cartQtyChange === 'function' && cartQtyChange(this, 1)">+</button>
                                        </div>
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
        function formatVnd(n) {
            n = Number(n);
            if (isNaN(n))
                return '0';
            return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
        }
        function parseVndText(txt) {
            if (!txt || typeof txt !== 'string')
                return 0;
            var num = txt.replace(/\s/g, '').replace(/\./g, '').replace(/đ/g, '');
            return parseInt(num, 10) || 0;
        }
        function updateSummaryFromCart() {
            var els = document.querySelectorAll('.cart-item .item-subtotal');
            var total = 0;
            for (var i = 0; i < els.length; i++)
                total += parseVndText(els[i].textContent);
            var txt = formatVnd(total) + 'đ';
            var summary = document.getElementById('cartOrderSummary');
            var sub = summary ? summary.querySelector('.cart-summary-subtotal') : document.getElementById('cartSubtotal');
            var tot = summary ? summary.querySelector('.cart-summary-total') : document.getElementById('cartTotal');
            if (!sub)
                sub = document.getElementById('cartSubtotal');
            if (!tot)
                tot = document.getElementById('cartTotal');
            if (sub)
                sub.textContent = txt;
            if (tot)
                tot.textContent = txt;
        }
        function doUpdateQty(box, change) {
            var input = box.querySelector('.item-qty');
            if (!input)
                return;
            var oldVal = parseInt(input.value, 10) || 0;
            var val = oldVal + change;
            if (val < 1)
                val = 1;
            input.value = val;
            var unitPrice = parseInt(box.getAttribute('data-unit-price'), 10) || 0;
            var row = box.closest('.cart-item');
            var itemSubtotalEl = row ? row.querySelector('.item-subtotal') : null;
            if (itemSubtotalEl)
                itemSubtotalEl.textContent = formatVnd(unitPrice * val) + 'đ';
            updateSummaryFromCart();
            var cartItemId = box.getAttribute('data-cart-item-id');
            var url = box.getAttribute('data-cart-url') || 'cartservlet';
            if (!cartItemId) {
                input.value = oldVal;
                if (itemSubtotalEl)
                    itemSubtotalEl.textContent = formatVnd(unitPrice * oldVal) + 'đ';
                updateSummaryFromCart();
                return;
            }
            var fd = new FormData();
            fd.append('action', 'update');
            fd.append('cart_item_id', cartItemId);
            fd.append('quantity', String(val));
            fd.append('ajax', '1');
            fetch(url, {
                method: 'POST',
                headers: {'X-Requested-With': 'XMLHttpRequest'},
                body: fd
            })
                    .then(function (res) {
                        if (!res.ok)
                            throw new Error('HTTP ' + res.status);
                        var ct = res.headers.get('Content-Type') || '';
                        if (ct.indexOf('application/json') === -1)
                            throw new Error('Not JSON');
                        return res.json();
                    })
                    .then(function (data) {
                        if (data && data.success !== false) {
                            updateSummaryFromCart();
                        } else {
                            input.value = oldVal;
                            if (itemSubtotalEl)
                                itemSubtotalEl.textContent = formatVnd(unitPrice * oldVal) + 'đ';
                            updateSummaryFromCart();
                        }
                    })
                    .catch(function (err) {
                        input.value = oldVal;
                        if (itemSubtotalEl)
                            itemSubtotalEl.textContent = formatVnd(unitPrice * oldVal) + 'đ';
                        updateSummaryFromCart();
                    });
        }
        window.cartQtyChange = function (btn, change) {
            var box = btn && btn.closest ? btn.closest('.cart-qty-box') : null;
            if (box)
                doUpdateQty(box, change);
        };
        function initCartQty() {
            var container = document.getElementById('cartItemsContainer');
            if (!container)
                return;
            container.addEventListener('click', function (e) {
                var target = e.target;
                var minusBtn = target.closest('.cart-qty-minus');
                var plusBtn = target.closest('.cart-qty-plus');
                var box = target.closest('.cart-qty-box');
                if (!box)
                    return;
                if (minusBtn) {
                    e.preventDefault();
                    doUpdateQty(box, -1);
                    return;
                }
                if (plusBtn) {
                    e.preventDefault();
                    doUpdateQty(box, 1);
                    return;
                }
            });
        }
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initCartQty);
        } else {
            initCartQty();
        }
    })();
</script>
