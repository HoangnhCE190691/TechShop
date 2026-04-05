<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="max-w-2xl mx-auto bg-white p-8 rounded-2xl shadow-xl border border-gray-100 mt-20">
    <div class="flex justify-center mb-6">
        <c:choose>
            <%-- Nếu đang ẨN -> Hiển thị giao diện XÁC NHẬN HIỆN --%>
            <c:when test="${review.status.toLowerCase() != 'visible'}">
                <div class="w-20 h-20 rounded-full flex items-center justify-center bg-green-50 text-green-500 animate-pulse">
                    <svg class="w-12 h-12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.644C3.399 8.044 7.192 4.5 12 4.5c4.799 0 8.591 3.544 9.964 7.178.07.207.07.431 0 .639C20.591 15.956 16.799 19.5 12 19.5c-4.8 0-8.591-3.544-9.964-7.178z" /><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                </div>
            </c:when>
            <%-- Nếu đang HIỆN -> Hiển thị giao diện XÁC NHẬN ẨN --%>
            <c:otherwise>
                <div class="w-20 h-20 rounded-full flex items-center justify-center bg-orange-50 text-orange-500 animate-pulse">
                    <svg class="w-12 h-12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
                    </svg>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="text-center space-y-4">
        <h2 class="text-2xl font-extrabold text-gray-900 uppercase">
            ${review.status.toLowerCase() != 'visible' ? 'Confirm Show Review' : 'Confirm Hide Review'}
        </h2>
        <p class="text-gray-600">
            Are you sure you want to <strong>${review.status.toLowerCase() != 'visible' ? 'show' : 'hide'}</strong> this review?
        </p>

        <div class="p-5 bg-gray-50 rounded-xl border border-gray-100 text-left">
            <p class="text-xs font-bold text-gray-400 uppercase">Product: <span class="text-gray-800">${review.productName}</span></p>
            <p class="text-xs font-bold text-gray-400 uppercase mt-2">Comment:</p>
            <p class="text-sm italic text-gray-700">"${review.comment}"</p>
        </div>
    </div>

    <form action="reviewServlet" method="POST" class="mt-10 flex justify-center gap-4">
        <input type="hidden" name="action" value="${review.status.toLowerCase() != 'visible' ? 'show' : 'hide'}">
        <input type="hidden" name="reviewId" value="${review.reviewId}">
        
        <a href="reviewServlet?action=all" class="px-6 py-2.5 text-gray-500 font-bold border rounded-lg hover:bg-gray-50 transition-colors">
            Cancel
        </a>
        
        <c:choose>
            <c:when test="${review.status.toLowerCase() != 'visible'}">
                <button type="submit" class="px-10 py-2.5 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 shadow-lg transition-transform transform hover:scale-105">
                    Show Review
                </button>
            </c:when>
            <c:otherwise>
                <button type="submit" class="px-10 py-2.5 bg-orange-600 text-white font-bold rounded-lg hover:bg-orange-700 shadow-lg transition-transform transform hover:scale-105">
                    Hide Review
                </button>
            </c:otherwise>
        </c:choose>
    </form>
</div>