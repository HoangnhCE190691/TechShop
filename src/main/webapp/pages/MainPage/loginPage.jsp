<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty verifyPOPUP && verifyPOPUP}">
    <div class="fixed inset-0 bg-gray-900 bg-opacity-60 z-50 flex justify-center items-center backdrop-blur-sm transition-opacity">
        <div class="bg-white rounded-2xl shadow-2xl p-6 max-w-sm w-full mx-4 text-center transform transition-all">
            <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                </svg>
            </div>
            
            <h3 class="text-xl font-bold text-gray-900 mb-2">Yêu cầu xác thực!</h3>
            <p class="text-sm text-gray-500 mb-6">
                Tài khoản <b>${username}</b> của bạn chưa được xác thực. Vui lòng xác thực email để tiếp tục đăng nhập.
            </p>
            
            <div class="flex space-x-3">
                <button onclick="this.closest('.fixed').style.display='none'" 
                        class="flex-1 px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-xl text-sm font-semibold transition-colors">
                    Hủy bỏ
                </button>
                
                <form action="forgotpassword" method="get" class="flex-1">
                    <input type="hidden" name="action" value="sendVerificationEmail">
                    <input type="hidden" name="username" value="${username}">
                    <button type="submit" 
                            class="w-full px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-semibold shadow-lg shadow-blue-500/30 transition-all active:scale-95">
                        Xác thực ngay
                    </button>
                </form>
            </div>
        </div>
    </div>
</c:if>
<div class="mt-20 mb-20">
    <form action="loginservlet" method="post" class="max-w-sm mx-auto p-6 border border-gray-200 rounded-lg shadow-sm bg-white mt-2">
        
        <h2 class="text-2xl font-bold text-gray-900 mb-6 text-center">Login</h2>

        <div class="mb-5">
            <label for="username" class="block mb-2 text-sm font-medium text-gray-900">Your username</label>
            <input type="text" id="username" name="username" value="${username}" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 placeholder-gray-400" placeholder="username" required />
        </div>

        <div class="mb-5">
            <label for="password" class="block mb-2 text-sm font-medium text-gray-900">Your password</label>
            <input type="password" id="password" name="password" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 placeholder-gray-400" placeholder="••••••••" required />
            
            <c:if test="${not empty error}">
                <p class="mt-2 text-sm text-red-600 font-medium">${error}</p>
            </c:if>
            
            <div class="flex justify-end mt-2">
                <a href="forgotpassword" class="text-sm text-blue-600 hover:underline">Forgot password?</a>
            </div>
        </div>

        <button type="submit" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full px-5 py-2.5 text-center transition-colors">Submit</button>
    </form>
</div>