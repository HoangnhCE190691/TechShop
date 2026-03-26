/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.SupplierDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Supplier;

@WebServlet(name = "SupplierServlet", urlPatterns = {"/supplier"})
public class SupplierServlet extends HttpServlet {

    private SupplierDAO dao;

    @Override
    public void init() {
        dao = new SupplierDAO();
    }

    private void redirectToSupplierManagement(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/staffservlet?action=supplierManagement");
    }

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
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    dao.deactivateSupplier(id);
                    setMsg(request.getSession(), "Supplier has been deactivated.", "success");
                } else {
                    setMsg(request.getSession(), "Invalid ID. Please check again.", "danger");
                }
                redirectToSupplierManagement(request, response);
                return;
            }
            case "restore": {
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    dao.restoreSupplier(id);
                    setMsg(request.getSession(), "Supplier has been reactivated.", "success");
                } else {
                    setMsg(request.getSession(), "Invalid ID. Please check again.", "danger");
                }
                redirectToSupplierManagement(request, response);
                return;
            }
            case "delete": {
                int id = parseIntSafe(request.getParameter("id"), 0);
                if (id > 0) {
                    if (dao.deleteSupplierIfNoReferences(id)) {
                        setMsg(request.getSession(), "Supplier deleted successfully.", "success");
                    } else {
                        setMsg(request.getSession(), "Cannot delete supplier because it is currently in use.", "danger");
                    }
                } else {
                    setMsg(request.getSession(), "Invalid ID. Please check again.", "danger");
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
                String name = request.getParameter("supplier_name");
                String phone = request.getParameter("phone");
                String isActive = request.getParameter("is_active");

                if (name != null && !name.trim().isEmpty() && phone != null && !phone.trim().isEmpty()) {
                    if (!phone.matches("[0-9]{10}")) {
                        setMsg(request.getSession(), "Phone number must contain exactly 10 digits.", "danger");
                    } else {
                        Supplier s = new Supplier(0, name.trim(), phone.trim(), "1".equals(isActive));
                        dao.insertSupplier(s);
                        setMsg(request.getSession(), "Supplier added successfully.", "success");
                    }
                } else {
                    setMsg(request.getSession(), "Please enter both supplier name and phone number.", "danger");
                }
                break;
            }
            case "update": {
                String idStr = request.getParameter("supplier_id");
                String name = request.getParameter("supplier_name");
                String phone = request.getParameter("phone");
                String isActive = request.getParameter("is_active");

                if (idStr != null && !idStr.isEmpty() && name != null && !name.trim().isEmpty() && phone != null && !phone.trim().isEmpty()) {
                    if (!phone.matches("[0-9]{10}")) {
                        setMsg(request.getSession(), "Phone number must contain exactly 10 digits.", "danger");
                    } else {
                        try {
                            int id = parseIntSafe(idStr, 0);
                            Supplier s = new Supplier(id, name.trim(), phone.trim(), "1".equals(isActive));
                            dao.updateSupplier(s);
                            setMsg(request.getSession(), "Supplier updated successfully.", "success");
                        } catch (Exception e) {
                            setMsg(request.getSession(), "Invalid ID. Please check again.", "danger");
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

    private void setMsg(HttpSession session, String msg, String type) {
        session.setAttribute("msg", msg);
        session.setAttribute("msgType", type);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
