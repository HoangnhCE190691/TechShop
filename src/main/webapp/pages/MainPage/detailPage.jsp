<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="bg-gray-50 min-h-screen pb-12 font-sans text-gray-800">
    <div class="max-w-[1200px] mx-auto px-4 py-8 md:py-12">

        <%-- 1. BREADCRUMB --%>
        <nav class="flex items-center gap-2 mb-8 text-sm text-gray-500">
            <a href="${pageContext.request.contextPath}/homepageservlet"
               class="text-blue-600 font-bold hover:underline">Home</a>
            <span class="text-gray-300">/</span>
            <c:if test="${not empty product.categoryName}">
                <a href="${pageContext.request.contextPath}/productpageservlet?categoryId=${product.categoryId}"
                   class="text-blue-600 font-bold hover:underline">${product.categoryName}</a>
                <span class="text-gray-300">/</span>
            </c:if>
            <c:if test="${not empty product.brandName}">
                <a href="${pageContext.request.contextPath}/productpageservlet?brandId=${product.brandId}"
                   class="text-blue-600 font-bold hover:underline">${product.brandName}</a>
                <span class="text-gray-300">/</span>
            </c:if>
            <span class="font-bold text-gray-900 truncate">${product.name}</span>
        </nav>

        <%-- 2. PRODUCT MAIN --%>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-10 mb-12">
            <%-- Left: Gallery --%>
            <div class="space-y-4">
                <a id="mainImageLink"
                   href="${not empty images ? pageContext.request.contextPath.concat('/').concat(images[0].imageUrl) : pageContext.request.contextPath.concat('/assets/img/product/default.png')}"
                   data-fancybox="gallery"
                   class="block aspect-square bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm flex items-center justify-center overflow-hidden cursor-zoom-in">
                    <img id="mainImage"
                         class="max-w-full max-h-full object-contain hover:scale-105 transition-transform duration-500"
                         src="${not empty images ? pageContext.request.contextPath.concat('/').concat(images[0].imageUrl) : pageContext.request.contextPath.concat('/assets/img/product/default.png')}"
                         alt="${product.name}">
                </a>
                <div class="flex gap-3 overflow-x-auto pb-2 no-scrollbar">
                    <c:forEach var="img" items="${images}" varStatus="st">
                        <div onclick="changeImage(this, '${pageContext.request.contextPath}/${img.imageUrl}')"
                             class="thumb-item w-20 h-20 flex-shrink-0 p-1 border-2 ${st.first ? 'border-red-500 shadow-md active' : 'border-gray-100'} rounded-xl cursor-pointer bg-white transition-all">
                            <img src="${pageContext.request.contextPath}/${img.imageUrl}"
                                 class="w-full h-full object-contain rounded-lg">
                        </div>
                    </c:forEach>
                </div>
            </div>

            <%-- Right: Product Info --%>
            <div class="flex flex-col">
                <h1 class="text-3xl font-black text-gray-900 mb-4 tracking-tight">
                    ${product.name}</h1>

                <div class="flex items-center gap-4 mb-6">
                    <div
                        class="flex items-center gap-1 bg-yellow-50 px-3 py-1 rounded-full">
                        <span class="text-yellow-600 font-bold text-lg">
                            <fmt:formatNumber value="${averageRating}"
                                              maxFractionDigits="1" minFractionDigits="1" />
                        </span>
                        <span class="text-yellow-400 text-xl">★</span>
                    </div>
                    <span class="text-gray-400 text-sm font-bold">(${totalReviews}
                        reviews)</span>
                    <div class="h-4 w-[1px] bg-gray-200"></div>
                    <span class="flex items-center gap-1.5 font-bold text-sm"
                          id="stockStatus"></span>
                </div>

                <%-- Price Box --%>
                <div
                    class="bg-white border border-gray-100 rounded-3xl p-6 mb-8 shadow-sm">
                    <p
                        class="text-gray-500 text-xs font-black uppercase tracking-widest mb-1">
                        Product Price</p>
                    <div class="text-4xl font-black text-red-600 tracking-tighter"
                         id="displayPrice">
                        <fmt:formatNumber
                            value="${not empty variants ? variants[0].sellingPrice : 0}"
                            type="number" groupingUsed="true" />đ
                    </div>
                </div>

                <%-- Variant Selectors --%>
                <div id="variantSelectors" class="mb-8"></div>

                <%-- Thêm giỏ --%>
                <form id="addToCartForm"
                      action="${pageContext.request.contextPath}/cartservlet"
                      method="post"
                      class="mt-auto flex flex-wrap gap-4 pt-6 border-t border-gray-100">
                    <input type="hidden" name="action" value="add" />
                    <input type="hidden" name="variant_id"
                           id="formVariantId" value="" />

                    <div
                        class="flex items-center bg-gray-50 border border-gray-200 p-1 rounded-2xl h-14 w-32">
                        <button type="button" id="qtyMinusBtn"
                                onclick="updateQuantity(-1)"
                                class="qty-step-btn w-10 h-full flex items-center justify-center font-bold text-gray-400 hover:text-black hover:bg-white rounded-xl transition-all disabled:opacity-40 disabled:pointer-events-none">−</button>
                        <input type="text" id="qtyInput" name="quantity"
                               value="1"
                               class="w-12 bg-transparent text-center font-black text-lg border-0 outline-none focus:outline-none focus:ring-0 shadow-none appearance-none"
                               readonly>
                        <button type="button" id="qtyPlusBtn"
                                onclick="updateQuantity(1)"
                                class="qty-step-btn w-10 h-full flex items-center justify-center font-bold text-gray-400 hover:text-black hover:bg-white rounded-xl transition-all disabled:opacity-40 disabled:pointer-events-none">+</button>
                    </div>

                    <button type="submit" id="addToCartBtn"
                            class="flex-1 bg-red-600 hover:bg-red-700 disabled:bg-gray-300 text-white font-black text-lg rounded-2xl h-14 shadow-lg transition-all flex items-center justify-center gap-3 active:scale-95">
                        <svg class="w-6 h-6" fill="none"
                             stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round"
                              stroke-linejoin="round" stroke-width="2"
                              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z">
                        </path>
                        </svg>
                        ADD TO CART
                    </button>
                </form>
            </div>
        </div>

        <%-- 3. SPECIFICATIONS & DESCRIPTION --%>
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 mb-12 items-start">
            <div
                class="lg:col-span-7 bg-white border border-gray-100 rounded-[2rem] overflow-hidden shadow-sm">
                <div
                    class="px-6 py-4 bg-gray-50 border-b border-gray-100 font-black uppercase text-xs tracking-widest text-gray-500">
                    📝 Description</div>
                <div class="p-8 text-gray-600 leading-relaxed text-base">
                    ${not empty product.description ? product.description : 'Product
                      description is being updated...'}
                </div>
            </div>

            <div
                class="lg:col-span-5 bg-white border border-gray-100 rounded-[2rem] overflow-hidden shadow-sm">
                <div
                    class="px-6 py-4 bg-gray-50 border-b border-gray-100 font-black uppercase text-xs tracking-widest text-gray-500">
                    ⚙️ Specifications</div>
                <div class="p-2">
                    <div class="divide-y divide-gray-50">
                        <div id="dynamic-variant-specs"></div>
                        <c:choose>
                            <c:when test="${not empty specs}">
                                <c:forEach var="s" items="${specs}">
                                    <div
                                        class="flex px-4 py-3 hover:bg-gray-50 transition-colors rounded-xl justify-between items-center">
                                        <span
                                            class="text-gray-400 font-bold text-sm">${s.specName}</span>
                                        <span
                                            class="text-gray-900 font-black text-sm text-right">
                                            ${s.specValue} ${(not empty s.unit and s.unit ne
                                              '-') ? s.unit : ''}
                                        </span>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div id="no-specs-msg"
                                     class="py-8 text-center text-gray-400 italic text-sm">
                                    Updating specifications...</div>
                                </c:otherwise>
                            </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <%--=====REVIEWS SECTION=====--%>
        <div class="bg-white border border-gray-100 rounded-[2rem] overflow-hidden shadow-sm mb-12"
             id="reviews-section">
            <div
                class="px-6 py-4 bg-gray-50 border-b border-gray-100 font-black uppercase text-xs tracking-widest text-gray-500">
                ⭐ Customer Reviews</div>

            <div
                class="grid grid-cols-1 md:grid-cols-3 gap-8 p-8 border-b border-gray-100 bg-gray-50/30">
                <%-- Average Score --%>
                <div class="text-center space-y-2">
                    <div class="text-6xl font-black text-red-600 leading-none">
                        <fmt:formatNumber value="${averageRating}"
                                          maxFractionDigits="1" minFractionDigits="1" />
                    </div>
                    <div class="text-yellow-400 text-2xl">
                        <c:forEach begin="1" end="5" var="i">
                            <c:choose>
                                <c:when test="${i <= averageRating}">★</c:when>
                                <c:otherwise><span class="text-gray-200">★</span>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                    </div>
                    <p class="text-sm font-bold text-gray-400 italic">Based on
                        ${totalReviews} reviews</p>
                </div>

                <%-- Progress Bars --%>
                <div class="space-y-2">
                    <c:forEach begin="1" end="5" step="1" var="star">
                        <c:set var="idx" value="${6 - star}" />
                        <div class="flex items-center gap-3 text-sm">
                            <span
                                class="w-12 text-right font-black text-gray-600">${idx}
                                ★</span>
                            <div
                                class="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
                                <div class="h-full bg-red-600 rounded-full"
                                     style="width: ${starPercentages[idx]}%">
                                </div>
                            </div>
                            <span
                                class="w-10 text-gray-400 font-bold text-xs">${starPercentages[idx]}%</span>
                        </div>
                    </c:forEach>
                </div>

                <%-- Action Button --%>
                <div class="flex items-center justify-center">
                    <c:choose>
                        <c:when test="${userReview != null}">
                            <button type="button"
                                    onclick="openReviewModal(true)"
                                    class="px-6 py-3 bg-white border-2 border-blue-600 text-blue-600 font-black rounded-2xl hover:bg-blue-600 hover:text-white transition-all text-xs cursor-pointer">✍️
                                EDIT YOUR REVIEW</button>
                            </c:when>
                            <c:when test="${canReview}">
                            <button type="button"
                                    onclick="openReviewModal(false)"
                                    class="px-6 py-3 bg-red-600 text-white font-black rounded-2xl hover:bg-red-700 transition-all shadow-md text-xs cursor-pointer">✍️
                                WRITE A REVIEW</button>
                            </c:when>
                            <c:otherwise>
                            <p
                                class="text-xs text-gray-400 font-bold italic text-center max-w-[150px]">
                                Must purchase this product to leave a
                                review.</p>
                            </c:otherwise>
                        </c:choose>
                </div>
            </div>

            <%-- Review List --%>
            <div class="divide-y divide-gray-50 px-8">
                <c:choose>
                    <c:when test="${empty productReviews}">
                        <div class="py-16 text-center text-gray-400 italic text-sm">
                            No reviews yet.</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="rev" items="${productReviews}">
                            <div class="py-8 flex gap-6">
                                <div
                                    class="w-12 h-12 bg-red-50 text-red-600 font-black rounded-2xl flex items-center justify-center text-xl flex-shrink-0">
                                    ${fn:substring(rev.customerName, 0, 1)}</div>
                                <div class="flex-1">
                                    <div
                                        class="flex justify-between items-center mb-1">
                                        <h4 class="font-black text-gray-900">
                                            ${rev.customerName}</h4>
                                        <span
                                            class="text-xs font-bold text-gray-300 uppercase">${rev.formattedDate}</span>
                                    </div>
                                    <div class="text-yellow-400 text-xs mb-2">
                                        <c:forEach begin="1" end="5" var="i">
                                            <c:choose>
                                                <c:when test="${i <= rev.rating}">★
                                                </c:when>
                                                <c:otherwise><span
                                                        class="text-gray-100">★</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </div>
                                    <p
                                        class="text-gray-600 text-sm leading-relaxed">
                                        ${rev.comment}</p>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%--=====MODAL REVIEW (Fixed Layout)=====--%>
        <div id="reviewModal"
             class="fixed inset-0 z-[9999] flex items-center justify-center bg-black/40 backdrop-blur-sm hidden opacity-0 transition-all duration-300">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md mx-4 p-8 transform scale-95 transition-transform duration-300"
                 id="reviewModalContent">
                <h2 id="modalTitle"
                    class="text-2xl font-black text-gray-900 mb-6 tracking-tight">
                    Write a Review</h2>
                <form action="${pageContext.request.contextPath}/reviewservlet"
                      method="post" id="reviewForm">
                    <input type="hidden" name="action" id="reviewAction"
                           value="add">
                    <input type="hidden" name="productId"
                           value="${product.productId}">
                    <form action="${pageContext.request.contextPath}/reviewservlet"
                          method="post" id="reviewForm">
                        <input type="hidden" name="action" id="reviewAction"
                               value="add">
                        <input type="hidden" name="productId"
                               value="${product.productId}">
                        <input type="hidden" name="reviewId" id="reviewId"
                               value="${userReview != null ? userReview.reviewId : ''}">
                        <input type="hidden" name="rating" id="reviewRating"
                               value="${userReview != null ? userReview.rating : 5}">

                        <div class="text-center mb-6">
                            <div class="flex justify-center gap-2 mb-2">
                                <c:forEach begin="1" end="5" var="i">
                                    <button type="button" onclick="setRating(${i})"
                                            class="star-btn text-3xl text-gray-200 transition-colors cursor-pointer"
                                            data-value="${i}">★</button>
                                </c:forEach>
                            </div>
                            <%-- Dòng text trạng thái --%>
                            <p id="ratingText"
                               class="font-bold text-sm uppercase tracking-wider">
                            </p>
                        </div>

                        <textarea name="comment" rows="4" required maxlength="500"
                                  class="w-full border border-gray-200 rounded-2xl px-4 py-3 text-sm focus:ring-2 focus:ring-red-500 focus:outline-none mb-6 bg-gray-50"
                                  placeholder="Share your experience...">${userReview != null ? userReview.comment : ''}</textarea>

                        <div class="flex gap-3">
                            <button type="button" onclick="closeReviewModal()"
                                    class="flex-1 h-12 rounded-xl border border-gray-200 font-bold text-gray-500 hover:bg-gray-50 cursor-pointer">Cancel</button>
                            <button type="submit"
                                    class="flex-1 h-12 rounded-xl bg-red-600 text-white font-bold hover:bg-red-700 shadow-md cursor-pointer">Submit
                                Review</button>
                        </div>
                    </form>
            </div>
        </div>

        <style>
            #reviewModal.show {
                display: flex !important;
                opacity: 100 !important;
            }

            #reviewModal.show #reviewModalContent {
                transform: scale(1);
            }

            .star-btn.active {
                color: #f59e0b !important;
            }

            .no-scrollbar::-webkit-scrollbar {
                display: none;
            }
        </style>

        <script
        src="https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.umd.js"></script>
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.css" />

        <script>
                                // 1. DATA BUILD
                                var VARIANTS = {};
            <c:forEach var="v" items="${variants}">
                                VARIANTS[${v.variantId}] = {
                                    id: ${v.variantId},
                                    sku: '${fn:replace(v.sku, "'", "\\'")}',
                                    price: ${v.sellingPrice},
                                    stock: ${variantStockMap[v.variantId] != null ? variantStockMap[v.variantId] : 0},
                                    specs: {}
                                };
            </c:forEach>

            <c:forEach var="vs" items="${variantSpecs}">
                                if (VARIANTS[${vs.variantId}]) {
                                    VARIANTS[${vs.variantId}].specs['${fn:replace(vs.specName, "'", "\\'")}'] = '${fn:replace(vs.specValue, "'", "\\'")}';
                                }
            </c:forEach>

                                var VARIANT_AXES = [];
            <c:forEach var="n" items="${variantAxisNames}">
                                VARIANT_AXES.push('${fn:replace(n, "'", "\\'")}');
            </c:forEach>

                                var selectedSpecs = {};
                                var selectedVariantId = ${ not empty variants ?variants[0].variantId: 0};

                                function selectVariantAndUpdate(variant) {
                                    if (!variant)
                                        return;

                                    selectedVariantId = variant.id;
                                    document.getElementById('formVariantId').value = variant.id;
                                    document.getElementById('displayPrice').textContent = Number(variant.price || 0).toLocaleString('vi-VN') + 'đ';

                                    var btn = document.getElementById('addToCartBtn');
                                    var stockCount = Number(variant.stock || 0);
                                    var inStock = stockCount > 0;

                                    btn.disabled = !inStock;
                                    btn.className = "flex-1 text-white font-black text-lg rounded-2xl h-14 shadow-lg transition-all flex items-center justify-center gap-3 "
                                            + (inStock ? "bg-red-600 hover:bg-red-700 shadow-red-100" : "bg-gray-300");

                                    document.getElementById('stockStatus').innerHTML =
                                            '<span class="w-2 h-2 rounded-full ' + (inStock ? 'bg-green-500 animate-pulse' : 'bg-red-500') + '"></span>'
                                            + (inStock ? 'In Stock' : 'Out of Stock');

                                    document.getElementById('stockStatus').className =
                                            "flex items-center gap-1.5 font-bold text-sm " + (inStock ? "text-green-600" : "text-red-500");

                                    clampQtyToStock();
                                    updateQtyButtonStates();

                                    var dynamicContainer = document.getElementById('dynamic-variant-specs');
                                    var noSpecsMsg = document.getElementById('no-specs-msg');
                                    dynamicContainer.innerHTML = '';

                                    var hasVariantSpecs = Object.keys(variant.specs).length > 0;
                                    if (noSpecsMsg) {
                                        noSpecsMsg.style.display = hasVariantSpecs ? 'none' : '';
                                    }

                                    for (var sn in variant.specs) {
                                        var row = document.createElement('div');
                                        row.className = 'flex px-4 py-3 bg-red-50/50 justify-between items-center rounded-xl mb-1 border-b border-red-100';
                                        row.innerHTML =
                                                '<span class="text-gray-500 font-bold text-sm">' + sn + '</span>' +
                                                '<span class="text-red-600 font-black text-sm text-right">' + variant.specs[sn] + '</span>';
                                        dynamicContainer.appendChild(row);
                                    }
                                }

                                function buildVariantUI() {
                                    var container = document.getElementById("variantSelectors");
                                    container.innerHTML = "";

                                    if (!Object.keys(VARIANTS).length) {
                                        return;
                                    }

                                    if (!VARIANT_AXES.length) {
                                        if (VARIANTS[selectedVariantId]) {
                                            selectVariantAndUpdate(VARIANTS[selectedVariantId]);
                                        } else {
                                            var firstVariant = Object.values(VARIANTS)[0];
                                            if (firstVariant)
                                                selectVariantAndUpdate(firstVariant);
                                        }
                                        return;
                                    }

                                    VARIANT_AXES.forEach(function (axisName, axisIndex) {
                                        var section = document.createElement("div");
                                        section.className = "mb-6";

                                        var title = document.createElement("h4");
                                        title.className = "text-xs font-black text-gray-400 uppercase tracking-widest mb-3";
                                        title.textContent = axisName;
                                        section.appendChild(title);

                                        var optionsWrap = document.createElement("div");
                                        optionsWrap.className = "flex flex-wrap gap-3";

                                        var validVariants = Object.values(VARIANTS).filter(function (v) {
                                            for (var i = 0; i < axisIndex; i++) {
                                                var prevAxis = VARIANT_AXES[i];
                                                if (selectedSpecs[prevAxis] && v.specs[prevAxis] !== selectedSpecs[prevAxis]) {
                                                    return false;
                                                }
                                            }
                                            return true;
                                        });

                                        var values = [...new Set(
                                                    validVariants
                                                    .map(function (v) {
                                                        return v.specs[axisName];
                                                    })
                                                    .filter(function (val) {
                                                        return val !== undefined && val !== null && val !== '';
                                                    })
                                                    )];

                                        if (values.length === 0) {
                                            delete selectedSpecs[axisName];
                                            return;
                                        }

                                        if (!selectedSpecs[axisName] || values.indexOf(selectedSpecs[axisName]) === -1) {
                                            selectedSpecs[axisName] = values[0];
                                        }

                                        values.forEach(function (val) {
                                            var btn = document.createElement("div");
                                            var active = selectedSpecs[axisName] === val;

                                            btn.className = 'px-4 py-2 border-2 rounded-xl text-sm font-bold cursor-pointer transition-all '
                                                    + (active
                                                            ? 'border-red-600 bg-red-50 text-red-600'
                                                            : 'border-gray-100 bg-white text-gray-600');

                                            btn.textContent = val;

                                            btn.onclick = function () {
                                                selectedSpecs[axisName] = val;

                                                for (var j = axisIndex + 1; j < VARIANT_AXES.length; j++) {
                                                    delete selectedSpecs[VARIANT_AXES[j]];
                                                }

                                                buildVariantUI();
                                                syncSelectedVariant();
                                            };

                                            optionsWrap.appendChild(btn);
                                        });

                                        section.appendChild(optionsWrap);
                                        container.appendChild(section);
                                    });

                                    syncSelectedVariant();
                                }

                                function syncSelectedVariant() {
                                    var matched = Object.values(VARIANTS).find(function (v) {
                                        return VARIANT_AXES.every(function (axis) {
                                            return !selectedSpecs[axis] || v.specs[axis] === selectedSpecs[axis];
                                        });
                                    });

                                    if (!matched) {
                                        matched = Object.values(VARIANTS)[0];
                                    }

                                    if (matched) {
                                        selectVariantAndUpdate(matched);
                                    }
                                }

                                // 3. LOGIC REVIEW & AJAX
                                function openReviewModal(isEdit) {
                                    const modal = document.getElementById('reviewModal');
                                    modal.classList.remove('hidden');
                                    void modal.offsetWidth;
                                    modal.classList.add('show');

                                    document.getElementById('reviewAction').value = isEdit ? 'edit' : 'add';
                                    document.getElementById('modalTitle').textContent = isEdit ? 'Edit Your Review' : 'Write a Review';

                                    if (isEdit) {
                                        const oldRating = document.getElementById('reviewRating').value;
                                        setRating(parseInt(oldRating));
                                    } else {
                                        document.getElementById('reviewId').value = '';
                                        const textarea = modal.querySelector('textarea[name="comment"]');
                                        if (textarea)
                                            textarea.value = '';
                                        setRating(5);
                                    }
                                }

                                function closeReviewModal() {
                                    const modal = document.getElementById('reviewModal');
                                    modal.classList.remove('show');
                                    setTimeout(() => {
                                        modal.classList.add('hidden');
                                    }, 300);
                                }

                                function setRating(rating) {
                                    document.getElementById('reviewRating').value = rating;

                                    document.querySelectorAll('.star-btn').forEach(function (s) {
                                        s.classList.toggle('active', parseInt(s.dataset.value) <= rating);
                                    });

                                    var texts = ["Poor", "Dissatisfied", "Average", "Satisfied", "Excellent"];
                                    var colors = ["#6b7280", "#f97316", "#3b82f6", "#16a34a", "#dc2626"];
                                    var textEl = document.getElementById('ratingText');
                                    if (textEl) {
                                        textEl.textContent = texts[rating - 1];
                                        textEl.style.color = colors[rating - 1];
                                    }
                                }

                                var addToCartOverlay = null;

                                function showAddToCartLoading() {
                                    if (!addToCartOverlay) {
                                        addToCartOverlay = document.createElement('div');
                                        addToCartOverlay.style.cssText = 'position:fixed;inset:0;z-index:9998;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,0.3);';
                                        addToCartOverlay.innerHTML =
                                                '<div style="display:flex;flex-direction:column;align-items:center;gap:16px;background:#fff;padding:24px 32px;border-radius:16px;box-shadow:0 8px 32px rgba(0,0,0,0.15);">' +
                                                '<div style="width:48px;height:48px;border:4px solid #e5e7eb;border-top-color:#dc2626;border-radius:50%;animation:spin 0.8s linear infinite;"></div>' +
                                                '<span style="font-size:14px;font-weight:500;color:#374151;">Processing...</span></div>';
                                        var style = document.createElement('style');
                                        style.textContent = '@keyframes spin{to{transform:rotate(360deg)}}';
                                        document.head.appendChild(style);
                                    }
                                    addToCartOverlay.style.display = 'flex';
                                    if (!addToCartOverlay.parentNode)
                                        document.body.appendChild(addToCartOverlay);
                                }

                                function hideAddToCartLoading() {
                                    if (addToCartOverlay)
                                        addToCartOverlay.style.display = 'none';
                                }

                                function refreshNavbarCartCount() {
                                    fetch('${pageContext.request.contextPath}/cartservlet?action=count', {credentials: 'same-origin'})
                                            .then(r => r.json())
                                            .then(data => {
                                                if (!data)
                                                    return;
                                                var badge = document.getElementById('navbarCartCount');
                                                if (!badge)
                                                    return;

                                                var count = Number(data.cartCount || 0);
                                                badge.textContent = count;

                                                if (count > 0)
                                                    badge.classList.remove('hidden');
                                                else
                                                    badge.classList.add('hidden');
                                            })
                                            .catch(() => {
                                            });
                                }

                                function showAddToCartToast(message, isError) {
                                    var old = document.getElementById('toast-add-cart');
                                    if (old)
                                        old.remove();

                                    var wrapper = document.createElement('div');
                                    wrapper.id = 'toast-add-cart';
                                    wrapper.style.cssText = 'position:fixed;top:16px;right:16px;z-index:9999;min-width:280px;max-width:360px;';

                                    var bg = isError ? '#fef2f2' : '#f0fdf4';
                                    var border = isError ? '#fecaca' : '#bbf7d0';
                                    var color = isError ? '#991b1b' : '#166534';
                                    var icon = isError
                                            ? '<span style="color:#dc2626;font-weight:700;font-size:18px;">!</span>'
                                            : '<svg width="20" height="20" fill="none" stroke="#16a34a" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>';

                                    wrapper.innerHTML =
                                            '<div style="display:flex;align-items:center;gap:12px;padding:14px 18px;border-radius:14px;border:1px solid ' + border + ';background:' + bg + ';color:' + color + ';box-shadow:0 4px 16px rgba(0,0,0,0.08);">' +
                                            icon +
                                            '<span style="flex:1;font-size:14px;font-weight:500;">' + message + '</span>' +
                                            '<button onclick="this.closest(\'#toast-add-cart\').remove()" style="background:none;border:none;cursor:pointer;color:#9ca3af;font-size:16px;">✕</button>' +
                                            '</div>';

                                    document.body.appendChild(wrapper);

                                    setTimeout(() => {
                                        if (wrapper.parentNode)
                                            wrapper.remove();
                                    }, 3000);
                                }

                                document.addEventListener('DOMContentLoaded', () => {
                                    Fancybox.bind('[data-fancybox="gallery"]', {hideScrollbar: false});

                                    buildVariantUI();

                                    if (!VARIANT_AXES.length && Object.keys(VARIANTS).length > 0) {
                                        var firstVariant = VARIANTS[selectedVariantId] || Object.values(VARIANTS)[0];
                                        if (firstVariant) {
                                            selectVariantAndUpdate(firstVariant);
                                        }
                                    }

                                    var form = document.getElementById('addToCartForm');
                                    if (!form)
                                        return;

                                    form.addEventListener('submit', function (e) {
                                        var activeVariant = VARIANTS[selectedVariantId];
                                        if (!activeVariant) {
                                            e.preventDefault();
                                            return;
                                        }

                                        e.preventDefault();
                                        showAddToCartLoading();

                                        var url = form.getAttribute('action') + (form.getAttribute('action').indexOf('?') >= 0 ? '&' : '?') + 'ajax=1';
                                        var params = new URLSearchParams(new FormData(form));
                                        params.append('ajax', '1');

                                        fetch(url, {
                                            method: 'POST',
                                            credentials: 'same-origin',
                                            headers: {
                                                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                                                'X-Requested-With': 'XMLHttpRequest',
                                                'Accept': 'application/json'
                                            },
                                            body: params.toString()
                                        })
                                                .then(r => {
                                                    if (!r.ok)
                                                        throw new Error('HTTP ' + r.status);
                                                    var ct = (r.headers.get('content-type') || '').toLowerCase();

                                                    if (ct.indexOf('application/json') === -1) {
                                                        hideAddToCartLoading();
                                                        showAddToCartToast('Added to cart.', false);
                                                        refreshNavbarCartCount();
                                                        return null;
                                                    }

                                                    return r.json();
                                                })
                                                .then(data => {
                                                    if (!data)
                                                        return;

                                                    if (data.success === false) {
                                                        hideAddToCartLoading();
                                                        showAddToCartToast(data.message || 'Error adding to cart.', true);
                                                        return;
                                                    }

                                                    hideAddToCartLoading();
                                                    showAddToCartToast(data.message || 'Added to cart!', false);
                                                    refreshNavbarCartCount();
                                                })
                                                .catch(() => {
                                                    hideAddToCartLoading();
                                                    showAddToCartToast('System error, please try again.', true);
                                                });
                                    });
                                });

                                function getMaxQtyForSelected() {
                                    if (!selectedVariantId || !VARIANTS[selectedVariantId])
                                        return 0;
                                    var s = VARIANTS[selectedVariantId].stock;
                                    return (typeof s === 'number' && s >= 0) ? s : 0;
                                }

                                function clampQtyToStock() {
                                    var inp = document.getElementById('qtyInput');
                                    if (!inp)
                                        return;

                                    var maxQ = getMaxQtyForSelected();
                                    var cur = parseInt(inp.value, 10) || 1;

                                    if (maxQ < 1) {
                                        inp.value = 1;
                                        return;
                                    }

                                    if (cur > maxQ)
                                        inp.value = maxQ;
                                    if (cur < 1)
                                        inp.value = 1;
                                }

                                function updateQtyButtonStates() {
                                    var maxQ = getMaxQtyForSelected();
                                    var inp = document.getElementById('qtyInput');
                                    var cur = inp ? (parseInt(inp.value, 10) || 1) : 1;
                                    var minusBtn = document.getElementById('qtyMinusBtn');
                                    var plusBtn = document.getElementById('qtyPlusBtn');

                                    if (minusBtn)
                                        minusBtn.disabled = (cur <= 1);
                                    if (plusBtn)
                                        plusBtn.disabled = (maxQ < 1 || cur >= maxQ);
                                }

                                function updateQuantity(c) {
                                    var maxQ = getMaxQtyForSelected();
                                    if (maxQ < 1)
                                        return;

                                    var i = document.getElementById('qtyInput');
                                    var cur = parseInt(i.value, 10) || 1;
                                    var v = cur + c;

                                    if (v < 1)
                                        v = 1;
                                    if (v > maxQ)
                                        v = maxQ;

                                    i.value = v;
                                    updateQtyButtonStates();
                                }

                                function changeImage(t, s) {
                                    document.getElementById('mainImage').src = s;
                                    document.getElementById('mainImageLink').href = s;
                                    document.querySelectorAll('.thumb-item').forEach(el => el.classList.remove('border-red-500', 'shadow-md'));
                                    t.classList.add('border-red-500', 'shadow-md');
                                }
        </script>