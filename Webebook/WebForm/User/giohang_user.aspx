<%@ Page Title="Giỏ Hàng" Language="C#" MasterPageFile="~/WebForm/User/User.Master" AutoEventWireup="true" CodeBehind="giohang_user.aspx.cs" Inherits="Webebook.WebForm.User.giohang_user" %>
<%@ Import Namespace="System.Data" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
    /* ================================== */
    /* ==   GENERAL & DESKTOP STYLES   == */
    /* ================================== */
    #<%= gvGioHang.ClientID %> {
        width: 100%;
        border-collapse: collapse;
        border-spacing: 0 0.5rem;
    }
    #<%= gvGioHang.ClientID %> th,
    #<%= gvGioHang.ClientID %> td {
        padding: 1rem 1.25rem;
        vertical-align: middle;
        text-align: left;
    }
    #<%= gvGioHang.ClientID %> th {
        background-color: transparent;
        color: #6B7280;
        font-size: 0.875rem;
        font-weight: 500;
        text-transform: none;
        letter-spacing: normal;
        border-bottom: 1px solid #E5E7EB;
    }
    .gridview-row {
         border-bottom: 1px solid #E5E7EB;
    }
    .gridview-row:hover {
        background-color: #F9FAFB;
    }
    .item-checkbox, .header-checkbox {
        width: 1.25rem;
        height: 1.25rem;
        accent-color: #4F46E5;
    }
    .product-image {
        width: 60px;
        height: 90px;
        object-fit: cover;
        border-radius: 0.375rem;
        background-color: #F3F4F6;
    }
    .book-title-link {
        color: #1F2937;
        font-weight: 600;
        text-decoration: none;
        transition: color 0.15s ease-in-out;
        display: inline-block;
        max-width: 350px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        vertical-align: middle;
    }
    .book-title-link:hover {
        color: #4F46E5;
    }
    .gv-col-delete a {
        display: inline-block;
        border: 1px solid #D1D5DB;
        padding: 0.375rem 1rem;
        border-radius: 0.375rem;
        color: #4B5563;
        font-size: 0.875rem;
        text-decoration: none;
        background-color: #fff;
        transition: all 0.2s ease-in-out;
    }
    .gv-col-delete a:hover {
        border-color: #9CA3AF;
        background-color: #F9FAFB;
    }
    .gv-col-delete .fa-trash-alt {
        display: none;
    }
    .gv-col-delete a::before {
        content: 'Xóa';
    }
    #<%= btnThanhToan.ClientID %> {
        border: none;
        color: white;
        font-weight: 600;
        padding: 0.75rem 1.5rem;
        border-radius: 0.375rem;
        background-image: linear-gradient(to right, #4338CA , #6D28D9);
        transition: all 0.2s ease-in-out;
        box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
    }
    #<%= btnThanhToan.ClientID %>:hover {
        box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
        filter: brightness(1.1);
    }
     #<%= btnThanhToan.ClientID %>:disabled {
        background-image: none;
        background-color: #9CA3AF;
        cursor: not-allowed;
        box-shadow: none;
     }

    /* ==================================================== */
    /* ==   REVISED MOBILE STYLES (Layout theo ảnh mới)  == */
    /* ==================================================== */
    @media (max-width: 640px) {
        #<%= gvGioHang.ClientID %> thead {
            display: none;
        }

        #<%= gvGioHang.ClientID %>, #<%= gvGioHang.ClientID %> tbody {
            display: block;
            width: 100%;
        }

        /* 1. Dùng CSS Grid với 3 cột để sắp xếp layout */
        #<%= gvGioHang.ClientID %> tr {
            display: grid;
            /* Cột 1: Giá (linh hoạt) | Cột 2: Nút xóa (auto) | Cột 3: Ảnh (cố định) */
            grid-template-columns: 1fr auto 90px;
            grid-template-rows: auto auto; /* Hàng 1: Tên sách | Hàng 2: Footer */
            column-gap: 0.75rem; /* Giảm khoảng cách cột */
            position: relative;
            padding: 1rem;
            padding-top: 3rem; /* Chừa không gian cho checkbox */
            margin-bottom: 1.5rem;
            border: 1px solid #E5E7EB;
            border-radius: 0.5rem;
        }

        /* 2. Reset style và sắp xếp các ô (TD) vào grid */
        #<%= gvGioHang.ClientID %> td {
            display: flex;
            padding: 0;
            border: none;
            align-items: center; /* Căn giữa theo chiều dọc */
        }
        
        /* Checkbox (TD 1) - Định vị tuyệt đối ở góc trên bên phải */
        #<%= gvGioHang.ClientID %> td:nth-child(1) {
            position: absolute;
            top: 0.75rem;
            right: 0.75rem;
        }

        /* Ảnh Bìa (TD 2) - Nằm ở cột 3, chiếm cả 2 hàng */
        #<%= gvGioHang.ClientID %> td:nth-child(2) {
            grid-column: 3 / 4;
            grid-row: 1 / 3;
        }
        #<%= gvGioHang.ClientID %> td:nth-child(2) .product-image {
            width: 100%;
            height: auto;
        }

        /* Tên Sách (TD 3) - Nằm ở hàng 1, chiếm 2 cột đầu */
        #<%= gvGioHang.ClientID %> td:nth-child(3) {
            grid-column: 1 / 3;
            grid-row: 1 / 2;
            align-items: flex-start; /* Căn lên trên */
            padding-bottom: 1rem; /* Khoảng cách với footer */
        }
        /* Giới hạn tên sách trong 3 dòng */
        #<%= gvGioHang.ClientID %> td:nth-child(3) .book-title-link {
            white-space: normal;
            text-align: left;
            max-width: 100%;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;  
            overflow: hidden;
            line-height: 1.4;
        }

        /* Giá Sách (TD 4) - Nằm ở hàng 2, cột 1 */
        #<%= gvGioHang.ClientID %> td:nth-child(4) {
            grid-column: 1 / 2;
            grid-row: 2 / 3;
            align-items: flex-end; /* Căn xuống dưới */
        }
        #<%= gvGioHang.ClientID %> td:nth-child(4) {
            font-weight: 600;
            font-size: 1.1rem;
            color: #1F2937;
        }

        /* Nút Xóa (TD 5) - Nằm ở hàng 2, cột 2 */
        #<%= gvGioHang.ClientID %> td:nth-child(5) {
            grid-column: 2 / 3;
            grid-row: 2 / 3;
            align-items: flex-end; /* Căn xuống dưới */
        }
        /* Style lại nút xóa thành icon */
        #<%= gvGioHang.ClientID %> td:nth-child(5) a {
            background: none; border: none; padding: 0;
        }
        #<%= gvGioHang.ClientID %> td:nth-child(5) a::before {
            content: none;
        }
        #<%= gvGioHang.ClientID %> td:nth-child(5) .fa-trash-alt {
            display: inline-block;
            font-size: 1.25rem;
            color: #6B7280;
        }
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mx-auto px-4 lg:px-8 py-8">
        <h2 class="text-3xl font-semibold text-gray-800 mb-6 border-b pb-4">Giỏ Hàng Của Bạn</h2>

        <asp:Label ID="lblMessage" runat="server" CssClass="block mb-4 text-sm p-3 rounded-md" EnableViewState="false" Visible="false"></asp:Label>

        <asp:Panel ID="pnlCart" runat="server" Visible="false">
            <div class="bg-white shadow-md rounded-lg overflow-x-auto mb-8 border border-gray-200">
                <%-- The RowDataBound event in your C# code-behind is now necessary for the mobile view --%>
                <asp:GridView ID="gvGioHang" runat="server"
                    AutoGenerateColumns="False"
                    DataKeyNames="IDGioHang,IDSach"
                    CssClass="min-w-full"
                    GridLines="None"
                    OnRowCommand="gvGioHang_RowCommand"
                    OnRowDataBound="gvGioHang_RowDataBound" 
                    EmptyDataText="<div class='text-center py-10 text-gray-500'>Giỏ hàng của bạn đang trống.</div>">
                    <HeaderStyle CssClass="bg-gray-100 border-b border-gray-200 text-gray-500" />
                    <RowStyle CssClass="border-b border-gray-200 gridview-row" />
                    <AlternatingRowStyle CssClass="border-b border-gray-200 gridview-row bg-gray-50" />
                    <EmptyDataRowStyle CssClass="border-t border-gray-200" />
                    <Columns>
                        <%-- Your existing TemplateFields go here. No changes needed inside the <Columns> tag. --%>
                        <%-- The C# code-behind will handle the mobile layout adjustments. --%>
                         <asp:TemplateField HeaderStyle-CssClass="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider gv-col-checkbox">
                            <HeaderTemplate>
                                <div class="flex justify-center">
                                    <asp:CheckBox ID="chkHeader" runat="server" ToolTip="Chọn/Bỏ chọn tất cả" CssClass="header-checkbox form-checkbox"/>
                                </div>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <div class="flex justify-end items-center w-full">
                                    <asp:CheckBox ID="chkSelect" runat="server" CssClass="item-checkbox form-checkbox"/>
                                </div>
                            </ItemTemplate>
                            <ItemStyle CssClass="px-4 py-3 text-center"/>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Ảnh Bìa" HeaderStyle-CssClass="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider gv-col-image">
                            <ItemTemplate>
                                <div class="flex justify-center items-center py-2">
                                    <asp:HyperLink ID="hlProductImage" runat="server" CssClass="product-link"
                                        NavigateUrl='<%# string.Format("~/WebForm/User/chitietsach_user.aspx?IDSach={0}", Eval("IDSach")) %>'
                                        ToolTip='<%# "Xem chi tiết " + Eval("TenSach") %>'>
                                        <asp:Image ID="imgProduct" runat="server" CssClass="product-image"
                                            ImageUrl='<%# Eval("DuongDanBiaSach") != DBNull.Value && !string.IsNullOrEmpty(Eval("DuongDanBiaSach").ToString()) ? ResolveUrl(Eval("DuongDanBiaSach").ToString()) : ResolveUrl("~/Images/placeholder_cover.png") %>'
                                            AlternateText='<%# Eval("TenSach") %>' />
                                    </asp:HyperLink>
                                </div>
                            </ItemTemplate>
                            <ItemStyle CssClass="px-4 py-3"/>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Tên Sách" HeaderStyle-CssClass="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider gv-col-name">
                            <ItemTemplate>
                                <div class="flex justify-start items-center w-full">
                                    <asp:HyperLink ID="hlTenSach" runat="server" CssClass="book-title-link text-sm"
                                        NavigateUrl='<%# string.Format("~/WebForm/User/chitietsach_user.aspx?IDSach={0}", Eval("IDSach")) %>'
                                        Text='<%# Eval("TenSach") %>'
                                        ToolTip='<%# "Xem chi tiết " + Eval("TenSach") %>' />
                                </div>
                            </ItemTemplate>
                            <ItemStyle CssClass="px-6 py-3"/>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Giá Sách (VNĐ)" HeaderStyle-CssClass="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider gv-col-price">
                            <ItemTemplate>
                                <div class="flex justify-end items-center w-full">
                                    <asp:Label ID="lblDonGia" runat="server"
                                        CssClass="item-price-display text-sm font-medium text-gray-700"
                                        Text='<%# string.Format("{0:N0} VNĐ", Convert.ToDecimal(Eval("GiaSach"))) %>'></asp:Label>
                                </div>
                            </ItemTemplate>
                            <ItemStyle CssClass="px-6 py-3 whitespace-nowrap text-sm font-medium text-gray-700 text-right"/>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Xóa" HeaderStyle-CssClass="px-6 py-3 text-center text-xs font-medium uppercase tracking-wider gv-col-delete">
                            <ItemTemplate>
                                <div class="flex justify-end items-center w-full">
                                <asp:LinkButton ID="lnkXoa" runat="server" CommandName="Xoa"
                                    CommandArgument='<%# Eval("IDGioHang") %>'
                                    CssClass="text-gray-400 hover:text-red-500 transition duration-150 ease-in-out" ToolTip="Xóa khỏi giỏ hàng">
                                    <i class="fas fa-trash-alt fa-fw text-base"></i>
                                </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                            <ItemStyle CssClass="px-6 py-3 text-center"/>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <%-- Summary and Checkout Button (No Change) --%>
            <div class="mt-6 flex flex-col sm:flex-row justify-between items-center bg-white p-5 rounded-lg shadow-sm border border-gray-200">
                <div class="text-lg sm:text-xl text-gray-700 mb-3 sm:mb-0 total-section">
                    <span>Tổng cộng (<asp:Label ID="lblSelectedItemCount" runat="server" Text="0"></asp:Label> chọn): </span>
                    <asp:Label ID="lblSelectedTotal" runat="server" Text="0 VNĐ" CssClass="text-red-600 font-bold"></asp:Label>
                </div>
                <asp:Button ID="btnThanhToan" runat="server" Text="Tiến Hành Thanh Toán"
                    CssClass="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2.5 px-6 rounded-md shadow hover:shadow-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-150 ease-in-out disabled:opacity-60 disabled:bg-gray-400 disabled:cursor-not-allowed disabled:shadow-none"
                    OnClick="btnThanhToan_Click" Enabled="false" />
            </div>
        </asp:Panel>

        <%-- Empty Cart Panel (No Change) --%>
        <asp:Panel ID="pnlEmptyCart" runat="server" Visible="true" CssClass="text-center py-16 bg-white rounded-lg shadow-md border border-gray-200">
            <i class="fas fa-shopping-cart fa-3x text-gray-400 mb-4"></i>
            <p class="text-gray-500 text-lg mb-5">Giỏ hàng của bạn hiện đang trống.</p>
            <asp:HyperLink runat="server" NavigateUrl="~/WebForm/User/usertrangchu.aspx" Text="Tiếp tục mua sắm"
                CssClass="inline-block bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-5 rounded-md transition duration-150 ease-in-out shadow"/>
        </asp:Panel>
    </div>


    <%-- JavaScript không thay đổi --%>
    <script type="text/javascript">
        // Các hàm JavaScript hiện có: formatCurrency, updateTotalAndCheckoutButtonState, initializeCartEvents
        function formatCurrency(value) {
            const numberValue = Number(value);
            if (isNaN(numberValue)) { return "0 VNĐ"; }
            return numberValue.toLocaleString('vi-VN') + " VNĐ";
        }

        function updateTotalAndCheckoutButtonState() {
            let selectedTotal = 0;
            let selectedCount = 0;
            let itemSelected = false;
            const gridView = document.getElementById('<%= gvGioHang.ClientID %>');
            const checkoutButton = document.getElementById('<%= btnThanhToan.ClientID %>');
            const totalLabel = document.getElementById('<%= lblSelectedTotal.ClientID %>');
            const countLabel = document.getElementById('<%= lblSelectedItemCount.ClientID %>');
            let headerCheckboxInput = null;

            if (!gridView || !checkoutButton || !totalLabel || !countLabel) {
                console.error("Cart elements missing!");
                return;
            }

            const headerCheckboxElement = gridView.querySelector('th .header-checkbox');
            if (headerCheckboxElement) {
                headerCheckboxInput = headerCheckboxElement.querySelector('input[type=checkbox]');
                if (!headerCheckboxInput) headerCheckboxInput = headerCheckboxElement;
            }

            const itemCheckboxInputs = gridView.querySelectorAll('.item-checkbox input[type=checkbox], input.item-checkbox');
            let allItemsChecked = true;

            itemCheckboxInputs.forEach(checkboxInput => {
                const row = checkboxInput.closest('tr');
                let priceElement = row ? row.querySelector('[data-price]') : checkboxInput.closest('[data-price]');
                if (!priceElement) {
                    // Fallback to find the checkbox's parent div which now holds the data-price
                    const parentDiv = checkboxInput.closest('div[data-price]');
                    if (parentDiv) priceElement = parentDiv;
                    else priceElement = checkboxInput;
                }

                const priceString = priceElement.getAttribute('data-price') || '0';
                const price = parseFloat(priceString) || 0;

                if (checkboxInput.checked) {
                    selectedTotal += price;
                    selectedCount++;
                    itemSelected = true;
                } else {
                    allItemsChecked = false;
                }
            });

            totalLabel.textContent = formatCurrency(selectedTotal);
            countLabel.textContent = selectedCount;
            checkoutButton.disabled = !itemSelected;

            if (headerCheckboxInput) {
                headerCheckboxInput.checked = itemCheckboxInputs.length > 0 && allItemsChecked;
            }
        }

        function initializeCartEvents() {
            const gridView = document.getElementById('<%= gvGioHang.ClientID %>');
            if (!gridView) {
                console.warn('GridView not found on init.');
                return;
            }

            const headerCheckboxElement = gridView.querySelector('th .header-checkbox');
            if (headerCheckboxElement) {
                const headerCheckboxInput = headerCheckboxElement.querySelector('input[type=checkbox]') || headerCheckboxElement;
                if (headerCheckboxInput) {
                    headerCheckboxInput.addEventListener('change', function () {
                        const isChecked = headerCheckboxInput.checked;
                        const itemInputs = gridView.querySelectorAll('.item-checkbox input[type=checkbox], input.item-checkbox');
                        itemInputs.forEach(itemInput => {
                            if (!itemInput.disabled) {
                                itemInput.checked = isChecked;
                            }
                        });
                        updateTotalAndCheckoutButtonState();
                    });
                } else { console.warn('Header checkbox INPUT not found!'); }
            } else { console.warn('Header checkbox element not found!'); }

            const itemCheckboxInputs = gridView.querySelectorAll('.item-checkbox input[type=checkbox], input.item-checkbox');
            itemCheckboxInputs.forEach(checkboxInput => {
                checkboxInput.addEventListener('change', function () {
                    updateTotalAndCheckoutButtonState();
                });
            });

            updateTotalAndCheckoutButtonState();
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializeCartEvents);
        } else {
            initializeCartEvents();
        }
        if (typeof (Sys) !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(initializeCartEvents);
        }

        // ==================== BẮT ĐẦU: THÊM HÀM POPUP XÓA ====================
        function showCartItemDeleteConfirmation(cartItemId, bookTitle, sourceControlUniqueId) {
            Swal.fire({
                title: 'Xóa sách khỏi giỏ hàng?',
                html: `Bạn có chắc chắn muốn xóa sách<br><strong>${bookTitle}</strong>`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#6b7280',
                confirmButtonText: '<i class="fas fa-trash-alt"></i> Đồng ý, Xóa!',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Nếu xác nhận, trigger postback để server thực thi lệnh xóa
                    __doPostBack(sourceControlUniqueId, '');
                }
            });
        }
        // ==================== KẾT THÚC: THÊM HÀM POPUP XÓA ====================
    </script>
</asp:Content>