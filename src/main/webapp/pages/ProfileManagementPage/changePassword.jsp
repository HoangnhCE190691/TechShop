<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div class="max-w-md mx-auto py-12 px-4">
    <div class="bg-white shadow-2xl rounded-2xl overflow-hidden border border-gray-100">
        <div class="bg-gray-900 px-6 py-6 text-white text-center">
            <h2 class="text-2xl font-bold">Đổi mật khẩu</h2>
            <p class="text-gray-400 text-sm mt-1">Vui lòng nhập mật khẩu hiện tại để thay đổi</p>
        </div>

        <form action="profileemployee" method="POST" class="p-8 space-y-5">
            <input type="hidden" name="action" value="changePassword">

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Mật khẩu hiện tại</label>
                <input type="password" name="oldPassword" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition">
                  <c:if test="${not empty errorOldPass}">
                            <p class="mt-1 text-xs text-red-600 font-medium">${errorOldPass}</p>
                        </c:if>
            </div>

            <hr class="border-gray-100">

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Mật khẩu mới</label>
                <input type="password" name="newPassword" id="newPassword" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition">
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
                <input type="password" name="confirmPassword" id="confirmPassword" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition">
                  <c:if test="${not empty errorNewPass}">
                            <p class="mt-1 text-xs text-red-600 font-medium">${errorNewPass}</p>
                        </c:if>
            </div>

            <div class="pt-4">
                <button type="submit" 
                        class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-xl shadow-lg transition-all duration-200 transform hover:-translate-y-1">
                    Cập nhật mật khẩu
                </button>
                <a href="userdashboardservlet" class="block text-center mt-4 text-sm text-gray-500 hover:text-gray-700">
                    Quay lại Dashboard
                </a>
            </div>
        </form>
    </div>
</div>

<!--<script>
    const form = document.querySelector('form');
    form.onsubmit = function () {
        const newPass = document.getElementById('newPassword').value;
        const confirmPass = document.getElementById('confirmPassword').value;
        if (newPass !== confirmPass) {
            alert("Mật khẩu mới và xác nhận mật khẩu không khớp!");
            return false;
        }
        return true;
    };
</script>-->