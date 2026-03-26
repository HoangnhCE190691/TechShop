<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

            <c:choose>
                <c:when test="${not empty suggestList}">
                    <ul class="py-2 text-sm text-gray-700 w-full list-none m-0 p-0 m-0 w-full box-border">
                        <c:forEach items="${suggestList}" var="product">
                            <li class="border-b border-gray-100 last:border-0 hover:bg-gray-50 block m-0">
                                <a href="detailservlet?productId=${product.productId}"
                                    class="flex items-center px-4 py-2 text-left gap-3 box-border" style="width: 100%;">
                                    <div
                                        class="flex-shrink-0 w-12 h-12 bg-gray-100 rounded flex items-center justify-center overflow-hidden">
                                        <c:if test="${not empty product.thumbnailUrl}">
                                            <img src="${pageContext.request.contextPath}/${product.thumbnailUrl}"
                                                alt="${product.name}" class="w-full h-full object-cover">
                                        </c:if>
                                        <c:if test="${empty product.thumbnailUrl}">
                                            <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z">
                                                </path>
                                            </svg>
                                        </c:if>
                                    </div>
                                    <div class="flex flex-col truncate" style="flex: 1; min-width: 0;">
                                        <span
                                            class="font-medium text-gray-900 truncate block w-full whitespace-nowrap overflow-hidden text-ellipsis">${product.name}</span>
                                        <span class="text-red-600 font-bold block">
                                            <c:if test="${not empty product.minPrice and product.minPrice > 0}">
                                                <fmt:formatNumber pattern="#,###" value="${product.minPrice}" />đ
                                            </c:if>
                                            <c:if test="${empty product.minPrice or product.minPrice == 0}">
                                                <span class="text-gray-500 font-normal">Contact</span>
                                            </c:if>
                                        </span>
                                    </div>
                                </a>
                            </li>
                        </c:forEach>
                        <!-- Xem thêm kết quả -->
                        <li class="bg-blue-50 hover:bg-blue-100 transition-colors m-0 block w-full">
                            <a href="productpageservlet?keyword=${searchKeyword}"
                                class="block px-4 py-3 text-center text-blue-600 font-medium box-border"
                                style="width: 100%;">
                                View all results for "${searchKeyword}"
                            </a>
                        </li>
                    </ul>
                </c:when>
                <c:otherwise>
                    <div class="px-4 py-3 text-sm text-gray-500 text-center m-0 box-border w-full block">
                        No results found!
                    </div>
                </c:otherwise>
            </c:choose>