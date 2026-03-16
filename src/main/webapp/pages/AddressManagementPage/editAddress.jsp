<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="max-w-2xl mx-auto bg-white overflow-hidden shadow-xl sm:rounded-lg">
    <div class="px-6 py-5 border-b border-gray-200 bg-gray-50">
        <div class="flex items-center gap-2">
            <a href="userservlet?action=addressBook" class="text-gray-400 hover:text-blue-600 transition-colors">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
            </a>
            <h3 class="text-lg leading-6 font-medium text-gray-900">Update Address</h3>
        </div>
    </div>

    <div class="px-6 py-6 bg-white">
        <form action="addresssuserservlet" method="POST" class="space-y-6">
            <input type="hidden" name="addressId" value="${addressId}">

            <input type="hidden" name="provinceName" id="provinceName" value="${provinceName}">
            <input type="hidden" name="wardName" id="wardName" value="${wardName}">
            <input type="hidden" name="action" id="action" value="update">

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label for="nameReceiver" class="block text-sm font-medium text-gray-700 mb-1">Recipient's name <span class="text-red-500">*</span></label>
                    <input type="text" name="nameReceiver" id="nameReceiver" required 
                           value="${nameReceiver}"
                           class="w-full px-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition-colors"
                           placeholder="VD: Nguyễn Văn A">
                </div>

                <div>
                    <label for="phoneReceiver" class="block text-sm font-medium text-gray-700 mb-1">Phone number <span class="text-red-500">*</span></label>
                    <input type="tel" name="phoneReceiver" id="phoneReceiver" required pattern="^0(3|5|7|8|9)[0-9]{8}$"  
                           title="Phone numbers must start with 0, followed by 3, 5, 7, 8, 9, and must have 10 digits.."
                           value="${phoneReceiver}"
                           class="w-full px-4 py-2 text-sm border ${not empty errorPhone ? 'border-red-500' : 'border-gray-300'} rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition-colors"
                           placeholder="VD: 0912345678">
                    <c:if test="${not empty errorPhone}">
                        <p class="mt-1 text-xs text-red-600 font-medium">${errorPhone}</p>
                    </c:if>
                </div>
            </div>

            <div class="border-t border-gray-100 pt-5 mt-2">
                <h4 class="text-sm font-medium text-gray-900 mb-4">Address details <span class="text-red-500">*</span></h4>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                        <label for="province" class="block text-sm text-gray-700 mb-1">Province/City</label>
                        <select name="province" id="province" required
                                class="w-full px-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white">
                            <option value="">Select Province/City</option>
                        </select>
                    </div>

                    <div>
                        <label for="ward" class="block text-sm text-gray-700 mb-1">Ward/Commune/Town</label>
                        <select name="ward" id="ward" required disabled
                                class="w-full px-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-gray-50 disabled:opacity-60 transition-all">
                            <option value="">Select Ward/Commune</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label for="street" class="block text-sm text-gray-700 mb-1">House number, Street name</label>
                    <input type="text" name="street" id="street" required
                           value="${street}"
                           class="w-full px-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                           placeholder="VD: Số 123, Đường 3/2">
                </div>
            </div>

            <div class="flex items-center mt-4">
                <input type="checkbox" name="isDefault" id="isDefault" value="true"
                       ${(isCurrentDefault == true || isCurrentDefault == 'true' || isDefault == 'true') ? 'checked' : ''}
                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded cursor-pointer hover:ring-2 transition-all">

                <label for="isDefault" class="ml-2 block text-sm text-gray-900 cursor-pointer">
                    Set as default address

                    <c:if test="${!(isCurrentDefault == true || isCurrentDefault == 'true')}">
                        <span class="text-xs text-gray-500 italic ml-1">
                                (The old default address will be automatically replaced)
                        </span>
                    </c:if>
                </label>
            </div>

            <div class="flex items-center justify-end gap-3 pt-4 border-t border-gray-100">
                <a href="userdashboardservlet" 
                   class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition">
                 Cancel
                </a>
                <button type="submit" 
                        class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition shadow-sm">
                   Update Address </button>
            </div>
        </form>
    </div>
</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";
    const provinceUrl = contextPath + "/assets/js/province.json";
    const wardUrl = contextPath + "/assets/js/ward.json";

    let provincesData = [];
    let wardsData = [];

    // Nhờ các biến này mà khi load trang, JS sẽ tự động chọn đúng Tỉnh/Xã cũ của người dùng
    const savedProvinceName = "${provinceName}";
    const savedWardName = "${wardName}";

    document.addEventListener("DOMContentLoaded", function () {
        const provinceSelect = document.getElementById('province');
        const wardSelect = document.getElementById('ward');

        Promise.all([
            fetch(provinceUrl).then(res => res.json()),
            fetch(wardUrl).then(res => res.json())
        ])
                .then(([provinces, wards]) => {
                    provincesData = Object.values(provinces);
                    wardsData = Object.values(wards);

                    provinceSelect.innerHTML = '<option value="">Chọn Tỉnh/Thành</option>';
                    provincesData.sort((a, b) => a.name.localeCompare(b.name)).forEach(p => {
                        let opt = document.createElement('option');
                        opt.value = p.code;
                        opt.textContent = p.name_with_type;

                        if (p.name_with_type === savedProvinceName) {
                            opt.selected = true;
                        }
                        provinceSelect.appendChild(opt);
                    });

                    if (provinceSelect.value) {
                        provinceSelect.dispatchEvent(new Event('change'));
                }
                })
                .catch(err => {
                    console.error("Lỗi nạp file:", err);
                    provinceSelect.innerHTML = '<option value="">Lỗi nạp dữ liệu!</option>';
                });

        provinceSelect.onchange = function () {
            const pCode = this.value;
            const pName = this.options[this.selectedIndex].text;

            document.getElementById('provinceName').value = (pCode === "") ? "" : pName;

            wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
            wardSelect.disabled = true;

            if (pCode) {
                const filteredWards = wardsData.filter(w => w.parent_code == pCode);

                if (filteredWards.length > 0) {
                    filteredWards.sort((a, b) => a.name.localeCompare(b.name)).forEach(w => {
                        let opt = document.createElement('option');
                        opt.value = w.code;
                        opt.textContent = w.name_with_type;

                        if (w.name_with_type === savedWardName) {
                            opt.selected = true;
                        }
                        wardSelect.appendChild(opt);
                    });
                    wardSelect.disabled = false;
                }
            }
        };

        wardSelect.onchange = function () {
            const wName = this.options[this.selectedIndex].text;
            document.getElementById('wardName').value = (this.value === "") ? "" : wName;
        };
    });
</script>