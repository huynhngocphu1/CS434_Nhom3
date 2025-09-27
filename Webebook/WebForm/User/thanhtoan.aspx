<%@ Page Title="Thanh Toán" Language="C#" MasterPageFile="~/WebForm/User/User.Master" AutoEventWireup="true" CodeBehind="thanhtoan.aspx.cs" Inherits="Webebook.WebForm.User.thanhtoan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" integrity="sha512-iecdLmaskl7CVkqkXNQ/ZH/XLlvWZOJyj7Yy7tcenmpD1ypASozpmT/E0iPtmFIB46ZmdtAc9eNBvH0H/ZpiBw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <%-- Tailwind CDN (Nếu bạn chưa tích hợp vào build process) --%>
    <%-- <script src="https://cdn.tailwindcss.com"></script> --%>
    <style>
        /* Custom Styles (bổ sung hoặc ghi đè Tailwind nếu cần) */

        /* Loading Overlay */
        #loadingOverlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-color: rgba(0, 0, 0, 0.6); /* Nền tối hơn chút */
            z-index: 9999;
            display: flex; justify-content: center; align-items: center; flex-direction: column;
            visibility: hidden; opacity: 0;
            transition: opacity 0.3s ease-in-out, visibility 0.3s ease-in-out; /* Smooth fade */
        }
        #loadingOverlay.visible { visibility: visible; opacity: 1; }
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3); /* Spinner trắng trên nền tối */
            width: 48px; height: 48px; border-radius: 50%;
            border-left-color: #ffffff; /* Màu nhấn trắng */
            animation: spin 1s ease infinite; margin-bottom: 16px;
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        #loadingOverlay p { color: #e5e7eb; font-weight: 600; font-size: 1.1rem; } /* Chữ trắng, to hơn */

        /* Payment Options - Styling cho label và hiệu ứng */
        .payment-option-item label {
            display: flex; align-items: center;
            padding: 1rem 1.25rem;
            border: 2px solid #e5e7eb; /* Border rõ hơn chút */
            border-radius: 0.5rem;
            cursor: pointer;
            transition: all 0.25s ease-out;
            width: 100%;
            background-color: #fff; /* Nền trắng */
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06); /* Shadow nhẹ */
        }
        .payment-option-item label:hover {
            background-color: #f9fafb;
            border-color: #9ca3af; /* Border đậm hơn khi hover */
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); /* Shadow rõ hơn khi hover */
        }
        /* Style khi radio được chọn (thông qua class 'selected' từ JS) */
        .payment-option-item.selected label {
            border-color: #3b82f6; /* Màu xanh dương */
            background-color: #eff6ff;
            font-weight: 600;
            color: #1d4ed8;
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.4); /* Ring effect */
        }
        /* Ẩn radio button gốc */
        .payment-option-item input[type="radio"] {
           position: absolute;
           opacity: 0;
           width: 0;
           height: 0;
        }
        .payment-option-item label i { width: 20px; text-align: center; margin-right: 0.75rem; }

        /* Payment Details Panel Transitions */
        .payment-details-panel {
            transition: opacity 0.3s ease-out, max-height 0.4s ease-out;
            overflow: hidden;
            max-height: 0; /* Bắt đầu ẩn */
            opacity: 0;
        }
        .payment-details-panel.visible {
            max-height: 1000px; /* Đủ lớn để chứa nội dung */
            opacity: 1;
            margin-top: 1rem; /* Thêm khoảng cách khi hiện ra */
        }

        /* Truncated Titles */
        .truncate-title {
            max-width: 100%;
            width: 250px; /* Tăng chiều rộng tối đa một chút */
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            display: inline-block; vertical-align: middle;
        }
        @media (max-width: 768px) { .truncate-title { width: 200px; } }
        @media (max-width: 640px) { .truncate-title { width: 150px; } }

        /* Responsive Adjustments */
        @media (max-width: 768px) {
            .container { padding-left: 1rem; padding-right: 1rem; } /* Tăng padding nhỏ */
            .md\:flex-row { flex-direction: column; }
            .md\:w-1\/2, .lg\:w-3\/5, .lg\:w-2\/5 { width: 100%; }
        }

        /* Style cho table */
        .order-summary-table th { background-color: #f9fafb; font-weight: 600; color: #4b5563;}
        .order-summary-table td { color: #374151; }
        .order-summary-table tbody tr:hover { background-color: #f3f4f6; } /* Hover nhẹ cho row */

        /* Style cho input fields */
        .form-input {
            margin-top: 0.25rem; display: block; width: 100%;
            padding: 0.75rem 1rem; /* Padding lớn hơn */
            border: 1px solid #d1d5db; border-radius: 0.375rem;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .form-input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3); /* Focus ring rõ hơn */
        }

    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="loadingOverlay">
        <div class="spinner"></div>
        <p>Đang xử lý đơn hàng...</p>
    </div>

    <div class="bg-gray-50 min-h-screen py-12"> <%-- Nền xám nhạt cho cả trang --%>
        <div class="container mx-auto px-4 lg:px-8">
            <h1 class="text-3xl lg:text-4xl font-bold text-gray-800 mb-8 text-center">Hoàn Tất Thanh Toán</h1>
            <asp:Label ID="lblMessage" runat="server" CssClass="block mb-6 text-sm p-4 rounded-lg border" EnableViewState="false" Visible="false"></asp:Label>

            <div class="flex flex-col lg:flex-row gap-8 lg:gap-12 mt-6">

                <asp:Panel ID="pnlOrderSummary" runat="server" CssClass="w-full lg:w-3/5 bg-white p-6 md:p-8 rounded-xl shadow-lg border border-gray-200">
                    <h2 class="text-2xl font-semibold text-gray-800 mb-6 border-b border-gray-200 pb-4">Thông Tin Đơn Hàng</h2>
                    <div class="overflow-x-auto">
                        <asp:Repeater ID="rptSelectedItems" runat="server">
                            <HeaderTemplate>
                                <table class="min-w-full divide-y divide-gray-200 text-sm order-summary-table">
                                    <thead class="sticky top-0"> <%-- Thêm class styling --%>
                                        <tr>
                                            <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sản Phẩm</th>
                                            <th scope="col" class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider hidden sm:table-cell">Số Lượng</th> <%-- Ẩn trên mobile --%>
                                            <th scope="col" class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Đơn giá</th>
                                            <th scope="col" class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody class="bg-white divide-y divide-gray-200">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td class="px-4 py-3 whitespace-normal font-medium text-gray-800" title='<%# HttpUtility.HtmlEncode(Eval("TenSach")) %>'>
                                        <span class="truncate-title"><%# TruncateString(Eval("TenSach"), 45) %></span>
                                        <span class="block sm:hidden text-xs text-gray-500 mt-1">SL: <%# Eval("SoLuong") %></span> <%-- Hiện SL trên mobile --%>
                                    </td>
                                    <td class="px-4 py-3 whitespace-nowrap text-gray-600 text-center hidden sm:table-cell"><%# Eval("SoLuong") %></td> <%-- Ẩn trên mobile --%>
                                    <td class="px-4 py-3 whitespace-nowrap text-gray-600 text-right"><%# FormatCurrency(Eval("DonGia")) %></td>
                                    <td class="px-4 py-3 whitespace-nowrap text-gray-700 text-right font-semibold"><%# FormatCurrency(Eval("ThanhTien")) %></td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                    <tfoot class="border-t-2 border-gray-300 bg-gray-50">
                                        <tr>
                                            <td colspan="<%# IsMobile() ? 2 : 3 %>" class="px-4 py-4 text-right text-base font-bold text-gray-800 uppercase">Tổng Cộng:</td> <%-- Điều chỉnh colspan responsive --%>
                                            <td class="px-4 py-4 text-right text-xl font-bold text-red-600"><%# FormatCurrency(this.GrandTotal) %></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                    <div class="mt-8"> <%-- Tăng khoảng cách --%>
                        <asp:HyperLink ID="hlBackToCart" runat="server" NavigateUrl="~/WebForm/User/giohang_user.aspx"
                            CssClass="inline-flex items-center px-5 py-2.5 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition ease-in-out duration-150"
                            Visible='<%# !this.IsBuyNowMode %>'>
                            <i class="fas fa-arrow-left mr-2"></i> Quay lại giỏ hàng
                        </asp:HyperLink>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlPaymentMethods" runat="server" CssClass="w-full lg:w-2/5 bg-white p-6 md:p-8 rounded-xl shadow-lg border border-gray-200">
                    <h2 class="text-2xl font-semibold text-gray-800 mb-6 border-b border-gray-200 pb-4">Chọn Phương Thức Thanh Toán</h2>
                    <%-- Container cho các Radio Button List Item - Quan trọng cho JS --%>
                    <div id="paymentOptionsContainer" class="space-y-4">
                         <asp:RadioButtonList ID="rblPaymentMethod" runat="server" RepeatLayout="Flow" RepeatDirection="Vertical"
                             CssClass="" CssItemClass="payment-option-item"
                             AutoPostBack="false"> <%-- ***** Bỏ AutoPostBack ***** --%>
                                <asp:ListItem Value="Bank" Selected="True">
                                    <i class='fas fa-university'></i> Chuyển khoản ngân hàng
                                </asp:ListItem>
                                <asp:ListItem Value="Card"> <%-- Value có chính xác là "Card" không? --%>
                                    <i class='fas fa-credit-card'></i> Thẻ ngân hàng (ATM/Visa/Mastercard)
                                </asp:ListItem>
                                <asp:ListItem Value="Wallet"> <%-- Value có chính xác là "Wallet" không? --%>
                                    <i class='fas fa-wallet'></i> Ví điện tử (Momo, ViettelPay, VNPay)
                                </asp:ListItem>
                         </asp:RadioButtonList>
                    </div>

                    <asp:Panel ID="pnlBankInfo" runat="server" CssClass="payment-details-panel p-5 border rounded-lg bg-blue-50 border-blue-200 space-y-3 text-sm"> <%-- Thêm class chung và styling --%>
                        <h4 class="font-semibold text-gray-800 mb-2 text-base">Thông tin chuyển khoản:</h4>
                        <p><strong>Ngân hàng:</strong> <span class="font-semibold text-blue-800">[MB Bank]</span></p>
                        <p><strong>Số tài khoản:</strong> <span class="font-semibold text-blue-800">[0376512695]</span> <button type="button" class="ml-2 text-blue-600 hover:text-blue-800 text-xs" onclick="copyToClipboard('0376512695')"><i class="far fa-copy"></i> Copy</button></p>
                        <p><strong>Chủ tài khoản:</strong> <span class="font-semibold text-blue-800">[Lam Chu Bao Toan]</span></p>
                        <p><strong>Nội dung CK:</strong> <span class="font-semibold text-red-600">TTDH [Mã đơn hàng]</span> <span class="text-xs text-gray-500">(Sẽ được cấp sau khi đặt)</span></p>
                        <div class="mt-4 text-center">
                            <img src="/Images/QR/placeholder-qr.png" alt="QR Code Chuyển khoản" class="mx-auto w-36 h-36 md:w-40 md:h-40 border-2 border-gray-300 shadow-md rounded-lg" />
                            <p class="text-xs text-gray-600 mt-2">Quét mã QR để thanh toán nhanh chóng</p>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlCardForm" runat="server" CssClass="payment-details-panel p-5 border rounded-lg bg-gray-50 border-gray-200 space-y-4 text-sm"> <%-- Thêm class chung và styling --%>
                        <h4 class="font-semibold text-gray-800 mb-2 text-base">Nhập thông tin thẻ:</h4>
                        <div>
                            <label for="<%=txtCardNumber.ClientID%>" class="block text-sm font-medium text-gray-700 mb-1">Số thẻ</label>
                            <asp:TextBox ID="txtCardNumber" runat="server" CssClass="form-input" placeholder="**** **** **** ****"></asp:TextBox>
                        </div>
                        <div>
                            <label for="<%=txtCardName.ClientID%>" class="block text-sm font-medium text-gray-700 mb-1">Tên chủ thẻ</label>
                            <asp:TextBox ID="txtCardName" runat="server" CssClass="form-input" placeholder="NGUYEN VAN A"></asp:TextBox>
                        </div>
                        <div class="flex flex-col sm:flex-row gap-4">
                            <div class="flex-1">
                                <label for="<%=txtCardExpiry.ClientID%>" class="block text-sm font-medium text-gray-700 mb-1">Ngày hết hạn</label>
                                <asp:TextBox ID="txtCardExpiry" runat="server" CssClass="form-input" placeholder="MM/YY"></asp:TextBox>
                            </div>
                            <div class="sm:w-1/3">
                                <label for="<%=txtCardCVV.ClientID%>" class="block text-sm font-medium text-gray-700 mb-1">CVV</label>
                                <asp:TextBox ID="txtCardCVV" runat="server" CssClass="form-input" placeholder="123" type="password" MaxLength="4"></asp:TextBox>
                            </div>
                        </div>
                         <p class="text-xs text-gray-500 mt-3"><i class="fas fa-lock mr-1 text-green-600"></i> Thông tin thẻ của bạn được mã hóa và bảo mật.</p>
                    </asp:Panel>

                    <asp:Panel ID="pnlWalletInfo" runat="server" CssClass="payment-details-panel p-5 border rounded-lg bg-yellow-50 border-yellow-200 space-y-4"> <%-- Thêm class chung và styling --%>
                        <h4 class="font-semibold text-gray-800 mb-3 text-base">Quét mã QR bằng ví điện tử:</h4>
                        <div class="flex flex-wrap justify-around items-center gap-4">
                            <div class="text-center flex-shrink-0 p-2">
                                <img src="/Images/Icons/momo-logo.png" alt="Momo" class="h-8 mx-auto mb-2" />
                                <img src="/Images/QR/placeholder-qr-momo.png" alt="QR Momo" class="w-32 h-32 border border-gray-300 shadow-sm rounded-md" />
                                <p class="text-xs text-gray-600 mt-1 font-medium">Momo</p>
                            </div>
                             <div class="text-center flex-shrink-0 p-2">
                                <img src="/Images/Icons/viettelmoney-logo.png" alt="Viettel Money" class="h-8 mx-auto mb-2" />
                                <img src="/Images/QR/placeholder-qr-viettelmoney.png" alt="QR Viettel Money" class="w-32 h-32 border border-gray-300 shadow-sm rounded-md" />
                                <p class="text-xs text-gray-600 mt-1 font-medium">Viettel Money</p>
                            </div>
                            <div class="text-center flex-shrink-0 p-2">
                                <img src="/Images/Icons/vnpay-logo.png" alt="VNPay" class="h-8 mx-auto mb-2" />
                                <img src="/Images/QR/placeholder-qr-vnpay.png" alt="QR VNPay" class="w-32 h-32 border border-gray-300 shadow-sm rounded-md" />
                                <p class="text-xs text-gray-600 mt-1 font-medium">VNPay</p>
                            </div>
                        </div>
                    </asp:Panel>


                    <div class="mt-10"> <%-- Tăng khoảng cách --%>
                        <asp:Button ID="btnXacNhan" runat="server" Text="Xác Nhận & Đặt Hàng"
                            CssClass="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 px-6 rounded-lg shadow-md hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-200 ease-in-out disabled:opacity-50 disabled:cursor-not-allowed"
                            OnClick="btnXacNhan_Click" OnClientClick="showProcessing(); return true;" />
                               <p class="text-xs text-gray-500 mt-3 text-center"><i class="fas fa-info-circle mr-1"></i> Bằng việc nhấn nút, bạn đồng ý với <a href="gioithieu.aspx#terms" class="text-indigo-600 hover:underline">Điều khoản dịch vụ</a>.</p>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

<script type="text/javascript">
    function showProcessing() {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) overlay.classList.add('visible');

        const button = document.getElementById('<%= btnXacNhan.ClientID %>');
            if (button && !button.disabled) {
                setTimeout(() => {
                    const currentButton = document.getElementById('<%= btnXacNhan.ClientID %>');
                     if (currentButton && !currentButton.disabled) {
                         currentButton.disabled = true;
                         //console.log('Button disabled');
                     }
                 }, 50);
        }
    }

    // Function to handle payment method change
    function handlePaymentMethodChange() {
        const paymentOptionsContainer = document.getElementById('paymentOptionsContainer');
        if (!paymentOptionsContainer) {
            console.error("Lỗi: Không tìm thấy container 'paymentOptionsContainer'.");
            return;
        }
        // Lấy ClientID thực tế từ ASP.NET
        const bankPanelId = '<%= pnlBankInfo.ClientID %>';
            const cardPanelId = '<%= pnlCardForm.ClientID %>';
            const walletPanelId = '<%= pnlWalletInfo.ClientID %>';

            const radios = paymentOptionsContainer.querySelectorAll('input[type="radio"]');
            const detailPanels = document.querySelectorAll('.payment-details-panel'); // Lấy tất cả panel chi tiết
            const listItems = paymentOptionsContainer.querySelectorAll('.payment-option-item');

            console.log("Khởi tạo handlePaymentMethodChange...");
            console.log("Panel IDs:", { bank: bankPanelId, card: cardPanelId, wallet: walletPanelId });
            console.log("Tìm thấy radios:", radios.length);
            console.log("Tìm thấy detail panels:", detailPanels.length);

            // --- Hàm cập nhật hiển thị ---
            const updatePanelVisibility = (selectedValue) => {
                console.log("Đang cập nhật cho lựa chọn:", selectedValue);

                // 1. Ẩn tất cả các panel chi tiết trước
                detailPanels.forEach(panel => {
                    panel.classList.remove('visible');
                    panel.style.maxHeight = '0'; // Đảm bảo ẩn hoàn toàn
                    panel.style.opacity = '0';
                    panel.style.marginTop = '0';
                });

                // 2. Xác định panel cần hiển thị dựa trên ClientID
                let panelIdToShow = null;
                if (selectedValue === 'Bank') panelIdToShow = bankPanelId;
                else if (selectedValue === 'Card') panelIdToShow = cardPanelId;
                else if (selectedValue === 'Wallet') panelIdToShow = walletPanelId;

                console.log("Panel ID cần hiển thị:", panelIdToShow);

                // 3. Hiển thị panel được chọn (nếu tìm thấy)
                if (panelIdToShow) {
                    const panelToShow = document.getElementById(panelIdToShow);
                    if (panelToShow) {
                        console.log("Đã tìm thấy panel:", panelToShow.id);
                        // Dùng setTimeout để đảm bảo trình duyệt có thời gian áp dụng style ẩn trước khi bắt đầu transition hiện
                        setTimeout(() => {
                            panelToShow.style.maxHeight = '1000px'; // Giá trị đủ lớn
                            panelToShow.style.opacity = '1';
                            panelToShow.style.marginTop = '1rem';
                            panelToShow.classList.add('visible'); // Thêm class để CSS target nếu cần
                            console.log("Panel đã được thiết lập để hiển thị:", panelToShow.id);
                        }, 10); // Delay nhỏ
                    } else {
                        console.error("Lỗi: Không tìm thấy element panel với ID:", panelIdToShow);
                    }
                }

                // 4. Cập nhật trạng thái 'selected' cho mục trong danh sách
                listItems.forEach(item => item.classList.remove('selected'));
                radios.forEach(r => {
                    if (r.value === selectedValue && r.checked) {
                        let parentItem = r.closest('.payment-option-item');
                        if (parentItem) {
                            parentItem.classList.add('selected');
                            console.log("Đã thêm class 'selected' cho:", parentItem);
                        }
                    }
                });
            };

            // --- Gắn sự kiện và xử lý trạng thái ban đầu ---
            radios.forEach(radio => {
                // Gắn sự kiện 'change'
                radio.addEventListener('change', function() {
                    if (this.checked) {
                        updatePanelVisibility(this.value);
                    }
                });

                // Xử lý trạng thái ban đầu khi tải trang
                if (radio.checked) {
                    console.log("Radio được chọn ban đầu:", radio.value);
                    updatePanelVisibility(radio.value);

                    // Đảm bảo panel ban đầu hiển thị ngay lập tức mà không bị ảnh hưởng bởi transition chậm
                    let initialPanelId = null;
                    if (radio.value === 'Bank') initialPanelId = bankPanelId;
                    else if (radio.value === 'Card') initialPanelId = cardPanelId;
                    else if (radio.value === 'Wallet') initialPanelId = walletPanelId;

                    if (initialPanelId) {
                        const initialPanel = document.getElementById(initialPanelId);
                        if (initialPanel) {
                            initialPanel.style.transition = 'none'; // Tạm tắt transition
                            initialPanel.style.maxHeight = '1000px';
                            initialPanel.style.opacity = '1';
                            initialPanel.style.marginTop = '1rem';
                            initialPanel.classList.add('visible');
                             console.log("Panel ban đầu được hiển thị ngay:", initialPanel.id);
                            // Bật lại transition sau một khoảng ngắn
                            setTimeout(() => { initialPanel.style.transition = ''; }, 50);
                        }
                    }
                }
            });
        }

        // Function to copy text to clipboard
        function copyToClipboard(text) {
            navigator.clipboard.writeText(text).then(() => {
                alert('Đã sao chép: ' + text);
            }).catch(err => {
                console.error('Không thể sao chép: ', err);
                alert('Lỗi khi sao chép!');
            });
        }


        // Execute when the DOM is fully loaded
        document.addEventListener('DOMContentLoaded', function () {
             console.log("Sự kiện DOMContentLoaded đã kích hoạt.");
             handlePaymentMethodChange(); // Khởi tạo và gắn sự kiện

             // --- Xử lý Overlay và Button sau PostBack (nếu có lỗi server) ---
             const overlay = document.getElementById('loadingOverlay');
             const messageLabel = document.getElementById('<%= lblMessage.ClientID %>'); // Lấy ClientID của Label thông báo
             const button = document.getElementById('<%= btnXacNhan.ClientID %>'); // Lấy ClientID của Button

            if (overlay && overlay.classList.contains('visible')) {
                overlay.classList.remove('visible');
                console.log('Overlay đã được ẩn (DOMContentLoaded)');
            }

            // Bật lại nút nếu nó bị disable bởi JS và có thông báo lỗi từ server hiển thị
            if (button && button.disabled) {
                // Kiểm tra xem Label thông báo có hiển thị và có nội dung không
                const isMessageVisible = messageLabel && messageLabel.offsetHeight > 0 && messageLabel.innerText.trim() !== '';
                if (isMessageVisible) {
                    button.disabled = false;
                    console.log('Nút Xác nhận đã được bật lại do có thông báo lỗi.');
                } else {
                    console.log('Nút Xác nhận vẫn bị disable (không có thông báo lỗi hiển thị).');
                }
            }
        });

    // Fallback for older browsers or specific cases
    window.addEventListener('load', function () {
        console.log("Sự kiện window.load đã kích hoạt.");
        const overlay = document.getElementById('loadingOverlay');
        if (overlay && overlay.classList.contains('visible')) {
            overlay.classList.remove('visible');
            console.log('Overlay đã được ẩn (window.load fallback)');
        }
        // Có thể thêm logic bật lại button ở đây nếu cần thiết làm fallback
    });

</script>
</asp:Content>