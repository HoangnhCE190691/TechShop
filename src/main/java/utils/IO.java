/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import dao.CustomerAddressDAO;
import dao.CustomerDAO;
import dao.EmployeesDAO;
import dao.VoucherDAO;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import model.Customer;
import model.CustomerAddress;
import model.Employees;
import model.Voucher;

/**
 *
 * @author ASUS
 */
public class IO {

    private static CustomerDAO cdao = new CustomerDAO();
    private static EmployeesDAO edao = new EmployeesDAO();
    private static VoucherDAO vdao = new VoucherDAO();
    private static CustomerAddressDAO addressDAO = new CustomerAddressDAO();
    private static final String UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private static final String LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
    private static final String NUMBERS = "0123456789";
    private static final String SPECIAL_CHARS = "!@#$%^&*()-_=+[]{};:,.<>/?";
    private static final String ALL_CHARS = UPPERCASE + LOWERCASE + NUMBERS + SPECIAL_CHARS;

    public static String generate8DigitPassword() {
        SecureRandom random = new SecureRandom(); // Dùng SecureRandom cho mật khẩu
        List<Character> passwordChars = new ArrayList<>();

        // 1. Đảm bảo có ít nhất 1 chữ hoa
        passwordChars.add(UPPERCASE.charAt(random.nextInt(UPPERCASE.length())));

        // 2. Đảm bảo có ít nhất 1 ký tự đặc biệt
        passwordChars.add(SPECIAL_CHARS.charAt(random.nextInt(SPECIAL_CHARS.length())));

        // 3. Random 6 ký tự còn lại từ tất cả các tập hợp
        for (int i = 0; i < 6; i++) {
            passwordChars.add(ALL_CHARS.charAt(random.nextInt(ALL_CHARS.length())));
        }

        // 4. Trộn ngẫu nhiên vị trí các ký tự (để chữ hoa/kí tự đặc biệt không luôn ở đầu)
        Collections.shuffle(passwordChars, random);

        // 5. Ghép lại thành chuỗi String
        StringBuilder password = new StringBuilder();
        for (char c : passwordChars) {
            password.append(c);
        }

        return password.toString();
    }

    public static boolean CheckDuplicationUsername(String username) {

        List<Customer> listC = cdao.getAllCustomer();
        List<Employees> listE = edao.getAllEmployeeses();

        for (Customer customer : listC) {
            if (username.equalsIgnoreCase(customer.getUserName())) {
                return false;
            }
        }

        for (Employees employees : listE) {
            if (username.equalsIgnoreCase(employees.getUsername())) {
                return false;
            }
        }
        return true;
    }

    public static boolean checkDuplicationGmailInEdit(String newEmail, String oldEmail) {
        // 1. Nếu email mới không đổi so với email cũ -> Hợp lệ ngay lập tức
        if (newEmail.equalsIgnoreCase(oldEmail)) {
            return true;
        }

        // 2. Nếu họ đổi sang email khác, lúc này mới đi kiểm tra xem có trùng với ai không
        List<Customer> listC = cdao.getAllCustomer();
        List<Employees> listE = edao.getAllEmployeeses();

        for (Customer customer : listC) {
            if (newEmail.equalsIgnoreCase(customer.getEmail())) {
                return false;
            }
        }

        for (Employees employees : listE) {
            if (newEmail.equalsIgnoreCase(employees.getEmail())) {
                return false;
            }
        }

        return true;
    }

    public static boolean checkDuplicationGmail(String email) {
        List<Customer> listC = cdao.getAllCustomer();
        List<Employees> listE = edao.getAllEmployeeses();
        for (Customer customer : listC) {
            if (email.equalsIgnoreCase(customer.getEmail())) {

                if (customer.getStatus().equalsIgnoreCase("LOCKED") || customer.getStatus().equalsIgnoreCase("INACTIVE")) {
                    return true;
                }

                return false;
            }
        }

        for (Employees employees : listE) {
            if (email.equalsIgnoreCase(employees.getEmail())) {
                if (employees.getStatus().equalsIgnoreCase("LOCKED") || employees.getStatus().equalsIgnoreCase("INACTIVE")) {
                    return true;
                }
                return false;
            }
        }

        return true;
    }

    public static boolean CheckNumber(String number) {

        if (number.length() != 10) {
            return false;
        }

        return true;
    }

    public static boolean checkCodeDuplicate(String code) {
        List<Voucher> listV = vdao.getAllVoucher();

        for (Voucher voucher : listV) {
            if (code.equalsIgnoreCase(voucher.getCode())) {
                return false;
            }
        }
        return true;
    }

    public static boolean checkValidDates(String validFromStr, String validToStr) {

        if (validFromStr == null || validFromStr.trim().isEmpty()
                || validToStr == null || validToStr.trim().isEmpty()) {
            return false;
        }

        try {

            LocalDateTime validFrom = LocalDateTime.parse(validFromStr);
            LocalDateTime validTo = LocalDateTime.parse(validToStr);

            if (!validTo.isAfter(validFrom)) {
                return false;
            }

        } catch (DateTimeParseException e) {

            return false;
        }

        return true;
    }

    public static Boolean checkVoucherConditions(String minOrderStr, String maxDiscountStr) {
        // 1. Validate min order (Bắt buộc nhập, phải là số >= 0)
        if (minOrderStr == null || minOrderStr.trim().isEmpty()) {
            return false;
        }
        try {
            double minOrder = Double.parseDouble(minOrderStr);
            if (minOrder < 0) {
                return false;
            }
        } catch (NumberFormatException e) {
            return false;
        }

        // 2. Validate max discount (Không bắt buộc, nhưng nếu nhập thì phải là số >= 0)
        if (maxDiscountStr != null && !maxDiscountStr.trim().isEmpty()) {
            try {
                double maxDiscount = Double.parseDouble(maxDiscountStr);
                if (maxDiscount < 0) {
                    return false;
                }
            } catch (NumberFormatException e) {
                return false;
            }
        }

        return true; // Vượt qua mọi chốt chặn -> Hợp lệ
    }

    public static String checkDefaultAddress(int id) {
        List<CustomerAddress> listA = addressDAO.getAddressesByCustomerId(id);

        for (CustomerAddress customerAddress : listA) {
            if (customerAddress.isIsDefault()) {
                return "true";
            }
        }

        return "false";
    }

    public static void deleteDefaultAddress(int idC, int idA) {
        // Lấy danh sách tất cả địa chỉ của khách hàng (idC)
        List<CustomerAddress> listA = addressDAO.getAddressesByCustomerId(idC);

        // Duyệt qua từng địa chỉ
        for (CustomerAddress customerAddress : listA) {

            // SỬA LỖI 1: Phải so sánh Mã Địa Chỉ (getAddressId) với idA, 
            // chứ không phải Mã Khách Hàng (getCustomerId)
            if (customerAddress.getAddressId() != idA) {

                // SỬA LỖI 2: Truyền Mã Địa Chỉ vào tham số đầu tiên của hàm setAsDefault
                addressDAO.setAsDefault(customerAddress.getAddressId(), idC);

                // SỬA LỖI 3: Rất quan trọng! 
                // Sau khi đã set được 1 địa chỉ khác làm mặc định thì phải thoát vòng lặp ngay.
                break;
            }
        }
    }

}
