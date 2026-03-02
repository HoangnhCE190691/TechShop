<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="mt-20 mb-20 px-4">
    <div class="max-w-sm mx-auto p-6 border border-gray-200 rounded-lg shadow-sm bg-white">
        <h2 class="text-2xl font-bold text-gray-900 mb-4 text-center">Reset Password</h2>
        <p class="text-sm text-gray-600 mb-6 text-center">
            Enter your email address and we'll send you a OTP to reset your password.
        </p>

        <form action="forgotpassword" method="post">
            <div class="mb-5">
                <label for="email" class="block mb-2 text-sm font-medium text-gray-900">Your Email</label>
                <input type="email" id="email" name="email" 
                       class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 placeholder-gray-400" 
                       placeholder="name@company.com" required />
                
                <%-- Hiển thị thông báo lỗi hoặc thành công nếu có --%>
             
                <c:if test="${not empty errorEmail}">
                    <p class="mt-2 text-sm text-red-600 font-medium">${errorEmail}</p>
                </c:if>
            </div>

            <button type="submit" 
                    class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full px-5 py-2.5 text-center">
                Send OTP
            </button>
            
            <div class="mt-4 text-center">
                <a href="login.jsp" class="text-sm text-blue-600 hover:underline">Back to Login</a>
            </div>
        </form>
    </div>
</div>