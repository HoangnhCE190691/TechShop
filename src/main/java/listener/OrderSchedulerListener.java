package listener;

import dao.OrderDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.Timer;
import java.util.TimerTask;

@WebListener
public class OrderSchedulerListener implements ServletContextListener {

    private Timer orderTimer;
    private static final long CHECK_INTERVAL = 24 * 60 * 60 * 1000; // 24 giờ (1 ngày)
    private static final int AUTO_COMPLETE_DAYS = 5; // Sau 5 ngày từ shipped_date

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[Scheduler] Order Scheduler started!");
        
        orderTimer = new Timer("OrderAutoCompleteScheduler", true);
        
        
        orderTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                runAutoCompleteJob();
            }
        }, 60 * 1000, CHECK_INTERVAL); // delay 1 phút, lặp mỗi 24 giờ
        
        System.out.println("[Scheduler] Auto-complete job scheduled: check every 24 hours");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (orderTimer != null) {
            orderTimer.cancel();
            System.out.println("[Scheduler] Order Scheduler stopped!");
        }
    }

    private void runAutoCompleteJob() {
        System.out.println("[Scheduler] Running auto-complete job at: " + new java.util.Date());
        
        try {
            OrderDAO orderDao = new OrderDAO();
            int completedCount = orderDao.autoCompleteShippedOrders(AUTO_COMPLETE_DAYS);
            
            if (completedCount > 0) {
                System.out.println("[Scheduler] Auto-completed " + completedCount + " order(s)");
            } else {
                System.out.println("[Scheduler] No orders to auto-complete");
            }
        } catch (Exception e) {
            System.err.println("[Scheduler] Error running auto-complete job: " + e.getMessage());
            e.printStackTrace();
        }
    }
}