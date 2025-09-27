<%@ Page Title="Quản Lý Đánh Giá" Language="C#" MasterPageFile="~/WebForm/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyDanhGia.aspx.cs" Inherits="Webebook.WebForm.Admin.QuanLyDanhGia" %>
<%@ MasterType VirtualPath="~/WebForm/Admin/Admin.Master" %> <%-- Thêm dòng này để truy cập phương thức public của MasterPage nếu cần --%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.0/dist/chart.min.js"></script>
    <style>
        /* === Star Rating Edit Styles === */
        .star-rating-edit { display: inline-flex; flex-direction: row-reverse; justify-content: flex-end; }
        .star-rating-edit input[type="radio"] { display: none; }
        .star-rating-edit label { font-size: 1.8em; /* Slightly larger stars */ color: #d1d5db; /* gray-300 */ cursor: pointer; transition: color 0.2s ease-in-out; padding: 0 0.1em; }
        /* Checked state */
        .star-rating-edit input[type="radio"]:checked ~ label { color: #f59e0b; /* amber-500 */ }
        /* Hover state (affecting current and previous stars) */
        .star-rating-edit:hover label { color: #f59e0b; /* amber-500 */ }
        .star-rating-edit label:hover ~ label { color: #d1d5db; /* gray-300 - reset stars after the hovered one */ }
        .star-rating-edit:not(:hover) input[type="radio"]:checked ~ label { color: #f59e0b; /* amber-500 - ensure checked stays yellow when not hovering */ }

        /* === Tooltip for Truncated Text === */
        .truncate-comment[title]:hover::after {
            content: attr(title);
            position: absolute;
            left: 50%; /* Center the tooltip */
            transform: translateX(-50%); /* Center the tooltip */
            bottom: 110%; /* Position above the element */
            z-index: 10;
            background: rgba(17, 24, 39, 0.9); /* gray-900 */
            color: white;
            padding: 6px 10px;
            border-radius: 4px;
            font-size: 0.8rem;
            white-space: normal; /* Allow wrapping */
            width: max-content; /* Adjust width to content */
            max-width: 350px; /* Max width */
            pointer-events: none;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            opacity: 0; /* Start hidden for transition */
            visibility: hidden;
            transition: opacity 0.2s ease-in-out, visibility 0.2s ease-in-out;
        }
        .truncate-comment[title]:hover::after {
            opacity: 1;
            visibility: visible;
        }
        .truncate-comment[title] { position: relative; cursor: help; } /* Make parent relative */
        .truncate-comment { display: block; max-width: 300px; /* Adjust as needed */ white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        /* === Edit Panel Animation === */
        #<%= pnlEditReview.ClientID %> {
            opacity: 0;
            transform: translateY(15px) scale(0.98);
            transition: opacity 0.3s ease-out, transform 0.3s ease-out;
            will-change: opacity, transform; /* Performance hint */
        }
        #<%= pnlEditReview.ClientID %>.panel-visible {
            opacity: 1;
            transform: translateY(0) scale(1);
        }

        /* === Subtle Button Hover Effect === */
        .btn-hover-effect {
            transition: transform 0.2s ease-out, box-shadow 0.2s ease-out;
        }
        .btn-hover-effect:hover {
            transform: translateY(-2px) scale(1.03);
             box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
        }

         /* === GridView Row Hover === */
        #<%= gvReviews.ClientID %> tbody tr:hover {
             background-color: #f9fafb; /* gray-50 slightly lighter */
        }

    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mx-auto px-4 py-8">
        <h2 class="text-3xl font-bold text-gray-800 mb-6 border-b pb-3">Quản Lý & Thống Kê Đánh Giá</h2>
        <%-- Message Area --%>
        <asp:Panel ID="pnlAdminMessage" runat="server" Visible="false" CssClass="mb-4">
             <asp:Label ID="lblAdminMessage" runat="server" EnableViewState="false"></asp:Label>
        </asp:Panel>

        <%-- === SECTION 1: THỐNG KÊ (Will be hidden during edit) === --%>
        <asp:Panel ID="pnlStatistics" runat="server" CssClass="mb-8 transition-opacity duration-300 ease-in-out">
            <h3 class="text-xl font-semibold text-gray-700 mb-4">Tổng Quan</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-6">
                <%-- Card 1: Total Reviews --%>
                <div class="bg-white p-5 rounded-xl shadow-md border border-gray-200 text-center transform transition duration-300 hover:scale-105 hover:shadow-lg">
                    <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Tổng đánh giá</div>
                    <div class="mt-2 text-4xl font-semibold text-blue-600 flex items-center justify-center gap-2">
                         <i class="fas fa-comments text-2xl text-blue-400"></i>
                         <asp:Label ID="lblTotalReviews" runat="server" Text="0"></asp:Label>
                    </div>
                </div>
                 <%-- Card 2: Average Rating --%>
                <div class="bg-white p-5 rounded-xl shadow-md border border-gray-200 text-center transform transition duration-300 hover:scale-105 hover:shadow-lg">
                    <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Điểm TB</div>
                     <div class="mt-2 text-4xl font-semibold text-green-600 flex items-center justify-center gap-2">
                         <i class="fas fa-star text-3xl text-yellow-400"></i>
                         <asp:Label ID="lblOverallAverage" runat="server" Text="N/A"></asp:Label> <%-- Removed icon from C#, add here --%>
                    </div>
                </div>
                 <%-- Add more cards if needed --%>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <%-- Panel: Top Books --%>
                 <asp:Panel ID="pnlAveragePerBook" runat="server" Visible="false" CssClass="bg-white p-5 rounded-xl shadow-md border border-gray-200">
                    <h4 class="text-lg font-semibold text-gray-700 mb-3">Top Sách Theo Đánh Giá</h4>
                    <div class="max-h-72 overflow-y-auto text-sm custom-scrollbar"> <%-- Increased height, added custom scrollbar class if you have one --%>
                        <asp:Repeater ID="rptAveragePerBook" runat="server">
                            <HeaderTemplate><ul class="divide-y divide-gray-100"></HeaderTemplate>
                            <ItemTemplate>
                                <li class="py-2.5 flex justify-between items-center gap-3 hover:bg-gray-50 px-1 rounded">
                                    <span class="text-gray-800 truncate pr-2 flex-grow" title='<%# Server.HtmlEncode(Eval("TenSach").ToString()) %>'><%# TruncateString(Eval("TenSach"), 45) %></span> <%-- Use HtmlEncode for title --%>
                                    <span class="font-semibold text-amber-500 whitespace-nowrap flex-shrink-0 flex items-center gap-1">
                                        <%# Eval("AvgRating", "{0:N1}") %> <i class='fas fa-star fa-xs'></i>
                                        <span class="text-xs text-gray-400 ml-1 font-normal">(<%# Eval("ReviewCount") %> lượt)</span>
                                    </span>
                                </li>
                            </ItemTemplate>
                            <FooterTemplate></ul></FooterTemplate>
                         </asp:Repeater>
                    </div>
                </asp:Panel>
                <%-- Panel: Rating Chart --%>
                 <asp:Panel ID="pnlChart" runat="server" Visible="false" CssClass="bg-white p-5 rounded-xl shadow-md border border-gray-200">
                    <h4 class="text-lg font-semibold text-gray-700 mb-3">Phân Bố Điểm</h4>
                    <div class="relative h-72"><canvas id="ratingsChartCanvas"></canvas></div> <%-- Increased height --%>
                 </asp:Panel>
            </div>
        </asp:Panel>

        <%-- === SECTION 2: BỘ LỌC (Will be hidden during edit) === --%>
        <asp:Panel ID="pnlFilters" runat="server" CssClass="bg-gray-50 p-5 rounded-xl border border-gray-200 mb-6 shadow-sm transition-opacity duration-300 ease-in-out">
             <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                <div>
                    <label for="<%= txtSearchUserBook.ClientID %>" class="block text-sm font-medium text-gray-700 mb-1">Tìm Tên sách/Người dùng</label>
                    <div class="relative">
                         <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                           <i class="fas fa-search text-gray-400"></i>
                         </div>
                         <asp:TextBox ID="txtSearchUserBook" runat="server" CssClass="pl-10 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" placeholder="Nhập từ khóa..."></asp:TextBox>
                    </div>
                 </div>
                <div>
                    <label for="<%= ddlRatingFilter.ClientID %>" class="block text-sm font-medium text-gray-700 mb-1">Lọc theo điểm</label>
                     <asp:DropDownList ID="ddlRatingFilter" runat="server" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 bg-white"></asp:DropDownList>
                </div>
                <div class="flex gap-3 items-center justify-start md:justify-end pt-4 md:pt-0">
                    <asp:Button ID="btnSearch" runat="server" Text="Lọc" OnClick="btnSearch_Click" CssClass="btn-hover-effect inline-flex justify-center items-center px-5 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-indigo-500" />
                    <asp:Button ID="btnReset" runat="server" Text="Reset" OnClick="btnReset_Click" CausesValidation="false" CssClass="btn-hover-effect inline-flex justify-center items-center px-5 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-gray-400" />
                </div>
            </div>
        </asp:Panel>

        <%-- === SECTION 3: DANH SÁCH ĐÁNH GIÁ (Will be hidden during edit) === --%>
        <asp:Panel ID="pnlReviewList" runat="server" CssClass="bg-white shadow-md border border-gray-200 rounded-xl overflow-hidden transition-opacity duration-300 ease-in-out">
            <h3 class="text-xl font-semibold text-gray-700 p-5 border-b border-gray-200">Danh Sách Đánh Giá</h3>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvReviews" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                    AllowPaging="True" PageSize="10" DataKeyNames="IDDanhGia"
                    OnPageIndexChanging="gvReviews_PageIndexChanging"
                    OnRowCommand="gvReviews_RowCommand"
                    OnRowDeleting="gvReviews_RowDeleting"
                    EmptyDataText="<div class='text-center py-10 text-gray-500'><i class='fas fa-inbox fa-2x mb-2'></i><p>Không có đánh giá nào phù hợp.</p></div>" GridLines="None">
                    <HeaderStyle CssClass="bg-gray-100 text-xs font-semibold text-gray-600 uppercase tracking-wider" />
                    <RowStyle CssClass="bg-white text-sm" /> <%-- Removed hover here, handled by CSS --%>
                    <AlternatingRowStyle CssClass="bg-gray-50 text-sm" />
                    <PagerStyle CssClass="bg-gray-50 px-4 py-3 border-t border-gray-200 text-sm" HorizontalAlign="Right" />
                    <EmptyDataRowStyle CssClass="bg-white" /> <%-- Style wrapper for empty text --%>
                     <Columns>
                        <asp:BoundField DataField="IDDanhGia" HeaderText="ID" ItemStyle-CssClass="px-3 py-3 whitespace-nowrap text-xs text-gray-500 text-center" HeaderStyle-CssClass="px-3 py-3 text-center w-12" />

                         <asp:TemplateField HeaderText="Người dùng" HeaderStyle-CssClass="px-4 py-3 text-left">
                            <ItemTemplate><span class="font-medium text-gray-800"><%# Server.HtmlEncode(Eval("Ten")?.ToString() ?? "N/A") %></span></ItemTemplate>
                            <ItemStyle CssClass="px-4 py-3 whitespace-nowrap" />
                        </asp:TemplateField>

                         <asp:TemplateField HeaderText="Sách" HeaderStyle-CssClass="px-4 py-3 text-left">
                             <ItemTemplate><span class="text-gray-700 truncate-comment" title='<%# Server.HtmlEncode(Eval("TenSach").ToString()) %>'><%# Server.HtmlEncode(Eval("TenSach").ToString()) %></span></ItemTemplate>
                             <ItemStyle CssClass="px-4 py-3" />
                        </asp:TemplateField>

                         <asp:TemplateField HeaderText="Điểm" HeaderStyle-CssClass="px-4 py-3 text-center w-28">
                            <ItemTemplate><%# GetStarRatingHtml(Eval("Diem")) %></ItemTemplate>
                            <ItemStyle CssClass="px-4 py-3 whitespace-nowrap text-center" />
                        </asp:TemplateField>

                         <asp:TemplateField HeaderText="Nhận xét" HeaderStyle-CssClass="px-4 py-3 text-left min-w-[250px]">
                             <ItemTemplate><span class="text-gray-600 truncate-comment" title='<%# Server.HtmlEncode(Eval("NhanXet")?.ToString() ?? "") %>'><%# TruncateString(Eval("NhanXet"), 100) %></span></ItemTemplate>
                             <ItemStyle CssClass="px-4 py-3" />
                        </asp:TemplateField>

                         <asp:BoundField DataField="NgayDanhGia" HeaderText="Ngày" DataFormatString="{0:dd/MM/yy HH:mm}" ItemStyle-CssClass="px-4 py-3 whitespace-nowrap text-xs text-gray-500" HeaderStyle-CssClass="px-4 py-3 text-left" />

                        <asp:TemplateField HeaderText="Hành động" ItemStyle-CssClass="px-4 py-3 whitespace-nowrap text-right text-sm font-medium" HeaderStyle-CssClass="px-4 py-3 text-right">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditReview" CommandArgument='<%# Eval("IDDanhGia") %>' CssClass="text-indigo-600 hover:text-indigo-800 mr-3 transition duration-150 ease-in-out" ToolTip="Sửa"><i class="fas fa-pencil-alt fa-fw"></i></asp:LinkButton>
                                <asp:LinkButton ID="lnkDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("IDDanhGia") %>' CssClass="text-red-600 hover:text-red-800 transition duration-150 ease-in-out" ToolTip="Xóa"
                                    OnClientClick='return confirm("Xác nhận xóa đánh giá này?");' CausesValidation="false" UseSubmitBehavior="false"><i class="fas fa-trash-alt fa-fw"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </asp:Panel>

        <%-- === SECTION 4: PANEL SỬA ĐÁNH GIÁ (Initially hidden, animated on appear) === --%>
        <asp:Panel ID="pnlEditReview" runat="server" Visible="false" CssClass="mt-8 bg-white p-6 rounded-xl shadow-xl border border-gray-300 max-w-2xl mx-auto"> <%-- Use shadow-xl --%>
            <h3 class="text-xl font-semibold text-gray-800 mb-5 border-b pb-3">Chỉnh Sửa Đánh Giá</h3>
            <asp:HiddenField ID="hfEditReviewId" runat="server" />
            <div class="space-y-5"> <%-- Increased spacing --%>
                <div class="text-sm p-3 bg-gray-100 rounded-lg border border-gray-200">
                    <span class="font-medium text-gray-600">Người dùng:</span>
                    <asp:Label ID="lblEditUser" runat="server" CssClass="ml-2 text-gray-900 font-semibold"></asp:Label><br />
                    <span class="font-medium text-gray-600 mt-1 inline-block">Sách:</span>
                    <asp:Label ID="lblEditBook" runat="server" CssClass="ml-2 text-gray-900 font-semibold"></asp:Label>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Điểm đánh giá:</label> <%-- Increased margin --%>
                    <div class="star-rating-edit">
                        <%-- ASP.NET RadioButtonList doesn't easily allow styling individual labels like pure HTML/CSS expects for this pattern. --%>
                        <%-- We'll keep the RadioButtonList but apply the style via CSS targeting its structure. --%>
                        <%-- IMPORTANT: The CSS for star-rating-edit needs specific targeting if using RadioButtonList --%>
                         <asp:RadioButtonList ID="rblEditRating" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="star-rating-inner flex flex-row-reverse">
                             <%-- Add labels with 'for' attribute matching the radio input IDs generated by ASP.NET --%>
                             <%-- This is tricky with RadioButtonList. A Repeater might offer more control for perfect star CSS. --%>
                             <%-- Let's keep RadioButtonList and adjust CSS slightly if needed, or accept minor hover imperfections --%>
                              <asp:ListItem Value="5" Text="<i class='far fa-star'></i>" title="5 stars" CssClass="hidden"></asp:ListItem> <%-- Hide default text, use CSS pseudo-elements or adjacent labels if possible --%>
                              <asp:ListItem Value="4" Text="<i class='far fa-star'></i>" title="4 stars" CssClass="hidden"></asp:ListItem>
                              <asp:ListItem Value="3" Text="<i class='far fa-star'></i>" title="3 stars" CssClass="hidden"></asp:ListItem>
                              <asp:ListItem Value="2" Text="<i class='far fa-star'></i>" title="2 stars" CssClass="hidden"></asp:ListItem>
                              <asp:ListItem Value="1" Text="<i class='far fa-star'></i>" title="1 star" CssClass="hidden"></asp:ListItem>
                         </asp:RadioButtonList>
                         <%-- Fallback/Simplified star display - If the above is too complex, use the simple display and rely on backend validation --%>
                         <%-- Example: Replace RadioButtonList with 5 buttons/icons if needed --%>
                    </div>
                      <%-- Manual Label structure for better CSS control (alternative to RadioButtonList if needed) --%>
                      <div class="star-rating-edit" style="display:none;"> <%-- Hide this structure, only for example --%>
                          <input type="radio" id="star5" name="rating" value="5" /><label for="star5" title="5 stars"><i class="fas fa-star"></i></label>
                          <input type="radio" id="star4" name="rating" value="4" /><label for="star4" title="4 stars"><i class="fas fa-star"></i></label>
                          <input type="radio" id="star3" name="rating" value="3" /><label for="star3" title="3 stars"><i class="fas fa-star"></i></label>
                          <input type="radio" id="star2" name="rating" value="2" /><label for="star2" title="2 stars"><i class="fas fa-star"></i></label>
                          <input type="radio" id="star1" name="rating" value="1" /><label for="star1" title="1 star"><i class="fas fa-star"></i></label>
                      </div>
                    <asp:RequiredFieldValidator ID="rfvEditRating" runat="server" ControlToValidate="rblEditRating" InitialValue="" ErrorMessage="Vui lòng chọn điểm." CssClass="text-red-600 text-xs mt-1 block" Display="Dynamic" ValidationGroup="EditReviewGroup" />
                 </div>
                <div>
                    <label for="<%=txtEditComment.ClientID %>" class="block text-sm font-medium text-gray-700 mb-1">Nội dung nhận xét:</label>
                    <asp:TextBox ID="txtEditComment" runat="server" TextMode="MultiLine" Rows="5" CssClass="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"></asp:TextBox>
                 </div>
                <div class="flex justify-end gap-4 pt-5 border-t mt-5"> <%-- Increased gap and padding --%>
                    <asp:Button ID="btnSaveChanges" runat="server" Text="Lưu Thay Đổi" OnClick="btnSaveChanges_Click" CssClass="btn-hover-effect inline-flex justify-center py-2 px-6 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-green-500" ValidationGroup="EditReviewGroup" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Hủy Bỏ" OnClick="btnCancelEdit_Click" CausesValidation="false" CssClass="btn-hover-effect inline-flex justify-center py-2 px-6 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-gray-400" />
                </div>
            </div>
        </asp:Panel>

    </div> <%-- End Container --%>

     <%-- JavaScript for Edit Panel Animation --%>
     <script type="text/javascript">
         // Function to apply the visible class for animation
         function showEditPanelAnimated() {
             const panel = document.getElementById('<%= pnlEditReview.ClientID %>');
             if (panel) {
                 // Use setTimeout to ensure the transition happens after the element is rendered visible
                 setTimeout(() => {
                     panel.classList.add('panel-visible');
                 }, 50); // Small delay
             }
         }

         // Function to potentially remove the class (though server-side hide usually suffices)
         function hideEditPanelCleanup() {
              const panel = document.getElementById('<%= pnlEditReview.ClientID %>');
             if (panel) {
                 panel.classList.remove('panel-visible');
             }
         }

         // Ensure Chart.js chart is destroyed before re-creation on postback
         // (The C# code already does this, but good practice)
         function destroyChartIfExists() {
             if (window.ratingsChart instanceof Chart) {
                 window.ratingsChart.destroy();
             }
         }
         // If using UpdatePanels, you might need: Sys.WebForms.PageRequestManager.getInstance().add_endRequest(destroyChartIfExists);

     </script>

</asp:Content>