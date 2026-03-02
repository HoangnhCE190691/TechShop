<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 px-4">
    
    <div class="w-full max-w-md bg-white shadow-2xl rounded-2xl p-8 space-y-6">
        
        <div class="text-center">
            <h2 class="text-2xl font-bold text-gray-800">Xác thực OTP</h2>
            <p class="text-gray-500 mt-2 text-sm">
                Nhập mã 6 chữ số đã gửi đến email của bạn
            </p>
        </div>

        <form action="VerifyControl" method="post" class="space-y-4">
            
            <input 
                type="text" 
                name="otp_input" 
                placeholder="000000"
                maxlength="6" 
                required
                class="w-full text-center tracking-widest text-2xl font-semibold 
                       border border-gray-300 rounded-xl py-3 
                       focus:outline-none focus:ring-2 focus:ring-indigo-500 
                       focus:border-indigo-500 transition duration-200"
            >

            <button 
                type="submit"
                class="w-full bg-indigo-600 hover:bg-indigo-700 
                       text-white font-semibold py-3 rounded-xl 
                       transition duration-200 shadow-md hover:shadow-lg"
            >
                Xác nhận
            </button>
        </form>

        <% String error = (String) request.getAttribute("mess"); %>
        <% if (error != null) { %>
            <p class="text-red-500 text-sm text-center font-medium">
                <%= error %>
            </p>
        <% } %>

    </div>
</div>