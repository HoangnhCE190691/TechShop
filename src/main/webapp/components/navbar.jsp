<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<header class=" w-full z-20 top-0 start-0 bg-white shadow-sm">

    <nav class="bg-white border-b border-gray-200">
        <div class="flex flex-wrap justify-between items-center mx-auto max-w-screen-xl p-4 gap-4">

            <a href="https://flowbite.com" class="flex items-center space-x-3 shrink-0">
                <img src="https://flowbite.com/docs/images/logo.svg" class="h-8" alt="Flowbite Logo" />
                <span class="self-center text-xl font-bold text-gray-900 whitespace-nowrap">Flowbite</span>
            </a>

            <div class="flex-1 max-w-lg mx-auto hidden md:block relative">
                <form action="productpageservlet" method="GET" class="relative w-full block" id="search-form"
                      autocomplete="off">

                    <div class="absolute inset-y-0 start-0 flex items-center ps-3 pointer-events-none">
                        <svg class="w-4 h-4 text-gray-500" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"
                             fill="none" viewBox="0 0 20 20">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"
                                  stroke-width="2" d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z" />
                        </svg>
                    </div>

                    <input type="search" id="search-input" name="keyword"
                           value="${not empty keyword ? keyword : ''}"
                           class="block w-full p-2.5 ps-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500"
                           placeholder="Tìm kiếm sản phẩm..." required autocomplete="off">
                </form>

                <!-- Box Dropdown Search AJAX -->
                <div id="search-results-dropdown"
                     class="absolute z-50 w-full bg-white rounded-lg shadow-lg border border-gray-200 mt-1 hidden overflow-hidden left-0 right-0">
                    <!-- HTML trả về sẽ render tại đây -->
                </div>
            </div>

            <div class="flex items-center gap-4 shrink-0">



                <c:choose>
                    <%-- TRƯỜNG HỢP 1: CÓ COOKIE (Đã đăng nhập) --%>
                    <c:when test="${not empty cookie.cookieID.value}">

                        <a href="cartservlet"
                           class="relative group p-2 text-gray-700 hover:text-blue-600 transition-colors">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none"
                                 viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                      d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>

                            <!--                <c:if test="">
                                    <span class="absolute top-0 right-0 inline-flex items-center justify-center px-1.5 py-0.5 text-xs font-bold leading-none text-white transform translate-x-1/4 -translate-y-1/4 bg-red-600 rounded-full">
                                   
                                    </span>
                            </c:if>-->
                        </a>

                        <div class="relative group ml-2">
                            <button type="button" class="flex items-center gap-2 focus:outline-none">
                                <img class="w-9 h-9 rounded-full border border-gray-200 object-cover"
                                     src="https://ui-avatars.com/api/?name=${cookie.cookieUser.value}&background=random"
                                     alt="Avatar">
                            </button>

                            <div
                                class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50 border border-gray-100">
                                <a href="userservlet?action=userDashboard&id=${cookie.cookieID.value}"
                                   class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Thông
                                    tin tài khoản</a>
                                <a href="orderhistorypageservlet"
                                   class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Lịch sử
                                    đơn hàng</a>
                                <div class="border-t border-gray-100 my-1"></div>
                                <c:if test="${cookie.cookieRole.value eq 'ADMIN' }">
                                    <a href="adminservlet?action=dashboard"
                                       class="block px-4 py-2 text-sm text-blue-600 hover:bg-gray-100 font-medium">Quản
                                        lý hệ thống</a>
                                    </c:if>
                                    <c:if test="${ cookie.cookieRole.value eq 'STAFF'}">
                                    <a href="staffservlet?action=dashboard"
                                       class="block px-4 py-2 text-sm text-blue-600 hover:bg-gray-100 font-medium">Quản
                                        lý hệ thống</a>
                                    </c:if>
                                <a href="logoutservlet"
                                   class="block px-4 py-2 text-sm text-red-600 hover:bg-gray-50">Đăng
                                    xuất</a>
                            </div>
                        </div>

                    </c:when>

                    <%-- TRƯỜNG HỢP 2: KHÔNG CÓ COOKIE (Chưa đăng nhập) --%>
                    <c:otherwise>
                        <a href="userservlet?action=loginPage"
                           class="text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors">
                            Đăng nhập
                        </a>

                        <a href="userservlet?action=registerPage"
                           class="text-white bg-blue-600 hover:bg-blue-700 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 transition-colors focus:outline-none ml-2">
                            Đăng kí
                        </a>
                    </c:otherwise>
                </c:choose>

            </div>
        </div>
    </nav>

    <nav class="bg-gray-50 border-b border-gray-200">
        <div class="max-w-screen-xl px-4 py-3 mx-auto flex justify-center">

            <ul class="flex flex-row font-medium space-x-12 text-sm">

                <li>
                    <a href="userservlet?action=homePage"
                       class="text-gray-900 hover:text-blue-600 transition-colors" aria-current="page">Trang
                        chủ</a>
                </li>

                <li class="relative group">
                    <a href="productpageservlet"
                       class="flex items-center text-gray-900 hover:text-blue-600 focus:outline-none transition-colors">
                        Sản phẩm
                        <!--                        <svg class="w-2.5 h-2.5 ms-2 transition-transform duration-200 group-hover:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 6">
                                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 4 4 4-4"/>
                                        </svg>-->
                    </a>

                    <!--                    <div class="absolute left-1/2 -translate-x-1/2 top-full mt-3 z-50 hidden group-hover:block w-48 bg-white divide-y divide-gray-100 rounded-lg shadow-xl border border-gray-100">
            
                                    <div class="absolute -top-1.5 left-1/2 -translate-x-1/2 w-3 h-3 bg-white border-t border-l border-gray-100 transform rotate-45"></div>
            
                                    <ul class="relative py-2 text-sm text-gray-700 bg-white rounded-lg">
                                        <li><a href="#" class="block px-4 py-2 hover:bg-blue-50 hover:text-blue-600">Điện thoại</a></li>
                                        <li><a href="#" class="block px-4 py-2 hover:bg-blue-50 hover:text-blue-600">Laptop</a></li>
                                        <li><a href="#" class="block px-4 py-2 hover:bg-blue-50 hover:text-blue-600">Máy tính bảng</a></li>
                                        <li><a href="#" class="block px-4 py-2 hover:bg-blue-50 hover:text-blue-600">Phụ kiện</a></li>
                                    </ul>
                                </div>-->
                </li>

                <li><a href="Infomationservlet" class="text-gray-900 hover:text-blue-600 transition-colors">Công
                        ty</a></li>
                <li><a href="contactservlet"
                       class="text-gray-900 hover:text-blue-600 transition-colors">Contact</a></li>
            </ul>

        </div>
    </nav>
</header>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const searchInput = document.getElementById('search-input');
        const searchResultsDropdown = document.getElementById('search-results-dropdown');
        const searchForm = document.getElementById('search-form');
        let searchTimeout = null;

        if (searchInput && searchResultsDropdown) {
            searchInput.addEventListener('input', function (e) {
                clearTimeout(searchTimeout);
                const keyword = e.target.value.trim();

                if (keyword.length > 0) {
                    // Render loading indicator nếu muốn

                    // Thời gian chờ tránh gọi API liên tục
                    searchTimeout = setTimeout(() => {
                        fetch('searchSuggestionServlet?keyword=' + encodeURIComponent(keyword))
                                .then(response => response.text())
                                .then(html => {
                                    searchResultsDropdown.innerHTML = html;
                                    searchResultsDropdown.classList.remove('hidden');
                                })
                                .catch(error => console.error('Fetch live search error:', error));
                    }, 300);
                } else {
                    searchResultsDropdown.classList.add('hidden');
                    searchResultsDropdown.innerHTML = '';
                }
            });

            // Event click ra ngoài để ẩn dropdown
            document.addEventListener('click', function (event) {
                if (!searchForm.contains(event.target) && !searchResultsDropdown.contains(event.target)) {
                    searchResultsDropdown.classList.add('hidden');
                }
            });

            // Event focus lại input sẽ show lên lại
            searchInput.addEventListener('focus', function () {
                if (this.value.trim().length > 0 && searchResultsDropdown.innerHTML.trim() !== '') {
                    searchResultsDropdown.classList.remove('hidden');
                }
            });
        }
    });
</script>