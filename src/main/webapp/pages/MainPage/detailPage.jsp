<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap"
      rel="stylesheet">
<style>
    .detail-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 16px;
        font-family: 'Inter', sans-serif;
    }

    /* Breadcrumb */
    .breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px 0;
        font-size: 13px;
        color: #6b7280;
        flex-wrap: wrap;
    }

    .breadcrumb a {
        color: #2563eb;
        text-decoration: none;
        font-weight: 500;
    }

    .breadcrumb a:hover {
        text-decoration: underline;
    }

    .breadcrumb .sep {
        color: #d1d5db;
    }

    .breadcrumb .current {
        color: #374151;
        font-weight: 600;
    }

    /* Main grid */
    .product-main {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 40px;
        margin-bottom: 40px;
    }

    @media (max-width: 900px) {
        .product-main {
            grid-template-columns: 1fr;
            gap: 24px;
        }
    }

    /* Gallery */
    .gallery-section {
        position: sticky;
        top: 20px;
    }

    .main-image-wrap {
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        overflow: hidden;
        background: #fafafa;
        display: flex;
        align-items: center;
        justify-content: center;
        aspect-ratio: 1;
        padding: 24px;
        cursor: zoom-in;
        transition: box-shadow 0.2s;
    }

    .main-image-wrap:hover {
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    }

    .main-image-wrap img {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
        transition: transform 0.3s;
    }

    .main-image-wrap:hover img {
        transform: scale(1.03);
    }

    .thumb-list {
        display: flex;
        gap: 8px;
        margin-top: 12px;
        overflow-x: auto;
        padding-bottom: 4px;
    }

    .thumb-item {
        width: 72px;
        height: 72px;
        flex-shrink: 0;
        border: 2px solid #e5e7eb;
        border-radius: 12px;
        padding: 4px;
        cursor: pointer;
        background: #fff;
        transition: border-color 0.2s, box-shadow 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .thumb-item:hover {
        border-color: #93c5fd;
    }

    .thumb-item.active {
        border-color: #2563eb;
        box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.15);
    }

    .thumb-item img {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
        border-radius: 8px;
    }

    /* Product info */
    .product-info {
        display: flex;
        flex-direction: column;
    }

    .product-name {
        font-size: 24px;
        font-weight: 800;
        color: #111827;
        margin: 0 0 8px 0;
        line-height: 1.3;
        letter-spacing: -0.02em;
    }

    .rating-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 16px;
        font-size: 14px;
    }

    .stars {
        color: #f59e0b;
        font-size: 16px;
        letter-spacing: 1px;
    }

    .rating-score {
        font-weight: 700;
        color: #f59e0b;
    }

    .rating-count {
        color: #6b7280;
    }

    .dot-sep {
        width: 4px;
        height: 4px;
        border-radius: 50%;
        background: #d1d5db;
    }

    .in-stock {
        color: #16a34a;
        font-weight: 600;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 4px;
    }

    /* Price box */
    .price-box {
        background: linear-gradient(135deg, #fef2f2, #fff);
        border: 1px solid #fecaca;
        border-radius: 16px;
        padding: 20px 24px;
        margin-bottom: 24px;
    }

    .price-current {
        font-size: 32px;
        font-weight: 900;
        color: #dc2626;
        letter-spacing: -0.02em;
    }

    .price-label {
        font-size: 13px;
        color: #6b7280;
        margin-bottom: 4px;
        font-weight: 500;
    }

    /* Variant sections */
    .variant-section {
        margin-bottom: 20px;
    }

    .variant-label {
        font-size: 13px;
        font-weight: 700;
        color: #374151;
        margin-bottom: 10px;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .variant-options {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
    }

    .variant-opt {
        position: relative;
        padding: 10px 20px;
        border: 2px solid #e5e7eb;
        border-radius: 12px;
        background: #fff;
        cursor: pointer;
        font-size: 14px;
        font-weight: 600;
        color: #374151;
        transition: all 0.2s;
        text-align: center;
        min-width: 80px;
    }

    .variant-opt:hover {
        border-color: #93c5fd;
        background: #f0f9ff;
    }

    .variant-opt.selected {
        border-color: #2563eb;
        color: #2563eb;
        background: #eff6ff;
        box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.12);
    }

    .variant-opt.disabled {
        opacity: 0.4;
        pointer-events: none;
        cursor: not-allowed;
    }

    .color-opt {
        padding: 10px 16px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 4px;
        min-width: 100px;
    }

    .color-opt .color-name {
        font-size: 14px;
        font-weight: 600;
    }

    .color-opt.selected .color-name {
        color: #2563eb;
    }

    /* Quantity + Cart */
    .cart-row {
        display: flex;
        gap: 12px;
        align-items: center;
        margin-top: auto;
        padding-top: 20px;
        flex-wrap: wrap;
    }

    .qty-control {
        display: flex;
        align-items: center;
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        height: 48px;
        background: #f9fafb;
        overflow: hidden;
    }

    .qty-btn {
        width: 40px;
        height: 100%;
        border: none;
        background: transparent;
        cursor: pointer;
        font-size: 18px;
        color: #6b7280;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.15s;
    }

    .qty-btn:hover {
        background: #e5e7eb;
    }

    .qty-input {
        width: 48px;
        height: 100%;
        border: none;
        background: transparent;
        text-align: center;
        font-size: 15px;
        font-weight: 700;
        color: #111827;
        outline: none;
    }

    .btn-add-cart {
        flex: 1;
        height: 48px;
        border: 2px solid #dc2626;
        background: #fff;
        color: #dc2626;
        font-size: 16px;
        font-weight: 700;
        border-radius: 12px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        transition: all 0.25s;
        min-width: 200px;
    }

    .btn-add-cart:hover {
        background: #dc2626;
        color: #fff;
    }

    /* Bottom sections */
    .bottom-grid {
        display: grid;
        grid-template-columns: 7fr 5fr;
        gap: 32px;
        margin-bottom: 40px;
    }

    @media (max-width: 900px) {
        .bottom-grid {
            grid-template-columns: 1fr;
        }
    }

    .section-card {
        border: 1px solid #e5e7eb;
        border-radius: 20px;
        background: #fff;
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }

    .section-header {
        padding: 16px 24px;
        font-size: 18px;
        font-weight: 800;
        color: #111827;
        border-bottom: 1px solid #f3f4f6;
        background: #fafafa;
    }

    .section-body {
        padding: 24px;
    }

    .desc-content {
        color: #4b5563;
        line-height: 1.8;
        font-size: 15px;
    }

    .desc-content p {
        margin-bottom: 12px;
    }

    /* Spec table */
    .spec-table {
        width: 100%;
    }

    .spec-row {
        display: flex;
        border-bottom: 1px solid #f3f4f6;
    }

    .spec-row:last-child {
        border-bottom: none;
    }

    .spec-row:nth-child(even) {
        background: #f9fafb;
    }

    .spec-name {
        flex: 0 0 40%;
        padding: 12px 16px;
        font-size: 14px;
        color: #6b7280;
        font-weight: 500;
    }

    .spec-value {
        flex: 1;
        padding: 12px 16px;
        font-size: 14px;
        color: #111827;
        font-weight: 600;
    }

    /* Reviews */
    .reviews-card {
        border: 1px solid #e5e7eb;
        border-radius: 20px;
        background: #fff;
        margin-bottom: 40px;
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }

    .reviews-header {
        padding: 16px 24px;
        font-size: 18px;
        font-weight: 800;
        color: #111827;
        border-bottom: 1px solid #f3f4f6;
        background: #fafafa;
    }

    .reviews-summary {
        display: grid;
        grid-template-columns: auto 1fr auto;
        gap: 32px;
        align-items: center;
        padding: 24px;
        background: #f9fafb;
        border-bottom: 1px solid #f3f4f6;
    }

    @media (max-width: 700px) {
        .reviews-summary {
            grid-template-columns: 1fr;
            gap: 16px;
        }
    }

    .avg-rating {
        text-align: center;
    }

    .avg-rating .big-num {
        font-size: 52px;
        font-weight: 900;
        color: #dc2626;
        line-height: 1;
    }

    .avg-rating .avg-stars {
        color: #f59e0b;
        font-size: 20px;
        margin: 6px 0 4px;
        letter-spacing: 2px;
    }

    .avg-rating .total-text {
        font-size: 13px;
        color: #6b7280;
    }

    .bars-col {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .bar-row {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 13px;
    }

    .bar-label {
        width: 40px;
        font-weight: 700;
        color: #374151;
        text-align: right;
    }

    .bar-track {
        flex: 1;
        height: 8px;
        background: #e5e7eb;
        border-radius: 999px;
        overflow: hidden;
    }

    .bar-fill {
        height: 100%;
        background: #dc2626;
        border-radius: 999px;
        transition: width 0.4s;
    }

    .bar-pct {
        width: 36px;
        font-weight: 600;
        color: #6b7280;
        text-align: right;
        font-size: 12px;
    }

    .btn-review {
        padding: 12px 24px;
        border: 2px solid #dc2626;
        color: #dc2626;
        background: #fff;
        font-weight: 700;
        border-radius: 12px;
        cursor: pointer;
        font-size: 14px;
        transition: all 0.25s;
        white-space: nowrap;
    }

    .btn-review:hover {
        background: #dc2626;
        color: #fff;
    }

    .btn-review.edit {
        border-color: #2563eb;
        color: #2563eb;
    }

    .btn-review.edit:hover {
        background: #2563eb;
        color: #fff;
    }

    .btn-review.login {
        border-color: #d1d5db;
        color: #6b7280;
        background: #f9fafb;
    }

    .btn-review.login:hover {
        background: #e5e7eb;
    }

    .review-list {
        padding: 0 24px 24px;
    }

    .review-item {
        display: flex;
        gap: 16px;
        padding: 20px 0;
        border-bottom: 1px solid #f3f4f6;
    }

    .review-item:last-child {
        border-bottom: none;
    }

    .review-avatar {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: #e5e7eb;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        color: #6b7280;
        font-size: 18px;
        flex-shrink: 0;
        text-transform: uppercase;
    }

    .review-body {
        flex: 1;
        min-width: 0;
    }

    .review-top {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 4px;
    }

    .review-name {
        font-weight: 700;
        color: #111827;
        font-size: 15px;
    }

    .review-date {
        font-size: 13px;
        color: #9ca3af;
    }

    .review-stars {
        color: #f59e0b;
        font-size: 13px;
        letter-spacing: 1px;
        margin-bottom: 6px;
    }

    .review-text {
        color: #4b5563;
        font-size: 14px;
        line-height: 1.6;
    }

    .no-reviews {
        text-align: center;
        padding: 40px;
        color: #9ca3af;
        font-size: 15px;
    }

    /* Modal */
    .modal-overlay {
        position: fixed;
        inset: 0;
        z-index: 100;
        background: rgba(0, 0, 0, 0.5);
        display: none;
        align-items: center;
        justify-content: center;
        padding: 16px;
    }

    .modal-overlay.show {
        display: flex;
    }

    .modal-box {
        background: #fff;
        border-radius: 20px;
        width: 100%;
        max-width: 480px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
        overflow: hidden;
    }

    .modal-head {
        padding: 16px 24px;
        border-bottom: 1px solid #f3f4f6;
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #fafafa;
    }

    .modal-head h3 {
        font-size: 18px;
        font-weight: 800;
        color: #111827;
        margin: 0;
    }

    .modal-close {
        background: none;
        border: none;
        cursor: pointer;
        color: #9ca3af;
        font-size: 20px;
        padding: 4px;
    }

    .modal-close:hover {
        color: #374151;
    }

    .modal-body {
        padding: 24px;
    }

    .modal-stars-wrap {
        text-align: center;
        margin-bottom: 20px;
    }

    .modal-stars-label {
        font-size: 14px;
        color: #374151;
        font-weight: 500;
        margin-bottom: 8px;
    }

    .modal-stars {
        display: inline-flex;
        gap: 6px;
        font-size: 32px;
        cursor: pointer;
    }

    .modal-stars .star-btn {
        color: #d1d5db;
        transition: color 0.15s;
    }

    .modal-stars .star-btn.active {
        color: #f59e0b;
    }

    .modal-rating-text {
        font-size: 14px;
        font-weight: 600;
        margin-top: 6px;
    }

    .modal-textarea {
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #d1d5db;
        border-radius: 12px;
        font-size: 14px;
        resize: none;
        outline: none;
        font-family: inherit;
        color: #374151;
        box-sizing: border-box;
    }

    .modal-textarea:focus {
        border-color: #2563eb;
        box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
    }

    .modal-textarea-label {
        font-size: 14px;
        color: #374151;
        font-weight: 500;
        margin-bottom: 8px;
        display: block;
    }

    .modal-actions {
        display: flex;
        gap: 10px;
        justify-content: flex-end;
        margin-top: 20px;
    }

    .modal-btn {
        padding: 10px 20px;
        border-radius: 12px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        border: 1px solid transparent;
    }

    .modal-btn.cancel {
        background: #f3f4f6;
        color: #374151;
        border-color: #d1d5db;
    }

    .modal-btn.cancel:hover {
        background: #e5e7eb;
    }

    .modal-btn.submit {
        background: #dc2626;
        color: #fff;
    }

    .modal-btn.submit:hover {
        background: #b91c1c;
    }
</style>

<div class="detail-container">

    <%--=====BREADCRUMB=====--%>
    <nav class="breadcrumb">
        <a href="${pageContext.request.contextPath}/homepageservlet">Trang chủ</a>
        <span class="sep">/</span>
        <c:if test="${not empty product.categoryName}">
            <a
                href="${pageContext.request.contextPath}/productpageservlet?category=${product.categoryId}">${product.categoryName}</a>
            <span class="sep">/</span>
        </c:if>
        <c:if test="${not empty product.brandName}">
            <a
                href="${pageContext.request.contextPath}/productpageservlet?brand=${product.brandId}">${product.brandName}</a>
            <span class="sep">/</span>
        </c:if>
        <span class="current">${product.name}</span>
    </nav>

    <%--=====PRODUCT MAIN=====--%>
    <div class="product-main">

        <%-- Left: Gallery --%>
        <div class="gallery-section">
            <a id="mainImageLink"
               href="${not empty images ? pageContext.request.contextPath.concat('/').concat(images[0].imageUrl) : pageContext.request.contextPath.concat('/assets/img/product/placeholder.jpg')}"
               data-fancybox="gallery" class="main-image-wrap">
                <img id="mainImage"
                     src="${not empty images ? pageContext.request.contextPath.concat('/').concat(images[0].imageUrl) : pageContext.request.contextPath.concat('/assets/img/product/placeholder.jpg')}"
                     alt="${product.name}">
            </a>
            <div class="thumb-list">
                <c:forEach var="img" items="${images}" varStatus="st">
                    <div onclick="changeImage(this, '${pageContext.request.contextPath}/${img.imageUrl}')"
                         class="thumb-item ${st.first ? 'active' : ''}">
                        <img src="${pageContext.request.contextPath}/${img.imageUrl}"
                             alt="Ảnh ${st.index + 1}">
                    </div>
                </c:forEach>
            </div>
        </div>

        <%-- Right: Product Info --%>
        <div class="product-info">

            <h1 class="product-name">${product.name}</h1>

            <div class="rating-row">
                <span class="rating-score">
                    <fmt:formatNumber value="${averageRating}" maxFractionDigits="1"
                                      minFractionDigits="1" />
                </span>
                <span class="stars">
                    <c:forEach begin="1" end="5" var="i">
                        <c:choose>
                            <c:when test="${i <= averageRating}">★</c:when>
                            <c:when test="${i - 0.5 <= averageRating}">★</c:when>
                            <c:otherwise><span style="color:#d1d5db">★</span>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </span>
                <span class="rating-count">(${totalReviews} đánh giá)</span>
                <span class="dot-sep"></span>
                <span class="in-stock">
                    <svg width="16" height="16" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd"
                          d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                          clip-rule="evenodd" />
                    </svg>
                    Còn hàng
                </span>
            </div>

            <%-- Price Box --%>
            <div class="price-box">
                <div class="price-label">Giá sản phẩm</div>
                <div id="displayPrice" class="price-current">
                    <fmt:formatNumber
                        value="${not empty variants ? variants[0].sellingPrice : 0}"
                        type="number" groupingUsed="true" />đ
                </div>
            </div>

            <%-- Variant Selection: Storage/Version --%>
            <div class="variant-section" id="storageSection"
                 style="display:none;">
                <div class="variant-label">Phiên bản</div>
                <div class="variant-options" id="storageOptions"></div>
            </div>

            <%-- Variant Selection: Color --%>
            <div class="variant-section" id="colorSection"
                 style="display:none;">
                <div class="variant-label">Màu sắc</div>
                <div class="variant-options" id="colorOptions"></div>
            </div>

            <%-- Fallback: If no variant specs, show SKU buttons --%>
            <div class="variant-section" id="skuSection"
                 style="display:none;">
                <div class="variant-label">Phiên bản</div>
                <div class="variant-options" id="skuOptions"></div>
            </div>

            <%-- Add to cart --%>
            <form id="addToCartForm"
                  action="${pageContext.request.contextPath}/cartservlet"
                  method="post">
                <input type="hidden" name="action" value="add" />
                <input type="hidden" name="variant_id"
                       id="formVariantId"
                       value="${not empty variants ? variants[0].variantId : ''}" />
                <div class="cart-row">
                    <div class="qty-control">
                        <button type="button" class="qty-btn"
                                onclick="updateQuantity(-1)">−</button>
                        <input type="text" id="qtyInput"
                               name="quantity" value="1"
                               class="qty-input" readonly>
                        <button type="button" class="qty-btn"
                                onclick="updateQuantity(1)">+</button>
                    </div>
                    <button type="submit" class="btn-add-cart">
                        🛒 Thêm vào giỏ hàng
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%--=====DESCRIPTION + SPECS=====--%>
    <div class="bottom-grid">
        <div class="section-card">
            <div class="section-header">📝 Mô tả sản phẩm</div>
            <div class="section-body">
                <div class="desc-content">
                    ${product.description != null ? product.description : 'Đang cập nhật mô
                      tả sản phẩm...'}
                </div>
            </div>
        </div>

        <div class="section-card">
            <div class="section-header">⚙️ Thông số kỹ thuật</div>
            <div class="section-body" style="padding:0;">
                <div class="spec-table">
                    <%-- Các thông số biến thể sẽ được render động ở đây bằng JS --%>
                    <div id="dynamic-variant-specs"></div>

                    <c:if test="${not empty specs}">
                        <c:forEach var="s" items="${specs}">
                            <div class="spec-row">
                                <div class="spec-name">${s.specName}</div>
                                <div class="spec-value">${s.specValue} ${(not empty
                                                          s.unit and s.unit ne '-') ? s.unit : ''}</div>
                            </div>
                        </c:forEach>
                    </c:if>
                </div>
                <c:if test="${empty specs and empty variantSpecs}">
                    <div class="no-reviews">Đang cập nhật thông số...</div>
                </c:if>
            </div>
        </div>
    </div>

    <%--=====REVIEWS=====--%>
    <div class="reviews-card" id="reviews-section">
        <div class="reviews-header">⭐ Đánh giá sản phẩm</div>

        <div class="reviews-summary">
            <div class="avg-rating">
                <div class="big-num">
                    <fmt:formatNumber value="${averageRating}" maxFractionDigits="1"
                                      minFractionDigits="1" />
                </div>
                <div class="avg-stars">
                    <c:forEach begin="1" end="5" var="i">
                        <c:choose>
                            <c:when test="${i <= averageRating}">★</c:when>
                            <c:when test="${i - 0.5 <= averageRating}">★</c:when>
                            <c:otherwise><span style="color:#d1d5db">★</span>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
                <div class="total-text">Dựa trên ${totalReviews} đánh giá</div>
            </div>

            <div class="bars-col">
                <c:forEach begin="1" end="5" step="1" var="star">
                    <c:set var="idx" value="${6 - star}" />
                    <div class="bar-row">
                        <span class="bar-label">${idx} sao</span>
                        <div class="bar-track">
                            <div class="bar-fill"
                                 style="width: ${starPercentages[idx]}%"></div>
                        </div>
                        <span class="bar-pct">${starPercentages[idx]}%</span>
                    </div>
                </c:forEach>
            </div>

            <div style="display:flex;justify-content:center;align-items:center;">
                <c:choose>
                    <c:when test="${userReview != null}">
                        <button onclick="openReviewModal(true)"
                                class="btn-review edit">✍️ Sửa đánh giá</button>
                    </c:when>
                    <c:when test="${canReview}">
                        <button onclick="openReviewModal(false)" class="btn-review">✍️
                            Viết đánh giá</button>
                        </c:when>
                        <c:when test="${empty cookie.cookieID.value}">
                        <a href="userservlet?action=loginPage"
                           class="btn-review login">Đăng nhập để đánh giá</a>
                    </c:when>
                    <c:otherwise>
                        <div style="font-size:13px;color:#9ca3af;text-align:center;">Bạn
                            cần mua sản phẩm này để đánh giá.</div>
                        </c:otherwise>
                    </c:choose>
            </div>
        </div>

        <div class="review-list">
            <c:choose>
                <c:when test="${empty productReviews}">
                    <div class="no-reviews">Chưa có đánh giá nào cho sản phẩm này.</div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="rev" items="${productReviews}">
                        <div class="review-item">
                            <div class="review-avatar">${fn:substring(rev.customerName,
                                                         0, 1)}</div>
                            <div class="review-body">
                                <div class="review-top">
                                    <span class="review-name">${rev.customerName}</span>
                                    <span
                                        class="review-date">${rev.formattedDate}</span>
                                </div>
                                <div class="review-stars">
                                    <c:forEach begin="1" end="5" var="i">
                                        <c:choose>
                                            <c:when test="${i <= rev.rating}">★</c:when>
                                            <c:otherwise><span
                                                    style="color:#d1d5db">★</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                                <div class="review-text">${rev.comment}</div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%--=====REVIEW MODAL=====--%>
    <div id="reviewModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-head">
                <h3 id="modalTitle">Viết đánh giá</h3>
                <button type="button" onclick="closeReviewModal()"
                        class="modal-close">✕</button>
            </div>
            <form action="reviewservlet" method="POST" class="modal-body">
                <input type="hidden" name="productId" value="${product.productId}">
                <input type="hidden" name="action" id="reviewAction" value="add">
                <input type="hidden" name="reviewId" id="reviewId"
                       value="${userReview != null ? userReview.reviewId : ''}">
                <input type="hidden" name="rating" id="reviewRating"
                       value="${userReview != null ? userReview.rating : 5}">

                <div class="modal-stars-wrap">
                    <div class="modal-stars-label">Chất lượng sản phẩm</div>
                    <div class="modal-stars" id="starContainer">
                        <c:set var="initialRating"
                               value="${userReview != null ? userReview.rating : 5}" />
                        <c:forEach begin="1" end="5" var="i">
                            <span data-value="${i}" onclick="setRating(${i})"
                                  class="star-btn ${i <= initialRating ? 'active' : ''}">★</span>
                        </c:forEach>
                    </div>
                    <div id="ratingText" class="modal-rating-text"
                         style="color:#dc2626;">Tuyệt vời</div>
                </div>

                <label class="modal-textarea-label">Cảm nhận của bạn</label>
                <textarea name="comment" id="reviewComment" rows="4" required
                          class="modal-textarea"
                          placeholder="Hãy chia sẻ trải nghiệm của bạn về sản phẩm này nhé...">${userReview != null ? userReview.comment : ''}</textarea>

                <div class="modal-actions">
                    <button type="button" onclick="closeReviewModal()"
                            class="modal-btn cancel">Hủy</button>
                    <button type="submit" class="modal-btn submit">Gửi đánh
                        giá</button>
                </div>
            </form>
        </div>
    </div>

</div>

<%--=====SCRIPTS=====--%>
<script src="https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.umd.js"></script>
<script>
                        // ============ DATA BUILD ============
                        // Build variants data from server
                        var VARIANTS = {};
    <c:forEach var="v" items="${variants}">
                        VARIANTS[${v.variantId}] = {
                            id: ${v.variantId},
                            sku: '${fn:replace(v.sku, "'", "\\'")}',
                            price: ${v.sellingPrice},
                            specs: {}
                        };
    </c:forEach>

// Build variant spec values
    <c:forEach var="vs" items="${variantSpecs}">
                        if (VARIANTS[${vs.variantId}]) {
                            VARIANTS[${vs.variantId}].specs['${fn:replace(vs.specName, "'", "\\'")}'] = '${fn:replace(vs.specValue, "'", "\\'")}';
                        }
    </c:forEach>

                        // ============ VARIANT LOGIC ============
                        var selectedStorage = null;
                        var selectedColor = null;
                        var selectedVariantId = ${ not empty variants ?variants[0].variantId: 0};

                        // Analyze variant specs to find grouping dimensions
                        function analyzeVariants() {
                            var specNames = {};
                            for (var vid in VARIANTS) {
                                var specs = VARIANTS[vid].specs;
                                for (var sn in specs) {
                                    if (!specNames[sn])
                                        specNames[sn] = {};
                                    specNames[sn][specs[sn]] = true;
                                }
                            }

                            // Identify which spec is "storage/version" and which is "color"
                            var colorKeywords = ['màu', 'color', 'màu sắc'];
                            var storageKeywords = ['dung lượng', 'bộ nhớ', 'storage', 'ram', 'phiên bản', 'rom'];

                            var colorSpec = null, storageSpec = null;
                            for (var sn in specNames) {
                                var snLower = sn.toLowerCase();
                                for (var i = 0; i < colorKeywords.length; i++) {
                                    if (snLower.indexOf(colorKeywords[i]) >= 0) {
                                        colorSpec = sn;
                                        break;
                                    }
                                }
                                for (var i = 0; i < storageKeywords.length; i++) {
                                    if (snLower.indexOf(storageKeywords[i]) >= 0) {
                                        storageSpec = sn;
                                        break;
                                    }
                                }
                            }

                            // If we have exactly 2 specs and couldn't identify, just assign
                            var specKeys = Object.keys(specNames);
                            if (specKeys.length === 2) {
                                if (!storageSpec && !colorSpec) {
                                    storageSpec = specKeys[0];
                                    colorSpec = specKeys[1];
                                } else if (!storageSpec) {
                                    storageSpec = specKeys[0] === colorSpec ? specKeys[1] : specKeys[0];
                                } else if (!colorSpec) {
                                    colorSpec = specKeys[0] === storageSpec ? specKeys[1] : specKeys[0];
                                }
                            } else if (specKeys.length === 1) {
                                // Only one spec dimension
                                if (colorSpec) {
                                    storageSpec = null;
                                } else if (storageSpec) {
                                    colorSpec = null;
                                } else {
                                    storageSpec = specKeys[0];
                                    colorSpec = null;
                                }
                            }

                            return {colorSpec: colorSpec, storageSpec: storageSpec, specNames: specNames};
                        }

                        function getUniqueValues(specName) {
                            var vals = [];
                            var seen = {};
                            for (var vid in VARIANTS) {
                                var v = VARIANTS[vid].specs[specName];
                                if (v && !seen[v]) {
                                    seen[v] = true;
                                    vals.push(v);
                                }
                            }
                            return vals;
                        }

                        function findVariant(storageVal, colorVal, storageSpec, colorSpec) {
                            for (var vid in VARIANTS) {
                                var v = VARIANTS[vid];
                                var matchStorage = !storageSpec || v.specs[storageSpec] === storageVal;
                                var matchColor = !colorSpec || v.specs[colorSpec] === colorVal;
                                if (matchStorage && matchColor)
                                    return v;
                            }
                            return null;
                        }

                        function getAvailableColors(storageVal, storageSpec, colorSpec) {
                            var colors = {};
                            for (var vid in VARIANTS) {
                                var v = VARIANTS[vid];
                                if (!storageSpec || v.specs[storageSpec] === storageVal) {
                                    var c = v.specs[colorSpec];
                                    if (c && !colors[c]) {
                                        colors[c] = v.price;
                                    }
                                }
                            }
                            return colors;
                        }

                        function formatPrice(price) {
                            return price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + 'đ';
                        }

                        function selectVariantAndUpdate(variant) {
                            if (!variant)
                                return;
                            selectedVariantId = variant.id;
                            document.getElementById('formVariantId').value = variant.id;
                            document.getElementById('displayPrice').textContent = formatPrice(variant.price);

                            // Cập nhật bảng thông số kỹ thuật (Spec Table)
                            var dynamicContainer = document.getElementById('dynamic-variant-specs');
                            if (dynamicContainer) {
                                dynamicContainer.innerHTML = '';
                                for (var sn in variant.specs) {
                                    var row = document.createElement('div');
                                    row.className = 'spec-row';
                                    row.style.background = '#fff5f5'; // Highlight nhẹ các thông số đang chọn
                                    row.innerHTML = '<div class="spec-name">' + sn + '</div>' +
                                            '<div class="spec-value" style="color:#dc2626;">' + variant.specs[sn] + '</div>';
                                    dynamicContainer.appendChild(row);
                                }
                            }
                        }

                        function buildVariantUI() {
                            var analysis = analyzeVariants();
                            var hasSpecs = Object.keys(analysis.specNames).length > 0;

                            if (!hasSpecs) {
                                // Fallback: show SKU buttons
                                var skuSection = document.getElementById('skuSection');
                                var skuOptions = document.getElementById('skuOptions');
                                skuSection.style.display = '';
                                var first = true;
                                for (var vid in VARIANTS) {
                                    var v = VARIANTS[vid];
                                    var btn = document.createElement('div');
                                    btn.className = 'variant-opt' + (first ? ' selected' : '');
                                    btn.textContent = v.sku;
                                    btn.dataset.variantId = v.id;
                                    btn.onclick = (function (variant) {
                                        return function () {
                                            document.querySelectorAll('#skuOptions .variant-opt').forEach(function (b) {
                                                b.classList.remove('selected');
                                            });
                                            this.classList.add('selected');
                                            selectVariantAndUpdate(variant);
                                        };
                                    })(v);
                                    skuOptions.appendChild(btn);
                                    first = false;
                                }
                                return;
                            }

                            var storageSpec = analysis.storageSpec;
                            var colorSpec = analysis.colorSpec;

                            // Build storage buttons
                            if (storageSpec) {
                                var storageSection = document.getElementById('storageSection');
                                var storageOptions = document.getElementById('storageOptions');
                                storageSection.style.display = '';
                                document.querySelector('#storageSection .variant-label').textContent = storageSpec;

                                var storageVals = getUniqueValues(storageSpec);
                                selectedStorage = storageVals[0];

                                storageVals.forEach(function (sv, idx) {
                                    var btn = document.createElement('div');
                                    btn.className = 'variant-opt' + (idx === 0 ? ' selected' : '');
                                    btn.textContent = sv;
                                    btn.dataset.value = sv;
                                    btn.onclick = function () {
                                        document.querySelectorAll('#storageOptions .variant-opt').forEach(function (b) {
                                            b.classList.remove('selected');
                                        });
                                        this.classList.add('selected');
                                        selectedStorage = sv;
                                        if (colorSpec) {
                                            buildColorButtons(selectedStorage, storageSpec, colorSpec);
                                        } else {
                                            // Only storage, find variant directly
                                            var variant = findVariant(sv, null, storageSpec, null);
                                            selectVariantAndUpdate(variant);
                                        }
                                    };
                                    storageOptions.appendChild(btn);
                                });
                            }

                            // Build color buttons
                            if (colorSpec) {
                                document.getElementById('colorSection').style.display = '';
                                document.querySelector('#colorSection .variant-label').textContent = colorSpec;
                                buildColorButtons(selectedStorage, storageSpec, colorSpec);
                            } else if (storageSpec) {
                                // Just storage, select first variant
                                var firstVariant = findVariant(selectedStorage, null, storageSpec, null);
                                selectVariantAndUpdate(firstVariant);
                            }
                        }

                        function buildColorButtons(storageVal, storageSpec, colorSpec) {
                            var colorOptions = document.getElementById('colorOptions');
                            colorOptions.innerHTML = '';

                            var availableColors = getAvailableColors(storageVal, storageSpec, colorSpec);
                            var colorKeys = Object.keys(availableColors);
                            selectedColor = colorKeys.length > 0 ? colorKeys[0] : null;

                            colorKeys.forEach(function (colorName, idx) {
                                var btn = document.createElement('div');
                                btn.className = 'variant-opt color-opt' + (idx === 0 ? ' selected' : '');
                                btn.innerHTML = '<span class="color-name">' + colorName + '</span>';
                                btn.dataset.color = colorName;
                                btn.onclick = function () {
                                    document.querySelectorAll('#colorOptions .variant-opt').forEach(function (b) {
                                        b.classList.remove('selected');
                                    });
                                    this.classList.add('selected');
                                    selectedColor = colorName;
                                    var variant = findVariant(storageVal, colorName, storageSpec, colorSpec);
                                    selectVariantAndUpdate(variant);
                                };
                                colorOptions.appendChild(btn);
                            });

                            // Auto-select first color
                            if (selectedColor) {
                                var variant = findVariant(storageVal, selectedColor, storageSpec, colorSpec);
                                selectVariantAndUpdate(variant);
                            }
                        }

                        // ============ INIT ============
                        document.addEventListener('DOMContentLoaded', function () {
                            Fancybox.bind('[data-fancybox="gallery"]', {hideScrollbar: false});
                            buildVariantUI();
                        });

                        // ============ GALLERY ============
                        function changeImage(thumbEl, imgSrc) {
                            document.getElementById('mainImage').src = imgSrc;
                            document.getElementById('mainImageLink').href = imgSrc;
                            document.querySelectorAll('.thumb-item').forEach(function (t) {
                                t.classList.remove('active');
                            });
                            thumbEl.classList.add('active');
                        }

                        // ============ QUANTITY ============
                        function updateQuantity(change) {
                            var input = document.getElementById('qtyInput');
                            var val = parseInt(input.value) + change;
                            if (val >= 1)
                                input.value = val;
                        }

                        // ============ REVIEW MODAL ============
                        function openReviewModal(isEdit) {
                            document.getElementById('reviewModal').classList.add('show');
                            document.getElementById('reviewAction').value = isEdit ? 'edit' : 'add';
                            document.getElementById('modalTitle').textContent = isEdit ? 'Sửa đánh giá của bạn' : 'Viết đánh giá';
                            setRating(document.getElementById('reviewRating').value);
                        }
                        function closeReviewModal() {
                            document.getElementById('reviewModal').classList.remove('show');
                        }
                        function setRating(rating) {
                            document.getElementById('reviewRating').value = rating;
                            document.querySelectorAll('.star-btn').forEach(function (s) {
                                s.classList.toggle('active', parseInt(s.dataset.value) <= rating);
                            });
                            var texts = ["Tệ", "Không hài lòng", "Bình thường", "Hài lòng", "Tuyệt vời"];
                            var colors = ["#6b7280", "#f97316", "#3b82f6", "#16a34a", "#dc2626"];
                            var textEl = document.getElementById('ratingText');
                            textEl.textContent = texts[rating - 1];
                            textEl.style.color = colors[rating - 1];
                        }

                        // ============ ADD TO CART (AJAX) ============
                        var addToCartOverlay = null;
                        function showAddToCartLoading() {
                            if (!addToCartOverlay) {
                                addToCartOverlay = document.createElement('div');
                                addToCartOverlay.style.cssText = 'position:fixed;inset:0;z-index:9998;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,0.3);';
                                addToCartOverlay.innerHTML = '<div style="display:flex;flex-direction:column;align-items:center;gap:16px;background:#fff;padding:24px 32px;border-radius:16px;box-shadow:0 8px 32px rgba(0,0,0,0.15);">' +
                                        '<div style="width:48px;height:48px;border:4px solid #e5e7eb;border-top-color:#dc2626;border-radius:50%;animation:spin 0.8s linear infinite;"></div>' +
                                        '<span style="font-size:14px;font-weight:500;color:#374151;">Đang xử lý...</span></div>';
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
                            var icon = isError ? '<span style="color:#dc2626;font-weight:700;font-size:18px;">!</span>' :
                                    '<svg width="20" height="20" fill="none" stroke="#16a34a" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>';
                            wrapper.innerHTML = '<div style="display:flex;align-items:center;gap:12px;padding:14px 18px;border-radius:14px;border:1px solid ' + border + ';background:' + bg + ';color:' + color + ';box-shadow:0 4px 16px rgba(0,0,0,0.08);">' +
                                    icon + '<span style="flex:1;font-size:14px;font-weight:500;">' + message + '</span>' +
                                    '<button onclick="this.closest(\'#toast-add-cart\').remove()" style="background:none;border:none;cursor:pointer;color:#9ca3af;font-size:16px;">✕</button></div>';
                            document.body.appendChild(wrapper);
                            setTimeout(function () {
                                if (wrapper.parentNode)
                                    wrapper.remove();
                            }, 3000);
                        }

                        function updateNavbarCartCount(delta) {
                            var badge = document.getElementById('navbarCartCount');
                            if (!badge)
                                return;
                            var cur = parseInt(badge.textContent, 10) || 0;
                            var next = cur + delta;
                            badge.textContent = next;
                            if (next > 0)
                                badge.classList.remove('hidden');
                            else
                                badge.classList.add('hidden');
                        }
                        function setNavbarCartCount(count) {
                            var badge = document.getElementById('navbarCartCount');
                            if (!badge)
                                return;
                            badge.textContent = count;
                            if (count > 0)
                                badge.classList.remove('hidden');
                            else
                                badge.classList.add('hidden');
                        }

                        document.addEventListener('DOMContentLoaded', function () {
                            var form = document.getElementById('addToCartForm');
                            if (!form)
                                return;
                            form.addEventListener('submit', function (e) {
                                e.preventDefault();
                                showAddToCartLoading();
                                var url = form.getAttribute('action');
                                url = url + (url.indexOf('?') >= 0 ? '&' : '?') + 'ajax=1';
                                var fd = new FormData(form);
                                var params = new URLSearchParams();
                                fd.forEach(function (value, key) {
                                    params.append(key, value);
                                });
                                params.append('ajax', '1');
                                fetch(url, {
                                    method: 'POST', credentials: 'same-origin',
                                    headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json'},
                                    body: params.toString()
                                }).then(function (response) {
                                    if (!response.ok)
                                        throw new Error('HTTP ' + response.status);
                                    var ct = (response.headers.get('content-type') || '').toLowerCase();
                                    if (ct.indexOf('application/json') === -1) {
                                        showAddToCartToast('Đã thêm vào giỏ hàng. Đang tải lại...', false);
                                        setTimeout(function () {
                                            window.location.reload();
                                        }, 1200);
                                        return null;
                                    }
                                    return response.json();
                                }).then(function (data) {
                                    if (!data)
                                        return;
                                    if (data.success === false) {
                                        hideAddToCartLoading();
                                        showAddToCartToast(data.message || 'Không thể thêm vào giỏ hàng.', true);
                                        return;
                                    }
                                    showAddToCartToast(data.message || 'Đã thêm vào giỏ hàng. Đang tải lại...', false);
                                    setTimeout(function () {
                                        window.location.reload();
                                    }, 1200);
                                }).catch(function () {
                                    hideAddToCartLoading();
                                    showAddToCartToast('Không thể thêm vào giỏ hàng, vui lòng thử lại.', true);
                                });
                            });
                        });
</script>