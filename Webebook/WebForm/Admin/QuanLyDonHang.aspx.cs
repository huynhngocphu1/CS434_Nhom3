using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Diagnostics; // Thêm using này để ghi log lỗi

namespace Webebook.WebForm.Admin
{
    public partial class QuanLyDonHang : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["datawebebookConnectionString"].ConnectionString;

        #region ViewState Properties for Filters
        private string FilterStatus
        {
            get { return ViewState["FilterStatus"] as string ?? string.Empty; }
            set { ViewState["FilterStatus"] = value; }
        }
        private string FilterPaymentMethod
        {
            get { return ViewState["FilterPaymentMethod"] as string ?? string.Empty; }
            set { ViewState["FilterPaymentMethod"] = value; }
        }
        private string FilterStartDate
        {
            get { return ViewState["FilterStartDate"] as string ?? string.Empty; }
            set { ViewState["FilterStartDate"] = value; }
        }
        private string FilterEndDate
        {
            get { return ViewState["FilterEndDate"] as string ?? string.Empty; }
            set { ViewState["FilterEndDate"] = value; }
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Master is Admin master)
                {
                    master.SetPageTitle("Quản Lý Đơn Hàng");
                }
                LoadFilters(); // Load filters from ViewState or defaults
                BindGrid();    // Bind data initially
            }
        }

        #region Filter Handling
        private void LoadFilters()
        {
            SetSelectedValue(ddlFilterStatus, FilterStatus);
            SetSelectedValue(ddlFilterPaymentMethod, FilterPaymentMethod);
            txtFilterStartDate.Text = FilterStartDate;
            txtFilterEndDate.Text = FilterEndDate;
        }

        private void SetSelectedValue(DropDownList ddl, string value)
        {
            try
            {
                if (ddl.Items.FindByValue(value) != null)
                {
                    ddl.SelectedValue = value;
                }
                else
                {
                    ddl.SelectedIndex = 0; // Default to the first item ("-- Tất cả --") if value not found
                }
            }
            catch (ArgumentOutOfRangeException) // Catch error if value doesn't exist
            {
                ddl.SelectedIndex = 0; // Default to the first item
            }
        }

        private void SaveFilters()
        {
            FilterStatus = ddlFilterStatus.SelectedValue;
            FilterPaymentMethod = ddlFilterPaymentMethod.SelectedValue;
            FilterStartDate = txtFilterStartDate.Text.Trim();
            FilterEndDate = txtFilterEndDate.Text.Trim();
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            SaveFilters();
            GridViewDonHang.PageIndex = 0;
            GridViewDonHang.EditIndex = -1;
            BindGrid();
        }

        protected void ApplyFilter_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            SaveFilters();
            GridViewDonHang.PageIndex = 0;
            GridViewDonHang.EditIndex = -1;
            BindGrid();
        }

        protected void ResetFilter_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            ddlFilterStatus.SelectedIndex = 0;
            ddlFilterPaymentMethod.SelectedIndex = 0;
            txtFilterStartDate.Text = string.Empty;
            txtFilterEndDate.Text = string.Empty;
            SaveFilters(); // Save the cleared values
            GridViewDonHang.PageIndex = 0;
            GridViewDonHang.EditIndex = -1;
            BindGrid();
        }
        #endregion

        #region GridView Binding and Data Operations
        private void BindGrid()
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                StringBuilder queryBuilder = new StringBuilder(@"
                    SELECT
                        dh.IDDonHang, dh.IDNguoiDung,
                        ISNULL(nd.Ten, nd.Username) AS TenNguoiDung,
                        dh.NgayDat, dh.SoTien, dh.TrangThaiThanhToan, dh.PhuongThucThanhToan
                    FROM DonHang dh
                    LEFT JOIN NguoiDung nd ON dh.IDNguoiDung = nd.IDNguoiDung
                    WHERE 1=1 ");

                List<SqlParameter> parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(FilterStatus))
                {
                    queryBuilder.Append(" AND dh.TrangThaiThanhToan = @TrangThaiFilter ");
                    parameters.Add(new SqlParameter("@TrangThaiFilter", SqlDbType.NVarChar, 50) { Value = FilterStatus });
                }
                if (!string.IsNullOrEmpty(FilterPaymentMethod))
                {
                    queryBuilder.Append(" AND dh.PhuongThucThanhToan = @PhuongThucFilter ");
                    parameters.Add(new SqlParameter("@PhuongThucFilter", SqlDbType.NVarChar, 50) { Value = FilterPaymentMethod });
                }
                DateTime startDate, endDate;
                if (DateTime.TryParseExact(FilterStartDate, "d/M/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out startDate))
                {
                    queryBuilder.Append(" AND dh.NgayDat >= @StartDate ");
                    parameters.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate.Date });
                }
                if (DateTime.TryParseExact(FilterEndDate, "d/M/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out endDate))
                {
                    queryBuilder.Append(" AND dh.NgayDat < @EndDate ");
                    parameters.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate.Date.AddDays(1) });
                }

                queryBuilder.Append(" ORDER BY dh.NgayDat DESC");

                using (SqlCommand cmd = new SqlCommand(queryBuilder.ToString(), con))
                {
                    cmd.Parameters.AddRange(parameters.ToArray());
                    try
                    {
                        con.Open();
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dt);
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine($"Error in BindGrid: {ex}");
                        ShowMessage("Lỗi khi tải dữ liệu đơn hàng.", true);
                    }
                }
            }

            GridViewDonHang.DataSource = dt;
            // Only reset EditIndex if not caused by an edit/update/cancel/delete command triggering postback
            // (IsPostBackFromGridCommand checks for EditStatus, UpdateStatus, CancelUpdate)
            if (!IsPostBack || (IsPostBack && !IsPostBackFromGridCommand()))
            {
                if (GridViewDonHang.EditIndex != -1) GridViewDonHang.EditIndex = -1;
            }
            try { GridViewDonHang.DataBind(); }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error during GridView DataBind: {ex.Message}");
                ShowMessage("Lỗi hiển thị dữ liệu đơn hàng.", true);
            }
        }

        protected void GridViewDonHang_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridViewDonHang.PageIndex = e.NewPageIndex;
            GridViewDonHang.EditIndex = -1; // Exit edit mode when changing page
            BindGrid();
        }

        protected void GridViewDonHang_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Clear previous message for relevant commands
            if (e.CommandName == "UpdateStatus" || e.CommandName == "DeleteOrder" || e.CommandName == "EditStatus" || e.CommandName == "CancelUpdate")
            {
                pnlMessage.Visible = false;
            }

            int rowIndex = -1;
            GridViewRow row = null;

            // Try to get row index from command argument first (mostly for Edit/Cancel)
            if (int.TryParse(e.CommandArgument?.ToString(), out rowIndex))
            {
                // Ensure rowIndex is valid within the current page
                if (rowIndex >= 0 && rowIndex < GridViewDonHang.Rows.Count)
                {
                    row = GridViewDonHang.Rows[rowIndex];
                }
                else { rowIndex = -1; } // Invalidate index if out of bounds
            }

            // If row still null (e.g., for UpdateStatus/DeleteOrder where argument is ID), try getting from CommandSource
            if (row == null && e.CommandSource is Control commandControl)
            {
                var container = commandControl.NamingContainer;
                while (container != null && !(container is GridViewRow))
                {
                    container = container.NamingContainer;
                }
                row = container as GridViewRow;
                if (row != null) rowIndex = row.RowIndex; // Update index if row found this way
            }


            if (e.CommandName == "UpdateStatus")
            {
                if (!int.TryParse(e.CommandArgument?.ToString(), out int idDonHang)) { ShowMessage("Lỗi: ID Đơn hàng không hợp lệ.", true); return; }
                if (row == null) { ShowMessage("Lỗi: Không tìm thấy dòng đơn hàng để cập nhật.", true); GridViewDonHang.EditIndex = -1; BindGrid(); return; }
                if (rowIndex == -1) { ShowMessage("Lỗi: Không xác định được chỉ số dòng.", true); GridViewDonHang.EditIndex = -1; BindGrid(); return; } // Added check for valid rowIndex

                DropDownList ddlTrangThai = (DropDownList)row.FindControl("ddlTrangThai");
                if (ddlTrangThai == null) { ShowMessage("Lỗi: Không tìm thấy control DropDownList trạng thái.", true); GridViewDonHang.EditIndex = -1; BindGrid(); return; }

                try
                {
                    if (GridViewDonHang.DataKeys == null || rowIndex >= GridViewDonHang.DataKeys.Count) { ShowMessage("Lỗi: Không thể truy xuất khóa dữ liệu cho dòng này.", true); GridViewDonHang.EditIndex = -1; BindGrid(); return; }
                    int idNguoiDung = Convert.ToInt32(GridViewDonHang.DataKeys[rowIndex]?["IDNguoiDung"]); // Use updated rowIndex
                    string newStatus = ddlTrangThai.SelectedValue;
                    UpdateOrderStatus(idDonHang, idNguoiDung, newStatus);
                    GridViewDonHang.EditIndex = -1; // Exit edit mode
                }
                catch (Exception ex)
                {
                    Debug.WriteLine($"RowCommand Update Error: {ex}");
                    // Message is shown in UpdateOrderStatus
                    GridViewDonHang.EditIndex = -1; // Exit edit mode on error too
                }
                finally
                {
                    BindGrid(); // Rebind grid AFTER processing command
                }
            }
            else if (e.CommandName == "EditStatus")
            {
                if (rowIndex != -1) // Use index determined earlier
                {
                    GridViewDonHang.EditIndex = rowIndex;
                    BindGrid();
                }
                else { ShowMessage("Lỗi: Không xác định được dòng để sửa.", true); }
            }
            else if (e.CommandName == "CancelUpdate")
            {
                GridViewDonHang.EditIndex = -1;
                BindGrid();
            }
            else if (e.CommandName == "DeleteOrder")
            {
                if (!int.TryParse(e.CommandArgument?.ToString(), out int idDonHangToDelete))
                {
                    ShowMessage("Lỗi: ID Đơn hàng không hợp lệ để xóa.", true);
                    return;
                }

                try
                {
                    DeleteOrder(idDonHangToDelete); // Call the delete method
                }
                catch (Exception ex)
                {
                    // Error message is handled within DeleteOrder
                    Debug.WriteLine($"Error invoking DeleteOrder from RowCommand: {ex.Message}");
                }
                finally
                {
                    GridViewDonHang.EditIndex = -1; // Ensure we exit edit mode if somehow active
                    BindGrid(); // Rebind the grid to reflect the deletion
                }
            }
        }

        private void UpdateOrderStatus(int idDonHang, int idNguoiDung, string newStatus)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    if (idNguoiDung <= 0)
                    {
                        Debug.WriteLine($"Warning: Invalid IDNguoiDung ({idNguoiDung}) for DonHang ID {idDonHang}. Bookshelf add will be skipped.");
                    }

                    string updateQuery = "UPDATE DonHang SET TrangThaiThanhToan = @TrangThai WHERE IDDonHang = @IDDonHang";
                    int rowsAffected = 0;
                    using (SqlCommand cmdUpdate = new SqlCommand(updateQuery, con, transaction))
                    {
                        cmdUpdate.Parameters.AddWithValue("@TrangThai", newStatus);
                        cmdUpdate.Parameters.AddWithValue("@IDDonHang", idDonHang);
                        rowsAffected = cmdUpdate.ExecuteNonQuery();
                    }

                    if (rowsAffected > 0)
                    {
                        bool addedToBookshelf = false;
                        if (newStatus.Equals("Completed", StringComparison.OrdinalIgnoreCase) && idNguoiDung > 0)
                        {
                            AddBooksToBookshelf(idDonHang, idNguoiDung, con, transaction);
                            addedToBookshelf = true;
                        }
                        transaction.Commit();
                        string successMessage = $"Cập nhật trạng thái đơn hàng #{idDonHang} thành '{GetStatusText(newStatus)}' thành công.";
                        if (addedToBookshelf) successMessage += " Sách đã được kiểm tra/thêm vào tủ sách.";
                        ShowMessage(successMessage, false);
                    }
                    else
                    {
                        transaction.Rollback();
                        ShowMessage($"Không tìm thấy đơn hàng #{idDonHang} để cập nhật.", true);
                    }
                }
                catch (Exception ex)
                {
                    try { transaction.Rollback(); } catch (Exception rbEx) { Debug.WriteLine("Rollback failed: " + rbEx.Message); }
                    Debug.WriteLine($"Update Order Status Error (Order ID: {idDonHang}): {ex}");
                    ShowMessage($"Lỗi khi cập nhật trạng thái hoặc thêm sách: {ex.Message}", true);
                }
            }
        }

        private void AddBooksToBookshelf(int idDonHang, int idNguoiDung, SqlConnection con, SqlTransaction transaction)
        {
            // Throws exception on failure, caught by UpdateOrderStatus
            string getBooksQuery = "SELECT DISTINCT IDSach FROM ChiTietDonHang WHERE IDDonHang = @IDDonHang";
            var bookIds = new List<int>();
            using (SqlCommand cmdGetBooks = new SqlCommand(getBooksQuery, con, transaction))
            {
                cmdGetBooks.Parameters.AddWithValue("@IDDonHang", idDonHang);
                using (SqlDataReader reader = cmdGetBooks.ExecuteReader())
                {
                    while (reader.Read()) { if (!reader.IsDBNull(0)) bookIds.Add(reader.GetInt32(0)); }
                } // Reader is automatically closed here
            }

            if (!bookIds.Any()) { Debug.WriteLine($"No valid book IDs found in Order ID {idDonHang} to add to bookshelf."); return; } // No books, just return

            foreach (int idSach in bookIds)
            {
                if (idSach <= 0)
                {
                    Debug.WriteLine($"Skipping invalid Book ID ({idSach}) from Order {idDonHang}.");
                    continue; // Skip invalid book IDs
                }

                string checkExistQuery = "SELECT COUNT(*) FROM TuSach WHERE IDNguoiDung = @IDNguoiDung AND IDSach = @IDSach";
                int existingCount = 0;
                using (SqlCommand cmdCheck = new SqlCommand(checkExistQuery, con, transaction))
                {
                    cmdCheck.Parameters.AddWithValue("@IDNguoiDung", idNguoiDung);
                    cmdCheck.Parameters.AddWithValue("@IDSach", idSach);
                    object result = cmdCheck.ExecuteScalar(); // Returns the count
                    if (result != null && result != DBNull.Value) existingCount = Convert.ToInt32(result);
                }

                if (existingCount == 0) // Only insert if it doesn't exist
                {
                    string insertQuery = "INSERT INTO TuSach (IDNguoiDung, IDSach, NgayThem) VALUES (@IDNguoiDung, @IDSach, GETDATE())";
                    using (SqlCommand cmdInsert = new SqlCommand(insertQuery, con, transaction))
                    {
                        cmdInsert.Parameters.AddWithValue("@IDNguoiDung", idNguoiDung);
                        cmdInsert.Parameters.AddWithValue("@IDSach", idSach);
                        int inserted = cmdInsert.ExecuteNonQuery();
                        if (inserted <= 0)
                        {
                            // This shouldn't ideally happen if the check passed, but log it.
                            Debug.WriteLine($"Failed to insert Book ID {idSach} into TuSach for User ID {idNguoiDung} despite not existing (Order {idDonHang}).");
                            // Consider throwing an exception here if this is critical
                            // throw new Exception($"Không thể thêm sách ID {idSach} vào tủ sách.");
                        }
                        else
                        {
                            Debug.WriteLine($"Successfully added Book ID {idSach} to TuSach for User ID {idNguoiDung} (Order {idDonHang}).");
                        }
                    }
                }
                else { Debug.WriteLine($"Book ID {idSach} already in TuSach for User ID {idNguoiDung} (Order {idDonHang}). Skipping."); }
            }
        }

        // === PHƯƠNG THỨC XÓA ĐƠN HÀNG ===
        private void DeleteOrder(int idDonHang)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    // 1. Delete related order details FIRST
                    string deleteDetailsQuery = "DELETE FROM ChiTietDonHang WHERE IDDonHang = @IDDonHang";
                    using (SqlCommand cmdDetails = new SqlCommand(deleteDetailsQuery, con, transaction))
                    {
                        cmdDetails.Parameters.AddWithValue("@IDDonHang", idDonHang);
                        cmdDetails.ExecuteNonQuery();
                        Debug.WriteLine($"Executed delete details for Order ID {idDonHang}.");
                    }

                    // 2. Delete the main order record
                    string deleteOrderQuery = "DELETE FROM DonHang WHERE IDDonHang = @IDDonHang";
                    int rowsAffected = 0;
                    using (SqlCommand cmdOrder = new SqlCommand(deleteOrderQuery, con, transaction))
                    {
                        cmdOrder.Parameters.AddWithValue("@IDDonHang", idDonHang);
                        rowsAffected = cmdOrder.ExecuteNonQuery();
                        Debug.WriteLine($"Executed delete order for Order ID {idDonHang}. Rows affected: {rowsAffected}");
                    }

                    // 3. Commit if the main order was deleted successfully
                    if (rowsAffected > 0)
                    {
                        transaction.Commit();
                        ShowMessage($"Đơn hàng #{idDonHang} và các chi tiết liên quan đã được xóa thành công.", false);
                    }
                    else
                    {
                        // If no rows in DonHang were affected (maybe deleted already?)
                        transaction.Rollback(); // Still rollback to ensure consistency
                        ShowMessage($"Không tìm thấy đơn hàng #{idDonHang} để xóa, hoặc đã bị xóa trước đó.", true);
                    }
                }
                catch (SqlException sqlEx) // Catch specific SQL errors
                {
                    try { transaction.Rollback(); } catch (Exception rbEx) { Debug.WriteLine("Rollback failed: " + rbEx.Message); }
                    Debug.WriteLine($"SQL Error Deleting Order ID {idDonHang}: {sqlEx}");
                    ShowMessage($"Lỗi CSDL khi xóa đơn hàng #{idDonHang}. Chi tiết: {sqlEx.Message}", true);
                }
                catch (Exception ex) // Catch general errors
                {
                    try { transaction.Rollback(); } catch (Exception rbEx) { Debug.WriteLine("Rollback failed: " + rbEx.Message); }
                    Debug.WriteLine($"General Error Deleting Order ID {idDonHang}: {ex}");
                    ShowMessage($"Lỗi không xác định khi xóa đơn hàng #{idDonHang}. Chi tiết: {ex.Message}", true);
                }
            } // Connection is automatically closed here
        }
        // === KẾT THÚC PHƯƠNG THỨC XÓA ĐƠN HÀNG ===

        protected void GridViewDonHang_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Optional: Add row-specific logic here if needed in the future
        }
        #endregion

        #region Helper Methods
        protected string GetStatusText(string statusValue)
        {
            switch (statusValue?.ToLowerInvariant()) { case "pending": return "Chờ"; case "completed": return "Hoàn thành"; case "cancelled": return "Bị hủy bỏ"; case "failed": return "Thất bại"; default: return statusValue ?? "N/A"; }
        }
        protected string GetPaymentMethodText(string paymentValue)
        {
            switch (paymentValue?.ToLowerInvariant()) { case "cod": return "COD"; case "bank": return "Chuyển khoản"; case "card": return "Thẻ NH"; case "ewallet": return "Ví ĐT"; default: return paymentValue ?? "N/A"; }
        }
        protected string GetStatusCssClass(string statusValue)
        {
            switch (statusValue?.ToLowerInvariant()) { case "pending": return "status-pending"; case "completed": return "status-completed"; case "cancelled": return "status-cancelled"; case "failed": return "status-failed"; default: return "status-default"; }
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = Server.HtmlEncode(message); // Encode message to prevent XSS
            var iconControl = pnlMessage.FindControl("iconMessage") as HtmlGenericControl;
            if (isError)
            {
                pnlMessage.CssClass = "mb-4 p-4 rounded-md bg-red-50 border-l-4 border-red-400 text-red-700";
                if (iconControl != null) iconControl.Attributes["class"] = "fas fa-times-circle fa-fw mr-2 text-red-500";
            }
            else
            {
                pnlMessage.CssClass = "mb-4 p-4 rounded-md bg-green-50 border-l-4 border-green-400 text-green-700";
                if (iconControl != null) iconControl.Attributes["class"] = "fas fa-check-circle fa-fw mr-2 text-green-500";
            }
            pnlMessage.Visible = true;
        }

        // Checks if postback was caused by buttons INSIDE the gridview (Edit, Update, Cancel)
        private bool IsPostBackFromGridCommand()
        {
            Control control = null;
            string ctrlname = Page.Request.Params.Get("__EVENTTARGET");
            if (!string.IsNullOrEmpty(ctrlname))
            {
                control = Page.FindControl(ctrlname);
                if (control != null && control.NamingContainer is GridViewRow)
                {
                    return (control.ID == "lnkEditStatus" || control.ID == "lnkUpdateStatus" || control.ID == "lnkCancelUpdate");
                }
            }
            else
            {
                foreach (string ctl in Page.Request.Form)
                {
                    Control c = Page.FindControl(ctl);
                    if (c == null) continue;

                    var parent = c.NamingContainer;
                    while (parent != null)
                    {
                        if (parent is GridViewRow)
                        {
                            // Check if the control that caused postback is one of our grid buttons
                            if (c is LinkButton || c is Button || c is ImageButton)
                            {
                                string buttonId = c.ID;
                                if (buttonId == "lnkEditStatus" || buttonId == "lnkUpdateStatus" || buttonId == "lnkCancelUpdate")
                                {
                                    return true;
                                }
                            }
                            break; // Found GridViewRow, stop traversing up
                        }
                        parent = parent.NamingContainer;
                    }
                }
            }
            return false; // Default if no specific grid button found
        }
        #endregion
    }
}