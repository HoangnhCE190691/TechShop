/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.SupplierDAO;
import java.io.IOException;
import java.util.Locale;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Supplier;

@WebServlet(name = "SupplierServlet", urlPatterns = {"/supplier"})
// Quản lý nhà cung cấp: danh sách, thêm, xem, sửa, khóa, mở lại, xóa (khi chưa dùng trên phiếu nhập).
public class SupplierServlet extends HttpServlet {

    /**
     * Lớp truy cập cơ sở dữ liệu cho nhà cung cấp.
     */
    private SupplierDAO dao;

    @Override
    public void init() {
        dao = new SupplierDAO();
    }

    private void redirectToSupplierManagement(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/staffservlet?action=supplierManagement");
    }

    /**
     * Đọc số nguyên từ chuỗi; sai định dạng thì trả về giá trị mặc định.
     */
    private int parseIntSafe(String s, int defaultValue) {
        if (s == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Cắt khoảng trắng hai đầu; sau khi cắt mà không còn ký tự thì trả về null.
     */
    private String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    /**
     * Chuẩn hóa tên: bỏ thừa khoảng trắng giữa các chữ.
     */
    private String normalizeSupplierName(String raw) {
        if (raw == null) {
            return "";
        }
        return raw.trim().replaceAll("\\s+", " ");
    }

    /**
     * Chỉ giữ lại chữ số trong số điện thoại.
     */
    private String normalizePhoneDigits(String raw) {
        if (raw == null) {
            return "";
        }
        return raw.replaceAll("\\D", "");
    }

    /**
     * Chuẩn hóa địa chỉ giống cách xử lý tên.
     */
    private String normalizeAddress(String raw) {
        String t = trimToNull(raw);
        if (t == null) {
            return null;
        }
        return t.replaceAll("\\s+", " ");
    }

    /**
     * Email: viết thường, bỏ trống thì coi như không nhập.
     */
    private String normalizeEmail(String raw) {
        if (raw == null) {
            return null;
        }
        String t = raw.trim();
        return t.isEmpty() ? null : t.toLowerCase(Locale.ROOT);
    }

    /**
     * Email để trống được; có nhập thì kiểm tra định dạng.
     */
    private boolean isValidEmailOrEmpty(String emailNormalized) {
        if (emailNormalized == null || emailNormalized.isEmpty()) {
            return true;
        }
        return emailNormalized.matches("^[a-z0-9+_.-]+@[a-z0-9.-]+\\.[a-z]{2,}$");
    }

    /**
     * Tên chỉ cho phép chữ, số, tiếng Việt, vài ký tự đặc biệt như trên form.
     */
    private boolean isValidSupplierName(String nameNormalized) {
        if (nameNormalized == null) {
            return false;
        }
        if (nameNormalized.isEmpty()) {
            return false;
        }
        return nameNormalized.matches("^[a-zA-Z0-9À-ỹ\\s&.-]+$");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.isBlank()) {
            redirectToSupplierManagement(request, response);
            return;
        }

        String page = "/pages/SupplierManagementPage/supplierManagement.jsp";
        switch (action) {
            case "add":
                page = "/pages/SupplierManagementPage/addSupplier.jsp";
                break;
            case "view": {
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    Supplier s = (Supplier) dao.getSupplierById(id);
                    request.setAttribute("supplier", s);
                }
                page = "/pages/SupplierManagementPage/viewSupplier.jsp";
                break;
            }
            case "edit": {
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    Supplier s = (Supplier) dao.getSupplierById(id);
                    request.setAttribute("supplier", s);
                }
                page = "/pages/SupplierManagementPage/editSupplier.jsp";
                break;
            }
            case "deactivate": {
                // Đánh dấu ngừng hoạt động, không xóa bản ghi.
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    if (!dao.hasConnection()) {
                        setMsg(request.getSession(), "Cannot connect to the database. Please try again later.", "danger");
                    } else if (dao.deactivateSupplier(id)) {
                        setMsg(request.getSession(), "Supplier has been deactivated.", "success");
                    } else {
                        setMsg(request.getSession(), "Could not deactivate (supplier not found or system error).", "danger");
                    }
                } else {
                    setMsg(request.getSession(), "Invalid id. Please try again.", "danger");
                }
                redirectToSupplierManagement(request, response);
                return;
            }
            case "restore": {
                // Bật lại nhà cung cấp đã bị khóa.
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    if (!dao.hasConnection()) {
                        setMsg(request.getSession(), "Cannot connect to the database. Please try again later.", "danger");
                    } else if (dao.restoreSupplier(id)) {
                        setMsg(request.getSession(), "Supplier has been reactivated.", "success");
                    } else {
                        setMsg(request.getSession(), "Could not reactivate (supplier not found or system error).", "danger");
                    }
                } else {
                    setMsg(request.getSession(), "Invalid id. Please try again.", "danger");
                }
                redirectToSupplierManagement(request, response);
                return;
            }
            case "delete": {
                // Xóa hẳn chỉ khi chưa có phiếu nhập nào trỏ tới nhà cung cấp này.
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    if (!dao.hasConnection()) {
                        setMsg(request.getSession(), "Cannot connect to the database. Please try again later.", "danger");
                    } else if (dao.deleteSupplierIfNoReferences(id)) {
                        setMsg(request.getSession(), "Supplier deleted.", "success");
                    } else {
                        setMsg(request.getSession(), "Cannot delete: supplier is used on import receipts or does not exist.", "danger");
                    }
                } else {
                    setMsg(request.getSession(), "Invalid id. Please try again.", "danger");
                }
                redirectToSupplierManagement(request, response);
                return;
            }
            default: {
                redirectToSupplierManagement(request, response);
                return;
            }
        }

        request.setAttribute("contentPage", page);
        request.getRequestDispatcher("/template/staffTemplate.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.isBlank()) {
            redirectToSupplierManagement(request, response);
            return;
        }

        switch (action) {
            case "add": {
                // Kiểm tra lần lượt: tên, số điện thoại, email, trùng email, trùng tên cùng địa chỉ, rồi mới lưu.
                String name = normalizeSupplierName(request.getParameter("supplier_name"));
                String phone = normalizePhoneDigits(request.getParameter("phone"));
                String email = normalizeEmail(request.getParameter("email"));
                String address = normalizeAddress(request.getParameter("address"));
                String isActive = request.getParameter("is_active");

                if (!name.isEmpty() && phone.length() == 10 && address != null && !address.isEmpty()) {
                    if (!dao.hasConnection()) {
                        setMsg(request.getSession(), "Cannot connect to the database. Please try again later.", "danger");
                    } else if (!isValidSupplierName(name)) {
                        setMsg(request.getSession(), "Invalid name. Letters, digits, Vietnamese, spaces, &, . and - only.", "danger");
                    } else if (!phone.matches("[0-9]{10}")) {
                        setMsg(request.getSession(), "Phone must be exactly 10 digits.", "danger");
                    } else if (!isValidEmailOrEmpty(email)) {
                        setMsg(request.getSession(), "Invalid email format.", "danger");
                    } else if (email != null && dao.existsSupplierEmail(email, 0)) {
                        setMsg(request.getSession(), "This email is already in use by another supplier.", "danger");
                    } else if (dao.existsSupplierPhone(phone, 0)) {
                        setMsg(request.getSession(), "This phone number is already in use by another supplier.", "danger");
                    } else if (dao.existsSameNameAndAddress(name, address, 0)) {
                        setMsg(request.getSession(), "Another supplier already has the same name and address. Same name is allowed if the address differs.", "danger");
                    } else {
                        Supplier s = new Supplier(0, name, phone, email, address, "1".equals(isActive));
                        if (dao.insertSupplier(s)) {
                            setMsg(request.getSession(), "Supplier added.", "success");
                        } else {
                            setMsg(request.getSession(), "Could not add supplier. Please try again.", "danger");
                        }
                    }
                } else {
                    setMsg(request.getSession(), "Please enter name, phone, and address.", "danger");
                }
                break;
            }
            case "update": {
                // Giống thêm mới nhưng có mã nhà cung cấp; kiểm tra trùng bỏ qua chính bản ghi đang sửa.
                String idStr = request.getParameter("supplier_id");
                String name = normalizeSupplierName(request.getParameter("supplier_name"));
                String phone = normalizePhoneDigits(request.getParameter("phone"));
                String email = normalizeEmail(request.getParameter("email"));
                String address = normalizeAddress(request.getParameter("address"));
                String isActive = request.getParameter("is_active");

                if (idStr != null && !idStr.isEmpty() && !name.isEmpty() && phone.length() == 10
                        && address != null && !address.isEmpty()) {
                    int id = parseIntSafe(idStr, 0);
                    if (id <= 0) {
                        setMsg(request.getSession(), "Invalid supplier id.", "danger");
                    } else if (!dao.hasConnection()) {
                        setMsg(request.getSession(), "Cannot connect to the database. Please try again later.", "danger");
                    } else if (!isValidSupplierName(name)) {
                        setMsg(request.getSession(), "Invalid name. Letters, digits, Vietnamese, spaces, &, . and - only.", "danger");
                    } else if (!phone.matches("[0-9]{10}")) {
                        setMsg(request.getSession(), "Phone must be exactly 10 digits.", "danger");
                    } else if (!isValidEmailOrEmpty(email)) {
                        setMsg(request.getSession(), "Invalid email format.", "danger");
                    } else if (email != null && dao.existsSupplierEmail(email, id)) {
                        setMsg(request.getSession(), "This email is already in use by another supplier.", "danger");
                    } else if (dao.existsSupplierPhone(phone, id)) {
                        setMsg(request.getSession(), "This phone number is already in use by another supplier.", "danger");
                    } else if (dao.existsSameNameAndAddress(name, address, id)) {
                        setMsg(request.getSession(), "Another supplier already has the same name and address. Same name is allowed if the address differs.", "danger");
                    } else {
                        Supplier s = new Supplier(id, name, phone, email, address, "1".equals(isActive));
                        if (dao.updateSupplier(s)) {
                            setMsg(request.getSession(), "Supplier updated.", "success");
                        } else {
                            setMsg(request.getSession(), "Could not update (supplier not found or system error).", "danger");
                        }
                    }
                } else {
                    setMsg(request.getSession(), "Please fill in all required fields.", "danger");
                }
                break;
            }
            default: {
                break;
            }
        }

        redirectToSupplierManagement(request, response);
    }

    /**
     * Ghi thông báo tạm trên phiên làm việc để trang danh sách hiển thị.
     */
    private void setMsg(HttpSession session, String msg, String type) {
        session.setAttribute("msg", msg);
        session.setAttribute("msgType", type);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
