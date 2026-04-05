<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty sessionScope.msg}">
    <div id="toast-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[9999] min-w-[320px] transition-all duration-500">
        <div class="flex items-center justify-center p-4 rounded-xl shadow-2xl border-2 animate-bounce
             ${sessionScope.msgType == 'danger' ? 'bg-red-50 text-red-800 border-red-200' : 'bg-green-50 text-green-800 border-green-200'}">
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

<div class="bg-white rounded-xl shadow-lg p-5">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <h2 class="text-xl font-bold text-gray-800 uppercase tracking-tight">Review Management</h2>
    </div>

    <div class="flex flex-col md:flex-row gap-3 mb-6 items-center bg-gray-50 p-3 rounded-xl border border-gray-100">
        <div class="relative flex-1 w-full">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
            </span>
            <input type="text" id="nameSearch" oninput="filterReviews()" 
                   class="w-full pl-10 pr-4 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white shadow-sm" 
                   placeholder="Search product name...">
        </div>
        <select id="productSelect" onchange="filterReviews()" class="w-full md:w-56 px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white cursor-pointer shadow-sm">
            <option value="">All Products</option>
            <c:forEach items="${reviewedProducts}" var="pName">
                <option value="${pName}">${pName}</option>
            </c:forEach>
        </select>
        <select id="ratingFilter" onchange="filterReviews()" class="w-full md:w-44 px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white cursor-pointer shadow-sm">
            <option value="">All Ratings</option>
            <option value="5">5 Stars</option><option value="4">4 Stars</option><option value="3">3 Stars</option><option value="2">2 Stars</option><option value="1">1 Star</option>
        </select>
    </div>

    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs uppercase bg-gray-50 text-gray-700 font-bold">
                <tr>
                    <th class="px-4 py-3 w-16 text-center">ID</th>
                    <th class="px-4 py-3">Product Name</th>
                    <th class="px-4 py-3">Content</th>
                    <th class="px-4 py-3 text-center">Rating</th>
                    <th class="px-4 py-3 text-center">Status</th> <%-- Thêm Status vào Header --%>
                    <th class="px-4 py-3">Date</th>
                    <th class="px-4 py-3 text-center w-32">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200" id="reviewTableBody">
                <c:forEach items="${listdata}" var="r">
                    <tr class="review-row hover:bg-gray-50 transition-colors">
                        <td class="px-4 py-3 text-center font-medium text-gray-500">#${r.reviewId}</td>
                        <td class="px-4 py-3 font-bold text-gray-900 product-name-cell">${r.productName}</td>
                        <td class="px-4 py-3 text-gray-600 italic truncate max-w-xs">"${r.comment}"</td>
                        <td class="px-4 py-3 text-center rating-cell">
                            <span class="inline-block px-2.5 py-0.5 text-xs font-bold text-yellow-700 bg-yellow-50 rounded border border-yellow-100 uppercase">
                                ${r.rating} ⭐
                            </span>
                        </td>
                        <%-- Thêm cột hiển thị Status --%>
                        <td class="px-4 py-3 text-center">
                            <c:choose>
                                <c:when test="${r.status.toLowerCase() == 'visible'}">
                                    <span class="px-2 py-1 text-[10px] font-bold text-green-700 bg-green-50 rounded-full border border-green-100 uppercase">Visible</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 text-[10px] font-bold text-red-700 bg-red-50 rounded-full border border-red-100 uppercase">Hidden</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-4 py-3 text-xs text-gray-500">${r.formattedDate}</td>
                        <td class="px-4 py-4 text-center">
                            <div class="flex items-center justify-center gap-4">
                                <a href="reviewServlet?action=detail&id=${r.reviewId}" class="text-blue-500 hover:scale-110 transition-transform">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                    <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                </a>

                                <c:choose>
                                    <c:when test="${r.status.toLowerCase() == 'visible'}">
                                        <a href="reviewServlet?action=delete&id=${r.reviewId}" class="text-gray-400 hover:text-red-500 hover:scale-110 transition-transform">
                                            <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
                                            </svg>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="reviewServlet?action=delete&id=${r.reviewId}" class="text-green-500 hover:text-green-700 hover:scale-110 transition-transform">
                                            <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.644C3.399 8.044 7.192 4.5 12 4.5c4.799 0 8.591 3.544 9.964 7.178.07.207.07.431 0 .639C20.591 15.956 16.799 19.5 12 19.5c-4.8 0-8.591-3.544-9.964-7.178z" />
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                            </svg>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <tr id="noResultsRow" style="display: none;">
                    <td colspan="7" class="px-4 py-12 text-center">
                        <div class="flex flex-col items-center justify-center text-gray-400">
                            <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 9.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                            <span class="text-lg font-medium">No reviews match.</span>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<script>
    function filterReviews() {
        const searchVal = document.getElementById('nameSearch').value.toLowerCase();
        const selectVal = document.getElementById('productSelect').value.toLowerCase();
        const ratingVal = document.getElementById('ratingFilter').value;
        const rows = document.querySelectorAll('#reviewTableBody .review-row');
        const noResultsRow = document.getElementById('noResultsRow');
        let visibleCount = 0;
        rows.forEach(row => {
            const productName = row.querySelector('.product-name-cell').innerText.toLowerCase();
            const ratingText = row.querySelector('.rating-cell').innerText.trim().charAt(0);
            const matchesSearch = productName.includes(searchVal);
            const matchesSelect = selectVal === "" || productName === selectVal;
            const matchesRating = ratingVal === "" || ratingText === ratingVal;
            const isVisible = matchesSearch && matchesSelect && matchesRating;
            row.style.display = isVisible ? "" : "none";
            if (isVisible)
                visibleCount++;
        });
        if (noResultsRow) {
            noResultsRow.style.display = (visibleCount === 0 && rows.length > 0) ? "" : "none";
        }
    }
</script>