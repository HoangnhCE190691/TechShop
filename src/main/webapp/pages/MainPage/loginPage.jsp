<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="mt-20 mb-20">
    <form action="loginservlet" method="post" class="max-w-sm mx-auto p-4 border border-gray-200 rounded-lg shadow-sm bg-white mt-2">
        <div class="mb-5">
            <label for="username" class="block mb-2 text-sm font-medium text-gray-900">Your username</label>
            <input type="text" id="username" name="username" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 placeholder-gray-400" placeholder="username" required />
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



        <button type="submit" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center">Submit</button>
    </form>
</div>
