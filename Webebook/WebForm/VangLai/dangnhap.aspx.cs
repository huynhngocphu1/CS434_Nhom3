// Webebook/WebForm/VangLai/dangnhap.aspx.cs
using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics; // Thêm để debug nếu cần

namespace Webebook.WebForm.VangLai
{
    public partial class dangnhap : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["datawebebookConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // --- Cache Control Headers (Giữ nguyên) ---
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddYears(-1));
            Response.Cache.SetNoTransforms();
            // ---

            // Kiểm tra nếu người dùng ĐÃ được xác thực (Giữ nguyên)
            if (Request.IsAuthenticated && Session["UserID"] != null && Session["VaiTro"] != null)
            {
                RedirectAuthenticatedUser();
                // Quan trọng: Thêm return hoặc Context.ApplicationInstance.CompleteRequest()
                // để ngăn code phía dưới chạy sau khi redirect đã được gọi.
                // RedirectAuthenticatedUser đã có xử lý này nên không cần thêm ở đây.
                return;
            }

            if (!IsPostBack)
            {
                // --- THÊM LOGIC KIỂM TRA RESET PASSWORD ---
                if (Request.QueryString["status"] == "reset_success")
                {
                    ShowMessage("Đặt lại mật khẩu thành công. Vui lòng đăng nhập.", "success");
                }
                // --- KẾT THÚC LOGIC KIỂM TRA RESET ---
                else if (Request.QueryString["registered"] == "true") // Giữ lại kiểm tra đăng ký
                {
                    ShowMessage("Đăng ký thành công. Mời bạn đăng nhập.", "success");
                }
                else
                {
                    // Chỉ ẩn nếu không có thông báo nào được hiển thị từ QueryString
                    lblLoginError.Visible = false;
                    pnlMessageContainer.Visible = false;
                }
                txtLoginUsername.Focus();
            }
            // Nếu là PostBack, không cần ẩn lỗi/thông báo vì chúng có thể được đặt bởi btnLogin_Click
        }

        // Hàm RedirectAuthenticatedUser (Giữ nguyên như cũ)
        private void RedirectAuthenticatedUser()
        {
            try
            {
                int vaiTro = Convert.ToInt32(Session["VaiTro"]);
                string defaultRedirect = (vaiTro == 0)
                                        ? ResolveUrl("~/WebForm/Admin/adminhome.aspx")
                                        : ResolveUrl("~/WebForm/User/usertrangchu.aspx");

                // Kiểm tra returnUrl nếu có (cho User)
                if (vaiTro != 0)
                {
                    string returnUrlFromQuery = Request.QueryString["returnUrl"];
                    if (!string.IsNullOrEmpty(returnUrlFromQuery) && IsLocalUrl(returnUrlFromQuery))
                    {
                        defaultRedirect = returnUrlFromQuery; // Đã được kiểm tra IsLocalUrl
                    }
                }

                Response.Redirect(defaultRedirect, false);
                Context.ApplicationInstance.CompleteRequest(); // Ngăn code tiếp tục chạy
            }
            catch (FormatException) { LogoutCurrentUser(); } // Session lỗi
            catch (Exception ex)
            {
                Debug.WriteLine($"Lỗi chuyển hướng khi đã đăng nhập: {ex.Message}");
                LogoutCurrentUser();
            }
        }

        // Hàm LogoutCurrentUser (Giữ nguyên như cũ)
        private void LogoutCurrentUser()
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            // Xóa cookie xác thực cũ
            if (Request.Cookies[FormsAuthentication.FormsCookieName] != null)
            {
                HttpCookie myCookie = new HttpCookie(FormsAuthentication.FormsCookieName)
                {
                    Expires = DateTime.Now.AddDays(-1d),
                    Path = FormsAuthentication.FormsCookiePath // Đảm bảo xóa đúng path
                };
                Response.Cookies.Add(myCookie);
            }
        }

        // Hàm ShowMessage (Giữ nguyên như cũ)
        private void ShowMessage(string message, string type)
        {
            lblLoginMessage.Text = message;
            HtmlGenericControl icon = (HtmlGenericControl)pnlMessageContainer.FindControl("iconMessage");

            if (icon != null)
            {
                if (type == "success")
                {
                    pnlMessageContainer.CssClass = "mb-4 p-3 rounded-lg text-sm bg-green-50 border border-green-300 text-green-800 flex items-center"; // Adjusted styles
                    icon.Attributes["class"] = "fas fa-check-circle mr-2 flex-shrink-0";
                }
                else // Default/Info
                {
                    pnlMessageContainer.CssClass = "mb-4 p-3 rounded-lg text-sm bg-blue-50 border border-blue-300 text-blue-800 flex items-center"; // Adjusted styles
                    icon.Attributes["class"] = "fas fa-info-circle mr-2 flex-shrink-0";
                }
            }
            else
            {
                // Fallback nếu không tìm thấy icon (ít xảy ra)
                if (type == "success")
                {
                    pnlMessageContainer.CssClass = "mb-4 p-3 rounded-lg text-sm bg-green-50 border border-green-300 text-green-800";
                }
                else
                {
                    pnlMessageContainer.CssClass = "mb-4 p-3 rounded-lg text-sm bg-blue-50 border border-blue-300 text-blue-800";
                }
            }
            pnlMessageContainer.Visible = true;
            lblLoginError.Visible = false;
        }

        // Hàm ShowLoginError (Giữ nguyên như cũ)
        private void ShowLoginError(string errorMessage)
        {
            // Đảm bảo message panel khác bị ẩn
            pnlMessageContainer.Visible = false;

            // Sử dụng label trực tiếp hoặc tìm span bên trong
            lblLoginError.Text = $"<i class='fas fa-times-circle mr-2 flex-shrink-0'></i> {HttpUtility.HtmlEncode(errorMessage)}"; // Encode lỗi cho an toàn
            lblLoginError.CssClass = "mb-4 p-3 rounded-lg text-sm bg-red-50 border border-red-300 text-red-800 flex items-center"; // Adjusted styles
            lblLoginError.Visible = true;
        }

        // Hàm btnLogin_Click (Giữ nguyên logic cốt lõi, NHƯNG NHỚ VẤN ĐỀ HASH PASSWORD)
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Ẩn thông báo cũ trước khi xử lý
            pnlMessageContainer.Visible = false;
            lblLoginError.Visible = false;

            Page.Validate(); // Validate các RequiredFieldValidator
            if (!Page.IsValid)
            {
                return;
            }

            string loginIdentifier = txtLoginUsername.Text.Trim();
            string password = txtLoginPassword.Text; // **CẦN THAY BẰNG SO SÁNH HASH**

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                // **CẢNH BÁO BẢO MẬT:** Query này không an toàn vì so sánh mật khẩu dạng plain text.
                // Cần phải:
                // 1. Lấy HASH mật khẩu đã lưu của người dùng từ CSDL dựa trên loginIdentifier.
                // 2. Băm mật khẩu người dùng vừa nhập (password).
                // 3. So sánh hai chuỗi HASH đó.
                string query = @"SELECT IDNguoiDung, Username, Ten, VaiTro, MatKhau, ISNULL(TrangThai, 'Active') AS TrangThai
                                 FROM NguoiDung
                                 WHERE (Username = @Identifier OR Email = @Identifier OR DienThoai = @Identifier)";

                try
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@Identifier", loginIdentifier);

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read()) // Tìm thấy người dùng theo Identifier
                            {
                                string storedPasswordHash = reader["MatKhau"].ToString(); // Lấy hash từ CSDL
                                string trangThai = reader["TrangThai"].ToString();

                                // **THAY THẾ SO SÁNH NÀY BẰNG HÀM KIỂM TRA HASH**
                                // Ví dụ sử dụng BCrypt.Net (cần cài đặt NuGet package):
                                // bool isPasswordValid = BCrypt.Net.BCrypt.Verify(password, storedPasswordHash);

                                // Tạm thời so sánh plain text (KHÔNG AN TOÀN - CHỈ ĐỂ MINH HỌA LUỒNG)
                                bool isPasswordValid = (password == storedPasswordHash);

                                if (isPasswordValid)
                                {
                                    // Mật khẩu đúng, kiểm tra trạng thái
                                    if (trangThai.Equals("Active", StringComparison.OrdinalIgnoreCase))
                                    {
                                        // --- Đăng nhập thành công ---
                                        int userId = (int)reader["IDNguoiDung"];
                                        string username = reader["Username"].ToString();
                                        string displayName = reader["Ten"] != DBNull.Value ? reader["Ten"].ToString() : username;
                                        int role = Convert.ToInt32(reader["VaiTro"]);

                                        // --- Thiết lập Session và Cookie ---
                                        Session["UserID"] = userId;
                                        Session["Username"] = username;
                                        Session["UsernameDisplay"] = displayName;
                                        Session["VaiTro"] = role;

                                        // Tạo cookie xác thực
                                        FormsAuthentication.SetAuthCookie(username, false); // false = session cookie

                                        // --- Redirect ---
                                        RedirectAuthenticatedUser(); // Gọi hàm đã tạo ở trên
                                        return; // Quan trọng: Dừng xử lý sau khi redirect
                                    }
                                    else if (trangThai.Equals("Locked", StringComparison.OrdinalIgnoreCase))
                                    {
                                        ShowLoginError("Tài khoản của bạn đã bị khóa.");
                                    }
                                    else
                                    {
                                        ShowLoginError($"Tài khoản của bạn đã bị  ({trangThai}):(.");
                                    }
                                }
                                else
                                {
                                    // Sai mật khẩu
                                    ShowLoginError("Thông tin đăng nhập hoặc mật khẩu không chính xác.");
                                }
                            }
                            else // Không tìm thấy người dùng theo Identifier
                            {
                                ShowLoginError("Thông tin đăng nhập hoặc mật khẩu không chính xác.");
                            }
                        } // reader Dispose
                    } // command Dispose
                }
                catch (SqlException sqlEx)
                {
                    ShowLoginError("Lỗi cơ sở dữ liệu khi đăng nhập.");
                    Debug.WriteLine($"Login SQL Exception: {sqlEx}");
                }
                catch (Exception ex)
                {
                    ShowLoginError("Lỗi hệ thống khi đăng nhập.");
                    Debug.WriteLine($"Login Exception: {ex}");
                }
            } // connection Dispose
        }

        // Hàm IsLocalUrl (Giữ nguyên như cũ)
        private bool IsLocalUrl(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return false;
            // Chấp nhận URL tương đối hoặc bắt đầu bằng / hoặc ~/
            // Từ chối URL có scheme (http:, mailto:) hoặc host khác (//host, \\host)
            // Cải thiện để kiểm tra Uri.IsWellFormedUriString nếu cần chặt chẽ hơn
            return url.StartsWith("/") || url.StartsWith("~/") || (!url.Contains(":") && !url.StartsWith("//") && !url.StartsWith("\\\\"));

            // Cách chặt chẽ hơn:
            // Uri absoluteUri;
            // if (Uri.TryCreate(url, UriKind.Absolute, out absoluteUri)) {
            //     // Là URL tuyệt đối, kiểm tra xem có cùng host không (phức tạp hơn)
            //     return false; // Hoặc kiểm tra host
            // }
            // // Nếu là tương đối, kiểm tra xem có hợp lệ không
            // return Uri.IsWellFormedUriString(url, UriKind.Relative);
        }
    }
}