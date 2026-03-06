<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${empty employee}">
    <c:redirect url="../../employeeservlet?action=loginPage"/>
</c:if>

<div class="bg-gray-50 min-h-screen py-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <div class="flex items-center justify-between mb-8">
            <div>
                <h1 class="text-3xl font-bold text-gray-900">Employee Profile</h1>
                <p class="mt-1 text-sm text-gray-500">Welcome back, <span class="font-semibold text-blue-600">${employee.fullName}</span></p>
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
                                     src="https://ui-avatars.com/api/?name=${employee.username}&background=random" 
                                     alt="Avatar">
                                <span class="absolute bottom-2 right-2 w-6 h-6 
                                      ${employee.status == 'ACTIVE' ? 'bg-green-500' : (employee.status == 'LOCKED' ? 'bg-red-500' : 'bg-gray-400')} 
                                      border-4 border-white rounded-full" title="Status: ${employee.status}"></span>
                            </div>

                            <h2 class="text-xl font-bold text-gray-900 text-center mt-3">${employee.fullName}</h2>
                            <p class="text-sm text-gray-500 text-center mb-4">@${employee.username}</p>

                            <div class="w-full border-t border-gray-200 my-4"></div>

                            <nav class="w-full space-y-1">
                                <a href="profileemployee" class="bg-blue-50 text-blue-700 group flex items-center px-3 py-2 text-sm font-medium rounded-md">
                                    <svg class="text-blue-500 flex-shrink-0 -ml-1 mr-3 h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                                    <span class="truncate">My Profile</span>
                                </a>

                                <a href="profileemployee?action=changepassword" class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors">
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
                        <h3 class="text-lg leading-6 font-medium text-gray-900">Employee Information</h3>
                        <a href="profileemployee?action=edit" class="text-sm text-blue-600 hover:text-blue-800 font-medium">Edit Info</a>
                    </div>
                    <div class="px-6 py-5">
                        <dl class="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Employee ID</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">#${employee.employeeId}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Username</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">${employee.username}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Full name</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">${employee.fullName}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Email address</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">${employee.email}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Phone number</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">${employee.phoneNumber}</dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">System Role</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">
                                    ${employee.role.role_name}
                                </dd>
                            </div>
                            <div class="sm:col-span-1">
                                <dt class="text-sm font-medium text-gray-500">Account Status</dt>
                                <dd class="mt-1 text-sm text-gray-900 font-semibold">
                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                          ${employee.status == 'ACTIVE' ? 'bg-green-100 text-green-800' : 
                                            employee.status == 'LOCKED' ? 'bg-red-100 text-red-800' : 
                                            'bg-gray-100 text-gray-800'}">
                                              ${employee.status}
                                          </span>
                                    </dd>
                                </div>
                                <div class="sm:col-span-1">
                                    <dt class="text-sm font-medium text-gray-500">Created At</dt>
                                    <dd class="mt-1 text-sm text-gray-900">${employee.createdAt}</dd>
                                </div>
                            </dl>
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
    </div>