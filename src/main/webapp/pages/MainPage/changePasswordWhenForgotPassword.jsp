<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="mt-20 mb-20 px-4">
    <div class="max-w-sm mx-auto p-6 border border-gray-200 rounded-lg shadow-sm bg-white">
        <h2 class="text-2xl font-bold text-gray-900 mb-2 text-center">New Password</h2>
        <p class="text-sm text-gray-600 mb-6 text-center">
            Set a strong password with at least 8 characters, 1 uppercase, and 1 special symbol.
        </p>

        <form action="changepasswordforgot" method="post" id="passwordForm">
            
            <%-- New Password Input --%>
            <div class="mb-5">
                <label for="password" class="block mb-2 text-sm font-medium text-gray-900">New Password</label>
                <input type="password" id="password" name="password" 
                       class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5" 
                       placeholder="••••••••" required />
                
                <%-- Password Requirements Checklist --%>
                <div id="checklist" class="mt-3 space-y-1">
                    <p id="length" class="text-xs text-red-500 transition-colors duration-200">✖ At least 8 characters</p>
                    <p id="uppercase" class="text-xs text-red-500 transition-colors duration-200">✖ At least 1 uppercase letter (A-Z)</p>
                    <p id="special" class="text-xs text-red-500 transition-colors duration-200">✖ At least 1 special character (!@#$...)</p>
                </div>
            </div>

            <%-- Confirm Password Input --%>
            <div class="mb-5">
                <label for="confirmPassword" class="block mb-2 text-sm font-medium text-gray-900">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" 
                       class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5" 
                       placeholder="••••••••" required />
                
                <%-- Server-side Error --%>
                <c:if test="${not empty errorPassword}">
                    <p class="mt-2 text-sm text-red-600 font-medium">${errorPassword}</p>
                </c:if>
                
                <%-- Client-side Match Error --%>
                <p id="matchError" class="mt-2 text-sm text-red-600 font-medium hidden">Passwords do not match!</p>
            </div>

            <button type="submit" id="submitBtn" disabled
                    class="text-white bg-gray-400 cursor-not-allowed font-medium rounded-lg text-sm w-full px-5 py-2.5 text-center transition-all duration-200">
                Reset Password
            </button>
        </form>
    </div>
</div>

<script>
    const passwordInput = document.getElementById('password');
    const confirmInput = document.getElementById('confirmPassword');
    const submitBtn = document.getElementById('submitBtn');
    
    // Checklist items
    const checkLength = document.getElementById('length');
    const checkUpper = document.getElementById('uppercase');
    const checkSpecial = document.getElementById('special');
    const matchError = document.getElementById('matchError');

    function validate() {
        const val = passwordInput.value;
        const confVal = confirmInput.value;

        // 1. Validate Length
        const isLengthValid = val.length >= 8;
        updateStatus(checkLength, isLengthValid);

        // 2. Validate Uppercase
        const isUpperValid = /[A-Z]/.test(val);
        updateStatus(checkUpper, isUpperValid);

        // 3. Validate Special Character
        const isSpecialValid = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(val);
        updateStatus(checkSpecial, isSpecialValid);

        // 4. Validate Passwords Match
        let isMatch = false;
        if (confVal !== "") {
            isMatch = (val === confVal);
            matchError.classList.toggle('hidden', isMatch);
        }

        // Final Check to Enable Button
        if (isLengthValid && isUpperValid && isSpecialValid && isMatch) {
            submitBtn.disabled = false;
            submitBtn.classList.remove('bg-gray-400', 'cursor-not-allowed');
            submitBtn.classList.add('bg-blue-700', 'hover:bg-blue-800', 'active:scale-95');
        } else {
            submitBtn.disabled = true;
            submitBtn.classList.add('bg-gray-400', 'cursor-not-allowed');
            submitBtn.classList.remove('bg-blue-700', 'hover:bg-blue-800', 'active:scale-95');
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

    passwordInput.addEventListener('input', validate);
    confirmInput.addEventListener('input', validate);
</script>