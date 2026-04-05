<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="max-w-md mx-auto py-12 px-4">
    <div class="bg-white shadow-2xl rounded-2xl overflow-hidden border border-gray-100">
        <div class="bg-gray-900 px-6 py-6 text-white text-center">
            <h2 class="text-2xl font-bold">Change Password</h2>
            <p class="text-gray-400 text-sm mt-1">Please enter your current password to change it.</p>
        </div>

        <form action="profilestaff" method="POST" class="p-8 space-y-5" id="changePasswordForm">
            <input type="hidden" name="action" value="changePassword">

            <%-- Current Password --%>
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Current Password</label>
                <input type="password" name="oldPassword" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition">
                <c:if test="${not empty errorOldPass}">
                    <p class="mt-1 text-xs text-red-600 font-medium">${errorOldPass}</p>
                </c:if>
            </div>

            <hr class="border-gray-100">

            <%-- New Password --%>
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">New Password</label>
                <input type="password" name="newPassword" id="newPassword" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition">
                
                <%-- Password Requirements Checklist --%>
                <div id="checklist" class="mt-3 space-y-1">
                    <p id="length" class="text-xs text-red-500">✖ At least 8 characters</p>
                    <p id="uppercase" class="text-xs text-red-500">✖ At least 1 uppercase letter (A-Z)</p>
                    <p id="special" class="text-xs text-red-500">✖ At least 1 special character (!@#$...)</p>
                </div>
            </div>

            <%-- Confirm New Password --%>
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Confirm New Password</label>
                <input type="password" name="confirmPassword" id="confirmPassword" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition">
                
                <c:if test="${not empty errorNewPass}">
                    <p class="mt-1 text-xs text-red-600 font-medium">${errorNewPass}</p>
                </c:if>
                <p id="matchError" class="mt-2 text-sm text-red-600 font-medium hidden">New passwords do not match!</p>
            </div>

            <div class="pt-4">
                <button type="submit" id="submitBtn" disabled
                        class="w-full bg-gray-400 cursor-not-allowed text-white font-bold py-3 rounded-xl shadow-lg transition-all duration-200 transform">
                    Update Password
                </button>
                <a href="profilestaff" class="block text-center mt-4 text-sm text-gray-500 hover:text-gray-700">
                    Return to Dashboard
                </a>
            </div>
        </form>
    </div>
</div>

<script>
    const newPassInput = document.getElementById('newPassword');
    const confirmInput = document.getElementById('confirmPassword');
    const submitBtn = document.getElementById('submitBtn');
    
    const checkLength = document.getElementById('length');
    const checkUpper = document.getElementById('uppercase');
    const checkSpecial = document.getElementById('special');
    const matchError = document.getElementById('matchError');

    function validatePasswords() {
        const val = newPassInput.value;
        const confVal = confirmInput.value;

        // 1. Validate Requirements
        const isLengthValid = val.length >= 8;
        updateStatus(checkLength, isLengthValid);

        const isUpperValid = /[A-Z]/.test(val);
        updateStatus(checkUpper, isUpperValid);

        const isSpecialValid = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(val);
        updateStatus(checkSpecial, isSpecialValid);

        // 2. Validate Matching
        let isMatch = false;
        if (confVal !== "") {
            isMatch = (val === confVal);
            matchError.classList.toggle('hidden', isMatch);
        }

        // 3. Final Check to Enable Button
        if (isLengthValid && isUpperValid && isSpecialValid && isMatch) {
            submitBtn.disabled = false;
            submitBtn.classList.remove('bg-gray-400', 'cursor-not-allowed');
            submitBtn.classList.add('bg-blue-600', 'hover:bg-blue-700', 'hover:-translate-y-1');
        } else {
            submitBtn.disabled = true;
            submitBtn.classList.add('bg-gray-400', 'cursor-not-allowed');
            submitBtn.classList.remove('bg-blue-600', 'hover:bg-blue-700', 'hover:-translate-y-1');
        }
    }

    function updateStatus(element, isValid) {
        if (isValid) {
            element.classList.remove('text-red-500');
            element.classList.add('text-green-600');
            element.innerText = element.innerText.replace('✖', '✔');
        } else {
            element.classList.remove('text-green-600');
            element.classList.add('text-red-500');
            element.innerText = element.innerText.replace('✔', '✖');
        }
    }

    newPassInput.addEventListener('input', validatePasswords);
    confirmInput.addEventListener('input', validatePasswords);
</script>