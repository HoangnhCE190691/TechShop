<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="flex justify-center items-start pt-10 px-4">
    <div class="w-full max-w-2xl bg-white rounded-2xl shadow-2xl border border-gray-100 p-8 transition-all duration-300 hover:shadow-blue-100">

        <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-50 text-blue-600 rounded-full mb-4">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                </svg>
            </div>
            <h2 class="text-3xl font-extrabold text-gray-900 tracking-tight">Update Customer</h2>
            <p class="text-gray-500 mt-2">Editing profile for: <span class="px-2 py-0.5 bg-blue-100 text-blue-700 rounded font-mono text-sm">@${customer.userName}</span></p>
        </div>

        <form action="customerservlet" method="POST" class="space-y-6">
            <input type="hidden" name="action" value="edit">
                <input type="hidden" name="customerID" value="${customer.customerID}">

                    <div class="grid md:grid-cols-2 md:gap-8">
                        <div class="relative z-0 w-full mb-6 group">
                            <input type="text" name="username" value="${customer.userName}" readonly 
                                   class="block py-2.5 px-0 w-full text-sm text-gray-400 bg-transparent border-0 border-b-2 border-gray-200 appearance-none focus:outline-none cursor-not-allowed" />
                            <label class="absolute text-sm text-gray-400 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0]">Username (Locked)</label>
                        </div>

                        <div class="relative z-0 w-full mb-6 group">
                            <input type="text" name="full_name" id="full_name" value="${customer.fullname}" 
                                   class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" placeholder=" " required />
                            <label for="full_name" class="peer-focus:font-medium absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">Full Name</label>
                        </div>
                    </div>

                    <div class="relative z-0 w-full mb-6 group">
                        <input type="email" name="email" id="email" value="${customer.email}" 
                               class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" placeholder=" " required />
                        <label for="email" class="peer-focus:font-medium absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">Email Address</label>
                        <c:if test="${not empty errorEmail}">
                            <p class="mt-1 text-xs text-red-600 font-medium">${errorEmail}</p>
                        </c:if>
                    </div>            

                    <div class="grid md:grid-cols-1 md:gap-8">
                        <div class="relative z-0 w-full mb-6 group">
                            <input type="tel" pattern="^0(3|5|7|8|9)[0-9]{8}$"  title="Số điện thoại phải bắt đầu bằng 0, theo sau là 3, 5, 7, 8, 9 và đủ 10 chữ số." name="phone_number" id="phone_number" value="${customer.phoneNumber}" 
                                   class="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" placeholder=" " required />
                            <label for="phone_number" class="peer-focus:font-medium absolute text-sm text-gray-500 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">Phone Number</label>
                            <c:if test="${not empty errorNumber}">
                                <p class="mt-1 text-xs text-red-600 font-medium">${errorNumber}</p>
                            </c:if>
                        </div>


                    </div>

                    <div class="flex items-center justify-end space-x-3 pt-6 border-t border-gray-50">
                        <a href="customerservlet?action=all" 
                           class="inline-flex items-center px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-red-600 focus:ring-4 focus:outline-none focus:ring-gray-100 transition-all duration-200">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                            Cancel
                        </a>
                        <button type="submit" 
                                class="inline-flex items-center px-8 py-2.5 text-sm font-bold text-white bg-gradient-to-r from-blue-600 to-indigo-600 rounded-lg hover:from-blue-700 hover:to-indigo-700 focus:ring-4 focus:outline-none focus:ring-blue-300 shadow-lg shadow-blue-500/30 active:scale-95 transition-all duration-200">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                            Save Changes
                        </button>
                    </div>
                    </form>
                    </div>
                    </div>


                    <script>
                        function togglePasswordVisibility() {
                            const passwordInput = document.getElementById('password');
                            const eyeIcon = document.getElementById('eyeIcon');

                            if (passwordInput.type === 'password') {
                                // Hiện mật khẩu
                                passwordInput.type = 'text';
                                // Đổi icon sang con mắt có gạch chéo (ẩn)
                                eyeIcon.innerHTML = `
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.542-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18"></path>
`;
                            } else {
                                // Ẩn mật khẩu
                                passwordInput.type = 'password';
                                // Đổi icon lại con mắt bình thường
                                eyeIcon.innerHTML = `
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
`;
                            }
                        }
                    </script>