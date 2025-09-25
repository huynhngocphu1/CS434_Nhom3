<%@ Page Title="Quên Mật Khẩu" Language="C#" MasterPageFile="~/WebForm/VangLai/Site.Master" AutoEventWireup="true" CodeBehind="quenmatkhau.aspx.cs" Inherits="Webebook.WebForm.VangLai.quenmatkhau" %>



    <%-- Các thẻ link và style giữ nguyên --%>
<asp:Content ID="Content4" ContentPlaceHolderID="HeadContent" runat="server">
    <%-- Font Awesome nếu cần cho icon --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <style>
        /* CSS cho hiệu ứng modal - Đã sửa lỗi chặn click */
        #popupMaXacNhan {
            transition: opacity 0.3s ease-out;
        }
        #popupMaXacNhan .modal-content {
            transition: transform 0.3s ease-out, opacity 0.3s ease-out;
        }

        /* Trạng thái ẩn: Quan trọng là display: none */
        #popupMaXacNhan.modal-hidden {
            display: none;
            opacity: 0;
        }

        /* Trạng thái hiện */
        #popupMaXacNhan.modal-visible {
            display: flex; /* Hoặc block */
            opacity: 1;
        }
        /* Áp dụng transform/opacity cho nội dung khi hiện */
        #popupMaXacNhan.modal-visible .modal-content {
           opacity: 1;
           transform: translateY(0) scale(1);
        }
        /* Đặt transform/opacity ban đầu cho nội dung trước khi hiện */
        #popupMaXacNhan .modal-content {
           opacity: 0;
           transform: translateY(-20px) scale(0.95);
        }

        /* Đảm bảo nội dung trang không bị scroll khi modal mở */
        body.modal-open {
            overflow: hidden;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="min-h-screen flex items-center justify-center bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8">
            
            <%-- ==================== BẮT ĐẦU SỬA LỖI ==================== --%>
            <asp:Panel ID="pnlRequestContainer" runat="server" DefaultButton="btnGui">
                <div id="divRequestEmail" runat="server" class="bg-white p-8 md:p-10 rounded-2xl shadow-xl space-y-6">
                    <div>
                        <h2 class="text-center text-3xl font-extrabold text-gray-900">Quên Mật Khẩu</h2>
                        <p class="mt-2 text-center text-sm text-gray-600">Nhập email hoặc tên đăng nhập của bạn.</p>
                    </div>
                    <asp:Label ID="lblMessage" runat="server" EnableViewState="false" Visible="false"></asp:Label>
                    <div class="rounded-md shadow-sm -space-y-px">
                        <div>
                            <label for="<%=txtEmailOrUsername.ClientID%>" class="sr-only">Email hoặc Tên đăng nhập</label>
                            <asp:TextBox ID="txtEmailOrUsername" runat="server" TextMode="SingleLine" CssClass="appearance-none rounded-md relative block w-full px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" placeholder="Địa chỉ Email hoặc Tên đăng nhập"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmailOrUsername" ErrorMessage="Vui lòng nhập email hoặc tên đăng nhập." CssClass="text-red-600 text-xs mt-1 block" Display="Dynamic" ValidationGroup="RequestGroup"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="flex items-center justify-between">
                        <asp:Button ID="btnGui" runat="server" Text="Gửi Yêu Cầu" CssClass="group relative flex-grow justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out disabled:bg-indigo-300 disabled:cursor-not-allowed" OnClick="btnGui_Click" ValidationGroup="RequestGroup" />
                        <span id="countdownTimer" class="ml-4 text-sm font-medium text-gray-500"></span>
                    </div>
                    <p class="mt-4 text-center text-sm text-gray-600">
                        Nhớ mật khẩu? <a href="dangnhap.aspx" class="font-medium text-indigo-600 hover:text-indigo-500 hover:underline">Đăng nhập ngay</a>
                    </p>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlResetContainer" runat="server" DefaultButton="btnXacNhan">
                <div id="divResetPassword" runat="server" class="bg-white p-8 md:p-10 rounded-2xl shadow-xl space-y-6" visible="false">
                    <div>
                        <h2 class="text-center text-3xl font-extrabold text-gray-900">Đặt Lại Mật Khẩu</h2>
                        <p class="mt-2 text-center text-sm text-gray-600">Nhập mã xác nhận đã được gửi tới email của bạn.</p>
                    </div>
                    <asp:Label ID="lblResetMessage" runat="server" EnableViewState="false" Visible="false"></asp:Label>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                        <asp:Label ID="lblDisplayEmail" runat="server" CssClass="block w-full px-3 py-3 bg-gray-100 border border-gray-300 rounded-md text-gray-600 sm:text-sm"></asp:Label>
                    </div>
                    
                    <%-- Các ô nhập liệu --%>
                    <div>
                        <label for="<%=txtMaXacNhan.ClientID%>" class="block text-sm font-medium text-gray-700 mb-1">Mã Xác Nhận</label>
                        <asp:TextBox ID="txtMaXacNhan" runat="server" CssClass="appearance-none rounded-md relative block w-full px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" placeholder="Nhập mã gồm 4 chữ số"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCode" runat="server" ControlToValidate="txtMaXacNhan" ErrorMessage="Vui lòng nhập mã xác nhận." CssClass="text-red-600 text-xs mt-1 block" Display="Dynamic" ValidationGroup="ResetGroup"></asp:RequiredFieldValidator>
                    </div>
                    <div>
                        <label for="<%=txtMatKhauMoi.ClientID%>" class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu mới</label>
                        <div class="relative">
                            <asp:TextBox ID="txtMatKhauMoi" runat="server" TextMode="Password" CssClass="appearance-none rounded-md relative block w-full px-3 pr-10 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" placeholder="Tối thiểu 6 ký tự"></asp:TextBox>
                            <div class="absolute inset-y-0 right-0 pr-3 flex items-center"><span id="toggleNewPassword" class="cursor-pointer text-gray-500 hover:text-indigo-600"><i class="fas fa-eye"></i></span></div>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtMatKhauMoi" ErrorMessage="Vui lòng nhập mật khẩu mới." CssClass="text-red-600 text-xs mt-1 block" Display="Dynamic" ValidationGroup="ResetGroup"></asp:RequiredFieldValidator>
                        <asp:RegularExpressionValidator ID="revPasswordLength" runat="server" ControlToValidate="txtMatKhauMoi" ErrorMessage="Mật khẩu phải có ít nhất 6 ký tự." ValidationExpression=".{6,}" Display="Dynamic" CssClass="text-red-600 text-xs mt-1 block" ValidationGroup="ResetGroup" />
                    </div>
                    <div>
                        <label for="<%=txtXacNhanMatKhau.ClientID%>" class="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu</label>
                        <div class="relative">
                            <asp:TextBox ID="txtXacNhanMatKhau" runat="server" TextMode="Password" CssClass="appearance-none rounded-md relative block w-full px-3 pr-10 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm" placeholder="Nhập lại mật khẩu mới"></asp:TextBox>
                            <div class="absolute inset-y-0 right-0 pr-3 flex items-center"><span id="toggleConfirmPassword" class="cursor-pointer text-gray-500 hover:text-indigo-600"><i class="fas fa-eye"></i></span></div>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtXacNhanMatKhau" ErrorMessage="Vui lòng xác nhận mật khẩu." CssClass="text-red-600 text-xs mt-1 block" Display="Dynamic" ValidationGroup="ResetGroup"></asp:RequiredFieldValidator>
                        <asp:CompareValidator ID="cvPasswords" runat="server" ControlToValidate="txtXacNhanMatKhau" ControlToCompare="txtMatKhauMoi" Operator="Equal" Type="String" ErrorMessage="Mật khẩu xác nhận không khớp." CssClass="text-red-600 text-xs mt-1 block" Display="Dynamic" ValidationGroup="ResetGroup"></asp:CompareValidator>
                    </div>
                    <div class="flex flex-col space-y-3">
                        <asp:Button ID="btnXacNhan" runat="server" Text="Xác Nhận Đổi Mật Khẩu" CssClass="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out" OnClick="btnXacNhan_Click" ValidationGroup="ResetGroup" />
                        <asp:Button ID="btnHuy" runat="server" Text="Hủy" CausesValidation="false" CssClass="group relative w-full flex justify-center py-3 px-4 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out" OnClick="btnHuy_Click" />
                    </div>
                    <div class="text-center text-sm pt-4 border-t border-gray-200">
                        <asp:LinkButton ID="btnResendCode" runat="server" OnClick="btnResendCode_Click" CssClass="font-medium text-indigo-600 hover:text-indigo-500 hover:underline disabled:text-gray-400 disabled:no-underline disabled:cursor-wait" CausesValidation="false">Chưa nhận được mã? Gửi lại</asp:LinkButton>
                        <span id="resendCountdownTimer" class="ml-2 text-gray-500"></span>
                    </div>
                </div>
            </asp:Panel>

            <%-- **CẬP NHẬT**: Thêm script cho nút gửi lại --%>
            <script type="text/javascript">

                // **BẮT ĐẦU CODE MỚI**
                document.addEventListener('DOMContentLoaded', function () {
                    // Hàm tái sử dụng để cài đặt chức năng ẩn/hiện mật khẩu
                    function setupPasswordToggle(toggleId, inputId) {
                        const toggleElement = document.getElementById(toggleId);
                        const passwordInput = document.getElementById(inputId);
                        const icon = toggleElement ? toggleElement.querySelector('i') : null;

                        if (toggleElement && passwordInput && icon) {
                            toggleElement.addEventListener('click', function () {
                                // Thay đổi type của input từ 'password' sang 'text' và ngược lại
                                const currentType = passwordInput.getAttribute('type');
                                const newType = currentType === 'password' ? 'text' : 'password';
                                passwordInput.setAttribute('type', newType);

                                // Thay đổi icon con mắt
                                icon.classList.toggle('fa-eye');
                                icon.classList.toggle('fa-eye-slash');
                            });
                        }
                    }

                    // Áp dụng cho ô mật khẩu mới
                    setupPasswordToggle('toggleNewPassword', '<%= txtMatKhauMoi.ClientID %>');

                    // Áp dụng cho ô xác nhận mật khẩu
                    setupPasswordToggle('toggleConfirmPassword', '<%= txtXacNhanMatKhau.ClientID %>');
                });
                // **KẾT THÚC CODE MỚI**


                function startCountdown(durationInSeconds) {
                    const countdownElement = document.getElementById('countdownTimer');
                    const submitButton = document.getElementById('<%= btnGui.ClientID %>');
                    if (!countdownElement || !submitButton) return;
                    let timer = durationInSeconds;
                    submitButton.disabled = true;
                    const intervalId = setInterval(function () {
                        countdownElement.textContent = `Vui lòng đợi (${timer}s)`;
                        timer--;
                        if (timer < 0) {
                            clearInterval(intervalId);
                            countdownElement.textContent = '';
                            submitButton.disabled = false;
                        }
                    }, 1000);
                }

                // **MỚI**: Hàm đếm ngược cho nút gửi lại
                function startResendCountdown(durationInSeconds) {
                    const countdownElement = document.getElementById('resendCountdownTimer');
                    const resendButton = document.getElementById('<%= btnResendCode.ClientID %>');
                    if (!countdownElement || !resendButton) return;
                    let timer = durationInSeconds;
                    resendButton.classList.add('disabled:text-gray-400', 'disabled:no-underline', 'disabled:cursor-wait'); // Thêm class để style
                    resendButton.disabled = true;

                    const intervalId = setInterval(function () {
                        countdownElement.textContent = `(${timer}s)`;
                        timer--;
                        if (timer < 0) {
                            clearInterval(intervalId);
                            countdownElement.textContent = '';
                            resendButton.disabled = false;
                        }
                    }, 1000);
                }
            </script>
        </div>
    </div>
</asp:Content>