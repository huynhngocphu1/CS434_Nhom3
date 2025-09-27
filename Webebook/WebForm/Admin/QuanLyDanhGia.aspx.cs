// Generated on: 26/04/2025 - Minor adjustments based on UI changes
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization; // For chart data
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Webebook.WebForm.Admin
{
    public partial class QuanLyDanhGia : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["datawebebookConnectionString"].ConnectionString;

        // ViewState properties for filtering (no changes needed here)
        private string CurrentUserBookFilter
        {
            get { return ViewState["UserBookFilter"] as string ?? string.Empty; }
            set { ViewState["UserBookFilter"] = value; }
        }
        private int CurrentRatingFilter
        {
            get { return (ViewState["RatingFilter"] != null) ? Convert.ToInt32(ViewState["RatingFilter"]) : 0; }
            set { ViewState["RatingFilter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // --- IMPORTANT: Admin Role Check ---
            // if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            // {
            //     Response.Redirect("~/SomeOtherPage.aspx"); // Redirect if not admin
            //     return;
            // }

            if (!IsPostBack)
            {
                LoadStatistics();
                PopulateRatingFilterDropdown();
                BindGrid();
                // Ensure edit panel is hidden initially
                pnlEditReview.Visible = false;
                pnlStatistics.Visible = true;
                pnlFilters.Visible = true;
                pnlReviewList.Visible = true;
            }
            // Hide message panel by default on subsequent postbacks unless explicitly shown
            if (IsPostBack)
            {
                pnlAdminMessage.Visible = false;
            }
        }

        #region Load Data and Statistics (Minor UI related change in Average Rating)

        private void LoadStatistics()
        {
            LoadTotalReviewCount();
            LoadOverallAverageRating();
            LoadAverageRatingPerBook();
            LoadRatingDistributionChartData();
        }

        private void LoadTotalReviewCount()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "SELECT COUNT(*) FROM DanhGiaSach";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        con.Open();
                        lblTotalReviews.Text = ((int)cmd.ExecuteScalar()).ToString("N0", CultureInfo.InvariantCulture); // Use InvariantCulture for formatting consistency
                    }
                }
            }
            catch (Exception ex) { lblTotalReviews.Text = "Lỗi"; LogError("LoadTotalReviewCount Error: " + ex.Message); }
        }

        private void LoadOverallAverageRating()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "SELECT AVG(CAST(Diem AS DECIMAL(3, 2))) FROM DanhGiaSach";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != DBNull.Value && result != null)
                        {
                            // Set only the number, icon is now in ASPX
                            lblOverallAverage.Text = Convert.ToDecimal(result).ToString("N1", CultureInfo.InvariantCulture);
                        }
                        else { lblOverallAverage.Text = "N/A"; } // Use N/A instead of "Chưa có" for consistency
                    }
                }
            }
            catch (Exception ex) { lblOverallAverage.Text = "Lỗi"; LogError("LoadOverallAverageRating Error: " + ex.Message); }
        }

        // No functional changes needed in LoadAverageRatingPerBook and LoadRatingDistributionChartData
        private void LoadAverageRatingPerBook()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    // Query remains the same
                    string query = @"SELECT TOP 10 s.TenSach, AVG(CAST(dg.Diem AS DECIMAL(3, 2))) AS AvgRating, COUNT(dg.IDDanhGia) AS ReviewCount
                                     FROM DanhGiaSach dg JOIN Sach s ON dg.IDSach = s.IDSach
                                     GROUP BY s.TenSach ORDER BY AvgRating DESC, ReviewCount DESC";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        con.Open();
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptAveragePerBook.DataSource = dt;
                        rptAveragePerBook.DataBind();
                        pnlAveragePerBook.Visible = dt.Rows.Count > 0;
                    }
                }
            }
            catch (Exception ex) { pnlAveragePerBook.Visible = false; LogError("LoadAverageRatingPerBook Error: " + ex.Message); ShowAdminMessage("Lỗi tải điểm trung bình sách.", true); }
        }

        private void LoadRatingDistributionChartData()
        {
            try
            {
                var ratingCounts = new Dictionary<int, int> { { 1, 0 }, { 2, 0 }, { 3, 0 }, { 4, 0 }, { 5, 0 } };
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "SELECT Diem, COUNT(*) AS Count FROM DanhGiaSach WHERE Diem BETWEEN 1 AND 5 GROUP BY Diem";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (reader["Diem"] != DBNull.Value && reader["Count"] != DBNull.Value)
                                {
                                    int diem = Convert.ToInt32(reader["Diem"]);
                                    if (ratingCounts.ContainsKey(diem)) { ratingCounts[diem] = Convert.ToInt32(reader["Count"]); }
                                }
                            }
                        }
                    }
                }
                var labels = ratingCounts.Keys.OrderBy(k => k).Select(k => $"{k} sao").ToList();
                var data = ratingCounts.OrderBy(kv => kv.Key).Select(kv => kv.Value).ToList();

                JavaScriptSerializer serializer = new JavaScriptSerializer();
                string chartLabels = serializer.Serialize(labels);
                string chartData = serializer.Serialize(data);

                // Chart.js script - Ensure it destroys the old chart before creating a new one
                // Added responsive and maintainAspectRatio: false
                string script = $@"
                    var ctx = document.getElementById('ratingsChartCanvas').getContext('2d');
                    if (window.ratingsChart instanceof Chart) {{ window.ratingsChart.destroy(); }}
                    window.ratingsChart = new Chart(ctx, {{
                        type: 'bar',
                        data: {{
                            labels: {chartLabels},
                            datasets: [{{
                                label: 'Số lượng đánh giá',
                                data: {chartData},
                                backgroundColor: [
                                    'rgba(239, 68, 68, 0.6)',  // Red-500
                                    'rgba(249, 115, 22, 0.6)', // Orange-500
                                    'rgba(234, 179, 8, 0.6)',  // Amber-500
                                    'rgba(132, 204, 22, 0.6)', // Lime-500
                                    'rgba(34, 197, 94, 0.6)'   // Green-500
                                ],
                                borderColor: [
                                    'rgba(239, 68, 68, 1)',
                                    'rgba(249, 115, 22, 1)',
                                    'rgba(234, 179, 8, 1)',
                                    'rgba(132, 204, 22, 1)',
                                    'rgba(34, 197, 94, 1)'
                                ],
                                borderWidth: 1
                            }}]
                        }},
                        options: {{
                            responsive: true,
                            maintainAspectRatio: false,
                            scales: {{
                                y: {{
                                    beginAtZero: true,
                                    ticks: {{
                                        stepSize: 1, // Ensure integer ticks if counts are low
                                        precision: 0 // Display whole numbers only
                                     }}
                                }}
                            }},
                            plugins: {{
                                legend: {{ display: false }},
                                tooltip: {{
                                     callbacks: {{
                                         label: function(context) {{
                                             let label = context.dataset.label || '';
                                             if (label) {{ label += ': '; }}
                                             if (context.parsed.y !== null) {{ label += context.parsed.y; }}
                                             return label;
                                         }}
                                     }}
                                }}
                            }}
                        }}
                    }});";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "RatingChartScript", script, true);
                pnlChart.Visible = data.Sum() > 0;
            }
            catch (Exception ex) { pnlChart.Visible = false; LogError("LoadRatingDistributionChartData Error: " + ex.Message); ShowAdminMessage("Lỗi tải dữ liệu biểu đồ.", true); }
        }
        #endregion

        #region GridView Binding and Actions (Updated RowCommand)

        private void BindGrid()
        {
            string searchTerm = CurrentUserBookFilter;
            int ratingFilter = CurrentRatingFilter;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Query includes Username for searching
                StringBuilder queryBuilder = new StringBuilder(@"
                    SELECT dg.IDDanhGia, nd.Ten, nd.Username, s.TenSach, dg.Diem, dg.NhanXet, dg.NgayDanhGia
                    FROM DanhGiaSach dg
                    JOIN NguoiDung nd ON dg.IDNguoiDung = nd.IDNguoiDung
                    JOIN Sach s ON dg.IDSach = s.IDSach
                ");
                List<string> conditions = new List<string>();
                SqlCommand cmd = new SqlCommand();

                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    // Search in user's display name (Ten), username, and book title (TenSach)
                    conditions.Add("(nd.Ten LIKE @SearchTerm OR s.TenSach LIKE @SearchTerm OR nd.Username LIKE @SearchTerm)");
                    cmd.Parameters.AddWithValue("@SearchTerm", "%" + searchTerm.Trim() + "%");
                }
                if (ratingFilter > 0)
                {
                    conditions.Add("dg.Diem = @Rating");
                    cmd.Parameters.AddWithValue("@Rating", ratingFilter);
                }

                if (conditions.Any()) { queryBuilder.Append(" WHERE " + string.Join(" AND ", conditions)); }
                queryBuilder.Append(" ORDER BY dg.NgayDanhGia DESC");

                cmd.CommandText = queryBuilder.ToString();
                cmd.Connection = con;

                try
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvReviews.DataSource = dt;
                    gvReviews.DataBind();

                    // Ensure correct panels are visible after binding
                    // This state is usually when showing the list, not editing
                    // pnlReviewList.Visible = true; // Already handled by default visibility logic usually
                    // pnlFilters.Visible = true;
                    // pnlStatistics.Visible = true;

                }
                catch (Exception ex)
                {
                    ShowAdminMessage("Lỗi tải danh sách đánh giá: " + ex.Message, true);
                    LogError("BindGrid Error: " + ex.ToString());
                    gvReviews.DataSource = null; // Clear data source on error
                    gvReviews.DataBind();
                    // Optionally hide panels if data load fails critically
                    // pnlReviewList.Visible = false;
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentUserBookFilter = txtSearchUserBook.Text.Trim();
            CurrentRatingFilter = Convert.ToInt32(ddlRatingFilter.SelectedValue);
            gvReviews.PageIndex = 0; // Reset to first page on new search
            BindGrid();
            // Ensure correct panels are visible after search/filter
            ShowListPanels();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearchUserBook.Text = string.Empty;
            ddlRatingFilter.SelectedIndex = 0; // Reset dropdown to "All"
            CurrentUserBookFilter = string.Empty;
            CurrentRatingFilter = 0;
            gvReviews.PageIndex = 0; // Reset to first page
            BindGrid();
            // Ensure correct panels are visible after reset
            ShowListPanels();
        }

        protected void gvReviews_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvReviews.PageIndex = e.NewPageIndex;
            BindGrid(); // Rebind with existing filters
                        // Ensure correct panels are visible after paging
            ShowListPanels();
        }

        // *** UPDATED RowCommand ***
        protected void gvReviews_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditReview")
            {
                if (!int.TryParse(e.CommandArgument?.ToString(), out int reviewId) || reviewId <= 0)
                {
                    ShowAdminMessage("ID đánh giá không hợp lệ để sửa.", true);
                    return;
                }

                // Populate the form first
                bool populateSuccess = PopulateEditForm(reviewId);

                if (populateSuccess)
                {
                    // Hide list, filters, and statistics panels
                    pnlReviewList.Visible = false;
                    pnlFilters.Visible = false;
                    pnlStatistics.Visible = false; // <-- HIDE STATISTICS

                    // Show edit panel
                    pnlEditReview.Visible = true;

                    // Trigger the client-side animation *after* the panel is visible
                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditPanelScript", "showEditPanelAnimated();", true);
                }
                else
                {
                    // If populating failed, keep showing the list
                    ShowListPanels();
                }
            }
            // Delete command is handled by RowDeleting event
        }

        // *** UPDATED RowDeleting ***
        protected void gvReviews_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int reviewId = 0;
            try
            {
                if (gvReviews.DataKeys != null && e.RowIndex < gvReviews.DataKeys.Count)
                {
                    reviewId = Convert.ToInt32(gvReviews.DataKeys[e.RowIndex].Value);
                    DeleteReview(reviewId); // Call helper method
                    LoadStatistics(); // <-- RELOAD STATS after delete
                    BindGrid(); // Refresh the grid
                    ShowListPanels(); // Ensure correct panels are shown
                }
                else
                {
                    ShowAdminMessage("Không thể lấy ID đánh giá để xóa.", true);
                }
            }
            catch (FormatException ex)
            {
                ShowAdminMessage("Lỗi định dạng ID khi xóa.", true);
                LogError($"Delete Review Format Error (RowIndex: {e.RowIndex}): {ex.ToString()}");
                ShowListPanels();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Lỗi khi xóa đánh giá: " + ex.Message, true);
                LogError($"Delete Review Error (ID: {reviewId}, RowIndex: {e.RowIndex}): {ex.ToString()}");
                ShowListPanels(); // Still show list even if delete fails
            }
        }

        private void DeleteReview(int reviewId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "DELETE FROM DanhGiaSach WHERE IDDanhGia = @IDDanhGia";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IDDanhGia", reviewId);
                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0) { ShowAdminMessage("Xóa đánh giá thành công.", false); }
                    else { ShowAdminMessage("Không tìm thấy đánh giá để xóa (ID: " + reviewId + ").", true); }
                }
            }
            // No need for separate try-catch here if the caller handles it
        }

        #endregion

        #region Edit Review Panel (Updated Save/Cancel)

        // *** UPDATED PopulateEditForm to return success/failure ***
        private bool PopulateEditForm(int reviewId)
        {
            bool success = false;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Query uses user's display name (Ten)
                string query = @"SELECT dg.IDDanhGia, nd.Ten, s.TenSach, dg.Diem, dg.NhanXet
                                 FROM DanhGiaSach dg
                                 JOIN NguoiDung nd ON dg.IDNguoiDung = nd.IDNguoiDung
                                 JOIN Sach s ON dg.IDSach = s.IDSach
                                 WHERE dg.IDDanhGia = @IDDanhGia";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IDDanhGia", reviewId);
                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                hfEditReviewId.Value = reviewId.ToString();
                                lblEditUser.Text = Server.HtmlEncode(reader["Ten"] != DBNull.Value ? reader["Ten"].ToString() : "N/A");
                                lblEditBook.Text = Server.HtmlEncode(reader["TenSach"] != DBNull.Value ? reader["TenSach"].ToString() : "N/A");
                                txtEditComment.Text = reader["NhanXet"] != DBNull.Value ? reader["NhanXet"].ToString() : string.Empty;

                                // Safely set RadioButtonList value
                                string diemStr = reader["Diem"] != DBNull.Value ? reader["Diem"].ToString() : null;
                                rblEditRating.ClearSelection(); // Deselect all first
                                ListItem itemToSelect = rblEditRating.Items.FindByValue(diemStr);
                                if (itemToSelect != null)
                                {
                                    itemToSelect.Selected = true;
                                }
                                success = true; // Data loaded successfully
                            }
                            else
                            {
                                ShowAdminMessage("Không tìm thấy đánh giá để sửa (ID: " + reviewId + ").", true);
                                success = false;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowAdminMessage("Lỗi tải thông tin đánh giá để sửa: " + ex.Message, true);
                        LogError($"PopulateEditForm Error (ID: {reviewId}): {ex.ToString()}");
                        success = false;
                    }
                }
            }
            return success;
        }

        // *** UPDATED btnSaveChanges_Click ***
        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) // Check validation group
            {
                // Keep edit panel visible if validation fails
                pnlEditReview.Visible = true;
                pnlReviewList.Visible = false;
                pnlFilters.Visible = false;
                pnlStatistics.Visible = false;
                // Ensure animation class is present if validation fails on first attempt
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditPanelScript", "showEditPanelAnimated();", true);
                return;
            }

            if (!int.TryParse(hfEditReviewId.Value, out int reviewId) || reviewId <= 0)
            {
                ShowAdminMessage("ID đánh giá không hợp lệ để lưu.", true);
                // Keep edit panel visible on error
                pnlEditReview.Visible = true; pnlReviewList.Visible = false; pnlFilters.Visible = false; pnlStatistics.Visible = false;
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditPanelScript", "showEditPanelAnimated();", true);
                return;
            }
            if (!int.TryParse(rblEditRating.SelectedValue, out int rating) || rating < 1 || rating > 5)
            {
                // This case should be caught by RequiredFieldValidator, but double-check
                ShowAdminMessage("Điểm đánh giá không hợp lệ.", true);
                // Keep edit panel visible on error
                pnlEditReview.Visible = true; pnlReviewList.Visible = false; pnlFilters.Visible = false; pnlStatistics.Visible = false;
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditPanelScript", "showEditPanelAnimated();", true);
                return;
            }
            string comment = txtEditComment.Text.Trim(); // Trim whitespace

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "UPDATE DanhGiaSach SET Diem = @Diem, NhanXet = @NhanXet WHERE IDDanhGia = @IDDanhGia";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Diem", rating);
                    // Use DBNull.Value for empty comments if desired, or just save empty string
                    cmd.Parameters.AddWithValue("@NhanXet", string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment);
                    cmd.Parameters.AddWithValue("@IDDanhGia", reviewId);
                    try
                    {
                        con.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            ShowAdminMessage("Cập nhật đánh giá thành công.", false);
                            LoadStatistics(); // <-- RELOAD STATS
                            BindGrid(); // Refresh the list
                            ShowListPanels(); // Show List, Filters, and Statistics
                        }
                        else
                        {
                            ShowAdminMessage("Không có thay đổi nào được lưu hoặc không tìm thấy đánh giá.", true);
                            // Keep edit panel visible if nothing changed or error occurred
                            pnlEditReview.Visible = true; pnlReviewList.Visible = false; pnlFilters.Visible = false; pnlStatistics.Visible = false;
                            ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditPanelScript", "showEditPanelAnimated();", true);
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowAdminMessage("Lỗi khi cập nhật đánh giá: " + ex.Message, true);
                        LogError($"Save Review Changes Error (ID: {reviewId}): {ex.ToString()}");
                        // Keep edit panel visible on exception
                        pnlEditReview.Visible = true; pnlReviewList.Visible = false; pnlFilters.Visible = false; pnlStatistics.Visible = false;
                        ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditPanelScript", "showEditPanelAnimated();", true);
                    }
                }
            }
        }

        // *** UPDATED btnCancelEdit_Click ***
        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ShowListPanels(); // Show List, Filters, and Statistics
        }

        #endregion

        #region Helpers (Updated ShowAdminMessage, Added ShowListPanels)

        private void PopulateRatingFilterDropdown()
        {
            if (ddlRatingFilter.Items.Count == 0)
            {
                ddlRatingFilter.Items.Add(new ListItem("Tất cả điểm", "0"));
                for (int i = 5; i >= 1; i--) { ddlRatingFilter.Items.Add(new ListItem($"{i} sao", i.ToString())); }
            }
            // Ensure the ViewState value is selected if it exists
            if (ViewState["RatingFilter"] != null)
            {
                ddlRatingFilter.SelectedValue = ViewState["RatingFilter"].ToString();
            }
            // Ensure the ViewState value is restored for search box
            if (ViewState["UserBookFilter"] != null)
            {
                txtSearchUserBook.Text = ViewState["UserBookFilter"].ToString();
            }
        }

        // Make helper methods public if used directly in ASPX <%# %> bindings
        public string TruncateString(object inputObject, int maxLength)
        {
            if (inputObject == null || inputObject == DBNull.Value) return string.Empty;
            string input = inputObject.ToString();
            if (string.IsNullOrEmpty(input) || input.Length <= maxLength) return input;
            // Trim potentially partial words at the end
            return input.Substring(0, maxLength).TrimEnd('.', ' ', ',', ';') + "...";
        }

        // Updated ShowAdminMessage to use the dedicated panel
        private void ShowAdminMessage(string message, bool isError)
        {
            lblAdminMessage.Text = Server.HtmlEncode(message);
            // Use more distinct colors
            string cssClass = "block p-4 rounded-md border text-sm font-medium ";
            cssClass += isError
                ? "bg-red-100 border-red-300 text-red-800"
                : "bg-green-100 border-green-300 text-green-800";
            lblAdminMessage.CssClass = cssClass;
            pnlAdminMessage.Visible = true; // Show the panel containing the label
        }

        private void LogError(string message)
        {
            // Implement more robust logging if needed (e.g., log to file, database, monitoring service)
            System.Diagnostics.Trace.TraceError("ADMIN_ERROR [QuanLyDanhGia]: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + message);
        }

        // Ensure star display remains public for ASPX binding
        public string GetStarRatingHtml(object ratingObj)
        {
            if (ratingObj == null || ratingObj == DBNull.Value || !int.TryParse(ratingObj.ToString(), out int rating)) return "<span class='text-gray-400 text-xs'>Chưa có</span>";

            rating = Math.Max(0, Math.Min(5, rating)); // Clamp rating between 0 and 5

            StringBuilder stars = new StringBuilder("<span class='inline-block' title='" + rating + " sao'>"); // Add tooltip to the span
            for (int i = 1; i <= 5; i++)
            {
                // Use solid star (fas) for filled, regular star (far) for empty for better distinction
                string starClass = (i <= rating) ? "fas fa-star text-yellow-400" : "far fa-star text-gray-300";
                stars.Append($"<i class='{starClass} mx-px'></i>"); // Add small margin between stars
            }
            stars.Append("</span>");
            return stars.ToString();
        }

        // *** ADDED Helper to manage panel visibility for list view ***
        private void ShowListPanels()
        {
            pnlEditReview.Visible = false;
            pnlStatistics.Visible = true;
            pnlFilters.Visible = true;
            pnlReviewList.Visible = true;
            // Optional: Clean up animation class if edit panel was visible
            // ScriptManager.RegisterStartupScript(this, GetType(), "HideEditPanelScript", "hideEditPanelCleanup();", true);
        }

        #endregion

    } // End Class
} // End Namespace