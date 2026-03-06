<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="max-w-4xl mx-auto py-10 px-4 sm:px-6 lg:px-8">
    <div class="bg-white shadow-xl rounded-lg overflow-hidden">
        <div class="bg-gradient-to-r from-teal-600 to-emerald-700 px-6 py-8 text-white">
            <h1 class="text-2xl font-bold">Chỉnh sửa thông tin nhân viên</h1>
            <p class="text-teal-100 mt-2">Cập nhật hồ sơ cá nhân của bạn trên hệ thống quản trị.</p>
        </div>

        <form action="profileemployee" method="POST" class="p-8 space-y-6">
            <input type="hidden" name="action" value="edit">

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-sm font-medium text-gray-700 mb-2">Họ và tên</label>
                    <input type="text" name="fullName" value="${employee.fullName}" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-teal-500 focus:border-teal-500 transition shadow-sm"
                           required>
                </div>

                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tên đăng nhập (Không thể đổi)</label>
                    <input type="text" value="${employee.username}" 
                           class="w-full px-4 py-2 bg-gray-100 border border-gray-200 rounded-md text-gray-500 cursor-not-allowed"
                           readonly>
                </div>

                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                    <input type="email" name="email" value="${employee.email}" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-teal-500 focus:border-teal-500 transition shadow-sm"
                           required>
                    <c:if test="${not empty errorGmail}">
                        <p class="mt-1 text-xs text-red-600 font-medium">${errorGmail}</p>
                    </c:if>
                </div>

                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-sm font-medium text-gray-700 mb-2">Số điện thoại</label>
                    <input type="tel" name="phoneNumber" value="${employee.phoneNumber}"  pattern="^0(3|5|7|8|9)[0-9]{8}$"  title="Số điện thoại phải bắt đầu bằng 0, theo sau là 3, 5, 7, 8, 9 và đủ 10 chữ số." 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-teal-500 focus:border-teal-500 transition shadow-sm"
                           required>
                    <c:if test="${not empty errorPhone}">
                        <p class="mt-1 text-xs text-red-600 font-medium">${errorPhone}</p>
                    </c:if>
                </div>

            </div>

            <div class="pt-6 border-t border-gray-200 flex items-center justify-end gap-4">
                <a href="profileemployee" class="px-6 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
                    Hủy bỏ
                </a>
                <button type="submit" class="cursor-pointer  px-6 py-2 bg-teal-600 border border-transparent rounded-md shadow-sm text-sm font-medium text-white hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 transition">
                    Lưu thay đổi
                </button>
            </div>
        </form>
    </div>
</div>