<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div class="mt-20 mb-20 px-4">
    <div class="max-w-sm mx-auto p-6 border border-gray-200 rounded-lg shadow-sm bg-white">
        <h2 class="text-2xl font-bold text-gray-900 mb-2 text-center">New Password</h2>
        <p class="text-sm text-gray-600 mb-6 text-center">
            Please enter your new password below to secure your account.
        </p>

        <form action="changepasswordforgot" method="post">
           
            <div class="mb-5">
                <label for="password" class="block mb-2 text-sm font-medium text-gray-900">New Password</label>
                <input type="password" id="password" name="password" 
                       class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5" 
                       placeholder="••••••••" required />
            </div>

            <div class="mb-5">
                <label for="confirmPassword" class="block mb-2 text-sm font-medium text-gray-900">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" 
                       class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5" 
                       placeholder="••••••••" required />
                <c:if test="${not empty errorPassword}">
                    <p class="mt-2 text-sm text-red-600 font-medium">${errorPassword}</p>
                </c:if>

            </div>

            <button type="submit" 
                    class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full px-5 py-2.5 text-center">
                Reset Password
            </button>
        </form>
    </div>
</div>