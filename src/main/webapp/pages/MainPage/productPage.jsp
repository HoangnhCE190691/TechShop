<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<div class="max-w-[1200px] mx-auto px-4 py-8 font-sans text-gray-800">
    <div class="flex flex-col lg:flex-row gap-8">

        <aside class="w-full lg:w-1/4 flex flex-col gap-6">
            <form action="productpageservlet" method="GET" id="filterForm">
                <input type="hidden" name="keyword" value="${keyword}" />
                <div class="border border-gray-200 rounded-xl p-5 bg-white shadow-sm mb-6">
                    <h3 class="font-bold text-lg mb-4 text-gray-900 border-b pb-2">Danh mục</h3>
                    <ul class="space-y-3 text-sm">
                        <li>
                            <label
                                class="flex items-center gap-2 cursor-pointer hover:text-red-600 transition-colors">
                                <input type="radio" name="categoryId" value=""
                                       class="w-4 h-4 text-red-600 focus:ring-red-500" ${empty categoryId
                                                                                         ? 'checked' : '' } onchange="this.form.submit()">
                                <span>Tất cả</span>
                            </label>
                        </li>
                        <c:forEach var="c" items="${categoryList}">
                            <li>
                                <label
                                    class="flex items-center gap-2 cursor-pointer hover:text-red-600 transition-colors">
                                    <input type="radio" name="categoryId" value="${c.categoryId}"
                                           class="w-4 h-4 text-red-600 focus:ring-red-500"
                                           ${categoryId==c.categoryId ? 'checked' : '' }
                                           onchange="this.form.submit()">
                                    <span>${c.categoryName}</span>
                                </label>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <div class="border border-gray-200 rounded-xl p-5 bg-white shadow-sm mb-6">
                    <h3 class="font-bold text-lg mb-4 text-gray-900 border-b pb-2">Hãng sản xuất</h3>
                    <div class="space-y-3 text-sm">
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="brandId" value=""
                                   class="w-4 h-4 text-red-600 focus:ring-red-500" ${empty brandId ? 'checked'
                                                                                     : '' } onchange="this.form.submit()">
                            <span>Tất cả</span>
                        </label>
                        <c:forEach var="b" items="${brandList}">
                            <label class="flex items-center gap-2 cursor-pointer">
                                <input type="radio" name="brandId" value="${b.brandId}"
                                       class="w-4 h-4 text-red-600 focus:ring-red-500" ${brandId==b.brandId
                                                                                         ? 'checked' : '' } onchange="this.form.submit()">
                                <span>${b.brandName}</span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <div class="border border-gray-200 rounded-xl p-5 bg-white shadow-sm mb-6">
                    <h3 class="font-bold text-lg mb-4 text-gray-900 border-b pb-2">Mức giá</h3>
                    <div class="space-y-3 text-sm">
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="priceRange" value=""
                                   class="w-4 h-4 text-red-600 focus:ring-red-500" ${empty priceRange
                                                                                     ? 'checked' : '' } onchange="this.form.submit()">
                            <span>Tất cả</span>
                        </label>
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="priceRange" value="under5"
                                   class="w-4 h-4 text-red-600 focus:ring-red-500" ${priceRange=='under5'
                                                                                     ? 'checked' : '' } onchange="this.form.submit()">
                            <span>Dưới 5 triệu</span>
                        </label>
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="priceRange" value="5to10"
                                   class="w-4 h-4 text-red-600 focus:ring-red-500" ${priceRange=='5to10'
                                                                                     ? 'checked' : '' } onchange="this.form.submit()">
                            <span>Từ 5 - 10 triệu</span>
                        </label>
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="priceRange" value="15to25"
                                   class="w-4 h-4 text-red-600 focus:ring-red-500" ${priceRange=='15to25'
                                                                                     ? 'checked' : '' } onchange="this.form.submit()">
                            <span>Từ 15 - 25 triệu</span>
                        </label>
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="priceRange" value="over25"
                                   class="w-4 h-4 text-red-600 focus:ring-red-500" ${priceRange=='over25'
                                                                                     ? 'checked' : '' } onchange="this.form.submit()">
                            <span>Trên 25 triệu</span>
                        </label>
                    </div>
                </div>
            </form>
        </aside>

        <main class="w-full lg:w-3/4">

            <div
                class="flex justify-between items-center mb-6 bg-white p-3 rounded-xl border border-gray-200 shadow-sm">
                <span class="text-sm font-medium">Sắp xếp theo:</span>
                <select
                    class="border border-gray-300 rounded-md text-sm px-3 py-1.5 focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500">
                    <option>Giá: Thấp đến Cao</option>
                    <option>Giá: Cao đến Thấp</option>
                </select>
            </div>

            <div class="grid grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
                <c:forEach var="p" items="${productList}">
                    <div
                        class="group bg-white border border-gray-100 rounded-2xl p-4 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col relative">
                        <div
                            class="aspect-square mb-4 overflow-hidden rounded-xl bg-gray-50 flex items-center justify-center p-4">
                            <img src="${empty p.thumbnailUrl ? pageContext.request.contextPath.concat('/assest/img/product/samsung-galaxy-s25-green-thumbai-600x600.jpg') : pageContext.request.contextPath.concat('/').concat(p.thumbnailUrl)}"
                                 alt="${p.name}"
                                 class="object-contain w-full h-full group-hover:scale-105 transition-transform duration-500">
                        </div>

                        <div class="flex flex-col flex-1">
                            <h3
                                class="font-semibold text-gray-800 text-sm md:text-base line-clamp-2 hover:text-red-600 cursor-pointer">
                                ${p.name}</h3>
                            <div class="mt-2 flex items-center gap-1">
                                <span class="text-yellow-400 text-sm">★★★★★</span>
                                <span class="text-xs text-gray-500">(50)</span>
                            </div>
                            <div class="mt-auto pt-3">
                                <p class="text-red-600 font-bold text-lg">
                                <fmt:formatNumber value="${p.minPrice != null ? p.minPrice : 0}"
                                                  type="number" groupingUsed="true" />đ
                                </p>
                            </div>
                            <a href="detailservlet?productId=${p.productId}"
                               class="w-full mt-4 text-center bg-red-50 border border-red-500 text-red-600 font-semibold py-2 rounded-lg hover:bg-red-500 hover:text-white transition-colors duration-300 text-sm block">
                                Xem chi tiết
                            </a>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty productList}">
                    <div class="col-span-full py-12 text-center text-gray-500">
                        Không tìm thấy sản phẩm nào phù hợp với bộ lọc hiện tại.
                    </div>
                </c:if>
            </div>

            <!-- Removed pagination for now -->

        </main>
    </div>
</div>