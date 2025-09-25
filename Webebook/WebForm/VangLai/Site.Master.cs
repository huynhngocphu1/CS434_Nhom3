// Webebook/WebForm/VangLai/Site.Master.cs
using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls; // Thêm nếu TextBox, Button chưa được nhận diện

namespace Webebook.WebForm.VangLai
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Có thể thêm logic nếu cần
        }

        // Webebook/WebForm/VangLai/Site.Master.cs

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // Ưu tiên lấy từ ô search chính, nếu rỗng thì lấy từ mobile
            string searchTerm = txtSearch.Text.Trim();
            if (string.IsNullOrEmpty(searchTerm) && txtSearchMobile != null)
            {
                searchTerm = txtSearchMobile.Text.Trim();
            }

            // Logic mới: Luôn luôn chuyển trang, kể cả khi searchTerm là chuỗi rỗng ""
            Response.Redirect($"~/WebForm/VangLai/timkiem.aspx?q={HttpUtility.UrlEncode(searchTerm)}", false);
            Context.ApplicationInstance.CompleteRequest(); // Ngăn lỗi "Thread was being aborted."
        }
    }
}