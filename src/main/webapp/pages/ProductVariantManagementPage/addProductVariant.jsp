<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 1. THÔNG BÁO TOAST --%>
<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">
        <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 animate-bounce
             ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-green-50 text-green-800 border-green-200'}">
            <div class="flex-shrink-0 mr-3">
                <c:choose>
                    <c:when test="${sessionScope.msgType == 'danger'}">
                        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                        </svg>
                    </c:when>
                    <c:otherwise>
                        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                        </svg>
                    </c:otherwise>
                </c:choose>
            </div>
            <span class="font-bold uppercase tracking-wider text-sm">${sessionScope.msg}</span>
        </div>
    </div>
    <c:remove var="msg" scope="session" />
    <c:remove var="msgType" scope="session" />
    <script>
        setTimeout(() => {
            const toast = document.getElementById('toast-notification');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translate(-50%, -20px)';
                setTimeout(() => toast.remove(), 500);
            }
        }, 3000);
    </script>
</c:if>

<div class="max-w-4xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-10">
    <%-- HEADER --%>
    <div class="flex justify-between items-start border-b-4 border-gray-100 pb-6 mb-8">
        <div>
            <h2 class="text-3xl font-black text-gray-900 uppercase tracking-tighter">Add New Variant</h2>
            <p class="text-gray-500 mt-1 font-bold">Create a specific version for an existing product.</p>
        </div>
        <a href="variantServlet?action=all" class="text-gray-500 hover:text-blue-600 flex items-center gap-2 text-sm font-black transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            Back to List
        </a>
    </div>

    <form action="variantServlet" method="POST" class="space-y-8">
        <input type="hidden" name="action" value="add">

        <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
            <%-- THÔNG TIN KHO --%>
            <div class="space-y-6">
                <h3 class="text-lg font-black text-gray-800 border-l-8 border-blue-600 pl-3 uppercase">Inventory Info</h3>
                <div class="space-y-5">
                    <div>
                        <label class="text-xs font-black text-gray-500 uppercase tracking-widest">Select Product Parent</label>
                        <select id="productSelectDropdown" name="productId" required class="w-full mt-2 p-4 bg-gray-50 border-2 border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-500 outline-none font-bold cursor-pointer transition-all">
                            <option value="" data-category="" disabled selected>-- Choose Product --</option>
                            <c:forEach items="${products}" var="p">
                                <option value="${p.productId}" data-category="${p.categoryId}">${p.name} (ID: #${p.productId})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs font-black text-gray-500 uppercase tracking-widest"> SKU Identifier </label>
                        <input type="text" name="sku" 
                               required
                               pattern="^[A-Z0-9]+(?:-[A-Z0-9]+)+$"                               
                               title="Use uppercase letters, numbers, and hyphens only. Must contain at least one hyphen and cannot have leading, trailing, or consecutive hyphens (e.g., IP15-128-BLUE)."                               class="w-full mt-2 p-4 bg-gray-50 border-2 border-gray-200 rounded-xl font-black text-gray-900 uppercase focus:ring-4 focus:ring-blue-100 outline-none transition-all"
                               placeholder="e.g., IP15-128-BLUE"
                               oninput="this.value = this.value.toUpperCase()">
                    </div>
                </div>
            </div>

            <%-- GIÁ & TRẠNG THÁI --%>
            <div class="space-y-6">
                <h3 class="text-lg font-black text-gray-800 border-l-8 border-green-600 pl-3 uppercase">Market & Status</h3>
                <div class="space-y-5">
                    <div>
                        <label class="text-xs font-black text-gray-500 uppercase tracking-widest">Selling Price (₫)</label>
                        <input type="number" name="sellingPrice" required min="0" class="w-full mt-2 p-4 bg-gray-50 border-2 border-gray-200 rounded-xl font-black text-blue-700 text-2xl focus:ring-4 focus:ring-blue-100 outline-none transition-all" placeholder="0">
                    </div>
                    <div>
                        <label class="text-xs font-black text-gray-500 uppercase tracking-widest">Visibility Status</label>
                        <div class="mt-4 flex gap-8">
                            <label class="flex items-center gap-3 cursor-pointer">
                                <input type="radio" name="isActive" value="1" checked class="w-6 h-6 text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-black text-green-700 bg-green-50 px-5 py-1.5 rounded-full border-2 border-green-200 uppercase transition-all hover:bg-green-100">Active</span>
                            </label>
                            <label class="flex items-center gap-3 cursor-pointer">
                                <input type="radio" name="isActive" value="0" class="w-6 h-6 text-red-600 focus:ring-red-500">
                                <span class="text-sm font-black text-red-700 bg-red-50 px-5 py-1.5 rounded-full border-2 border-red-200 uppercase transition-all hover:bg-red-100">Inactive</span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- ===== VARIANT SPECIFICATIONS ===== --%>
        <div id="variant-specs-section" class="border-t-4 border-gray-100 pt-8" style="display: none;">
            <div class="flex justify-between items-center mb-6">
                <h3 class="text-lg font-black text-gray-800 border-l-8 border-purple-500 pl-3 uppercase">Variant Specifications</h3>
                <span class="px-4 py-1.5 bg-purple-50 text-purple-700 text-xs font-black tracking-widest rounded-full border-2 border-purple-200" id="spec-category-label">Category Specs</span>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6" id="spec-container">
                <c:forEach items="${allVariantSpecs}" var="specDef">
                    <div class="spec-group hidden transition-all duration-300 transform scale-95 opacity-0" data-category-id="${specDef.categoryId}">
                        <label class="text-xs font-black text-gray-400 uppercase tracking-widest">${specDef.specName}</label>
                        <input type="text" 
                               name="specValue_${specDef.specId}" 
                               disabled
                               placeholder="Enter ${specDef.specName}..." 
                               oninput="this.value = this.value.replace(/[^a-zA-Z0-9\s-]/g, '')"
                               pattern="^[a-zA-Z0-9\s-]+$"
                               title="Only letters, numbers, spaces, and hyphens are allowed."
                               class="w-full mt-2 p-3 bg-purple-50 border-2 border-purple-200 rounded-xl font-black text-purple-900 placeholder-purple-300 focus:border-purple-600 focus:ring-4 focus:ring-purple-100 transition-all outline-none">
                    </div>
                </c:forEach>
            </div>

            <div id="no-specs-message" class="hidden py-6 text-center bg-gray-50 border-2 border-dashed border-gray-200 rounded-xl mt-4">
                <p class="text-sm font-bold text-gray-400 italic">⚠️ This product listing does not require Variant specifications.</p>
            </div>
        </div>

        <div class="pt-10 border-t-4 border-gray-50 flex justify-end gap-6">
            <button type="reset" class="px-8 py-3 text-gray-500 font-black hover:bg-gray-100 rounded-xl uppercase transition-colors">Reset</button>
            <button type="submit" class="px-12 py-3 bg-blue-600 text-white font-black rounded-xl hover:bg-blue-700 shadow-2xl shadow-blue-300 transition-all transform hover:-translate-y-1 uppercase">Create Variant</button>
        </div>
    </form>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const productSelect = document.getElementById('productSelectDropdown');
        const specSection = document.getElementById('variant-specs-section');
        const specContainers = document.querySelectorAll('.spec-group');
        const noSpecsMessage = document.getElementById('no-specs-message');

        function updateSpecs() {
            specContainers.forEach(group => {
                group.classList.add('hidden', 'scale-95', 'opacity-0');
                group.classList.remove('scale-100', 'opacity-100');
                group.querySelectorAll('input').forEach(input => {
                    input.disabled = true;
                    input.removeAttribute('required');
                });
            });

            const selectedOption = productSelect.options[productSelect.selectedIndex];
            if (selectedOption && selectedOption.value) {
                const categoryId = selectedOption.getAttribute('data-category');

                specSection.style.display = 'block';

                let countSpecs = 0;
                specContainers.forEach(group => {
                    if (group.getAttribute('data-category-id') === categoryId) {
                        group.classList.remove('hidden');
                        requestAnimationFrame(() => {
                            group.classList.remove('scale-95', 'opacity-0');
                            group.classList.add('scale-100', 'opacity-100');
                        });

                        group.querySelectorAll('input').forEach(input => {
                            input.disabled = false;
                            input.setAttribute('required', 'required'); 
                        });
                        countSpecs++;
                    }
                });

                if (countSpecs === 0) {
                    noSpecsMessage.classList.remove('hidden');
                } else {
                    noSpecsMessage.classList.add('hidden');
                }
            } else {
                specSection.style.display = 'none';
            }
        }

        productSelect.addEventListener('change', updateSpecs);

        updateSpecs();
    });
</script>