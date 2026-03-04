<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div class="max-w-[1200px] mx-auto px-4 py-10 font-sans text-gray-800 bg-white">

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-14">

        <div class="lg:col-span-5 flex flex-col gap-4">

            <a id="mainImageLink"
               href="${not empty images ? pageContext.request.contextPath.concat('/').concat(images[0].imageUrl) : pageContext.request.contextPath.concat('/assest/img/product/samsung-galaxy-s25-green-thumbai-600x600.jpg')}"
               data-fancybox="gallery"
               class="cursor-zoom-in border border-gray-100 rounded-3xl overflow-hidden p-6 flex items-center justify-center bg-gray-50 aspect-square shadow-sm transition-shadow hover:shadow-md">
                <img id="mainImage"
                     src="${not empty images ? pageContext.request.contextPath.concat('/').concat(images[0].imageUrl) : pageContext.request.contextPath.concat('/assest/img/product/samsung-galaxy-s25-green-thumbai-600x600.jpg')}"
                     alt="${product.name}"
                     class="w-full h-full object-contain mix-blend-multiply transition-transform duration-300 hover:scale-105">
            </a>

            <div class="flex gap-3 justify-center overflow-x-auto pb-2 snap-x">
                <c:forEach var="img" items="${images}">
                    <button
                        onclick="changeImage(event, '${pageContext.request.contextPath}/${img.imageUrl}', '${pageContext.request.contextPath}/${img.imageUrl}')"
                        class="thumb-btn snap-center flex-shrink-0 w-20 h-20 border-2 border-gray-100 hover:border-red-300 transition-all rounded-2xl p-1 bg-white hover:shadow-sm ${img.imageUrl == images[0].imageUrl ? 'border-red-500' : ''}">
                        <img src="${pageContext.request.contextPath}/${img.imageUrl}"
                             class="w-full h-full object-contain rounded-xl">
                    </button>
                </c:forEach>
            </div>
        </div>

        <div class="lg:col-span-7 flex flex-col">
            <h1 class="text-3xl lg:text-4xl font-extrabold text-gray-900 mb-3 tracking-tight">
                ${product.name}</h1>
            <div class="flex items-center gap-3 mb-6 text-sm">
                <div class="flex items-center text-yellow-400 text-base">
                    ★★★★★ <span class="text-gray-500 ml-2 text-sm font-medium">(50 đánh giá)</span>
                </div>
                <span class="w-1.5 h-1.5 rounded-full bg-gray-300"></span>
                <span class="text-green-600 font-semibold flex items-center gap-1">
                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"
                         xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd"
                              d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                              clip-rule="evenodd"></path>
                    </svg>
                    Tình trạng: Còn hàng
                </span>
            </div>

            <div
                class="bg-gradient-to-r from-red-50 to-white border border-red-100 p-5 rounded-2xl mb-8 flex items-baseline gap-4">
                <span id="displayPrice" class="text-4xl font-black text-red-600 tracking-tight">
                    <fmt:formatNumber value="${not empty variants ? variants[0].sellingPrice : 0}"
                                      type="number" groupingUsed="true" />đ
                </span>
            </div>

            <div class="mb-6">
                <h3 class="font-bold text-gray-900 mb-3 uppercase text-xs tracking-wider">Phiên bản: </h3>
                <div class="flex flex-wrap gap-3">
                    <c:forEach var="v" items="${variants}" varStatus="status">
                        <button onclick="selectVariant(event, '${v.sellingPrice}', '${v.variantId}')"
                                class="variant-btn px-5 py-2.5 border-2 rounded-xl transition-all ${status.first ? 'border-red-600 text-red-600 font-bold bg-red-50 selected' : 'border-gray-200 text-gray-600 font-semibold hover:border-gray-400'}">
                            ${v.sku}
                        </button>
                    </c:forEach>
                </div>
            </div>

            <div class="flex flex-wrap sm:flex-nowrap gap-4 mt-auto">
                <div class="flex items-center border border-gray-200 rounded-xl h-14 bg-gray-50 p-1">
                    <button onclick="updateQuantity(-1)"
                            class="w-10 h-full flex items-center justify-center text-gray-500 hover:bg-white hover:shadow-sm rounded-lg transition-all text-xl">-</button>
                    <input type="text" id="qtyInput" value="1"
                           class="w-12 h-full text-center border-none bg-transparent focus:ring-0 text-gray-900 font-bold pointer-events-none"
                           readonly>
                        <button onclick="updateQuantity(1)"
                                class="w-10 h-full flex items-center justify-center text-gray-500 hover:bg-white hover:shadow-sm rounded-lg transition-all text-xl">+</button>
                </div>
                <button
                    class="flex-1 h-14 border-2 border-red-600 text-red-600 font-bold text-lg rounded-xl hover:bg-red-600 hover:text-white transition-colors duration-300 flex items-center justify-center gap-2 shadow-sm">
                    🛒 Thêm vào giỏ
                </button>
            </div>
        </div>
    </div>

    <div class="mt-16 grid grid-cols-1 lg:grid-cols-12 gap-10">
        <!-- Mô tả sản phẩm -->
        <div class="lg:col-span-7 xl:col-span-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                Mô tả sản phẩm
            </h2>
            <div class="border border-gray-200 rounded-3xl p-6 md:p-8 bg-white shadow-sm">
                <div class="text-gray-700 leading-relaxed prose max-w-none">
                    ${product.description != null ? product.description : 'Đang cập nhật mô tả sản phẩm...'}
                </div>
            </div>
        </div>

        <!-- Thông số kỹ thuật -->
        <div class="lg:col-span-5 xl:col-span-4">
            <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                Thông số kỹ thuật
            </h2>
            <div class="border border-gray-200 rounded-3xl p-6 bg-white shadow-sm">
                <c:if test="${not empty specs}">
                    <div
                        class="flex flex-col border border-gray-100 rounded-2xl overflow-hidden divide-y divide-gray-100">
                        <c:forEach var="s" items="${specs}" varStatus="loop">
                            <div
                                class="flex px-4 py-3.5 ${loop.index % 2 == 0 ? 'bg-gray-50' : 'bg-white'}">
                                <div class="w-1/3 text-gray-500 font-medium text-sm flex-shrink-0 pr-2">
                                    ${s.specName}:</div>
                                <div class="w-2/3 text-gray-900 text-sm font-medium">
                                    ${s.specValue} ${(not empty s.unit and s.unit ne '-') ? s.unit : ''}
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
                <c:if test="${empty specs}">
                    <div
                        class="text-center py-8 text-gray-500 bg-gray-50 rounded-2xl border border-gray-100">
                        Đang cập nhật thông số...
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <div class="mt-16 border border-gray-200 rounded-3xl p-6 md:p-10 bg-white shadow-sm mb-12" id="reviews-section">
        <h2 class="text-2xl font-bold text-gray-900 mb-8">Đánh giá sản phẩm</h2>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 items-center bg-gray-50 rounded-2xl p-6 mb-10 border border-gray-100">
            <div class="flex flex-col items-center justify-center text-center">
                <span class="text-6xl font-black text-red-600">
                    <fmt:formatNumber value="${averageRating}" maxFractionDigits="1" minFractionDigits="1" />
                </span>
                <div class="flex text-yellow-400 text-xl mt-3 mb-1">
                    <c:forEach begin="1" end="5" var="i">
                        <c:choose>
                            <c:when test="${i <= averageRating}">★</c:when>
                            <c:when test="${i - 0.5 <= averageRating}">★</c:when> <%-- Nửa sao, thực ra unicode k có nửa nên hiển thị sao đen --%>
                            <c:otherwise><span class="text-gray-300">★</span></c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
                <span class="text-gray-500 text-sm font-medium">Dựa trên ${totalReviews} đánh giá</span>
            </div>

            <div class="flex flex-col gap-2.5">
                <c:forEach begin="1" end="5" step="1" var="star">
                    <c:set var="idx" value="${6 - star}" /> <!-- 5, 4, 3, 2, 1 -->
                    <div class="flex items-center gap-3 text-sm">
                        <span class="text-gray-700 font-bold w-12">${idx} sao</span>
                        <div class="flex-1 h-2.5 bg-gray-200 rounded-full overflow-hidden">
                            <div class="h-full bg-red-500 rounded-full" style="width: ${starPercentages[idx]}%"></div>
                        </div>
                        <span class="text-gray-500 text-xs font-bold w-8 text-right">${starPercentages[idx]}%</span>
                    </div>
                </c:forEach>
            </div>

            <div class="flex justify-center md:justify-end">
                <c:choose>
                    <c:when test="${userReview != null}">
                        <button onclick="openReviewModal(true)"
                                class="bg-white border-2 border-blue-600 text-blue-600 font-bold py-3 px-8 rounded-xl hover:bg-blue-600 hover:text-white transition-all duration-300 shadow-sm">
                            ✍️ Sửa đánh giá của bạn
                        </button>
                    </c:when>
                    <c:when test="${canReview}">
                        <button onclick="openReviewModal(false)"
                                class="bg-white border-2 border-red-600 text-red-600 font-bold py-3 px-8 rounded-xl hover:bg-red-600 hover:text-white transition-all duration-300 shadow-sm">
                            ✍️ Viết đánh giá của bạn
                        </button>
                    </c:when>
                    <c:when test="${empty cookie.cookieID.value}">
                        <a href="userservlet?action=loginPage"
                           class="bg-gray-100 border border-gray-300 text-gray-600 font-semibold py-3 px-6 rounded-xl hover:bg-gray-200 transition-all text-center">
                            Đăng nhập để đánh giá
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="text-sm text-gray-500 text-center px-4">
                            Bạn cần mua <br/> sản phẩm này để đánh giá.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="space-y-8">
            <c:choose>
                <c:when test="${empty productReviews}">
                    <div class="text-center py-10 text-gray-500">Chưa có đánh giá nào cho sản phẩm này.</div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="rev" items="${productReviews}">
                        <div class="flex gap-5 border-b border-gray-100 pb-8 last:border-0 last:pb-0">
                            <div class="w-14 h-14 bg-gray-200 rounded-full flex items-center justify-center font-bold text-gray-600 text-xl flex-shrink-0 uppercase">
                                ${fn:substring(rev.customerName, 0, 1)}
                            </div>
                            <div class="flex-1">
                                <div class="flex items-center justify-between mb-1">
                                    <h4 class="font-bold text-gray-900 text-base">${rev.customerName}</h4>
                                    <span class="text-sm text-gray-400 font-medium">${rev.formattedDate}</span>
                                </div>
                                <div class="text-yellow-400 text-sm mb-3 tracking-widest">
                                    <c:forEach begin="1" end="5" var="i">
                                        <c:choose>
                                            <c:when test="${i <= rev.rating}">★</c:when>
                                            <c:otherwise><span class="text-gray-300">★</span></c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                                <p class="text-gray-700 text-base leading-relaxed mb-4">
                                    ${rev.comment}
                                </p>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Review Modal Form -->
    <div id="reviewModal" class="fixed inset-0 z-[100] hidden bg-black bg-opacity-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl w-full max-w-lg shadow-xl overflow-hidden transform transition-all">
            <div class="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                <h3 id="modalTitle" class="text-xl font-bold text-gray-900">Viết đánh giá</h3>
                <button type="button" onclick="closeReviewModal()" class="text-gray-400 hover:text-gray-600 focus:outline-none">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <form action="reviewservlet" method="POST" class="p-6">
                <input type="hidden" name="productId" value="${product.productId}">
                    <input type="hidden" name="action" id="reviewAction" value="add">
                        <input type="hidden" name="reviewId" id="reviewId" value="${userReview != null ? userReview.reviewId : ''}">
                            <input type="hidden" name="rating" id="reviewRating" value="${userReview != null ? userReview.rating : 5}">

                                <div class="mb-6 flex flex-col items-center">
                                    <p class="text-sm font-medium text-gray-700 mb-2">Chất lượng sản phẩm</p>
                                    <div class="flex gap-2 text-3xl cursor-pointer" id="starContainer">
                                        <c:set var="initialRating" value="${userReview != null ? userReview.rating : 5}"/>
                                        <c:forEach begin="1" end="5" var="i">
                                            <span data-value="${i}" onclick="setRating(${i})" class="star-btn transition-colors ${i <= initialRating ? 'text-yellow-400' : 'text-gray-300'}">★</span>
                                        </c:forEach>
                                    </div>
                                    <span id="ratingText" class="text-sm text-red-500 font-medium mt-2">Tuyệt vời</span>
                                </div>

                                <div class="mb-6">
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Cảm nhận của bạn</label>
                                    <textarea name="comment" id="reviewComment" rows="4" required
                                              class="w-full p-3 border border-gray-300 rounded-xl focus:ring-red-500 focus:border-red-500 resize-none text-gray-700"
                                              placeholder="Hãy chia sẻ trải nghiệm của bạn về sản phẩm này nhé...">${userReview != null ? userReview.comment : ''}</textarea>
                                </div>

                                <div class="flex gap-3 justify-end">
                                    <button type="button" onclick="closeReviewModal()"
                                            class="px-5 py-2.5 border border-gray-300 rounded-xl text-gray-700 font-medium hover:bg-gray-50 transition-colors">
                                        Hủy
                                    </button>
                                    <button type="submit"
                                            class="px-5 py-2.5 bg-red-600 rounded-xl text-white font-medium hover:bg-red-700 shadow-sm transition-colors">
                                        Gửi đánh giá
                                    </button>
                                </div>
                                </form>
                                </div>
                                </div>

                                </div>

                                <script src="https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.umd.js"></script>

                                <script>
                                        // 1. Khởi tạo Fancybox
                                        Fancybox.bind('[data-fancybox="gallery"]', {
                                            hideScrollbar: false,
                                        });

                                        // 2. Hàm đổi ảnh khi click ảnh thu nhỏ
                                        function changeImage(event, newImgSrc, newHighResSrc) {
                                            document.getElementById('mainImage').src = newImgSrc;
                                            document.getElementById('mainImageLink').href = newHighResSrc;

                                            let buttons = document.querySelectorAll('.thumb-btn');
                                            buttons.forEach(btn => {
                                                btn.classList.remove('border-red-500');
                                                btn.classList.add('border-gray-100');
                                            });

                                            event.currentTarget.classList.remove('border-gray-100');
                                            event.currentTarget.classList.add('border-red-500');
                                        }

                                        // 3. Xử lý click chọn Phiên bản
                                        function selectVariant(event, price, variantId) {
                                            // Lấy danh sách tất cả các nút
                                            let buttons = document.querySelectorAll('.variant-btn');

                                            // Reset tất cả các nút về trạng thái xám (không chọn)
                                            buttons.forEach(btn => {
                                                btn.className = "variant-btn px-5 py-2.5 border border-gray-200 text-gray-600 font-semibold rounded-xl hover:border-gray-400 transition-all";
                                            });

                                            // Đổi màu nút vừa được click thành màu đỏ (đã chọn)
                                            let clickedBtn = event.currentTarget;
                                            clickedBtn.className = "variant-btn px-5 py-2.5 border-2 border-red-600 text-red-600 font-bold rounded-xl bg-red-50 transition-all selected";
                                            clickedBtn.dataset.variantId = variantId;

                                            // Update price
                                            document.getElementById('displayPrice').innerText = price.toLocaleString('vi-VN') + 'đ';
                                        }

                                        // 5. Nút tăng giảm số lượng
                                        function updateQuantity(change) {
                                            let input = document.getElementById('qtyInput');
                                            let currentVal = parseInt(input.value);
                                            let newVal = currentVal + change;

                                            // Đảm bảo số lượng không thể rớt xuống số 0 hoặc âm
                                            if (newVal >= 1) {
                                                input.value = newVal;
                                            }
                                        }

                                        // 6. Xử lý logic Modal Đánh giá
                                        function openReviewModal(isEdit) {
                                            document.getElementById('reviewModal').classList.remove('hidden');
                                            document.getElementById('reviewAction').value = isEdit ? 'edit' : 'add';
                                            document.getElementById('modalTitle').innerText = isEdit ? 'Sửa đánh giá của bạn' : 'Viết đánh giá';

                                            // Trigger setRating text based on initial/current value
                                            let val = document.getElementById('reviewRating').value;
                                            setRating(val);
                                        }

                                        function closeReviewModal() {
                                            document.getElementById('reviewModal').classList.add('hidden');
                                        }

                                        function setRating(rating) {
                                            document.getElementById('reviewRating').value = rating;

                                            // Update UI
                                            let stars = document.querySelectorAll('.star-btn');
                                            stars.forEach(star => {
                                                if (parseInt(star.dataset.value) <= rating) {
                                                    star.classList.remove('text-gray-300');
                                                    star.classList.add('text-yellow-400');
                                                } else {
                                                    star.classList.remove('text-yellow-400');
                                                    star.classList.add('text-gray-300');
                                                }
                                            });

                                            // Update Text
                                            let textSpan = document.getElementById('ratingText');
                                            let texts = ["Tệ", "Không hài lòng", "Bình thường", "Hài lòng", "Tuyệt vời"];
                                            textSpan.innerText = texts[rating - 1];

                                            // Update text color
                                            let colors = ["text-gray-500", "text-orange-500", "text-blue-500", "text-green-500", "text-red-500"];
                                            textSpan.className = "text-sm font-medium mt-2 " + colors[rating - 1];
                                        }
                                </script>