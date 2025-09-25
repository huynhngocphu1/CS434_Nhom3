<%@ Page Title="Xác Nhận Đơn Hàng" Language="C#" MasterPageFile="~/WebForm/User/User.Master" AutoEventWireup="true" CodeBehind="xacnhandonhang.aspx.cs" Inherits="Webebook.WebForm.User.xacnhandonhang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <%-- Font Awesome nếu muốn dùng icon --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <style>
        /* Có thể thêm CSS tùy chỉnh nếu cần */
        .details-grid {
            display: grid;
            grid-template-columns: auto 1fr; /* Cột label tự động, cột value chiếm phần còn lại */
            gap: 0.5rem 1rem; /* Khoảng cách giữa hàng và cột */
            align-items: center;
        }

        .details-grid dt { /* Label (ví dụ: ID Đơn Hàng:) */
            font-weight: 600; /* semibold */
            color: #4b5563; /* gray-600 */
            text-align: right;
        }

         .details-grid dd { /* Value (ví dụ: 18) */
            font-weight: 500; /* medium */
             color: #1f2937; /* gray-800 */
         }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mx-auto px-4 py-12">

        <%-- Thông báo thành công/lỗi --%>
        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" Visible="false"></asp:Label>

        <%-- Panel chứa chi tiết đơn hàng, chỉ hiển thị khi load thành công --%>
<asp:Panel ID="pnlOrderDetails" runat="server" Visible="false"
    CssClass="max-w-2xl mx-auto bg-white p-6 sm:p-8 rounded-xl shadow-lg border border-gray-200 text-center">

    <%-- Vùng chứa icon (sẽ được điều khiển hiển thị) --%>
    <div class="text-center mb-5">
        <asp:Panel ID="pnlSuccessIcon" runat="server">
            <i class="fas fa-check-circle text-5xl text-green-500"></i>
        </asp:Panel>
        <asp:Panel ID="pnlFailureIcon" runat="server" Visible="false">
            <i class="fas fa-times-circle text-5xl text-red-500"></i>
        </asp:Panel>
    </div>

    <%-- Tiêu đề và thông báo (sẽ được gán text từ code-behind) --%>
    <h2 class="text-2xl font-bold text-gray-800 mb-3">
        <asp:Label ID="lblOrderStatusTitle" runat="server"></asp:Label>
    </h2>
    <p class="text-gray-600 mb-6">
        <asp:Label ID="lblOrderStatusMessage" runat="server"></asp:Label>
    </p>

    <%-- Bảng chi tiết đơn hàng (giữ nguyên) --%>
    <div class="details-grid text-sm sm:text-base text-left max-w-md mx-auto border-t border-b border-gray-200 py-4 my-4">
        <dt>ID Đơn Hàng:</dt>
        <dd><asp:Label ID="lblIDDonHang" runat="server" CssClass="select-all"></asp:Label></dd>
        <dt>Ngày Đặt:</dt>
        <dd><asp:Label ID="lblNgayDat" runat="server"></asp:Label></dd>
        <dt>Tổng Tiền:</dt>
        <dd class="font-bold text-red-600"><asp:Label ID="lblTongTien" runat="server"></asp:Label></dd>
        <dt>Thanh Toán:</dt>
        <dd><asp:Label ID="lblPhuongThuc" runat="server"></asp:Label></dd>
    </div>

    <%-- Các nút hành động --%>
    <div class="mt-8 space-x-4">
        <asp:HyperLink ID="hlBackToHome" runat="server"
            NavigateUrl="~/WebForm/User/usertrangchu.aspx"
            CssClass="inline-flex items-center justify-center px-6 py-3 border border-transparent rounded-md shadow-sm text-base font-medium text-white bg-blue-600 hover:bg-blue-700">
            <i class="fas fa-home mr-2"></i> Quay Về Trang Chủ
        </asp:HyperLink>
        
        <%-- *** THAY ĐỔI NÚT NÀY *** --%>
        <asp:HyperLink ID="hlViewHistory" runat="server" Visible="false"
            NavigateUrl="~/WebForm/User/lichsumuahang.aspx"
            CssClass="inline-flex items-center justify-center px-6 py-3 border border-gray-300 rounded-md shadow-sm text-base font-medium text-gray-700 bg-white hover:bg-gray-50">
            <i class="fas fa-history mr-2"></i> Xem Lịch sử mua hàng
        </asp:HyperLink>
    </div>
</asp:Panel>

    </div> <%-- Kết thúc container --%>

</asp:Content>