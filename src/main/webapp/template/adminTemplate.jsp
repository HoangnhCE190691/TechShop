<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.min.css" rel="stylesheet" />        <title>Admin Dashboard - Tech Shop</title>
    </head>
    <body class="bg-gray-50">

        <button data-drawer-target="separator-sidebar" data-drawer-toggle="separator-sidebar" aria-controls="separator-sidebar" type="button" class="inline-flex items-center p-2 mt-2 ms-3 text-sm text-gray-500 rounded-lg sm:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200">
            <span class="sr-only">Open sidebar</span>
            <svg class="w-6 h-6" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path clip-rule="evenodd" fill-rule="evenodd" d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zm0 10.5a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5a.75.75 0 01-.75-.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10z"></path>
            </svg>
        </button>

        <aside id="separator-sidebar" class="fixed top-0 left-0 z-40 w-64 h-screen transition-transform -translate-x-full sm:translate-x-0" aria-label="Sidebar">
            <div class="h-full px-3 py-4 overflow-y-auto bg-white border-r border-gray-200">
                <div class="flex items-center ps-2.5 mb-5">
                    <span class="self-center text-xl font-semibold whitespace-nowrap text-blue-600">TechShop Admin</span>
                </div>

                <ul class="space-y-2 font-medium">
                    <c:set var="isDash" value="${param.action == 'dashboard' || empty param.action}" />
                    <li>
                        <a href="adminservlet?action=dashboard" 
                           class="flex items-center p-2 rounded-lg group ${isDash ? 'bg-blue-50 text-blue-600 font-bold' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isDash ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 22 21">
                            <path d="M16.975 11H10V4.025a1 1 0 0 0-1.066-.998 8.5 8.5 0 1 0 9.039 9.039.999.999 0 0 0-1-1.066h.002Z"/>
                            <path d="M12.5 0c-.157 0-.311.01-.565.027A1 1 0 0 0 11 1.02V10h8.975a1 1 0 0 0 1-.935c.013-.188.028-.374.028-.565A8.51 8.51 0 0 0 12.5 0Z"/>
                            </svg>
                            <span class="ms-3">Dashboard</span>
                        </a>
                    </li>

                    <c:set var="isCust" value="${param.action == 'customerManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isCust ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=customerManagement" 
                               class="flex-1 flex items-center p-2 ${isCust ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isCust ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"></path>
                                </svg>
                                <span class="ms-3 text-nowrap">Customer</span>
                            </a>

                        </div>

                    </li>

                    <c:set var="isEmp" value="${param.action == 'employeeManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isEmp ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=employeeManagement" 
                               class="flex-1 flex items-center p-2 ${isEmp ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isEmp ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/>
                                </svg>
                                <span class="ms-3">Employee</span>
                            </a>

                        </div>

                    </li>

                    <c:set var="isCat" value="${param.action == 'categoryManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isCat ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=categoryManagement" 
                               class="flex-1 flex items-center p-2 ${isCat ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isCat ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M18 5h-7V2a1 1 0 0 0-2 0v3H2a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2Z"/>
                                </svg>
                                <span class="ms-3">Category</span>
                            </a>

                        </div>

                    </li>



                    <c:set var="isBrand" value="${param.action == 'brandManagement'}" />                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isBrand ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=brandManagement" 
                               class="flex-1 flex items-center p-2 ${isBrand ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isBrand ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M17 5.923A1 1 0 0 0 16 5h-3V4a4 4 0 1 0-8 0v1H2a1 1 0 0 0-1 .923L.086 17.846A2 2 0 0 0 2.08 20h13.84a2 2 0 0 0 1.994-2.153L17 5.923ZM7 9a1 1 0 0 1-2 0V7h2v2Zm0-5a2 2 0 1 1 4 0v1H7V4Zm6 5a1 1 0 1 1-2 0V7h2v2Z"/>
                                </svg>
                                <span class="ms-3 text-nowrap">Brand</span>
                            </a>

                        </div>

                    </li>


                    <c:set var="isSpecificationDefinition" value="${param.action == 'specificationDefinitionManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isSpecificationDefinition ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=specificationDefinitionManagement" 
                               class="flex-1 flex items-center p-2 ${isSpecificationDefinition ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isSpecificationDefinition ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M17 5.923A1 1 0 0 0 16 5h-3V4a4 4 0 1 0-8 0v1H2a1 1 0 0 0-1 .923L.086 17.846A2 2 0 0 0 2.08 20h13.84a2 2 0 0 0 1.994-2.153L17 5.923ZM7 9a1 1 0 0 1-2 0V7h2v2Zm0-5a2 2 0 1 1 4 0v1H7V4Zm6 5a1 1 0 1 1-2 0V7h2v2Z"/>
                                </svg>
                                <span class="ms-3 text-nowrap">Specification Definition</span>
                            </a>

                        </div>

                    </li>

                    <c:set var="isSpecificationValue" value="${param.action == 'specificationValueManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isSpecificationValue ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=specificationValueManagement" 
                               class="flex-1 flex items-center p-2 ${isSpecificationValue ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isSpecificationValue ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M17 5.923A1 1 0 0 0 16 5h-3V4a4 4 0 1 0-8 0v1H2a1 1 0 0 0-1 .923L.086 17.846A2 2 0 0 0 2.08 20h13.84a2 2 0 0 0 1.994-2.153L17 5.923ZM7 9a1 1 0 0 1-2 0V7h2v2Zm0-5a2 2 0 1 1 4 0v1H7V4Zm6 5a1 1 0 1 1-2 0V7h2v2Z"/>
                                </svg>
                                <span class="ms-3 text-nowrap">Specification Value</span>
                            </a>
                        </div>
                    </li>

                    <c:set var="isVouch" value="${param.action == 'voucherManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isVouch ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=voucherManagement" 
                               class="flex-1 flex items-center p-2 ${isVouch ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isVouch ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M11.074 4 8.442.47a1 1 0 0 0-1.588 0L4.223 4H11.074ZM2 6v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V6H2Zm14 3a1 1 0 1 1 0 2 1 1 0 0 1 0-2ZM5 9a1 1 0 1 1 0 2 1 1 0 0 1 0-2Z"/>
                                </svg>
                                <span class="ms-3">Voucher</span>
                            </a>

                        </div>

                    </li>

                    <c:set var="isPayment" value="${param.action == 'paymentMethodManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isPayment ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=paymentMethodManagement" 
                               class="flex-1 flex items-center p-2 ${isPayment ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isPayment ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M11.074 4 8.442.47a1 1 0 0 0-1.588 0L4.223 4H11.074ZM2 6v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V6H2Zm14 3a1 1 0 1 1 0 2 1 1 0 0 1 0-2ZM5 9a1 1 0 1 1 0 2 1 1 0 0 1 0-2Z"/>
                                </svg>
                                <span class="ms-3">Payment method</span>
                            </a>

                        </div>

                    </li>
                    <c:set var="isOrderStatus" value="${param.action == 'orderStatusManagement'}" />
                    <li>
                        <div class="flex items-center w-full rounded-lg group ${isOrderStatus ? 'bg-blue-50' : 'hover:bg-gray-100'}">
                            <a href="adminservlet?action=orderStatusManagement" 
                               class="flex-1 flex items-center p-2 ${isOrderStatus ? 'text-blue-600 font-bold' : 'text-gray-900 group-hover:text-blue-600'}">
                                <svg class="w-5 h-5 transition duration-75 ${isOrderStatus ? 'text-blue-600' : 'text-gray-500 group-hover:text-blue-600'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M2 5a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2V5zM2 13a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2v-2z" />
                                </svg>
                                <span class="ms-3">Order Statuses</span>
                            </a>
                        </div>
                    </li>
                </ul>

                <ul class="pt-4 mt-4 space-y-2 font-medium border-t border-gray-200">
                    <li>
                        <a href="logoutservlet" class="flex items-center p-2 text-red-600 rounded-lg hover:bg-red-50 group">
                            <svg class="w-5 h-5 transition duration-75" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 16">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 8h11m0 0L8 4m4 4-4 4m4-11h3a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-3"/>
                            </svg>
                            <span class="ms-3">Đăng xuất</span>
                        </a>
                    </li>
                </ul>
            </div>
        </aside>

        <div class="p-4 sm:ml-64">
            <div class="p-4 border-2 border-gray-200 border-dashed rounded-lg mt-3 bg-white shadow-sm min-h-[85vh]">
                <jsp:include page="${contentPage}" />
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.min.js"></script>      
        <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    </body>
</html>