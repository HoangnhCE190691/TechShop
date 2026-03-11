<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    /* Ẩn thanh cuộn nhưng vẫn cho phép cuộn ngang */
    .no-scrollbar::-webkit-scrollbar {
        display: none;
    }

    .no-scrollbar {
        -ms-overflow-style: none;
        scrollbar-width: none;
    }
</style>

<div class="container mx-auto max-w-screen-xl">

    <div class="w-full py-6">
        <figure
            class="w-full overflow-hidden rounded-2xl shadow-lg hover:shadow-xl transition-shadow duration-300">
            <img class="w-full h-auto object-cover hover:scale-[1.02] transition-transform duration-500"
                 src="../assets/img/banner/banner_TGDD_tet.png" alt="Banner Tết">
        </figure>
    </div>

    <div class="w-full my-8 bg-white p-6 rounded-2xl shadow-sm">
        <h3 class="text-2xl md:text-3xl font-bold mb-6 text-gray-800 flex items-center gap-2">
            <span class="text-yellow-400">⭐</span> Sản phẩm giá không rẻ
        </h3>

        <div class="ant-tabs ant-tabs-top">
            <div class="ant-tabs-nav" role="tablist">
                <div class="ant-tabs-nav-wrap border-b border-gray-200">
                    <div class="ant-tabs-nav-list flex gap-6 md:gap-8">
                        <div class="ant-tabs-tab tab-item active cursor-pointer pb-3 border-b-2 border-blue-600 text-blue-600 font-bold transition-colors"
                             onclick="switchTab(event, 'tab-1')">
                            <div class="ant-tabs-tab-btn text-base">Điện thoại</div>
                        </div>
                        <div class="ant-tabs-tab tab-item cursor-pointer pb-3 border-b-2 border-transparent text-gray-500 hover:text-blue-500 transition-colors"
                             onclick="switchTab(event, 'tab-2')">
                            <div class="ant-tabs-tab-btn text-base">Máy tính</div>
                        </div>
                        <div class="ant-tabs-tab tab-item cursor-pointer pb-3 border-b-2 border-transparent text-gray-500 hover:text-blue-500 transition-colors"
                             onclick="switchTab(event, 'tab-3')">
                            <div class="ant-tabs-tab-btn text-base">Phụ kiện</div>
                        </div>
                        <div class="ant-tabs-tab tab-item cursor-pointer pb-3 border-b-2 border-transparent text-gray-500 hover:text-blue-500 transition-colors"
                             onclick="switchTab(event, 'tab-4')">
                            <div class="ant-tabs-tab-btn text-base">Laptop</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="ant-tabs-content-holder mt-6">
                <!-- Tab 1: Điện thoại -->
                <div id="tab-1" class="tab-pane block fade-in">
                    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
                        <c:forEach var="p" items="${phoneList}">
                            <a href="detailservlet?productId=${p.productId}"
                               class="bg-white p-4 border border-gray-100 rounded-xl shadow-sm hover:shadow-xl hover:border-blue-200 transition-all duration-300 group cursor-pointer flex flex-col h-full block">
                                <div
                                    class="relative overflow-hidden mb-4 flex-shrink-0 rounded-lg bg-gray-50 p-2">
                                    <img class="w-full h-44 object-contain group-hover:scale-110 group-hover:-translate-y-2 transition-all duration-500"
                                         src="${empty p.thumbnailUrl ? '../assets/img/product/default.png' : p.thumbnailUrl}"
                                         alt="${p.name}">
                                </div>
                                <h3
                                    class="text-[14px] font-semibold leading-snug text-gray-800 mb-2 group-hover:text-blue-600 line-clamp-2 min-h-[40px]">
                                    ${p.name}
                                </h3>
                                <div class="mt-auto mb-2">
                                    <strong class="text-red-600 text-lg block">
                                        <fmt:formatNumber value="${p.minPrice != null ? p.minPrice : 0}"
                                                          type="number" groupingUsed="true" />₫
                                    </strong>
                                </div>
                            </a>
                        </c:forEach>
                        <c:if test="${empty phoneList}">
                            <div
                                class="col-span-full bg-gray-50 p-4 rounded-lg border border-dashed border-gray-300 text-center text-gray-400 font-medium">
                                Chưa có sản phẩm nào</div>
                            </c:if>
                    </div>
                </div>

                <!-- Tab 2: Máy tính -->
                <div id="tab-2" class="tab-pane hidden fade-in">
                    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
                        <c:forEach var="p" items="${computerList}">
                            <a href="detailservlet?productId=${p.productId}"
                               class="bg-white p-4 border border-gray-100 rounded-xl shadow-sm hover:shadow-xl hover:border-blue-200 transition-all duration-300 group cursor-pointer flex flex-col h-full block">
                                <div
                                    class="relative overflow-hidden mb-4 flex-shrink-0 rounded-lg bg-gray-50 p-2">
                                    <img class="w-full h-44 object-contain group-hover:scale-110 group-hover:-translate-y-2 transition-all duration-500"
                                         src="${empty p.thumbnailUrl ? '../assets/img/product/default.png' : p.thumbnailUrl}"
                                         alt="${p.name}">
                                </div>
                                <h3
                                    class="text-[14px] font-semibold leading-snug text-gray-800 mb-2 group-hover:text-blue-600 line-clamp-2 min-h-[40px]">
                                    ${p.name}
                                </h3>
                                <div class="mt-auto mb-2">
                                    <strong class="text-red-600 text-lg block">
                                        <fmt:formatNumber value="${p.minPrice != null ? p.minPrice : 0}"
                                                          type="number" groupingUsed="true" />₫
                                    </strong>
                                </div>
                            </a>
                        </c:forEach>
                        <c:if test="${empty computerList}">
                            <div
                                class="col-span-full bg-gray-50 p-4 rounded-lg border border-dashed border-gray-300 text-center text-gray-400 font-medium">
                                Chưa có sản phẩm nào</div>
                            </c:if>
                    </div>
                </div>

                <!-- Tab 3: Phụ kiện -->
                <div id="tab-3" class="tab-pane hidden fade-in">
                    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
                        <c:forEach var="p" items="${accessoryList}">
                            <a href="detailservlet?productId=${p.productId}"
                               class="bg-white p-4 border border-gray-100 rounded-xl shadow-sm hover:shadow-xl hover:border-blue-200 transition-all duration-300 group cursor-pointer flex flex-col h-full block">
                                <div
                                    class="relative overflow-hidden mb-4 flex-shrink-0 rounded-lg bg-gray-50 p-2">
                                    <img class="w-full h-44 object-contain group-hover:scale-110 group-hover:-translate-y-2 transition-all duration-500"
                                         src="${empty p.thumbnailUrl ? '../assets/img/product/default.png' : p.thumbnailUrl}"
                                         alt="${p.name}">
                                </div>
                                <h3
                                    class="text-[14px] font-semibold leading-snug text-gray-800 mb-2 group-hover:text-blue-600 line-clamp-2 min-h-[40px]">
                                    ${p.name}
                                </h3>
                                <div class="mt-auto mb-2">
                                    <strong class="text-red-600 text-lg block">
                                        <fmt:formatNumber value="${p.minPrice != null ? p.minPrice : 0}"
                                                          type="number" groupingUsed="true" />₫
                                    </strong>
                                </div>
                            </a>
                        </c:forEach>
                        <c:if test="${empty accessoryList}">
                            <div
                                class="col-span-full bg-gray-50 p-4 rounded-lg border border-dashed border-gray-300 text-center text-gray-400 font-medium">
                                Chưa có sản phẩm nào</div>
                            </c:if>
                    </div>
                </div>

                <!-- Tab 4: Laptop -->
                <div id="tab-4" class="tab-pane hidden fade-in">
                    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
                        <c:forEach var="p" items="${laptopList}">
                            <a href="detailservlet?productId=${p.productId}"
                               class="bg-white p-4 border border-gray-100 rounded-xl shadow-sm hover:shadow-xl hover:border-blue-200 transition-all duration-300 group cursor-pointer flex flex-col h-full block">
                                <div
                                    class="relative overflow-hidden mb-4 flex-shrink-0 rounded-lg bg-gray-50 p-2">
                                    <img class="w-full h-44 object-contain group-hover:scale-110 group-hover:-translate-y-2 transition-all duration-500"
                                         src="${empty p.thumbnailUrl ? '../assets/img/product/default.png' : p.thumbnailUrl}"
                                         alt="${p.name}">
                                </div>
                                <h3
                                    class="text-[14px] font-semibold leading-snug text-gray-800 mb-2 group-hover:text-blue-600 line-clamp-2 min-h-[40px]">
                                    ${p.name}
                                </h3>
                                <div class="mt-auto mb-2">
                                    <strong class="text-red-600 text-lg block">
                                        <fmt:formatNumber value="${p.minPrice != null ? p.minPrice : 0}"
                                                          type="number" groupingUsed="true" />₫
                                    </strong>
                                </div>
                            </a>
                        </c:forEach>
                        <c:if test="${empty laptopList}">
                            <div
                                class="col-span-full bg-gray-50 p-4 rounded-lg border border-dashed border-gray-300 text-center text-gray-400 font-medium">
                                Chưa có sản phẩm nào</div>
                            </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="animation-carousel" class="relative w-full my-10 shadow-lg rounded-2xl group"
         data-carousel="slide">
        <div class="relative h-[220px] md:h-[450px] overflow-hidden rounded-2xl bg-white">
            <div class="hidden duration-700 ease-in-out flex items-center justify-center"
                 data-carousel-item="active">
                <img src="../assets/img/carousel/colorOS.jpg" class="block w-full h-full object-cover"
                     alt="ColorOS">
            </div>
            <div class="hidden duration-700 ease-in-out flex items-center justify-center"
                 data-carousel-item>
                <img src="../assets/img/carousel/kynguyenmoi.png" class="block w-full h-full object-cover"
                     alt="Kỷ nguyên mới">
            </div>
            <div class="hidden duration-700 ease-in-out flex items-center justify-center"
                 data-carousel-item>
                <img src="../assets/img/carousel/tetsumvay.jpg" class="block w-full h-full object-cover"
                     alt="Tết sum vầy">
            </div>
        </div>

        <button type="button"
                class="absolute top-1/2 -translate-y-1/2 start-4 z-30 flex items-center justify-center w-12 h-12 rounded-full bg-white/50 hover:bg-white backdrop-blur-md shadow-md text-gray-800 transition-all opacity-70 group-hover:opacity-100 focus:outline-none"
                data-carousel-prev>
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
        </button>
        <button type="button"
                class="absolute top-1/2 -translate-y-1/2 end-4 z-30 flex items-center justify-center w-12 h-12 rounded-full bg-white/50 hover:bg-white backdrop-blur-md shadow-md text-gray-800 transition-all opacity-70 group-hover:opacity-100 focus:outline-none"
                data-carousel-next>
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
        </button>
    </div>

    <div class="relative my-12 bg-white p-6 rounded-2xl shadow-sm border border-red-50">
        <h2 class="text-2xl font-bold text-gray-800 uppercase mb-6 flex items-center gap-2">
            <span class="text-red-500 text-3xl">🔥</span> APPLE BRAND
        </h2>

        <button onclick="scrollProduct(-1)"
                class="absolute -left-5 top-[55%] -translate-y-1/2 z-10 bg-white shadow-xl border border-gray-100 w-12 h-12 rounded-full text-gray-600 hover:text-red-600 hover:border-red-600 transition-all flex items-center justify-center text-2xl focus:outline-none">
            ‹
        </button>

        <div id="productSlider"
             class="flex gap-4 overflow-x-auto scroll-smooth snap-x snap-mandatory pb-4 px-2 no-scrollbar">
            <c:forEach var="p" items="${appleList}">
                <div class="snap-start min-w-[240px] lg:min-w-[260px] flex-shrink-0">
                    <a href="detailservlet?productId=${p.productId}"
                       class="relative bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-xl hover:border-red-200 transition-all duration-300 p-4 group cursor-pointer h-full block">
                        <div
                            class="absolute top-0 left-0 bg-gradient-to-r from-red-600 to-red-500 text-white text-xs font-bold px-3 py-1.5 rounded-br-xl rounded-tl-xl z-10 shadow-md">
                            Tết 2026</div>
                        <div
                            class="absolute top-3 right-3 bg-gray-100 text-[10px] font-medium px-2.5 py-1 rounded-full text-gray-600 z-10 border border-gray-200">
                            Trả góp 0%</div>

                        <div class="mt-8 mb-4 overflow-hidden rounded-xl bg-gray-50 p-2">
                            <img src="../assets/img/product/default.png" class="w-full h-44 object-contain transition-transform duration-500 group-hover:scale-110">
                        </div>

                        <h3
                            class="text-sm font-semibold text-gray-800 group-hover:text-red-600 transition-colors line-clamp-2 min-h-[40px] mb-2">
                            ${p.name}
                        </h3>

                        <div class="mt-auto">
                            <p class="text-red-600 font-bold text-xl">
                                <fmt:formatNumber value="${p.minPrice != null ? p.minPrice : 0}"
                                                  type="number" groupingUsed="true" />₫
                            </p>
                        </div>
                    </a>
                </div>
            </c:forEach>
            <c:if test="${empty appleList}">
                <div
                    class="w-full bg-gray-50 p-4 rounded-lg border border-dashed border-gray-300 text-center text-gray-400 font-medium">
                    Chưa có sản phẩm nào</div>
                </c:if>
        </div>

        <button onclick="scrollProduct(1)"
                class="absolute -right-5 top-[55%] -translate-y-1/2 z-10 bg-white shadow-xl border border-gray-100 w-12 h-12 rounded-full text-gray-600 hover:text-red-600 hover:border-red-600 transition-all flex items-center justify-center text-2xl focus:outline-none">
            ›
        </button>
    </div>

    <div class="relative my-12 bg-white p-6 rounded-2xl shadow-sm border border-blue-50">
        <h2 class="text-2xl font-bold text-gray-800 uppercase mb-6 flex items-center gap-2">
            <span class="text-blue-500 text-3xl">❄️</span> SAMSUNG BRAND
        </h2>

        <button onclick="scrollProduct2(-1)"
                class="absolute -left-5 top-[55%] -translate-y-1/2 z-10 bg-white shadow-xl border border-gray-100 w-12 h-12 rounded-full text-gray-600 hover:text-blue-600 hover:border-blue-600 transition-all flex items-center justify-center text-2xl focus:outline-none">
            ‹
        </button>

        <div id="productSlider2"
             class="flex gap-4 overflow-x-auto scroll-smooth snap-x snap-mandatory pb-4 px-2 no-scrollbar">
            <c:forEach var="p" items="${samsungList}">
                <div class="snap-start min-w-[240px] lg:min-w-[260px] flex-shrink-0">
                    <a href="detailservlet?productId=${p.productId}"
                       class="relative bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-xl hover:border-blue-200 transition-all duration-300 p-4 group cursor-pointer h-full block">
                        <div
                            class="absolute top-0 left-0 bg-gradient-to-r from-blue-600 to-blue-500 text-white text-xs font-bold px-3 py-1.5 rounded-br-xl rounded-tl-xl z-10 shadow-md">
                            Tết 2026</div>
                        <div
                            class="absolute top-3 right-3 bg-gray-100 text-[10px] font-medium px-2.5 py-1 rounded-full text-gray-600 z-10 border border-gray-200">
                            Trả góp 0%</div>

                        <div class="mt-8 mb-4 overflow-hidden rounded-xl bg-gray-50 p-2">
                            <img src="${empty p.thumbnailUrl ? '../assets/img/product/default.png' : p.thumbnailUrl}"
                                 class="w-full h-44 object-contain transition-transform duration-500 group-hover:scale-110"
                                 alt="${p.name}">
                        </div>

                        <h3
                            class="text-sm font-semibold text-gray-800 group-hover:text-blue-600 transition-colors line-clamp-2 min-h-[40px] mb-2">
                            ${p.name}
                        </h3>

                        <div class="mt-auto">
                            <p class="text-red-600 font-bold text-xl">
                                <fmt:formatNumber value="${p.minPrice != null ? p.minPrice : 0}"
                                                  type="number" groupingUsed="true" />₫
                            </p>
                        </div>
                    </a>
                </div>
            </c:forEach>
            <c:if test="${empty samsungList}">
                <div
                    class="w-full bg-gray-50 p-4 rounded-lg border border-dashed border-gray-300 text-center text-gray-400 font-medium">
                    Chưa có sản phẩm nào</div>
                </c:if>
        </div>

        <button onclick="scrollProduct2(1)"
                class="absolute -right-5 top-[55%] -translate-y-1/2 z-10 bg-white shadow-xl border border-gray-100 w-12 h-12 rounded-full text-gray-600 hover:text-blue-600 hover:border-blue-600 transition-all flex items-center justify-center text-2xl focus:outline-none">
            ›
        </button>
    </div>


    <div
        class="w-full max-w-[1200px] mx-auto my-12 bg-white p-6 rounded-2xl shadow-sm border border-red-50">
        <h2 class="text-2xl font-bold text-gray-800 uppercase mb-6 flex items-center gap-2">
            <span class="text-red-500 text-3xl">🎁</span> Món quà công nghệ
        </h2>

        <div class="grid grid-cols-1 lg:grid-cols-4 lg:grid-rows-3 gap-4 lg:h-[600px]">

            <div
                class="relative w-full h-[300px] lg:h-full rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 lg:col-start-1 lg:row-start-1 lg:row-span-2 group">
                <img src="/assets/img/Other/desk_block_6_03_ec4f7f4459.webp"
                     class="w-full h-full object-cover group-hover:scale-[1.03] transition-transform duration-700"
                     alt="">
            </div>

            <div
                class="relative w-full h-[200px] lg:h-full rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 lg:col-start-1 lg:row-start-3 group">
                <img src="/assets/img/Other/desk_block_6_02_0005292b04.webp"
                     class="w-full h-full object-cover group-hover:scale-[1.03] transition-transform duration-700"
                     alt="">
            </div>

            <div
                class="relative w-full h-[400px] lg:h-full rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 lg:col-start-2 lg:col-span-2 lg:row-start-1 lg:row-span-3 group">
                <img src="/assets/img/Other/desk_block_6_01_0a33a33b56.webp"
                     class="w-full h-full object-cover group-hover:scale-[1.03] transition-transform duration-700"
                     alt="">
            </div>

            <div
                class="relative w-full h-[200px] lg:h-full rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 lg:col-start-4 lg:row-start-1 group">
                <img src="/assets/img/Other/desk_block_6_06_a957eb885c.webp"
                     class="w-full h-full object-cover group-hover:scale-[1.03] transition-transform duration-700"
                     alt="">
            </div>

            <div
                class="relative w-full h-[200px] lg:h-full rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 lg:col-start-4 lg:row-start-2 group">
                <img src="/assets/img/Other/desk_block_6_05_a711c23f81.webp"
                     class="w-full h-full object-cover group-hover:scale-[1.03] transition-transform duration-700"
                     alt="">
            </div>

            <div
                class="relative w-full h-[200px] lg:h-full rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 lg:col-start-4 lg:row-start-3 group">
                <img src="/assets/img/Other/desk_block_6_04_eb61c25602.webp"
                     class="w-full h-full object-cover group-hover:scale-[1.03] transition-transform duration-700"
                     alt="">
            </div>

        </div>
    </div>

</div>

<script>
    // --- LOGIC TABS ---
    function switchTab(event, tabId) {
        // Ẩn tất cả tab-pane
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.replace('block', 'hidden'));
        document.getElementById(tabId).classList.replace('hidden', 'block');

        // Bỏ active của tất cả tab-item
        document.querySelectorAll('.tab-item').forEach(item => {
            item.classList.remove('active', 'border-blue-600', 'text-blue-600', 'font-bold');
            item.classList.add('border-transparent', 'text-gray-500');
        });

        // Thêm active cho tab hiện tại
        event.currentTarget.classList.add('active', 'border-blue-600', 'text-blue-600', 'font-bold');
        event.currentTarget.classList.remove('border-transparent', 'text-gray-500');
    }

    // --- LOGIC CUỘN SẢN PHẨM ---
    function scrollProduct(direction) {
        const slider = document.getElementById("productSlider");
        // Cuộn vừa bằng chiều rộng của 1 card (khoảng 260px)
        const scrollAmount = 280;
        slider.scrollBy({
            left: direction * scrollAmount,
            behavior: "smooth"
        });
    }

    // --- LOGIC CAROUSEL CHẠY TỰ ĐỘNG ---
    document.addEventListener('DOMContentLoaded', function () {
        const carousel = document.getElementById('animation-carousel');
        if (!carousel)
            return;

        const items = carousel.querySelectorAll('[data-carousel-item]');
        const btnPrev = carousel.querySelector('[data-carousel-prev]');
        const btnNext = carousel.querySelector('[data-carousel-next]');
        let currentIndex = 0;
        let slideInterval;

        function showSlide(index) {
            items.forEach((item, i) => {
                if (i === index) {
                    item.classList.remove('hidden');
                    item.setAttribute('data-carousel-item', 'active');
                } else {
                    item.classList.add('hidden');
                    item.removeAttribute('data-carousel-item');
                }
            });
        }

        function nextSlide() {
            currentIndex = (currentIndex + 1) % items.length;
            showSlide(currentIndex);
        }

        function prevSlide() {
            currentIndex = (currentIndex - 1 + items.length) % items.length;
            showSlide(currentIndex);
        }

        btnNext.addEventListener('click', () => {
            nextSlide();
            resetInterval();
        });
        btnPrev.addEventListener('click', () => {
            prevSlide();
            resetInterval();
        });

        function startInterval() {
            slideInterval = setInterval(nextSlide, 3500);
        }
        function resetInterval() {
            clearInterval(slideInterval);
            startInterval();
        }

        showSlide(currentIndex);
        startInterval();
    });
    // --- LOGIC CUỘN SẢN PHẨM 2 ---
    function scrollProduct2(direction) {
        const slider = document.getElementById("productSlider2");
        const scrollAmount = 280;
        slider.scrollBy({
            left: direction * scrollAmount,
            behavior: "smooth"
        });
    }
</script>