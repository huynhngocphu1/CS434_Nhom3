using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Timers;
using System.Web;
using System.Web.UI;

namespace Webebook
{
    public class Global : HttpApplication
    {
        private static System.Timers.Timer aTimer;
        private static readonly string connectionString = ConfigurationManager.ConnectionStrings["datawebebookConnectionString"].ConnectionString;


        void Application_Start(object sender, EventArgs e)
        {
            // Code gốc của bạn
            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery", new ScriptResourceDefinition
            {
                Path = "~/Scripts/jquery-3.7.1.min.js",
                DebugPath = "~/Scripts/jquery-3.7.1.js"
            });

            // *** BẮT ĐẦU CODE MỚI: KHỞI TẠO TIMER CHẠY NGẦM ***
            // Đặt chu kỳ là 5 phút (300,000 mili giây). Bạn có thể đổi thành 60000 (1 phút) để test.
            //  aTimer = new System.Timers.Timer(300000);
            aTimer = new System.Timers.Timer(60000);
            aTimer.Elapsed += OnTimerElapsed; // Gán sự kiện sẽ chạy khi hết giờ
            aTimer.AutoReset = true; // Timer sẽ tự động chạy lại
            aTimer.Enabled = true; // Bật timer
        }

        private static void OnTimerElapsed(Object source, ElapsedEventArgs e)
        {
            // Hàm này sẽ được tự động gọi mỗi khi hết chu kỳ của timer
            try
            {
                CheckAndSendInvoices();
            }
            catch (Exception ex)
            {
                // Ghi lại lỗi nếu tiến trình chạy ngầm thất bại
                System.Diagnostics.Trace.TraceError($"BACKGROUND_JOB_ERROR: {ex.ToString()}");
            }
        }

        private static void CheckAndSendInvoices()
        {
            var unsentOrders = new List<Tuple<int, string, DateTime, decimal>>();

            // 1. Lấy tất cả đơn hàng đã 'Completed' nhưng chưa gửi hóa đơn (IsInvoiceSent = 0)
            string query = @"SELECT dh.IDDonHang, nd.Email, dh.NgayDat, dh.SoTien 
                             FROM DonHang dh 
                             JOIN NguoiDung nd ON dh.IDNguoiDung = nd.IDNguoiDung
                             WHERE dh.TrangThaiThanhToan = 'Completed' AND dh.IsInvoiceSent = 0";

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();
                using (var cmd = new SqlCommand(query, con))
                {
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            unsentOrders.Add(new Tuple<int, string, DateTime, decimal>(
                                Convert.ToInt32(reader["IDDonHang"]),
                                reader["Email"].ToString(),
                                Convert.ToDateTime(reader["NgayDat"]),
                                Convert.ToDecimal(reader["SoTien"])
                            ));
                        }
                    }
                }
            }

            // 2. Gửi email cho từng đơn hàng tìm thấy
            foreach (var order in unsentOrders)
            {
                if (SendInvoiceEmail(order.Item1, order.Item2, order.Item3, order.Item4))
                {
                    // 3. Nếu gửi thành công, cập nhật lại cờ IsInvoiceSent = 1
                    UpdateInvoiceSentStatus(order.Item1);
                }
            }
        }

        private static bool SendInvoiceEmail(int orderId, string customerEmail, DateTime orderDate, decimal totalAmount)
        {
            try
            {
                var itemsHtml = new StringBuilder();
                // Lấy chi tiết các sản phẩm trong đơn hàng từ CSDL
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();
                    string itemsQuery = @"SELECT s.TenSach, ctdh.SoLuong, ctdh.Gia 
                                  FROM ChiTietDonHang ctdh JOIN Sach s ON ctdh.IDSach = s.IDSach 
                                  WHERE ctdh.IDDonHang = @IDDonHang";
                    using (var cmd = new SqlCommand(itemsQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@IDDonHang", orderId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            itemsHtml.Append("<table border='1' cellpadding='10' cellspacing='0' style='width:100%; border-collapse: collapse; font-family: Arial, sans-serif;'>");
                            itemsHtml.Append("<tr style='background-color:#f2f2f2;'><th style='text-align:left;'>Sản phẩm</th><th style='text-align:center;'>Số lượng</th><th style='text-align:right;'>Đơn giá</th><th style='text-align:right;'>Thành tiền</th></tr>");
                            while (reader.Read())
                            {
                                string tenSach = reader["TenSach"].ToString();
                                int soLuong = Convert.ToInt32(reader["SoLuong"]);
                                decimal donGia = Convert.ToDecimal(reader["Gia"]);
                                decimal thanhTien = soLuong * donGia;
                                itemsHtml.AppendFormat("<tr><td>{0}</td><td style='text-align:center;'>{1}</td><td style='text-align:right;'>{2:N0} VNĐ</td><td style='text-align:right;'>{3:N0} VNĐ</td></tr>",
                                    HttpUtility.HtmlEncode(tenSach), soLuong, donGia, thanhTien);
                            }
                            itemsHtml.Append($"<tr><td colspan='3' style='text-align:right; font-weight:bold;'>TỔNG CỘNG:</td><td style='text-align:right; font-weight:bold;'>{totalAmount:N0} VNĐ</td></tr>");
                            itemsHtml.Append("</table>");
                        }
                    }
                }

                string subject = $"Webebook - Hóa đơn cho đơn hàng #{orderId}";
                string body = $@"
            <div style='font-family: Arial, sans-serif; line-height: 1.6;'>
                <h2>Cảm ơn bạn đã mua hàng tại Webebook!</h2>
                <p>Xin chào, Webebook xin gửi bạn hóa đơn chi tiết cho đơn hàng vừa hoàn tất.</p>
                <h3>Hóa đơn điện tử cho Đơn hàng #{orderId}</h3>
                <p><strong>Ngày đặt:</strong> {orderDate:dd/MM/yyyy HH:mm}</p>
                <hr style='border:none; border-top:1px solid #eee;' />
                {itemsHtml.ToString()}
                <br>
                <p>Sách đã được thêm vào tủ sách của bạn. Hãy truy cập website và bắt đầu đọc ngay!</p>
                <p>Trân trọng,<br>Đội ngũ Webebook</p>
            </div>";

                // Lấy thông tin tài khoản gửi hóa đơn từ Web.config
                string fromEmail = ConfigurationManager.AppSettings["Smtp:Billing:FromAddress"];
                string fromPassword = ConfigurationManager.AppSettings["Smtp:Billing:Password"];
                string smtpHost = ConfigurationManager.AppSettings["Smtp:Host"];

                if (!int.TryParse(ConfigurationManager.AppSettings["Smtp:Port"], out int smtpPort)) { smtpPort = 587; }
                if (!bool.TryParse(ConfigurationManager.AppSettings["Smtp:EnableSsl"], out bool enableSsl)) { enableSsl = true; }

                if (string.IsNullOrEmpty(fromEmail) || string.IsNullOrEmpty(fromPassword) || string.IsNullOrEmpty(smtpHost))
                {
                    throw new ConfigurationErrorsException("Thông tin SMTP cho Billing trong Web.config bị thiếu.");
                }

                var message = new MailMessage();
                message.From = new MailAddress(fromEmail, "Webebook Hóa Đơn");
                message.To.Add(new MailAddress(customerEmail));
                message.Subject = subject;
                message.Body = body;
                message.IsBodyHtml = true;

                var smtpClient = new SmtpClient(smtpHost)
                {
                    Port = smtpPort,
                    Credentials = new NetworkCredential(fromEmail, fromPassword),
                    EnableSsl = enableSsl,
                };

                smtpClient.Send(message);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"SendInvoiceEmail Error for OrderID {orderId}: {ex.ToString()}");
                return false;
            }
        }

        private static void UpdateInvoiceSentStatus(int orderId)
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();
                    string query = "UPDATE DonHang SET IsInvoiceSent = 1 WHERE IDDonHang = @IDDonHang";
                    using (var cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@IDDonHang", orderId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"UpdateInvoiceSentStatus Error for OrderID {orderId}: {ex}");
            }
        }
    }
}