<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div class="mt-8 flex justify-center items-center">
    <div class="w-full max-w-md bg-white p-6 rounded-lg shadow-md border border-gray-100">

        <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">Create Account</h2>

        <form action="registerservlet" method="POST" class="max-w-md mx-auto">
            <input type="hidden" name="action" value="register">

            <div class="relative z-0 w-full mb-5 group">
                <input type="text" name="username" id="username" value="${oldUsername}" 
                       class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" 
                       placeholder=" " required />
                <label for="username" class="absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">
                    Username
                </label>
                <c:if test="${not empty errorUsername}">
                    <p class="mt-2 text-sm text-red-600 font-medium">${errorUsername}</p>
                </c:if>
            </div>

            <div class="grid md:grid-cols-2 md:gap-6">
                <div class="relative z-0 w-full mb-5 group">
                    <input type="text" name="full_name" id="full_name"  value="${oldFullName}"
                           class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" 
                           placeholder=" " required />
                    <label for="full_name" class="absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">
                        Full Name
                    </label>
                </div>
                <div class="relative z-0 w-full mb-5 group">
                    <input type="tel" name="phone_number" id="phone_number" pattern="^0(3|5|7|8|9)[0-9]{8}$"  title="Validation errors" value="${oldPhone}"
                           class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" 
                           placeholder=" " required />
                    <label for="phone_number" class="absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">
                        Phone (10 digits)
                    </label>
                    <c:if test="${not empty errorPhone}">
                        <p class="mt-2 text-sm text-red-600 font-medium">${errorPhone}</p>
                    </c:if>
                </div>
            </div>

            <div class="relative z-0 w-full mb-5 group">
                <input type="email" name="email" id="email"  value="${oldEmail}"
                       class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" 
                       placeholder=" " required />
                <label for="email" class="absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">
                    Email address
                </label>
                <c:if test="${not empty errorEmail}">
                    <p class="mt-2 text-sm text-red-600 font-medium">${errorEmail}</p>
                </c:if>
            </div>



            <div class="relative z-0 w-full mb-5 group">
                <input type="password" name="password" id="password" value="${oldPassword}"
                       class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" 
                       placeholder=" " required />
                <label for="password" class="absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">
                    Password
                </label>
            </div>



            <button type="submit" class="text-white bg-blue-600 hover:bg-blue-700 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full px-5 py-2.5 text-center shadow-lg shadow-blue-500/30 transform transition active:scale-95">
                Register Account
            </button>

            <p class="mt-4 text-sm text-center text-gray-500">
                Already have an account? <a href="userservlet?action=loginPage" class="text-blue-600 hover:underline">Log in</a>
            </p>
        </form>
    </div>
</div>