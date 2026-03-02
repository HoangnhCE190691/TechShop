<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.min.css" rel="stylesheet" />      
        <title>Staff Dashboard</title>
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
                    <div class="w-8 h-8 mr-2 rounded bg-blue-100 flex items-center justify-center text-blue-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                    </div>
                    <span class="self-center text-xl font-bold whitespace-nowrap text-gray-800">TechShop Staff</span>
                </div>

                <ul class="space-y-2 font-medium">
                    <%-- 1. DASHBOARD --%>
                    <c:set var="isDash" value="${param.action == 'dashboard' || empty param.action}" />
                    <li>
                        <a href="staffservlet?action=dashboard" 
                           class="flex items-center p-2 rounded-lg group transition-colors duration-200 ${isDash ? 'bg-blue-50 text-blue-700' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isDash ? 'text-blue-700' : 'text-gray-500 group-hover:text-blue-700'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M16.975 11H10V4.025a1 1 0 0 0-1.066-.998 8.5 8.5 0 1 0 9.039 9.039.999.999 0 0 0-1-1.066h.002Z"/>
                                <path d="M12.5 0c-.157 0-.311.01-.565.027A1 1 0 0 0 11 1.02V10h8.975a1 1 0 0 0 1-.935c.013-.188.028-.374.028-.565A8.51 8.51 0 0 0 12.5 0Z"/>
                            </svg>
                            <span class="ms-3">Dashboard</span>
                        </a>
                    </li>

                    <%-- 2. ORDER MANAGEMENT (Icon: Shopping Bag/Cart) --%>
                    <c:set var="isOrder" value="${param.action == 'processOrderManagement'}" />                    
                    <li>
                        <a href="staffservlet?action=processOrderManagement" 
                           class="flex items-center p-2 rounded-lg group transition-colors duration-200 ${isOrder ? 'bg-blue-50 text-blue-700' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isOrder ? 'text-blue-700' : 'text-gray-500 group-hover:text-blue-700'}" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 2a4 4 0 00-4 4v1H5a1 1 0 00-.994.89l-1 9A1 1 0 004 18h12a1 1 0 00.994-1.11l-1-9A1 1 0 0015 7h-1V6a4 4 0 00-4-4zm2 5V6a2 2 0 10-4 0v1h4zm-6 3a1 1 0 112 0 1 1 0 01-2 0zm7-1a1 1 0 100 2 1 1 0 000-2z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="ms-3 whitespace-nowrap">Manage Orders</span>
                        </a>
                    </li>

                    <%-- 3. SUPPLIER (Icon: Truck/Building) --%>
                    <c:set var="isSupplier" value="${param.action == 'supplierManagement'}" />                    
                    <li>
                        <a href="staffservlet?action=supplierManagement" 
                           class="flex items-center p-2 rounded-lg group transition-colors duration-200 ${isSupplier ? 'bg-blue-50 text-blue-700' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isSupplier ? 'text-blue-700' : 'text-gray-500 group-hover:text-blue-700'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M4 4a2 2 0 00-2 2v1h16V6a2 2 0 00-2-2H4z"></path>
                                <path fill-rule="evenodd" d="M18 9H2v5a2 2 0 002 2h12a2 2 0 002-2V9zM4 13a1 1 0 011-1h1a1 1 0 110 2H5a1 1 0 01-1-1zm5-1a1 1 0 100 2h1a1 1 0 100-2H9z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="ms-3 whitespace-nowrap">Suppliers</span>
                        </a>
                    </li>

                    <%-- 4. PRODUCTS (Icon: Box/Archive) --%>
                    <c:set var="isProduct" value="${param.action == 'productManagement'}" />                    
                    <li>
                        <a href="staffservlet?action=productManagement" 
                           class="flex items-center p-2 rounded-lg group transition-colors duration-200 ${isProduct ? 'bg-blue-50 text-blue-700' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isProduct ? 'text-blue-700' : 'text-gray-500 group-hover:text-blue-700'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M7 3a1 1 0 000 2h6a1 1 0 100-2H7zM4 7a1 1 0 011-1h10a1 1 0 110 2H5a1 1 0 01-1-1zM2 11a2 2 0 012-2h12a2 2 0 012 2v4a2 2 0 01-2 2H4a2 2 0 01-2-2v-4z"></path>
                            </svg>
                            <span class="ms-3 whitespace-nowrap">Products</span>
                        </a>
                    </li>
                    
                     <c:set var="isProductVariant" value="${param.action == 'productVariantManagement'}" />                    
                    <li>
                        <a href="staffservlet?action=productVariantManagement" 
                           class="flex items-center p-2 rounded-lg group transition-colors duration-200 ${isProductVariant ? 'bg-blue-50 text-blue-700' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isProductVariant ? 'text-blue-700' : 'text-gray-500 group-hover:text-blue-700'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M7 3a1 1 0 000 2h6a1 1 0 100-2H7zM4 7a1 1 0 011-1h10a1 1 0 110 2H5a1 1 0 01-1-1zM2 11a2 2 0 012-2h12a2 2 0 012 2v4a2 2 0 01-2 2H4a2 2 0 01-2-2v-4z"></path>
                            </svg>
                            <span class="ms-3 whitespace-nowrap">Products Variant</span>
                        </a>
                    </li>

                    <%-- 5. INVENTORY / RECEIPTS (Icon: Clipboard List) --%>
                    <c:set var="isInventory" value="${param.action == 'inventoryManagement'}" />                    
                    <li>
                        <a href="staffservlet?action=inventoryManagement" 
                           class="flex items-center p-2 rounded-lg group transition-colors duration-200 ${isInventory ? 'bg-blue-50 text-blue-700' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isInventory ? 'text-blue-700' : 'text-gray-500 group-hover:text-blue-700'}" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="ms-3 whitespace-nowrap">Inventory</span>
                        </a>
                    </li>

                    <%-- 6. REVIEWS / FEEDBACK (Icon: Star/Chat) --%>
                    <c:set var="isReview" value="${param.action == 'reviewManagement'}" />                    
                    <li>
                        <a href="staffservlet?action=reviewManagement" 
                           class="flex items-center p-2 rounded-lg group transition-colors duration-200 ${isReview ? 'bg-blue-50 text-blue-700' : 'text-gray-900 hover:bg-gray-100'}">
                            <svg class="w-5 h-5 transition duration-75 ${isReview ? 'text-blue-700' : 'text-gray-500 group-hover:text-blue-700'}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path>
                            </svg>
                            <span class="ms-3 whitespace-nowrap">Feedback</span>
                        </a>
                    </li>

                   

                    <ul class="pt-4 mt-4 space-y-2 font-medium border-t border-gray-200">
                        <li>
                            <a href="logoutservlet" class="flex items-center p-2 text-red-600 rounded-lg hover:bg-red-50 group">
                                <svg class="w-5 h-5 transition duration-75 text-red-500 group-hover:text-red-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
                                <span class="ms-3">Logout</span>
                            </a>
                        </li>
                    </ul>
                </ul>
            </div>
        </aside>

        <div class="p-4 sm:ml-64">
            <div class="p-4 border-2 border-gray-200 border-dashed rounded-lg mt-3 bg-white shadow-sm min-h-[85vh]">
                <%-- Nơi nội dung thay đổi --%>
                <jsp:include page="${contentPage}" />
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.min.js"></script>      
        <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    </body>
</html>