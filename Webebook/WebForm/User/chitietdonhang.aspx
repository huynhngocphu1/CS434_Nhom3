<%@ Page Title="Chi Tiết Đơn Hàng" Language="C#" MasterPageFile="~/WebForm/User/User.Master" AutoEventWireup="true" CodeBehind="chitietdonhang.aspx.cs" Inherits="Webebook.WebForm.User.chitietdonhang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <style>
        /* Keep specific image style */
        .book-item-img-detail {
            width: 60px; /* Consistent width */
            height: 90px; /* Consistent height */
            object-fit: cover; /* Ensure image covers the area */
            border-radius: 0.25rem; /* slight rounding */
            border: 1px solid #e5e7eb; /* subtle border */
            flex-shrink: 0; /* Prevent shrinking in flex contexts */
            background-color: #f9fafb; /* Light background for placeholders */
        }

        /* Tooltip style - Keep as is */
       .truncate[title]:hover::after {
            content: attr(title);
            position: absolute;
            left: 0;
            top: 100%; /* Position below the element */
            z-index: 10;
            background: rgba(17, 24, 39, 0.9); /* Darker background */
            color: white;
            padding: 6px 10px; /* Slightly larger padding */
            border-radius: 4px; /* Slightly more rounded */
            font-size: 0.75rem; /* Smaller font size */
            line-height: 1.2;
            white-space: nowrap;
            margin-top: 6px; /* Increased margin */
            width: max-content; /* Fit content */
            max-width: 300px; /* Max width */
            pointer-events: none; /* Allow clicks through */
            box-shadow: 0 2px 5px rgba(0,0,0,0.2); /* Subtle shadow */
       }
       .truncate[title] {
           position: relative; /* Needed for absolute positioning of ::after */
           cursor: help; /* Indicate tooltip availability */
       }
       .truncate {
            display: inline-block;
            vertical-align: middle;
            max-width: 100%;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
       }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 py-10">
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 pb-4 border-b border-gray-200 gap-4">
             <h2 class="text-2xl lg:text-3xl font-semibold text-gray-800">Chi Tiết Đơn Hàng</h2>
             <asp:HyperLink ID="hlBackToHistory" runat="server" NavigateUrl="~/WebForm/User/lichsumuahang.aspx"
                 CssClass="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out whitespace-nowrap">
                 <i class="fas fa-arrow-left mr-2 text-gray-500"></i> Quay lại Lịch sử mua hàng
             </asp:HyperLink>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" Visible="false"></asp:Label> <%-- Keep message logic --%>

        <%-- Panel Thông tin đơn hàng --%>
        <asp:Panel ID="pnlOrderInfo" runat="server" Visible="true" CssClass="bg-white p-6 rounded-lg shadow-md border border-gray-200 mb-8">
            <h3 class="text-lg font-semibold text-gray-800 mb-5 pb-3 border-b border-gray-200">Thông tin đơn hàng</h3>
            <%-- Tailwind grid for order info --%>
            <dl class="grid grid-cols-[auto,1fr] gap-x-6 gap-y-3 text-sm">
                 <dt class="font-semibold text-gray-600">Mã đơn hàng:</dt>
                 <dd class="text-gray-800 font-medium"><asp:Label ID="lblIDDonHang" runat="server" CssClass="font-mono"></asp:Label></dd>

                 <dt class="font-semibold text-gray-600">Ngày đặt:</dt>
                 <dd class="text-gray-800"><asp:Label ID="lblNgayDat" runat="server"></asp:Label></dd>

                 <dt class="font-semibold text-gray-600">Trạng thái:</dt>
                 <dd><asp:Literal ID="ltrTrangThai" runat="server"></asp:Literal></dd>

                 <dt class="font-semibold text-gray-600">Thanh toán:</dt>
                 <dd class="text-gray-800"><asp:Label ID="lblPhuongThuc" runat="server"></asp:Label></dd>
            </dl>
        </asp:Panel>

         <%-- Panel Danh sách sản phẩm --%>
        <asp:Panel ID="pnlOrderItems" runat="server" Visible="true" CssClass="bg-white rounded-lg shadow-md border border-gray-200 overflow-hidden">
            <h3 class="text-lg font-semibold text-gray-800 p-6 border-b border-gray-200">Sản phẩm trong đơn hàng</h3>
            <div class="overflow-x-auto"> <%-- Make table scrollable on small screens --%>
                <asp:Repeater ID="rptOrderItems" runat="server">
                    <HeaderTemplate>
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <%-- Increased padding, adjusted widths --%>
                                    <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-[calc(40%+70px)]" colspan="2">Sản phẩm</th>
                                    <th scope="col" class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-[20%]">Đơn giá</th>
                                    <th scope="col" class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider w-[15%]">Số lượng</th>
                                    <th scope="col" class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-[25%]">Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200"> <%-- Subtle dividers --%>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr class="hover:bg-gray-50 transition duration-150 ease-in-out">
                            <%-- Image Cell --%>
                            <td class="px-4 py-3 align-middle" style="width: 70px;">
                                <asp:Image ID="imgBookCover" runat="server" CssClass="book-item-img-detail" ImageUrl='<%# GetBookImageUrl(Eval("DuongDanBiaSach")) %>' AlternateText='<%# Eval("TenSach") %>' />
                            </td>
                            <%-- Book Title Cell - Applied truncate class directly --%>
                            <td class="px-2 py-3 align-middle text-sm">
                                <span class="font-medium text-gray-900 truncate" title='<%# Eval("TenSach") %>'>
                                     <%# TruncateString(Eval("TenSach"), 60) %>
                                </span>
                                <%-- Optionally add author or other info here if available --%>
                                <%-- <span class="block text-xs text-gray-500">Tác giả: ...</span> --%>
                            </td>
                            <%-- Price, Quantity, Total Cells --%>
                            <td class="px-4 py-3 whitespace-nowrap text-right text-sm text-gray-600 align-middle"><%# FormatCurrency(Eval("Gia")) %></td>
                            <td class="px-4 py-3 whitespace-nowrap text-center text-sm text-gray-600 align-middle">x <%# Eval("SoLuong") %></td>
                            <td class="px-4 py-3 whitespace-nowrap text-right text-sm font-semibold text-gray-800 align-middle"><%# CalculateLineTotal(Eval("SoLuong"), Eval("Gia")) %></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                    <%-- Removed EmptyDataTemplate, using Panel below instead --%>
                </asp:Repeater>

                 <%-- Panel thông báo khi không có item --%>
                <asp:Panel ID="pnlNoOrderItemsMessage" runat="server" Visible="false">
                    <div class="text-center py-16 px-6"> <%-- Increased padding for emphasis --%>
                        <i class="fas fa-shopping-cart fa-3x text-gray-400 mb-4"></i> <%-- Slightly larger icon --%>
                        <p class="text-gray-500">Không có sản phẩm nào trong đơn hàng này.</p>
                    </div>
                </asp:Panel>
            </div> <%-- End overflow-x-auto --%>

            <%-- Tổng tiền cuối cùng --%>
            <div class="bg-gray-50 px-6 py-4 border-t border-gray-300 text-right">
                <span class="text-sm font-medium text-gray-600 uppercase mr-2">Tổng cộng:</span>
                <asp:Label ID="lblTongTienValue" runat="server" CssClass="text-lg font-bold text-gray-900"></asp:Label> <%-- Clearer emphasis --%>
            </div>
        </asp:Panel> <%-- Kết thúc pnlOrderItems --%>

    </div> <%-- Kết thúc container --%>
</asp:Content>