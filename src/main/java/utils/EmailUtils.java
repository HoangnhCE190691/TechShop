/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.UnsupportedEncodingException;
import java.util.Properties;
import java.util.Random;
import java.util.Scanner;

/**
 *
 * @author ASUS
 */
public class EmailUtils {

    public static void sendEmail(String to, String subject, String content) throws MessagingException, UnsupportedEncodingException {
        // 1. Cấu hình Server
        Properties prop = new Properties();
        prop.put("mail.smtp.host", "smtp.gmail.com");
        prop.put("mail.smtp.port", "587");
        prop.put("mail.smtp.auth", "true");
        prop.put("mail.smtp.starttls.enable", "true");

        // 2. Đăng nhập
        String username = "gialong.game@gmail.com";
        String password = "vkzlcuwzjgyowcxu"; // Mật khẩu ứng dụng 16 ký tự

        Session session = Session.getInstance(prop, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        // 3. Tạo nội dung Mail
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(username, "TechShop Support"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setContent(content, "text/html; charset=utf-8"); // Gửi dạng HTML cho đẹp

        // 4. Gửi
        Transport.send(message);
    }

    public static String generateToken() {
        // Tạo một số ngẫu nhiên từ 0 đến 999999
        Random rnd = new Random();
        int number = rnd.nextInt(999999);

        // Sử dụng String.format để luôn có đủ 6 chữ số (thêm số 0 ở đầu nếu cần)
        // Ví dụ: số 123 sẽ thành "000123"
        return String.format("%06d", number);
    }

    public static void main(String[] args) {
        try {
            Scanner sc = new Scanner(System.in);
            String code = generateToken(); // Giả sử trả về "012345"

            EmailUtils.sendEmail("longtg.ce191181@gmail.com", "Test TechShop",
                    "<h1>Chào Long!</h1><p>Mã OTP của bạn là: <b>" + code + "</b></p>");

            System.out.println("Gửi mail thành công rồi đó!");
            System.out.print("Nhập vào mã OTP bạn nhận được: ");

            // Đọc mã nhập vào dưới dạng String để so sánh chuẩn nhất
            String otpInput = sc.next();

            System.out.println("Bạn vừa nhập mã: " + otpInput);

            // So sánh 2 chuỗi bằng .equals()
            if (otpInput.equals(code)) {
                System.out.println("Xác thực thành công!");
            } else {
                System.out.println("Mã sai rồi bro!");
            }

            sc.close(); // Đóng scanner cho sạch code

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
