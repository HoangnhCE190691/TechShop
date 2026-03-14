<%@page contentType="text/html" pageEncoding="UTF-8"%>

<body class="bg-[#f4f6f8] font-sans text-gray-800">

    <div class="max-w-[1200px] mx-auto px-4 pb-16">
        
        <div class="text-center mb-10 mt-4">
            <h1 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">Contact Us</h1>
            <p class="text-gray-500 max-w-2xl mx-auto">
                If you have any questions about our products, services, or need support, don't hesitate to send us a message. We will get back to you as soon as possible!
            </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            
            <div class="bg-white p-6 md:p-8 rounded-2xl shadow-sm border border-gray-100 flex flex-col h-full">
                <h2 class="text-2xl font-bold text-gray-800 mb-6 border-b pb-4">Contact Information</h2>
                
                <div class="space-y-6 mb-8 flex-grow">
                    <div class="flex items-start gap-4">
                        <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0 text-blue-600">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.243-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-900 text-lg">Address</h3>
                            <p class="text-gray-600 mt-1 leading-relaxed">333<br>City.Cần Thơ</p>
                        </div>
                    </div>

                    <div class="flex items-start gap-4">
                        <div class="w-12 h-12 rounded-full bg-red-50 flex items-center justify-center flex-shrink-0 text-red-600">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg>
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-900 text-lg">Hotline</h3>
                            <p class="text-gray-600 mt-1">0903224113</p>
                            <p class="text-gray-600">0911722444</p>
                        </div>
                    </div>

                    <div class="flex items-start gap-4">
                        <div class="w-12 h-12 rounded-full bg-green-50 flex items-center justify-center flex-shrink-0 text-green-600">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-900 text-lg">Email</h3>
                            <p class="text-gray-600 mt-1">techshop@gmail.com</p>
                        </div>
                    </div>
                </div>

                <div class="w-full h-64 rounded-xl overflow-hidden shadow-inner">
                  <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d62860.62287779897!2d105.71637039302058!3d10.034268928844126!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31a0629f6de3edb7%3A0x527f09dbfb20b659!2zQ-G6p24gVGjGoSwgTmluaCBLaeG7gXUsIEPhuqduIFRoxqEsIFZp4buHdCBOYW0!5e0!3m2!1svi!2s!4v1771410459570!5m2!1svi!2s" width="600" height="450" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
                </div>
            </div>

            <div class="bg-white p-6 md:p-8 rounded-2xl shadow-sm border border-gray-100 h-full">
                <h2 class="text-2xl font-bold text-gray-800 mb-6 border-b pb-4">Send Us Your Inquiry</h2>
                
                <form action="contactservlet" method="POST" class="space-y-5">
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label for="fullName" class="block text-sm font-semibold text-gray-700 mb-2">Full Name <span class="text-red-500">*</span></label>
                            <input type="text" id="fullName" name="fullName" required placeholder="Enter your full name" 
                                   class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white">
                        </div>
                        <div>
                            <label for="phone" class="block text-sm font-semibold text-gray-700 mb-2">Phone Number <span class="text-red-500">*</span></label>
                            <input type="tel" id="phone" name="phone" required placeholder="Enter your phone number" 
                                   class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white">
                        </div>
                    </div>

                    <div>
                        <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">Email</label>
                        <input type="email" id="email" name="email" placeholder="Enter your email (optional)" 
                               class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white">
                    </div>

                    <div>
                        <label for="subject" class="block text-sm font-semibold text-gray-700 mb-2">Subject <span class="text-red-500">*</span></label>
                        <select id="subject" name="subject" required 
                                class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white appearance-none cursor-pointer">
                            <option value="" disabled selected>-- Select a support topic --</option>
                            <option value="TuVan">Sales Consultation</option>
                            <option value="BaoHanh">Technical Support & Warranty</option>
                            <option value="KhieuNai">Feedback & Complaints</option>
                            <option value="Khac">Other Issues</option>
                        </select>
                    </div>

                    <div>
                        <label for="message" class="block text-sm font-semibold text-gray-700 mb-2">Message Content <span class="text-red-500">*</span></label>
                        <textarea id="message" name="message" rows="5" required placeholder="Describe your request in detail..." 
                                  class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white resize-y"></textarea>
                    </div>

                    <button type="submit" 
                            class="w-full bg-blue-600 text-white font-bold text-lg py-3.5 rounded-lg hover:bg-blue-700 hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-200">
                        Send 
                    </button>
                    
                </form>
            </div>

        </div>
    </div>

</body>