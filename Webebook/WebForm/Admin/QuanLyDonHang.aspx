<%@ Page Title="Quản Lý Đơn Hàng" Language="C#" MasterPageFile="~/WebForm/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyDonHang.aspx.cs" Inherits="Webebook.WebForm.Admin.QuanLyDonHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <%-- Font Awesome (nên đặt trong MasterPage) --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <%-- Flatpickr CSS cho Date Picker --%>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <style>
        /* Các lớp tiện ích Tailwind nên xử lý hầu hết mọi thứ */
        .form-label {
            @apply block text-sm font-medium text-gray-700 mb-1;
        }
        .form-input,
        .form-select {
             /* Nhất quán focus ring */
            @apply mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm;
        }
        .btn { /* Lớp cơ sở cho nút (áp dụng cho cả a và button) */
             @apply inline-flex items-center justify-center py-2 px-4 border shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 transition duration-150 ease-in-out no-underline; /* Thêm no-underline cho LinkButton */
        }
        .btn-primary { /* Nút chính (Áp dụng) */
            @apply border-transparent text-white bg-indigo-600 hover:bg-indigo-700 focus:ring-indigo-500;
        }
        .btn-secondary { /* Nút phụ (Đặt lại) */
             @apply border-gray-300 text-gray-700 bg-white hover:bg-gray-50 focus:ring-indigo-500;
        }
        /* Tailwind styles for Status Badges */
        .status-badge {
            @apply inline-block px-2.5 py-0.5 text-xs font-semibold rounded-full leading-tight;
        }
        .status-pending { @apply bg-yellow-100 text-yellow-800; }
        .status-completed { @apply bg-green-100 text-green-800; }
        .status-cancelled { @apply bg-red-100 text-red-800; }
        .status-failed { @apply bg-gray-200 text-gray-700; }
        .status-default { @apply bg-gray-100 text-gray-600; }

        .flatpickr-calendar {
            z-index: 1050 !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h2 class="text-3xl font-bold leading-tight text-gray-900 mb-6">Quản Lý Đơn Hàng</h2>

        <%-- Khu vực thông báo --%>
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert" class="mb-4 p-4 rounded-md">
             <div class="flex">
                 <div class="py-1">
                     <i id="iconMessage" runat="server" class="fas fa-fw mr-2"></i>
                 </div>
                 <div>
                     <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>
                 </div>
             </div>
        </asp:Panel>

        <%-- Khu vực lọc --%>
        <div class="bg-gradient-to-br from-indigo-50 via-white to-indigo-50 shadow-lg rounded-lg p-6 mb-8 border border-indigo-100">
             <h3 class="text-xl font-semibold leading-7 text-indigo-800 mb-5 border-b border-indigo-200 pb-3 flex items-center">
                 <i class="fas fa-filter mr-3 text-indigo-600 fa-fw"></i>
                 <span>Bộ Lọc Đơn Hàng</span>
             </h3>
             <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-4 items-end">

                 <div class="md:col-span-1">
                     <label for="<%= ddlFilterStatus.ClientID %>" class="form-label">Trạng Thái TT</label>
                     <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="FilterChanged">
                         <asp:ListItem Text="-- Tất cả --" Value=""></asp:ListItem>
                         <asp:ListItem Text="Chờ" Value="Pending"></asp:ListItem>
                         <asp:ListItem Text="Hoàn thành" Value="Completed"></asp:ListItem>
                         <asp:ListItem Text="Bị hủy bỏ" Value="Cancelled"></asp:ListItem>
                         <asp:ListItem Text="Thất bại" Value="Failed"></asp:ListItem>
                     </asp:DropDownList>
                 </div>

                 <div class="md:col-span-1">
                     <label for="<%= ddlFilterPaymentMethod.ClientID %>" class="form-label">Phương thức TT</label>
                     <asp:DropDownList ID="ddlFilterPaymentMethod" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="FilterChanged">
                         <asp:ListItem Text="-- Tất cả --" Value=""></asp:ListItem>
                         <asp:ListItem Text="COD" Value="COD"></asp:ListItem>
                         <asp:ListItem Text="Chuyển khoản ngân hàng" Value="Bank"></asp:ListItem>
                         <asp:ListItem Text="Thẻ ngân hàng" Value="Card"></asp:ListItem>
                         <asp:ListItem Text="Ví điện tử" Value="EWallet"></asp:ListItem>
                     </asp:DropDownList>
                 </div>

                 <div class="md:col-span-1">
                     <label for="txtFilterStartDate" class="form-label">Từ Ngày Đặt</label>
                     <asp:TextBox ID="txtFilterStartDate" runat="server" CssClass="form-input" placeholder="dd/MM/yyyy" ClientIDMode="Static"></asp:TextBox>
                 </div>

                 <div class="md:col-span-1">
                     <label for="txtFilterEndDate" class="form-label">Đến Ngày Đặt</label>
                     <asp:TextBox ID="txtFilterEndDate" runat="server" CssClass="form-input" placeholder="dd/MM/yyyy" ClientIDMode="Static"></asp:TextBox>
                 </div>

                 <%-- Khu vực nút bấm --%>
                 <div class="md:col-span-4 flex justify-end items-center mt-2">
                      <div class="flex items-center space-x-3">
                          <asp:LinkButton ID="btnResetFilter" runat="server"
                              CssClass="btn btn-secondary w-full sm:w-auto"
                              OnClick="ResetFilter_Click" CausesValidation="false" ToolTip="Xóa các bộ lọc đã nhập">
                              <i class="fas fa-undo fa-fw mr-1.5" aria-hidden="true"></i>Đặt lại
                          </asp:LinkButton>
                          <asp:LinkButton ID="btnApplyFilter" runat="server"
                              CssClass="btn btn-primary w-full sm:w-auto"
                              OnClick="ApplyFilter_Click" ToolTip="Áp dụng các bộ lọc">
                             <i class="fas fa-check fa-fw mr-1.5" aria-hidden="true"></i>Áp Dụng
                          </asp:LinkButton>
                      </div>
                 </div>

             </div> <%-- End Grid --%>
        </div> <%-- End Filter Section --%>

        <%-- Khu vực GridView --%>
        <div class="bg-white shadow-md overflow-hidden sm:rounded-lg border border-gray-200">
            <div class="overflow-x-auto">
                <asp:GridView ID="GridViewDonHang" runat="server" AutoGenerateColumns="False" DataKeyNames="IDDonHang,IDNguoiDung" CssClass="min-w-full divide-y divide-gray-200"
                    OnRowCommand="GridViewDonHang_RowCommand" AllowPaging="True" PageSize="15" OnPageIndexChanging="GridViewDonHang_PageIndexChanging" OnRowDataBound="GridViewDonHang_RowDataBound">
                    <HeaderStyle CssClass="bg-gray-100" Font-Bold="true" />
                    <RowStyle CssClass="bg-white hover:bg-indigo-50 transition duration-150 ease-in-out" />
                    <AlternatingRowStyle CssClass="bg-gray-50 hover:bg-indigo-50 transition duration-150 ease-in-out" />
                    <PagerStyle CssClass="bg-gray-100 px-4 py-3 border-t border-gray-200 text-right" HorizontalAlign="Right" />

                    <EmptyDataTemplate>
                        <div class="text-center py-12 px-6">
                             <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                                 <path vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m-9 1V7a2 2 0 012-2h10l4 4v10a2 2 0 01-2 2H4a2 2 0 01-2-2z" />
                             </svg>
                             <h3 class="mt-2 text-sm font-medium text-gray-900">Không có đơn hàng</h3>
                             <p class="mt-1 text-sm text-gray-500">Không tìm thấy đơn hàng nào phù hợp với bộ lọc hiện tại.</p>
                         </div>
                    </EmptyDataTemplate>

                    <Columns>
                        <asp:BoundField DataField="IDDonHang" HeaderText="ID ĐH" ReadOnly="True" SortExpression="IDDonHang"
                            HeaderStyle-CssClass="px-4 py-3.5 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider w-16"
                            ItemStyle-CssClass="whitespace-nowrap px-4 py-4 text-sm text-gray-500 font-medium" />

                        <asp:TemplateField HeaderText="Người Đặt" SortExpression="TenNguoiDung"
                            HeaderStyle-CssClass="px-4 py-3.5 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider min-w-[180px]">
                            <ItemTemplate>
                                <div class="font-medium text-gray-900 truncate" title='<%# Eval("TenNguoiDung") %>'>
                                    <%# Eval("TenNguoiDung") %>
                                </div>
                                <div class="text-gray-500 text-xs">ID: <%# Eval("IDNguoiDung") %></div>
                            </ItemTemplate>
                            <ItemStyle CssClass="px-4 py-4 text-sm"/>
                        </asp:TemplateField>

                        <asp:BoundField DataField="NgayDat" HeaderText="Ngày Đặt" DataFormatString="{0:dd/MM/yyyy HH:mm}" SortExpression="NgayDat"
                            HeaderStyle-CssClass="px-4 py-3.5 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider"
                            ItemStyle-CssClass="whitespace-nowrap px-4 py-4 text-sm text-gray-500" />

                        <asp:BoundField DataField="SoTien" HeaderText="Tổng Tiền" DataFormatString="{0:N0} VNĐ" SortExpression="SoTien"
                            HeaderStyle-CssClass="px-4 py-3.5 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider"
                            ItemStyle-CssClass="whitespace-nowrap px-4 py-4 text-sm text-gray-600 text-right font-semibold" />

                         <asp:TemplateField HeaderText="PT Thanh Toán" SortExpression="PhuongThucThanhToan"
                              HeaderStyle-CssClass="px-4 py-3.5 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              <ItemTemplate>
                                   <%# GetPaymentMethodText(Eval("PhuongThucThanhToan")?.ToString()) %>
                              </ItemTemplate>
                             <ItemStyle CssClass="whitespace-nowrap px-4 py-4 text-sm text-gray-500" />
                          </asp:TemplateField>

                        <asp:TemplateField HeaderText="Trạng Thái TT" SortExpression="TrangThaiThanhToan"
                            HeaderStyle-CssClass="px-4 py-3.5 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider"
                            ItemStyle-CssClass="px-4 py-4 text-sm text-gray-500">
                            <ItemTemplate>
                                <span class='status-badge <%# GetStatusCssClass(Eval("TrangThaiThanhToan")?.ToString()) %>'>
                                    <%# GetStatusText(Eval("TrangThaiThanhToan")?.ToString()) %>
                                </span>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlTrangThai" runat="server" SelectedValue='<%# Bind("TrangThaiThanhToan") %>' CssClass="form-select py-1 text-sm w-full">
                                    <asp:ListItem Text="Chờ" Value="Pending"></asp:ListItem>
                                    <asp:ListItem Text="Hoàn thành" Value="Completed"></asp:ListItem>
                                    <asp:ListItem Text="Bị hủy bỏ" Value="Cancelled"></asp:ListItem>
                                    <asp:ListItem Text="Thất bại" Value="Failed"></asp:ListItem>
                                </asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <%-- Cột Hành Động - Đã cập nhật với nút Xóa --%>
                        <asp:TemplateField HeaderText="Hành Động"
                            HeaderStyle-CssClass="px-6 py-3.5 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider"
                            ItemStyle-CssClass="whitespace-nowrap px-6 py-4 text-right text-sm font-medium">
                            <ItemTemplate>
                                <div class="flex justify-end items-center space-x-4">
                                    <asp:HyperLink ID="hlViewDetails" runat="server"
                                        NavigateUrl='<%# ResolveUrl("~/WebForm/Admin/ChiTietDonHang_Admin.aspx?IDDonHang=") + Eval("IDDonHang") %>'
                                        CssClass="text-gray-500 hover:text-indigo-700 transition duration-150 ease-in-out"
                                        ToolTip="Xem chi tiết">
                                        <i class="fas fa-eye fa-fw text-base" aria-hidden="true"></i>
                                    </asp:HyperLink>

                                    <asp:LinkButton ID="lnkEditStatus" runat="server" CommandName="EditStatus" CommandArgument='<%# Container.DataItemIndex %>'
                                        CssClass="text-gray-500 hover:text-blue-700 transition duration-150 ease-in-out" ToolTip="Sửa trạng thái">
                                        <i class="fas fa-pencil-alt fa-fw text-base" aria-hidden="true"></i>
                                    </asp:LinkButton>

                                    <%-- === NÚT XÓA ĐÃ THÊM === --%>
                                    <asp:LinkButton ID="lnkDeleteOrder" runat="server" CommandName="DeleteOrder" CommandArgument='<%# Eval("IDDonHang") %>'
                                        CssClass="text-red-500 hover:text-red-700 transition duration-150 ease-in-out" ToolTip="Xóa đơn hàng"
                                        OnClientClick="return confirm('Bạn có chắc chắn muốn xóa đơn hàng này không? Các chi tiết liên quan cũng sẽ bị xóa và hành động này không thể hoàn tác.');">
                                        <i class="fas fa-trash-alt fa-fw text-base" aria-hidden="true"></i>
                                    </asp:LinkButton>
                                    <%-- === KẾT THÚC NÚT XÓA === --%>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <div class="flex justify-end items-center space-x-4">
                                    <asp:LinkButton ID="lnkUpdateStatus" runat="server" CommandName="UpdateStatus" CommandArgument='<%# Eval("IDDonHang") %>'
                                        CssClass="text-green-600 hover:text-green-800 transition duration-150 ease-in-out" ToolTip="Lưu thay đổi">
                                         <i class="fas fa-check fa-fw text-base" aria-hidden="true"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="lnkCancelUpdate" runat="server" CommandName="CancelUpdate" CommandArgument='<%# Container.DataItemIndex %>'
                                        CausesValidation="false"
                                        CssClass="text-red-500 hover:text-red-700 transition duration-150 ease-in-out" ToolTip="Hủy">
                                         <i class="fas fa-times fa-fw text-base" aria-hidden="true"></i>
                                    </asp:LinkButton>
                                </div>
                            </EditItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div> <%-- End GridView Section --%>
    </div> <%-- End Container --%>

     <%-- Flatpickr JS --%>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://npmcdn.com/flatpickr/dist/l10n/vn.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            flatpickr("#txtFilterStartDate", { dateFormat: "d/m/Y", locale: "vn", allowInput: true });
            flatpickr("#txtFilterEndDate", { dateFormat: "d/m/Y", locale: "vn", allowInput: true });
        });
        // Optional: Re-init if using UpdatePanels
        // function pageLoad(sender, args) { ... }
    </script>
</asp:Content>