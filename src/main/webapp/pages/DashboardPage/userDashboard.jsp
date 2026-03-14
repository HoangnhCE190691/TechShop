<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${empty customer}">
    <c:redirect url="../../userservlet?action=loginPage"/>
</c:if>

<div class="bg-gray-50 min-h-screen py-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <div class="flex items-center justify-between mb-8">
            <div>
                <h1 class="text-3xl font-bold text-gray-900">My Account</h1>
                <p class="mt-1 text-sm text-gray-500">Welcome back, <span class="font-semibold text-blue-600">${customer.fullname}</span></p>
            </div>
            <a href="logoutservlet" class="inline-flex items-center px-4 py-2 bg-white border border-gray-300 rounded-md font-semibold text-xs text-red-600 uppercase tracking-widest shadow-sm hover:bg-red-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-25 transition ease-in-out duration-150">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" /></svg>
                Sign Out
            </a>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

            <div class="lg:col-span-4 xl:col-span-3">
                <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg sticky top-6">
                    <div class="p-6">
                        <div class="flex flex-col items-center">
                            <div class="relative group">

                                <img class="w-32 h-32 rounded-full border border-gray-200 object-cover" 
                                     src="https://ui-avatars.com/api/?name=${cookie.cookieUser.value}&background=random" 
                                     alt="Avatar">
                                <span class="absolute bottom-2 right-2 w-6 h-6 ${customer.status == 'ACTIVE' ? 'bg-green-500' : 'bg-gray-400'} border-4 border-white rounded-full" title="Status: ${customer.status}"></span>
                            </div>

                            <h2 class="text-xl font-bold text-gray-900 text-center">${customer.fullname}</h2>
                            <p class="text-sm text-gray-500 text-center mb-4">@${customer.userName}</p>

                            <div class="w-full border-t border-gray-200 my-4"></div>

                            <nav class="w-full space-y-1">
                                <a href="userdashboardservlet" class="bg-blue-50 text-blue-700 group flex items-center px-3 py-2 text-sm font-medium rounded-md">
                                    <svg class="text-blue-500 flex-shrink-0 -ml-1 mr-3 h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                                    <span class="truncate">Profile & Address</span>
                                </a>

                                <a href="orderhistorypageservlet" class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors">
                                    <svg class="text-gray-400 group-hover:text-gray-500 flex-shrink-0 -ml-1 mr-3 h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path></svg>
                                    <span class="truncate">Order History</span>
                                </a> 
                                 <a href="userdashboardservlet?action=changepassword" class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors">
                                  <svg class="text-gray-400 group-hover:text-gray-500 flex-shrink-0 -ml-1 mr-3 h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
        
                                    <span class="truncate">Change Password</span>
                                </a>  
                            </nav>
                        </div>
                    </div>
                </div>
            </div>

            <div class="lg:col-span-8 xl:col-span-9 space-y-6">

                <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg">
                    <div class="px-6 py-5 border-b border-gray-200 flex justify-between items-center">
                        <h3 class="text-lg leading-6 font-medium text-gray-900">Personal Information</h3>
                        <a href="userdashboardservlet?action=edit" class="text-sm text-blue-600 hover:text-blue-800 font-medium">Edit Info</a>
                    </div>
                    <div class="px-6 py-5">
                        <dl class="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Full name</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">${customer.fullname}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Phone number</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">${customer.phoneNumber}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Email address</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">${customer.email}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Member Since</dt>
                                <dd class="mt-1 text-sm text-gray-900">${customer.createdAt}</dd>
                            </div>
                        </dl>
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg">
                    <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg">
                        <div class="px-6 py-5 border-b border-gray-200 flex justify-between items-center bg-gray-50">
                            <div class="flex items-center gap-2">
                                <svg class="h-5 w-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                                <h3 class="text-lg leading-6 font-medium text-gray-900">Address Book</h3>
                            </div>

                            <c:choose>
                                <c:when test="${fn:length(listAddress) >= 2}">
                                    <button type="button" disabled class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-gray-500 bg-gray-200 cursor-not-allowed shadow-sm transition">
                                        <svg class="h-4 w-4 mr-1 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                                        Max 2 addresses
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <a href="addresssuserservlet?action=add" class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition">
                                        <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                                        Add New
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="px-6 py-6 bg-gray-50/50">
                            <c:choose>
                                <c:when test="${empty listAddress}">
                                    <div class="text-center py-10 border-2 border-dashed border-gray-300 rounded-lg">
                                        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                                        <h3 class="mt-2 text-sm font-medium text-gray-900">No addresses</h3>
                                        <p class="mt-1 text-sm text-gray-500">Get started by creating a new address.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                        <c:forEach items="${listAddress}" var="addr">
                                            <div class="relative bg-white rounded-xl p-5 border-2 ${addr.isDefault ? 'border-blue-500 ring-2 ring-blue-50 shadow-md' : 'border-gray-200 hover:border-blue-300'} transition-all duration-200 group">

                                                <div class="flex justify-between items-start">
                                                    <div>
                                                        <div class="flex items-center gap-2">
                                                            <span class="text-base font-bold text-gray-900">${addr.nameReceiver}</span>
                                                            <c:if test="${addr.isDefault}">
                                                                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-bold bg-blue-100 text-blue-800 uppercase">
                                                                    Default
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                        <p class="text-sm font-medium text-blue-600 mt-1">${addr.phoneReceiver}</p>
                                                    </div>
                                                    <div class="text-gray-400">
                                                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
                                                    </div>
                                                </div>

                                                <div class="mt-3">
                                                    <p class="text-sm text-gray-500 leading-relaxed min-h-[40px] line-clamp-2">
                                                        ${addr.address}
                                                    </p>
                                                </div>

                                                <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-end gap-3 opacity-0 group-hover:opacity-100 transition-opacity">
                                                  
                                                    <a href="addresssuserservlet?action=edit&id=${addr.addressId}"  class="text-xs font-semibold text-gray-500 hover:text-blue-600 transition-colors">Edit</a>
                                                    <span class="text-gray-300">|</span>
                                                    <a href="addresssuserservlet?action=delete&id=${addr.addressId}" 
                                                       onclick="return confirm('Delete this address?')" 
                                                       class="text-xs font-semibold text-red-500 hover:text-red-700 transition-colors flex items-center">
                                                        Delete
                                                    </a>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <script>
            setTimeout(function () {
                alert("${errorMessage}");
            }, 100);
        </script>
    </c:if>

    <c:if test="${not empty successMessage}">
        <script>
            setTimeout(function () {
                alert("${successMessage}");
            }, 100);
        </script>
    </c:if>