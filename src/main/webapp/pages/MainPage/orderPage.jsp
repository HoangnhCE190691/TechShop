<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="listCart" value="${requestScope.listCart != null ? requestScope.listCart : []}"/>
<c:set var="totalAmount" value="${requestScope.totalAmount != null ? requestScope.totalAmount : 0}"/>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div class="bg-gray-50 min-h-screen pb-12 font-sans text-gray-800 relative">
    <div class="max-w-[1200px] mx-auto px-4 py-8 md:py-12">

        <h1 class="text-2xl md:text-3xl font-extrabold text-gray-900 mb-8 tracking-tight">Thanh toán & Đặt hàng</h1>
        <%-- Thông báo lỗi hết hàng --%>
        <c:if test="${param.error == 'out_of_stock'}">
            <div class="mb-6 flex items-start gap-3 bg-red-50 border border-red-200 text-red-700 rounded-2xl px-5 py-4">
                <svg class="w-5 h-5 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                </svg>
                <div>
                    <p class="font-bold text-sm">Đặt hàng thất bại — Sản phẩm hết hàng</p>
                    <c:if test="${not empty param.product}">
                        <p class="text-sm mt-0.5">Sản phẩm <strong>"${param.product}"</strong> hiện không đủ số lượng trong kho. Vui lòng điều chỉnh giỏ hàng hoặc liên hệ cửa hàng.</p>
                    </c:if>
                    <c:if test="${empty param.product}">
                        <p class="text-sm mt-0.5">Một hoặc nhiều sản phẩm trong giỏ hàng hiện không đủ số lượng trong kho. Vui lòng điều chỉnh giỏ hàng.</p>
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
                        Địa chỉ giao hàng
                    </h2>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <c:choose>
                            <%-- TRƯỜNG HỢP 1: Danh sách rỗng (Chưa có địa chỉ nào) --%>
                            <c:when test="${empty listaddress}">
                                <div class="col-span-1 md:col-span-2">
                                    <a href="addresssuserservlet?action=add" class="relative block w-full border-2 border-dashed border-gray-300 bg-gray-50 rounded-2xl p-8 hover:bg-gray-100 hover:border-red-400 transition-all text-center group cursor-pointer">
                                        <svg class="mx-auto h-10 w-10 text-gray-400 group-hover:text-red-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                                        <h3 class="mt-2 text-base font-bold text-gray-900">Chưa có địa chỉ giao hàng</h3>
                                        <p class="mt-1 text-sm text-gray-500">Bấm vào đây để thêm địa chỉ mới nhé.</p>
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
                                                    <span class="px-2 py-0.5 text-[10px] font-bold bg-red-100 text-red-600 rounded">Mặc định</span>
                                                </c:if>
                                            </div>

                                            <p class="text-sm font-semibold text-gray-800 mb-2">${addr.nameReceiver} - ${addr.phoneReceiver}</p>
                                            <p class="text-sm text-gray-500 leading-relaxed">${addr.address}</p>
                                        </div>
                                    </label>
                                </c:forEach>

                                <%-- CHỈ HIỂN THỊ NÚT THÊM NẾU SỐ LƯỢNG ĐỊA CHỈ < 2 --%>
                                <c:if test="${fn:length(listaddress) < 2}">
                                    <a href="addresssuserservlet?action=add" class="relative border-2 border-dashed border-gray-300 bg-gray-50 rounded-2xl p-5 cursor-pointer hover:bg-gray-100 hover:border-red-400 transition-all flex flex-col items-center justify-center min-h-[140px] group">
                                        <svg class="w-8 h-8 text-gray-400 group-hover:text-red-500 transition-colors mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                                        <span class="font-bold text-gray-600 group-hover:text-red-600 transition-colors">Thêm địa chỉ mới</span>
                                    </a>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="bg-white p-6 md:p-8 rounded-3xl border border-gray-100 shadow-sm">
                    <h2 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                        <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
                        Phương thức thanh toán
                    </h2>

                    <div class="space-y-3">
                        <c:choose>
                            <c:when test="${empty paymentMethods}">
                                <p class="text-sm text-gray-500">
                                    Hiện chưa có phương thức thanh toán nào được cấu hình. Vui lòng liên hệ quản trị viên.
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
                    <h2 class="text-xl font-bold text-gray-900 mb-6 border-b border-gray-100 pb-4">Đơn hàng của bạn</h2>

                    <div class="space-y-4 mb-6 max-h-[400px] overflow-y-auto pr-2" id="orderItemsList">
                        <c:choose>
                            <c:when test="${empty listCart}">
                                <p class="text-gray-500 text-sm py-4">Giỏ hàng trống. <a href="${pageContext.request.contextPath}/productpageservlet" class="text-red-600 font-medium hover:underline">Tiếp tục mua sắm</a>.</p>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${listCart}">
                                    <div class="flex gap-4">
                                        <div class="w-20 h-20 bg-gray-50 rounded-xl border border-gray-100 p-1 flex-shrink-0 flex items-center justify-center">
                                            <span class="text-gray-400 text-xs font-medium text-center px-1 line-clamp-2"><c:out value="${item.productName}"/></span>
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
                            <input type="text" id="voucherInput" placeholder="Nhập mã giảm giá (VD: GIAM500K)" class="flex-1 border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 bg-gray-50 uppercase">
                            <button type="button" onclick="applyVoucher()" class="bg-gray-900 text-white px-5 py-3 rounded-xl text-sm font-bold hover:bg-gray-800 transition-colors">Áp dụng</button>
                        </div>
                        <div id="voucherMessage" class="mt-2 text-sm"></div>
                    </div>

                    <div class="space-y-3 text-sm text-gray-600 mb-6 border-t border-gray-100 pt-6">
                        <div class="flex justify-between items-center">
                            <span>Tạm tính (<c:out value="${listCart.size()}"/> sản phẩm):</span>
                            <span class="font-semibold text-gray-900 text-base" id="subtotalDisplay"><fmt:formatNumber value="${totalAmount}" groupingUsed="true"/>đ</span>
                        </div>

                        <div class="flex justify-between items-center text-green-600">
                            <span>Khuyến mãi:</span>
                            <span class="font-semibold" id="discountDisplay">-0đ</span>
                        </div>

                        <div class="flex justify-between items-center">
                            <span>Phí vận chuyển:</span>
                            <span class="font-semibold text-gray-900 text-base">Miễn phí</span>
                        </div>
                    </div>

                    <div class="flex justify-between items-end mb-8 border-t border-gray-100 pt-6">
                        <span class="font-bold text-gray-900 text-lg">Thành tiền:</span>
                        <div class="text-right">
                            <span class="block font-black text-red-600 text-3xl tracking-tight" id="totalDisplay"><fmt:formatNumber value="${totalAmount}" groupingUsed="true"/>đ</span>
                            <span class="text-xs text-gray-400 font-medium">(Đã bao gồm VAT)</span>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty listCart}">
                            <a href="${pageContext.request.contextPath}/cartservlet" class="w-full flex justify-center items-center bg-gray-400 text-white h-14 rounded-xl font-bold text-lg cursor-not-allowed pointer-events-none">
                                ĐẶT HÀNG
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="w-full flex justify-center items-center bg-red-600 text-white h-14 rounded-xl font-bold text-lg hover:bg-red-700 shadow-md hover:shadow-lg transition-all">
                                ĐẶT HÀNG
                            </button>
                        </c:otherwise>
                    </c:choose>
                    <p class="text-center text-xs text-gray-400 mt-4">Nhấn "Đặt hàng" đồng nghĩa với việc bạn đồng ý tuân theo <a href="#" class="text-blue-500 underline">Điều khoản</a> của chúng tôi.</p>
                </div>
            </div>

        </form>
    </div>
</div>

<div id="successModal" class="fixed inset-0 z-50 flex items-center justify-center hidden opacity-0 transition-opacity duration-300">
    <div class="absolute inset-0 bg-black/50 backdrop-blur-sm"></div>

    <div class="relative bg-white rounded-3xl shadow-2xl p-8 md:p-10 max-w-sm w-full mx-4 text-center transform scale-95 transition-transform duration-300" id="modalContent">
        <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-green-100 mb-6">
            <svg class="h-10 w-10 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"></path>
            </svg>
        </div>

        <h3 class="text-2xl font-black text-gray-900 mb-2">Thanh toán thành công!</h3>
        <p class="text-gray-500 text-sm mb-8 leading-relaxed">
            Cảm ơn bạn đã mua sắm. Đơn hàng <b>#${newOrderId}</b> của bạn đã được ghi nhận và đang được chuẩn bị.
        </p>

        <button onclick="closeModalAndRedirect('userservlet?action=homePage')" class="w-full bg-gray-900 text-white font-bold h-12 rounded-xl hover:bg-gray-800 transition-colors">
            Tiếp tục mua sắm
        </button>
        <button onclick="closeModalAndRedirect('orderhistorypageservlet')" class="w-full mt-3 bg-white text-gray-600 border border-gray-200 font-bold h-12 rounded-xl hover:bg-gray-50 transition-colors">
            Xem lịch sử đơn hàng
        </button>
    </div>
</div>

<script>

    function changeSelectedAddress(radioElement) {
        // 1. Tìm tất cả các thẻ label có class address-card và reset về viền xám nền trắng
        let allCards = document.querySelectorAll('.address-card');
        allCards.forEach(card => {
            card.classList.remove('border-red-600', 'bg-red-50');
            card.classList.add('border-gray-100', 'bg-white');
        });

        // 2. Tìm thẻ label đang bọc cái radio vừa được click và đổi sang viền đỏ nền đỏ
        let selectedCard = radioElement.closest('.address-card');
        selectedCard.classList.remove('border-gray-100', 'bg-white');
        selectedCard.classList.add('border-red-600', 'bg-red-50');
    }

    // --- 1. SCRIPT ĐỔI ĐỊA CHỈ ---
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

    // --- 2. SCRIPT XỬ LÝ VOUCHER (Tính toán giao diện) ---

    let subTotal = ${totalAmount != null ? totalAmount : 0};
    let currentDiscount = 0;

    // 1. CHUYỂN JAVA LIST SANG JAVASCRIPT ARRAY
    const availableVouchers = [
    <c:forEach items="${listVoucher}" var="v" varStatus="loop">
    {
    code: '${v.code}',
            voucherId: ${v.voucherId},
            discountPercent: ${v.discountPercent},
            maxDiscountAmount: ${v.maxDiscountAmount},
            minOrderValue: ${v.minOrderValue},
            isAvailable: ${v.available} // Gọi hàm isAvailable() của Java trả về boolean (true/false)
    }${!loop.last ? ',' : ''}
    </c:forEach>
    ];

    function applyVoucher() {
        const inputCode = document.getElementById('voucherInput').value.trim().toUpperCase();
        const messageDiv = document.getElementById('voucherMessage');
        const discountDisplay = document.getElementById('discountDisplay');
        const totalDisplay = document.getElementById('totalDisplay');

        // Hàm format số thành tiền VNĐ
        const formatMoney = (amount) => amount.toLocaleString('vi-VN') + 'đ';

        if (inputCode === '') {
            currentDiscount = 0;
            document.getElementById('appliedVoucherId').value = "0"; // Xóa ID
            messageDiv.innerHTML = '<span class="text-red-500 font-medium">Vui lòng nhập mã giảm giá.</span>';
        } else {
            // 2. TÌM VOUCHER TRONG MẢNG
            const foundVoucher = availableVouchers.find(v => v.code.toUpperCase() === inputCode);

            if (foundVoucher) {
                // Bước 2.1: Kiểm tra voucher còn khả dụng không (Status, Số lượt dùng, Thời gian)
                if (!foundVoucher.isAvailable) {
                    currentDiscount = 0;
                    document.getElementById('appliedVoucherId').value = "0"; // Xóa ID
                    messageDiv.innerHTML = '<span class="text-red-500 font-medium">Mã giảm giá đã hết lượt sử dụng hoặc đã hết hạn!</span>';
                }
                // Bước 2.2: Kiểm tra đơn hàng có đạt mức tối thiểu không
                else if (subTotal < foundVoucher.minOrderValue) {
                    currentDiscount = 0;
                    document.getElementById('appliedVoucherId').value = "0"; // Xóa ID
                    messageDiv.innerHTML = `<span class="text-red-500 font-medium">Đơn hàng tối thiểu để áp dụng mã này là ` + formatMoney(foundVoucher.minOrderValue) + `!</span>`;
                }
                // Bước 2.3: Nếu thỏa mãn mọi điều kiện -> Tiến hành tính tiền
                else {
                    // Tính mức giảm dựa trên phần trăm (%)
                    let calculatedDiscount = subTotal * (foundVoucher.discountPercent / 100);

                    // So sánh với mức giảm tối đa (Cap)
                    if (foundVoucher.maxDiscountAmount > 0 && calculatedDiscount > foundVoucher.maxDiscountAmount) {
                        currentDiscount = foundVoucher.maxDiscountAmount; // Giới hạn số tiền giảm
                    } else {
                        currentDiscount = calculatedDiscount;
                    }

                    // Đề phòng trường hợp tiền giảm vượt quá tổng tiền
                    if (currentDiscount > subTotal) {
                        currentDiscount = subTotal;
                    }

                    // Gán ID để gửi về Servlet
                    document.getElementById('appliedVoucherId').value = foundVoucher.voucherId;

                    messageDiv.innerHTML = `<span class="text-green-600 font-medium flex items-center gap-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg> 
                    Áp dụng thành công giảm ` + formatMoney(currentDiscount) + `!</span>`;
                }
            } else {
                currentDiscount = 0;
                document.getElementById('appliedVoucherId').value = "0"; // Xóa ID
                messageDiv.innerHTML = '<span class="text-red-500 font-medium">Mã giảm giá không tồn tại!</span>';
            }
        }

        // 3. Cập nhật lại HTML hiển thị giá tiền
        discountDisplay.innerText = '-' + formatMoney(currentDiscount);
        let finalTotal = subTotal - currentDiscount;
        totalDisplay.innerText = formatMoney(finalTotal);
    }
    // --- 3. SCRIPT HIỂN THỊ MODAL THÀNH CÔNG ---
    const modal = document.getElementById('successModal');
    const modalContent = document.getElementById('modalContent');

    function showSuccessModal() {
        modal.classList.remove('hidden');
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            modalContent.classList.remove('scale-95');
            modalContent.classList.add('scale-100');
        }, 10);
    }

    function closeModalAndRedirect(targetUrl) {
        modal.classList.add('opacity-0');
        modalContent.classList.remove('scale-100');
        modalContent.classList.add('scale-95');

        setTimeout(() => {
            modal.classList.add('hidden');
            window.location.href = targetUrl || "userservlet?action=homePage";
        }, 300);
    }

    // Hiện popup khi vừa đặt hàng thành công (redirect với ?orderSuccess=1)
    if (window.location.search.includes('orderSuccess=1')) {
        showSuccessModal();
    }
</script>