<%@ Page Title="Thanh Toán" Language="C#" MasterPageFile="~/WebForm/User/User.Master" AutoEventWireup="true" CodeBehind="thanhtoan.aspx.cs" Inherits="Webebook.WebForm.User.thanhtoan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        .payment-option-item label { display: flex; align-items: center; padding: 1rem 1.25rem; border: 2px solid #e5e7eb; border-radius: 0.5rem; cursor: pointer; transition: all 0.2s ease-out; width: 100%; background-color: #fff; box-shadow: 0 1px 2px 0 rgba(0,0,0,.05); }
        .payment-option-item label:hover { border-color: #9ca3af; }
        .payment-option-item.selected label { border-color: #3b82f6; background-color: #eff6ff; font-weight: 600; color: #1d4ed8; box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.4); }
        .payment-option-item input[type="radio"] { position: absolute; opacity: 0; width: 0; height: 0; }
        .payment-option-item label i { width: 20px; text-align: center; margin-right: 0.75rem; }
        .payment-details-panel { transition: opacity 0.3s ease-out, max-height 0.4s ease-out; overflow: hidden; max-height: 0; opacity: 0; }
        .payment-details-panel.visible { max-height: 1000px; opacity: 1; margin-top: 1rem; border-width: 1px; padding: 1.25rem; border-radius: 0.5rem; }
        .form-input { margin-top: 0.25rem; display: block; width: 100%; padding: 0.75rem 1rem; border: 1px solid #d1d5db; border-radius: 0.375rem; box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05); }
        .form-input:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3); }
        .order-summary-table th { background-color: #f9fafb; font-weight: 600; color: #4b5563;}
        .order-summary-table td { color: #374151; }

        @media (max-width: 640px) {
            .order-summary-table thead { display: none; }
            .order-summary-table, .order-summary-table tbody, .order-summary-table tr, .order-summary-table td { display: block; width: 100%; }
            .order-summary-table tr { padding: 1rem 0; border-bottom: 1px solid #e5e7eb; }
            .order-summary-table tbody tr:last-child { border-bottom: none; }
            .order-summary-table td { display: flex; justify-content: space-between; align-items: center; padding: 0.5rem 0.25rem; border: none; text-align: right; }
            .order-summary-table td::before { content: attr(data-label); font-weight: 600; color: #4b5563; text-align: left; margin-right: 1rem; }
            .order-summary-table td[data-label="Sản phẩm"] { flex-direction: column; align-items: flex-start; font-size: 1rem; font-weight: bold; margin-bottom: 0.5rem; }
            .order-summary-table td[data-label="Sản phẩm"]::before { display: none; }
            .order-summary-table tfoot tr, .order-summary-table tfoot td { display: flex; justify-content: space-between; align-items: center; width: 100%; padding: 1rem 0.25rem; }
            .order-summary-table tfoot .total-label { font-size: 1.125rem; font-weight: bold; text-transform: uppercase; color: #1f2937; }
            .order-summary-table tfoot .total-value { font-size: 1.25rem; font-weight: bold; color: #dc2626; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">    


    <div class="bg-gray-50 min-h-screen py-12">
        <div class="container mx-auto px-4 lg:px-8">
            <h1 class="text-3xl lg:text-4xl font-bold text-gray-800 mb-8 text-center">Hoàn Tất Thanh Toán</h1>
            
            <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

            <%-- *** SỬA LỖI: Bọc 2 Panel chính trong div flexbox này *** --%>
            <div class="flex flex-col lg:flex-row gap-8 lg:gap-12 mt-6">
                
                <%-- CỘT BÊN TRÁI: Tóm tắt đơn hàng --%>
                <asp:Panel ID="pnlOrderSummary" runat="server" CssClass="w-full lg:w-3/5 bg-white p-6 md:p-8 rounded-xl shadow-lg border">
                    <h2 class="text-2xl font-semibold text-gray-800 mb-6 border-b border-gray-200 pb-4">Thông Tin Đơn Hàng</h2>
                    <div class="overflow-x-auto">
                        <asp:Repeater ID="rptSelectedItems" runat="server">
                            <HeaderTemplate>
                                <table class="min-w-full text-sm order-summary-table">
                                    <thead class="bg-gray-50"><tr><th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sản Phẩm</th><th scope="col" class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Số Lượng</th><th scope="col" class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Đơn giá</th><th scope="col" class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Thành tiền</th></tr></thead>
                                    <tbody class="bg-white divide-y divide-gray-200 sm:divide-y-0">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td class="px-4 py-3 font-bold text-gray-800" data-label="Sản phẩm"><%# Eval("TenSach") %></td>
                                    <td class="px-4 py-3 text-gray-600 text-center" data-label="Số lượng"><%# Eval("SoLuong") %></td>
                                    <td class="px-4 py-3 text-gray-600 text-right" data-label="Đơn giá"><%# FormatCurrency(Eval("DonGia")) %></td>
                                    <td class="px-4 py-3 text-gray-700 text-right font-semibold" data-label="Thành tiền"><%# FormatCurrency(Eval("ThanhTien")) %></td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                    <tfoot class="border-t-2 border-gray-300 bg-gray-50">
                                        <tr>
                                            <td colspan="3" class="px-4 py-4 text-right text-base font-bold text-gray-800 uppercase total-label">Tổng Cộng:</td>
                                            <td class="px-4 py-4 text-right text-xl font-bold text-red-600 total-value"><%# FormatCurrency(this.GrandTotal) %></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                    <div class="mt-8">
                        <asp:HyperLink ID="hlBackToCart" runat="server" NavigateUrl="~/WebForm/User/giohang_user.aspx" CssClass="inline-flex items-center px-5 py-2.5 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-100" Visible='<%# !this.IsBuyNowMode %>'>
                            <i class="fas fa-arrow-left mr-2"></i> Quay lại giỏ hàng
                        </asp:HyperLink>
                    </div>
                </asp:Panel>

            <asp:Panel ID="pnlPaymentMethods" runat="server" CssClass="w-full lg:w-2/5 bg-white p-6 md:p-8 rounded-xl shadow-lg border">
                <h2 class="text-2xl font-semibold text-gray-800 mb-6 border-b pb-4">Chọn Phương Thức Thanh Toán</h2>
                <div id="paymentOptionsContainer" class="space-y-4">
                    <asp:RadioButtonList ID="rblPaymentMethod" runat="server" RepeatLayout="Flow" RepeatDirection="Vertical" CssClass="" CssItemClass="payment-option-item">
                        <asp:ListItem Value="BANK_TRANSFER" Selected="True"><i class='fas fa-university'></i> Chuyển khoản ngân hàng</asp:ListItem>
                        <asp:ListItem Value="CARD"><i class='fas fa-credit-card'></i> Thẻ Tín dụng/Ghi nợ</asp:ListItem>
                        <asp:ListItem Value="E_WALLET"><i class='fas fa-wallet'></i> Ví điện tử / Cổng thanh toán</asp:ListItem>
                    </asp:RadioButtonList>
                </div>

                <%-- SỬA LỖI: Đã xóa "Visible=false" khỏi các Panel dưới đây --%>

                <asp:Panel ID="pnlBankInfo" runat="server" CssClass="payment-details-panel bg-blue-50 border-blue-200 space-y-3 text-sm">
                    <h4 class="font-semibold text-gray-800 mb-2 text-base">Thông tin chuyển khoản:</h4>
                    <p><strong>Ngân hàng:</strong> <span class="font-semibold text-blue-800">MB Bank</span></p>
                    <p><strong>Số tài khoản:</strong> <span class="font-semibold text-blue-800">0376512695</span> <button type="button" class="ml-2 text-blue-600 hover:text-blue-800 text-xs" onclick="copyToClipboard('0376512695')"><i class="far fa-copy"></i> Copy</button></p>
                    <p><strong>Chủ tài khoản:</strong> <span class="font-semibold text-blue-800">Lam Chu Bao Toan</span></p>
                    <p><strong>Nội dung CK:</strong> <asp:Label ID="lblBankTransferContent" runat="server" CssClass="font-semibold text-red-600"></asp:Label></p>
                    <div class="mt-4 text-center">
                        <asp:Image ID="imgBankQR" runat="server" alt="QR Code Chuyển khoản" CssClass="mx-auto w-40 h-40 border-2 border-gray-300 shadow-md rounded-lg" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlCardForm" runat="server" CssClass="payment-details-panel bg-gray-50 border-gray-200 space-y-4 text-sm">
                    <h4 class="font-semibold text-gray-800 mb-2 text-base">Thông tin thẻ:</h4>
                    <p class="text-xs text-gray-500">Chức năng này sẽ được tích hợp với cổng thanh toán. Đây là giao diện mẫu.</p>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Số thẻ</label>
                        <asp:TextBox ID="txtCardNumber" runat="server" CssClass="form-input" placeholder="**** **** **** ****"></asp:TextBox>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Tên chủ thẻ</label>
                        <asp:TextBox ID="txtCardName" runat="server" CssClass="form-input" placeholder="NGUYEN VAN A"></asp:TextBox>
                    </div>
                    <div class="flex flex-col sm:flex-row gap-4">
                        <div class="flex-1">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Ngày hết hạn</label>
                            <asp:TextBox ID="txtCardExpiry" runat="server" CssClass="form-input" placeholder="MM/YY"></asp:TextBox>
                        </div>
                        <div class="sm:w-1/3">
                            <label class="block text-sm font-medium text-gray-700 mb-1">CVV</label>
                            <asp:TextBox ID="txtCardCVV" runat="server" CssClass="form-input" placeholder="123" type="password" MaxLength="4"></asp:TextBox>
                        </div>
                    </div>
               </asp:Panel>

                <asp:Panel ID="pnlWalletInfo" runat="server" CssClass="payment-details-panel bg-green-50 border-green-200">
                    <h4 class="font-semibold text-gray-800 mb-3 text-base">Chọn nhà cung cấp:</h4>
                    <asp:RadioButtonList ID="rblEWalletProvider" runat="server" RepeatLayout="Flow" RepeatDirection="Vertical" CssClass="space-y-3">
                       <asp:ListItem Value="VNPAY" Selected="True">
                           <div class="flex items-center"><img src="/Images/Icons/vnpay-logo.png" class="h-6 mr-3"/><span>Cổng VNPAY</span></div>
                       </asp:ListItem>
                       <asp:ListItem Value="MOMO"  >
                           <div class="flex items-center"><img src="/Images/Icons/momo-logo.png" class="h-6 mr-3"/><span>Ví MoMo</span></div>
                       </asp:ListItem>
                    </asp:RadioButtonList>
                </asp:Panel>

                   <div class="mt-10">
                        <asp:Button ID="btnXacNhan" runat="server" Text="Xác Nhận & Đặt Hàng" OnClick="btnXacNhan_Click" OnClientClick="showProcessing(); return true;" CssClass="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 px-6 rounded-lg"/>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>


    <script type="text/javascript">
        function copyToClipboard(text) {
            navigator.clipboard.writeText(text).then(() => {
                Swal.fire({ title: 'Đã sao chép!', text: text, icon: 'success', timer: 1500, showConfirmButton: false });
            });
        }
        function handlePaymentMethodChange() {
            const container = document.getElementById('paymentOptionsContainer');
            if (!container) return;
            const radios = container.querySelectorAll('input[type="radio"]');
            const panels = {
                'BANK_TRANSFER': document.getElementById('<%= pnlBankInfo.ClientID %>'),
                'CARD': document.getElementById('<%= pnlCardForm.ClientID %>'),
                'E_WALLET': document.getElementById('<%= pnlWalletInfo.ClientID %>')
            };
            const updateVisibility = (selectedValue) => {
                Object.values(panels).forEach(panel => {
                    if (panel) panel.classList.remove('visible');
                });
                if (panels[selectedValue]) {
                    panels[selectedValue].classList.add('visible');
                }
                radios.forEach(r => {
                    const parentItem = r.closest('.payment-option-item');
                    if (parentItem) {
                        parentItem.classList.toggle('selected', r.value === selectedValue);
                    }
                });
            };
            radios.forEach(radio => radio.addEventListener('change', () => updateVisibility(radio.value)));
            const checkedRadio = container.querySelector('input[type="radio"]:checked');
            if (checkedRadio) {
                updateVisibility(checkedRadio.value);
            }
        }
        document.addEventListener('DOMContentLoaded', handlePaymentMethodChange);
    </script>
</asp:Content>