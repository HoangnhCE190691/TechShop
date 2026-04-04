<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- Checkout: listCart + totalAmount từ orderpageServlet (cùng getCartDisplayByCustomerId như trang giỏ). --%>
<c:set var="listCart" value="${requestScope.listCart != null ? requestScope.listCart : []}"/>
<c:set var="totalAmount" value="${requestScope.totalAmount != null ? requestScope.totalAmount : 0}"/>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div class="bg-gray-50 min-h-screen pb-12 font-sans text-gray-800 relative">
    <div class="max-w-[1200px] mx-auto px-4 py-8 md:py-12">

        <h1 class="text-2xl md:text-3xl font-extrabold text-gray-900 mb-8 tracking-tight">Checkout & Order</h1>
        <%-- Thông báo lỗi hết hàng --%>
        <c:if test="${param.error == 'out_of_stock'}">
            <div class="mb-6 flex items-start gap-3 bg-red-50 border border-red-200 text-red-700 rounded-2xl px-5 py-4">
                <svg class="w-5 h-5 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                </svg>
                <div>
                    <p class="font-bold text-sm">Order failed — Product out of stock</p>
                    <c:if test="${not empty param.product}">
                        <c:choose>
                            <c:when test="${not empty param.available and not empty param.requested}">
                                <p class="text-sm mt-0.5">
                                    Product <strong>"${param.product}"</strong><c:if test="${not empty param.variant}"> - Variant <strong>${param.variant}</strong></c:if>: you requested <strong>${param.requested}</strong>,
                                    but only <strong>${param.available}</strong> item(s) are left in stock.
                                </p>
                            </c:when>
                            <c:otherwise>
                                <p class="text-sm mt-0.5">Product <strong>"${param.product}"</strong><c:if test="${not empty param.variant}"> - Variant <strong>${param.variant}</strong></c:if> does not have enough stock. Please update your cart or contact the store.</p>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <c:if test="${empty param.product}">
                        <p class="text-sm mt-0.5">One or more products in your cart are out of stock. Please update your cart.</p>
                    </c:if>
                </div>
            </div>
        </c:if>

        <form id="checkoutForm" method="post" action="orderpageservlet" class="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10">
            <input type="hidden" name="appliedVoucherId" id="appliedVoucherId" value="0">
            <div class="lg:col-span-7 flex flex-col gap-8">

                <div class="bg-white p-6 md:p-8 rounded-3xl border border-gray-100 shadow-sm">
                    <h2 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                        <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                        Delivery Address
                    </h2>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <c:choose>
                            <%-- TRƯỜNG HỢP 1: Danh sách rỗng (Chưa có địa chỉ nào) --%>
                            <c:when test="${empty listaddress}">
                                <div class="col-span-1 md:col-span-2">
                                    <a href="addresssuserservlet?action=addIncart&state=addIncart" class="relative block w-full border-2 border-dashed border-gray-300 bg-gray-50 rounded-2xl p-8 hover:bg-gray-100 hover:border-red-400 transition-all text-center group cursor-pointer">
                                        <svg class="mx-auto h-10 w-10 text-gray-400 group-hover:text-red-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                                        <h3 class="mt-2 text-base font-bold text-gray-900">No delivery address yet</h3>
                                        <p class="mt-1 text-sm text-gray-500">Click here to add a new address.</p>
                                    </a>
                                </div>
                            </c:when>

                            <%-- TRƯỜNG HỢP 2: Đã có danh sách địa chỉ --%>
                            <c:otherwise>
                                <c:forEach items="${listaddress}" var="addr" varStatus="loop">
                                    <c:set var="isSelected" value="${addr.isDefault || loop.first}" />
                                     
                                    <label class="address-card relative border-2 rounded-2xl p-5 cursor-pointer transition-all
                                           ${isSelected ? 'border-red-600 bg-red-50' : 'border-gray-100 bg-white hover:border-red-300'}">

                                        <input type="radio" name="addressId" value="${addr.addressId}" 
                                               class="absolute top-5 right-5 w-5 h-5 text-red-600 focus:ring-red-500" 
                                               ${isSelected ? 'checked' : ''}
                                               onclick="changeSelectedAddress(this)">

                                        <div class="pr-8">
                                            <div class="flex items-center gap-2 mb-1">
                                                <h3 class="font-bold text-gray-900 text-lg">
                                                    ${addr.nameReceiver}
                                                </h3>
                                                <c:if test="${addr.isDefault}">
                                                    <span class="px-2 py-0.5 text-[10px] font-bold bg-red-100 text-red-600 rounded">Default</span>
                                                </c:if>
                                            </div>

                                            <p class="text-sm font-semibold text-gray-800 mb-2">${addr.nameReceiver} - ${addr.phoneReceiver}</p>
                                            <p class="text-sm text-gray-500 leading-relaxed">${addr.address}</p>
                                        </div>
                                    </label>
                                </c:forEach>

                                <%-- CHỈ HIỂN THỊ NÚT THÊM NẾU SỐ LƯỢNG ĐỊA CHỈ < 2 --%>
                                <c:if test="${fn:length(listaddress) < 2}">
                                    <a href="addresssuserservlet?action=addIncart&state=addIncart" class="relative border-2 border-dashed border-gray-300 bg-gray-50 rounded-2xl p-5 cursor-pointer hover:bg-gray-100 hover:border-red-400 transition-all flex flex-col items-center justify-center min-h-[140px] group">
                                        <svg class="w-8 h-8 text-gray-400 group-hover:text-red-500 transition-colors mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                                        <span class="font-bold text-gray-600 group-hover:text-red-600 transition-colors">Add new address</span>
                                    </a>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="bg-white p-6 md:p-8 rounded-3xl border border-gray-100 shadow-sm">
                    <h2 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                        <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
                        Payment Method
                    </h2>

                    <div class="space-y-3">
                        <c:choose>
                            <c:when test="${empty paymentMethods}">
                                <p class="text-sm text-gray-500">
                                    No payment methods are configured. Please contact the administrator.
                                </p>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="pm" items="${paymentMethods}" varStatus="loop">
                                    <label class="flex items-center gap-4 border border-gray-200 rounded-xl p-4 cursor-pointer hover:bg-gray-50 transition-colors">
                                        <input
                                            type="radio"
                                            name="paymentMethodId"
                                            value="${pm.method_id}"
                                            class="w-5 h-5 text-red-600 focus:ring-red-500"
                                            ${loop.first ? 'checked' : ''}>
                                        <div class="flex-1">
                                            <h4 class="font-bold text-gray-900">
                                                <c:out value="${pm.method_name}"/>
                                            </h4>
                                        </div>
                                    </label>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>

            <div class="lg:col-span-5">
                <div class="bg-white p-6 md:p-8 rounded-3xl border border-gray-100 shadow-sm sticky top-6">
                    <h2 class="text-xl font-bold text-gray-900 mb-6 border-b border-gray-100 pb-4">Your Order</h2>

                    <div class="space-y-4 mb-6 max-h-[400px] overflow-y-auto pr-2" id="orderItemsList">
                        <c:choose>
                            <c:when test="${empty listCart}">
                                <p class="text-gray-500 text-sm py-4">Cart is empty. <a href="${pageContext.request.contextPath}/productpageservlet" class="text-red-600 font-medium hover:underline">Continue shopping</a>.</p>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${listCart}">
                                    <div class="flex gap-4">
                                        <div class="w-20 h-20 bg-gray-50 rounded-xl border border-gray-100 p-1 flex-shrink-0 flex items-center justify-center overflow-hidden">
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
                                        <div class="flex-1 flex flex-col justify-center">
                                            <h4 class="font-semibold text-gray-900 text-sm line-clamp-2 mb-1"><c:out value="${item.productName}"/> - <c:out value="${item.sku}"/></h4>
                                            <div class="flex justify-between items-end mt-auto">
                                                <span class="text-sm font-bold text-red-600"><fmt:formatNumber value="${item.sellingPrice}" groupingUsed="true"/>đ</span>
                                                <span class="text-xs font-semibold text-gray-500 bg-gray-100 px-2 py-1 rounded-md">x<c:out value="${item.quantity}"/></span>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="mb-4">
                        <div class="flex gap-2">
                            <input type="text" id="voucherInput" placeholder="Enter discount code (e.g. GIAM500K)" class="flex-1 border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 bg-gray-50 uppercase">
                            <button type="button" onclick="applyVoucher()" class="bg-gray-900 text-white px-5 py-3 rounded-xl text-sm font-bold hover:bg-gray-800 transition-colors">Apply</button>
                        </div>
                        <div id="voucherMessage" class="mt-2 text-sm"></div>
                    </div>

                    <div class="space-y-3 text-sm text-gray-600 mb-6 border-t border-gray-100 pt-6">
                        <div class="flex justify-between items-center">
                            <span>Subtotal (<c:out value="${listCart.size()}"/> items):</span>
                            <span class="font-semibold text-gray-900 text-base" id="subtotalDisplay"><fmt:formatNumber value="${totalAmount}" groupingUsed="true"/>đ</span>
                        </div>

                        <div class="flex justify-between items-center text-green-600">
                            <span>Promotion:</span>
                            <span class="font-semibold" id="discountDisplay">-0đ</span>
                        </div>

                        <div class="flex justify-between items-center">
                            <span>Shipping:</span>
                            <span class="font-semibold text-gray-900 text-base" id="shippingDisplay">Free</span>
                        </div>
                    </div>

                    <div class="flex justify-between items-end mb-8 border-t border-gray-100 pt-6">
                        <span class="font-bold text-gray-900 text-lg">Total:</span>
                        <div class="text-right">
                            <span class="block font-black text-red-600 text-3xl tracking-tight" id="totalDisplay"><fmt:formatNumber value="${totalAmount}" groupingUsed="true"/>đ</span>
                            <span class="text-xs text-gray-400 font-medium">(VAT included)</span>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty listCart}">
                            <a href="${pageContext.request.contextPath}/cartservlet" class="w-full flex justify-center items-center bg-gray-400 text-white h-14 rounded-xl font-bold text-lg cursor-not-allowed pointer-events-none">
                                PLACE ORDER
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="w-full flex justify-center items-center bg-red-600 text-white h-14 rounded-xl font-bold text-lg hover:bg-red-700 shadow-md hover:shadow-lg transition-all">
                                PLACE ORDER
                            </button>
                        </c:otherwise>
                    </c:choose>
                    <p class="text-center text-xs text-gray-400 mt-4">By clicking "Place Order" you agree to our <a href="#" class="text-blue-500 underline">Terms</a>.</p>
                </div>
            </div>

        </form>
    </div>
</div>
<%-- Thanh toán cổng trả lỗi / hủy: servlet ghi vnpayError, hiện toast rồi xóa session --%>
<c:if test="${not empty sessionScope.vnpayError}">
    <div id="vnpay-toast" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[360px] transition-all duration-500">
        <div class="flex items-center gap-3 p-4 rounded-xl shadow-2xl border-2 bg-red-50 text-red-800 border-red-200 ">
            <svg class="w-6 h-6 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
            </svg>
            <span class="font-bold text-sm">${sessionScope.vnpayError}</span>
        </div>
    </div>
    <c:remove var="vnpayError" scope="session"/>
    <script>
        /* Ẩn dần và gỡ toast lỗi thanh toán sau vài giây */
        setTimeout(() => {
            const t = document.getElementById('vnpay-toast');
            if (t) {
                t.style.opacity = '0';
                setTimeout(() => t.remove(), 500);
            }
        }, 4000);
    </script>
</c:if>
<div id="successModal" class="fixed inset-0 z-50 flex items-center justify-center hidden opacity-0 transition-opacity duration-300">
    <div class="absolute inset-0 bg-black/50 backdrop-blur-sm"></div>

    <div class="relative bg-white rounded-3xl shadow-2xl p-8 md:p-10 max-w-sm w-full mx-4 text-center transform scale-95 transition-transform duration-300" id="modalContent">
        <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-green-100 mb-6">
            <svg class="h-10 w-10 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path>
            </svg>
        </div>

        <h3 class="text-2xl font-black text-gray-900 mb-2">Order placed successfully!</h3>
        <p class="text-gray-500 text-sm mb-8 leading-relaxed">
            Thank you for your order. Order <b>#${newOrderId}</b> has been received and is being prepared.
        </p>

        <button onclick="closeModalAndRedirect('userservlet?action=homePage')" class="w-full bg-gray-900 text-white font-bold h-12 rounded-xl hover:bg-gray-800 transition-colors">
            Continue shopping
        </button>
        <button onclick="closeModalAndRedirect('orderhistorypageservlet')" class="w-full mt-3 bg-white text-gray-600 border border-gray-200 font-bold h-12 rounded-xl hover:bg-gray-50 transition-colors">
            View order history
        </button>
    </div>
</div>

<script>
    /*
     * Checkout: đổi kiểu chọn địa chỉ (onclick trên radio),
     * áp voucher trên giao diện (đồng bộ hidden appliedVoucherId gửi post),
     * phí ship và tổng cuối, modal đặt hàng thành công.
     */
    /** Khi chọn một địa chỉ: bỏ highlight cũ, tô đỏ thẻ label chứa radio vừa chọn. */
    function changeSelectedAddress(radioElement) {
        let allCards = document.querySelectorAll('.address-card');
        allCards.forEach(card => {
            card.classList.remove('border-red-600', 'bg-red-50');
            card.classList.add('border-gray-100', 'bg-white');
        });

        let selectedCard = radioElement.closest('.address-card');
        selectedCard.classList.remove('border-gray-100', 'bg-white');
        selectedCard.classList.add('border-red-600', 'bg-red-50');
    }

    /* Lắng nghe đổi radio name="address" (nếu có trên trang — tương thích layout cũ) */
    const addressLabels = document.querySelectorAll('input[name="address"]');
    addressLabels.forEach(radio => {
        radio.addEventListener('change', function () {
            document.querySelectorAll('input[name="address"]').forEach(r => {
                let lbl = r.closest('label');
                lbl.className = "relative border-2 border-gray-100 bg-white rounded-2xl p-5 cursor-pointer hover:border-red-300 transition-all";
            });
            if (this.checked) {
                let selectedLbl = this.closest('label');
                selectedLbl.className = "relative border-2 border-red-600 bg-red-50 rounded-2xl p-5 cursor-pointer transition-all";
            }
        });
    });

    let subTotal = ${totalAmount != null ? totalAmount : 0};
    let currentDiscount = 0;

    /** Danh sách mã giảm từ server (JSTL forEach sinh mảng JS). */
    const availableVouchers = [
    <c:forEach items="${listVoucher}" var="v" varStatus="loop">
    {
    code: '${v.code}',
            voucherId: ${v.voucherId},
            discountPercent: ${v.discountPercent},
            maxDiscountAmount: ${v.maxDiscountAmount},
            minOrderValue: ${v.minOrderValue},
            isAvailable: ${v.available}
    }${!loop.last ? ',' : ''}
    </c:forEach>
    ];
    const formatMoney = (amount) => amount.toLocaleString('vi-VN') + 'đ';
    /** Chạy một lần khi tải trang: tính phí ship và tổng ban đầu theo subTotal (chưa voucher). */
    (function () {
        const shippingDisplay = document.getElementById('shippingDisplay');
        const totalDisplay = document.getElementById('totalDisplay');
        const shipCost = subTotal < 500000 ? 30000 : 0;
        shippingDisplay.innerText = shipCost > 0 ? formatMoney(shipCost) : 'Free';
        shippingDisplay.className = shipCost > 0
                ? 'font-semibold text-gray-900 text-base'
                : 'font-semibold text-green-600 text-base';
        totalDisplay.innerText = formatMoney(subTotal + shipCost);
    })();
    /**
     * Đọc mã voucher, tìm trong availableVouchers, kiểm tra còn dùng được và đủ giá trị đơn tối thiểu.
     * Cập nhật currentDiscount, hidden appliedVoucherId, dòng giảm giá, phí ship (theo ngưỡng 500k), tổng cuối.
     */
    function applyVoucher() {
        const inputCode = document.getElementById('voucherInput').value.trim().toUpperCase();
        const messageDiv = document.getElementById('voucherMessage');
        const discountDisplay = document.getElementById('discountDisplay');
        const totalDisplay = document.getElementById('totalDisplay');

        const formatMoney = (amount) => amount.toLocaleString('vi-VN') + 'đ';

        if (inputCode === '') {
            currentDiscount = 0;
            document.getElementById('appliedVoucherId').value = "0";
            messageDiv.innerHTML = '<span class="text-red-500 font-medium">Please enter a discount code.</span>';
        } else {
            const foundVoucher = availableVouchers.find(v => v.code.toUpperCase() === inputCode);

            if (foundVoucher) {
                if (!foundVoucher.isAvailable) {
                    currentDiscount = 0;
                    document.getElementById('appliedVoucherId').value = "0";
                    messageDiv.innerHTML = '<span class="text-red-500 font-medium">This voucher has expired or reached its usage limit!</span>';
                }
                else if (subTotal < foundVoucher.minOrderValue) {
                    currentDiscount = 0;
                    document.getElementById('appliedVoucherId').value = "0";
                    messageDiv.innerHTML = `<span class="text-red-500 font-medium">Minimum order to apply this code is ` + formatMoney(foundVoucher.minOrderValue) + `!</span>`;
                }
                else {
                    let calculatedDiscount = subTotal * (foundVoucher.discountPercent / 100);

                    if (foundVoucher.maxDiscountAmount > 0 && calculatedDiscount > foundVoucher.maxDiscountAmount) {
                        currentDiscount = foundVoucher.maxDiscountAmount;
                    } else {
                        currentDiscount = calculatedDiscount;
                    }

                    if (currentDiscount > subTotal) {
                        currentDiscount = subTotal;
                    }

                    document.getElementById('appliedVoucherId').value = foundVoucher.voucherId;

                    messageDiv.innerHTML = `<span class="text-green-600 font-medium flex items-center gap-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg> 
                    Applied! You save ` + formatMoney(currentDiscount) + `!</span>`;
                }
            } else {
                currentDiscount = 0;
                document.getElementById('appliedVoucherId').value = "0";
                messageDiv.innerHTML = '<span class="text-red-500 font-medium">Invalid discount code!</span>';
            }
        }
discountDisplay.innerText = '-' + formatMoney(currentDiscount);
        let afterDiscount = subTotal - currentDiscount;
        const SHIP_FEE = 30000;
        const shippingDisplay = document.getElementById('shippingDisplay');
        let shipCost = afterDiscount < 500000 ? SHIP_FEE : 0;
        shippingDisplay.innerText = shipCost > 0 ? formatMoney(shipCost) : 'Free';
        shippingDisplay.className = shipCost > 0
                ? 'font-semibold text-gray-900 text-base'
                : 'font-semibold text-green-600 text-base';
        let finalTotal = afterDiscount + shipCost;
        totalDisplay.innerText = formatMoney(finalTotal);
    }

    const modal = document.getElementById('successModal');
    const modalContent = document.getElementById('modalContent');

    /** Hiện lớp phủ đặt hàng thành công (có hiệu ứng scale). */
    function showSuccessModal() {
        modal.classList.remove('hidden');
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            modalContent.classList.remove('scale-95');
            modalContent.classList.add('scale-100');
        }, 10);
    }

    /** Đóng modal rồi chuyển trang (trang chủ hoặc lịch sử đơn). */
    function closeModalAndRedirect(targetUrl) {
        modal.classList.add('opacity-0');
        modalContent.classList.remove('scale-100');
        modalContent.classList.add('scale-95');

        setTimeout(() => {
            modal.classList.add('hidden');
            window.location.href = targetUrl || "userservlet?action=homePage";
        }, 300);
    }

    if (window.location.search.includes('orderSuccess=1')) {
        showSuccessModal();
    }
</script>