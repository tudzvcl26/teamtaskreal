import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const supportedLocales = [Locale('vi'), Locale('en'), Locale('ja')];

  static const _localizedValues = {
    'en': {
      'appTitle': 'Team Task',
      'profileLoadError': 'Could not load profile',
      'retry': 'Try again',
      'noData': 'No data',
      'activeTasks': 'ACTIVE TASKS',
      'completedTasks': 'COMPLETED',
      'generalSettings': 'GENERAL SETTINGS',
      'editProfile': 'Edit profile',
      'changePassword': 'Change password',
      'darkMode': 'Dark mode',
      'language': 'Language',
      'selectLanguage': 'Select language',
      'selectedLanguage': 'Selected {language}',
      'logout': 'Log out',
      'appVersion': 'Team Task v2.4.0 • Built for Flow',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'japanese': '日本語',
    },
    'vi': {
      'appTitle': 'Team Task',
      'profileLoadError': 'Không tải được hồ sơ',
      'retry': 'Thử lại',
      'noData': 'Không có dữ liệu',
      'activeTasks': 'CÔNG VIỆC ĐANG LÀM',
      'completedTasks': 'ĐÃ HOÀN THÀNH',
      'generalSettings': 'CÀI ĐẶT CHUNG',
      'editProfile': 'Chỉnh sửa hồ sơ',
      'changePassword': 'Đổi mật khẩu',
      'darkMode': 'Chế độ tối',
      'language': 'Ngôn ngữ',
      'selectLanguage': 'Chọn ngôn ngữ',
      'selectedLanguage': 'Đã chọn {language}',
      'logout': 'Đăng xuất',
      'appVersion': 'Team Task v2.4.0 • Xây dựng cho Flow',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'japanese': '日本語',
    },
    'ja': {
      'appTitle': 'Team Task',
      'profileLoadError': 'プロフィールを読み込めません',
      'retry': '再試行',
      'noData': 'データがありません',
      'activeTasks': '進行中のタスク',
      'completedTasks': '完了済み',
      'generalSettings': '一般設定',
      'editProfile': 'プロフィールを編集',
      'changePassword': 'パスワードを変更',
      'darkMode': 'ダークモード',
      'language': '言語',
      'selectLanguage': '言語を選択',
      'selectedLanguage': '{language}を選択しました',
      'logout': 'ログアウト',
      'appVersion': 'Team Task v2.4.0 • Flow 向けに構築',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'japanese': '日本語',
    },
  };

  static const _directValues = {
    'en': {
      'Đăng nhập': 'Log in',
      'Đăng ký': 'Sign up',
      'Đăng nhập thành công': 'Logged in successfully',
      'Đăng ký thành công': 'Signed up successfully',
      'Đăng nhập thất bại': 'Login failed',
      'Đăng ký thất bại': 'Sign up failed',
      'Không tìm thấy tài khoản': 'Account not found',
      'Sai mật khẩu': 'Wrong password',
      'Email hoặc mật khẩu không đúng': 'Email or password is incorrect',
      'Email không hợp lệ': 'Invalid email',
      'Email này đã được sử dụng': 'This email is already in use',
      'Mật khẩu quá yếu': 'Password is too weak',
      'Có lỗi xảy ra, vui lòng thử lại':
          'Something went wrong, please try again',
      'Vui lòng nhập email và mật khẩu': 'Please enter email and password',
      'Vui lòng nhập đầy đủ thông tin': 'Please enter all information',
      'Mật khẩu phải có ít nhất 6 ký tự':
          'Password must be at least 6 characters',
      'Mật khẩu mới phải có ít nhất 6 ký tự':
          'New password must be at least 6 characters',
      'Mật khẩu xác nhận không khớp': 'Confirmation password does not match',
      'Nhập email': 'Enter email',
      'Nhập mật khẩu': 'Enter password',
      'Nhập họ và tên': 'Enter full name',
      'Nhập lại mật khẩu': 'Re-enter password',
      'Quên mật khẩu?': 'Forgot password?',
      'Chưa có tài khoản?': 'Do not have an account?',
      'Đã có tài khoản?': 'Already have an account?',
      'Chào mừng bạn quay lại với Team Task': 'Welcome back to Team Task',
      'Tạo không gian làm việc tập trung và bắt đầu cùng nhau đạt được mục tiêu.':
          'Create a focused workspace and start reaching goals together.',
      'Họ và tên': 'Full name',
      'Địa chỉ Email': 'Email address',
      'Mật khẩu': 'Password',
      'Xác nhận mật khẩu': 'Confirm password',
      'Bằng cách đăng ký, bạn đồng ý với Điều khoản Dịch vụ và Chính sách Bảo mật của chúng tôi.':
          'By signing up, you agree to our Terms of Service and Privacy Policy.',
      'Chỉnh sửa hồ sơ': 'Edit profile',
      'HỒ SƠ CÁ NHÂN': 'PERSONAL PROFILE',
      'Cập nhật thông tin của bạn': 'Update your information',
      'Đã chọn ảnh': 'Image selected',
      'Vui lòng nhập họ tên': 'Please enter your full name',
      'Vui lòng nhập email': 'Please enter email',
      'Cập nhật hồ sơ thành công': 'Profile updated successfully',
      'Không thể cập nhật hồ sơ': 'Could not update profile',
      'Vui lòng đăng nhập lại để đổi email':
          'Please log in again to change email',
      'Email đã được sử dụng': 'Email is already in use',
      'Lưu thay đổi': 'Save changes',
      'Hủy': 'Cancel',
      'Đổi mật khẩu': 'Change password',
      'BẢO MẬT TÀI KHOẢN': 'ACCOUNT SECURITY',
      'Cập nhật mật khẩu mới': 'Update new password',
      'Mật khẩu mới': 'New password',
      'Nhập mật khẩu mới': 'Enter new password',
      'Nhập lại mật khẩu mới': 'Re-enter new password',
      'Lưu ý: Firebase có thể yêu cầu bạn đăng nhập lại nếu phiên đăng nhập đã cũ.':
          'Note: Firebase may require you to log in again if your session is old.',
      'Lưu mật khẩu mới': 'Save new password',
      'Đổi mật khẩu thành công': 'Password changed successfully',
      'Không thể đổi mật khẩu': 'Could not change password',
      'Vui lòng đăng nhập lại trước khi đổi mật khẩu':
          'Please log in again before changing password',
      'Mật khẩu mới quá yếu': 'New password is too weak',
      'Thử lại': 'Try again',
      'Không có dữ liệu': 'No data',
      'Không tải được dữ liệu': 'Could not load data',
      'Tìm kiếm công việc, nhóm...': 'Search tasks, groups...',
      'Không có hạn chót gần nhất': 'No upcoming deadline',
      'Hôm nay': 'Today',
      'Chưa có': 'None',
      'Trang chủ': 'Home',
      'Hộp thư': 'Inbox',
      'Cá nhân': 'Profile',
      'Quản lý nhóm thông minh hơn': 'Manage teams smarter',
      'Tạo nhóm và quản lý thành viên': 'Create groups and manage members',
      'Tập hợp sức mạnh trí tuệ tập thể. Tổ chức nhóm, phòng ban hoặc dự án trong giây lát.':
          'Bring collective intelligence together. Organize teams, departments, or projects in seconds.',
      'Giao việc và quản lý deadline': 'Assign tasks and manage deadlines',
      'Theo dõi công việc rõ ràng, phân công đúng người và hoàn thành đúng thời hạn.':
          'Track work clearly, assign the right people, and finish on time.',
      'Theo dõi tiến độ và nhận thông báo':
          'Track progress and get notifications',
      'Luôn cập nhật tiến độ nhóm với thông báo thời gian thực và trạng thái công việc rõ ràng.':
          'Stay updated with real-time notifications and clear task statuses.',
      'Bắt đầu': 'Get started',
      'Tiếp theo': 'Next',
      'Bỏ qua': 'Skip',
      'Thông báo': 'Notifications',
      'Đánh dấu tất cả đã đọc': 'Mark all as read',
      'Không có thông báo': 'No notifications',
      'Bạn đã chấp nhận lời mời này rồi':
          'You have already accepted this invitation',
      'Bạn đã từ chối lời mời này rồi':
          'You have already declined this invitation',
      'Lời mời tham gia nhóm': 'Group invitation',
      'Yêu cầu tham gia nhóm': 'Group join request',
      'Từ chối': 'Decline',
      'Chấp nhận': 'Accept',
      'Yêu cầu này đã được chấp nhận rồi':
          'This request has already been accepted',
      'Yêu cầu này đã bị từ chối rồi': 'This request has already been declined',
      'Nhóm': 'Groups',
      'Không gian làm việc của bạn': 'Your workspace',
      'Bạn chưa có nhóm nào': 'You do not have any groups',
      'Hãy tạo nhóm mới hoặc xin tham gia bằng mã nhóm.':
          'Create a new group or request to join with a group code.',
      'Nhóm của tôi': 'My groups',
      'Nhóm gần đây': 'Recent groups',
      'Xem tất cả': 'View all',
      'Nhóm làm việc': 'Work group',
      'Không có mô tả': 'No description',
      'Thành viên': 'Members',
      'Hoàn thành': 'Completed',
      'Quá hạn': 'Overdue',
      'Tổng nhóm': 'Total groups',
      'Tổng công việc': 'Total tasks',
      'Tìm kiếm nhóm...': 'Search groups...',
      'Tạo nhóm': 'Create group',
      'Tham gia nhóm': 'Join group',
      'Thêm thành viên': 'Add member',
      'Gửi lời mời': 'Send invitation',
      'Tham gia nhóm bằng mã': 'Join group by code',
      'Nhập mã nhóm': 'Enter group code',
      'Tìm nhóm': 'Find group',
      'Gửi yêu cầu tham gia': 'Send join request',
      'Lưu trữ nhóm': 'Archive group',
      'Xóa nhóm': 'Delete group',
      'Đã sao chép mã mời': 'Invite code copied',
      'Đã lưu trữ nhóm': 'Group archived',
      'Đã xóa nhóm': 'Group deleted',
      'Lưu trữ': 'Archive',
      'Xóa': 'Delete',
      'Không tải được thông tin nhóm': 'Could not load group information',
      'Mời thành viên': 'Invite member',
      'Chỉnh sửa nhóm': 'Edit group',
      'Nhập tên nhóm': 'Enter group name',
      'Nhập mô tả nhóm': 'Enter group description',
      'Tên nhóm': 'Group name',
      'Hình ảnh nhóm': 'Group image',
      'Màu chủ đạo': 'Primary color',
      'Biểu tượng nhóm': 'Group icon',
      'Mã mời': 'Invite code',
      'Vùng nguy hiểm': 'Danger zone',
      'Chi tiết Nhóm': 'Group details',
      'Tổng quan nhóm của bạn': 'Your group overview',
      'Tiến độ nhóm': 'Group progress',
      'Thành viên nổi bật': 'Featured members',
      'Chưa có thành viên nào': 'No members yet',
      'Khu vực quản trị': 'Admin area',
      'Công việc': 'Tasks',
      'Công việc hôm nay': 'Today tasks',
      'Hôm nay không có công việc nào': 'No tasks today',
      'Tất cả': 'All',
      'Cần làm': 'To do',
      'Đang thực hiện': 'In progress',
      'Danh sách công việc': 'Task list',
      'Tổng': 'Total',
      'Đang làm': 'Active',
      'Xong': 'Done',
      'Tạo công việc': 'Create task',
      'Sửa công việc': 'Edit task',
      'Xóa công việc': 'Delete task',
      'Tiêu đề công việc': 'Task title',
      'Mô tả': 'Description',
      'Trạng thái': 'Status',
      'Độ ưu tiên': 'Priority',
      'Thông tin chính': 'Main information',
      'Ngày bắt đầu': 'Start date',
      'Hạn chót': 'Deadline',
      'Tiến độ': 'Progress',
      'bước đã hoàn thành': 'steps completed',
      'Người tạo': 'Creator',
      'Người tạo đã tạo công việc': 'Creator created the task',
      'Đã giao cho thành viên': 'Assigned to member',
      'Thành viên đã nhận công việc': 'Member received the task',
      'Thành viên đang thực hiện': 'Member is working',
      'Có thảo luận': 'Discussion started',
      'Có tệp đính kèm': 'Has attachments',
      'Công việc hoàn thành': 'Task completed',
      'Đang chờ người nhận': 'Waiting for assignee',
      'Chưa bắt đầu': 'Not started',
      'bình luận': 'comments',
      'Chưa có bình luận': 'No comments yet',
      'tệp': 'files',
      'Chưa có tệp đính kèm': 'No attachments yet',
      'Đang chờ hoàn thành': 'Waiting for completion',
      'Chưa giao': 'Unassigned',
      'Chưa chọn': 'Not selected',
      'Chưa có mô tả': 'No description',
      'Đang lưu...': 'Saving...',
      'Đã hoàn thành': 'Completed',
      'Trung bình': 'Medium',
      'Ưu tiên vừa': 'Medium priority',
      'Vui lòng chọn nhóm': 'Please select a group',
      'Bạn chưa có nhóm nào. Hãy tạo hoặc tham gia nhóm trước.':
          'You do not have any groups. Create or join a group first.',
      'Hạn chót không được nhỏ hơn ngày bắt đầu':
          'Deadline cannot be before the start date',
      'Đã cập nhật công việc': 'Task updated',
      'Đã chuyển sang hoàn thành': 'Marked as completed',
      'Bạn có chắc muốn xóa công việc này không?':
          'Are you sure you want to delete this task?',
      'Đã thêm tệp đính kèm': 'Attachment added',
      'Xóa tệp đính kèm': 'Delete attachment',
      'Đã xóa tệp đính kèm': 'Attachment deleted',
      'Đã copy link tệp': 'File link copied',
      'Viết bình luận...': 'Write a comment...',
      'Thống kê / Tiến độ': 'Statistics / Progress',
      'Ưu tiên cao': 'High priority',
      'Ưu tiên trung bình': 'Medium priority',
      'Ưu tiên thấp': 'Low priority',
    },
    'ja': {
      'Đăng nhập': 'ログイン',
      'Đăng ký': '登録',
      'Đăng nhập thành công': 'ログインしました',
      'Đăng ký thành công': '登録しました',
      'Đăng nhập thất bại': 'ログインに失敗しました',
      'Đăng ký thất bại': '登録に失敗しました',
      'Không tìm thấy tài khoản': 'アカウントが見つかりません',
      'Sai mật khẩu': 'パスワードが違います',
      'Email hoặc mật khẩu không đúng': 'メールまたはパスワードが正しくありません',
      'Email không hợp lệ': 'メールアドレスが無効です',
      'Email này đã được sử dụng': 'このメールは既に使用されています',
      'Mật khẩu quá yếu': 'パスワードが弱すぎます',
      'Có lỗi xảy ra, vui lòng thử lại': 'エラーが発生しました。もう一度お試しください',
      'Vui lòng nhập email và mật khẩu': 'メールとパスワードを入力してください',
      'Vui lòng nhập đầy đủ thông tin': 'すべての情報を入力してください',
      'Mật khẩu phải có ít nhất 6 ký tự': 'パスワードは6文字以上必要です',
      'Mật khẩu mới phải có ít nhất 6 ký tự': '新しいパスワードは6文字以上必要です',
      'Mật khẩu xác nhận không khớp': '確認用パスワードが一致しません',
      'Nhập email': 'メールを入力',
      'Nhập mật khẩu': 'パスワードを入力',
      'Nhập họ và tên': '氏名を入力',
      'Nhập lại mật khẩu': 'パスワードを再入力',
      'Quên mật khẩu?': 'パスワードをお忘れですか？',
      'Chưa có tài khoản?': 'アカウントをお持ちでないですか？',
      'Đã có tài khoản?': 'すでにアカウントをお持ちですか？',
      'Chào mừng bạn quay lại với Team Task': 'Team Taskへようこそ',
      'Tạo không gian làm việc tập trung và bắt đầu cùng nhau đạt được mục tiêu.':
          '集中できる作業スペースを作り、一緒に目標を達成しましょう。',
      'Họ và tên': '氏名',
      'Địa chỉ Email': 'メールアドレス',
      'Mật khẩu': 'パスワード',
      'Xác nhận mật khẩu': 'パスワード確認',
      'Bằng cách đăng ký, bạn đồng ý với Điều khoản Dịch vụ và Chính sách Bảo mật của chúng tôi.':
          '登録すると、利用規約とプライバシーポリシーに同意したことになります。',
      'Chỉnh sửa hồ sơ': 'プロフィール編集',
      'HỒ SƠ CÁ NHÂN': '個人プロフィール',
      'Cập nhật thông tin của bạn': '情報を更新',
      'Đã chọn ảnh': '画像を選択しました',
      'Vui lòng nhập họ tên': '氏名を入力してください',
      'Vui lòng nhập email': 'メールを入力してください',
      'Cập nhật hồ sơ thành công': 'プロフィールを更新しました',
      'Không thể cập nhật hồ sơ': 'プロフィールを更新できません',
      'Vui lòng đăng nhập lại để đổi email': 'メール変更には再ログインが必要です',
      'Email đã được sử dụng': 'メールは既に使用されています',
      'Lưu thay đổi': '変更を保存',
      'Hủy': 'キャンセル',
      'Đổi mật khẩu': 'パスワード変更',
      'BẢO MẬT TÀI KHOẢN': 'アカウントセキュリティ',
      'Cập nhật mật khẩu mới': '新しいパスワードを更新',
      'Mật khẩu mới': '新しいパスワード',
      'Nhập mật khẩu mới': '新しいパスワードを入力',
      'Nhập lại mật khẩu mới': '新しいパスワードを再入力',
      'Lưu ý: Firebase có thể yêu cầu bạn đăng nhập lại nếu phiên đăng nhập đã cũ.':
          '注意: セッションが古い場合、Firebaseが再ログインを求めることがあります。',
      'Lưu mật khẩu mới': '新しいパスワードを保存',
      'Đổi mật khẩu thành công': 'パスワードを変更しました',
      'Không thể đổi mật khẩu': 'パスワードを変更できません',
      'Vui lòng đăng nhập lại trước khi đổi mật khẩu': '変更前に再ログインしてください',
      'Mật khẩu mới quá yếu': '新しいパスワードが弱すぎます',
      'Thử lại': '再試行',
      'Không có dữ liệu': 'データがありません',
      'Không tải được dữ liệu': 'データを読み込めません',
      'Tìm kiếm công việc, nhóm...': 'タスク、グループを検索...',
      'Không có hạn chót gần nhất': '近日の期限はありません',
      'Hôm nay': '今日',
      'Chưa có': 'なし',
      'Trang chủ': 'ホーム',
      'Hộp thư': '受信箱',
      'Cá nhân': 'プロフィール',
      'Quản lý nhóm thông minh hơn': 'チーム管理をもっとスマートに',
      'Tạo nhóm và quản lý thành viên': 'グループ作成とメンバー管理',
      'Tập hợp sức mạnh trí tuệ tập thể. Tổ chức nhóm, phòng ban hoặc dự án trong giây lát.':
          'チーム、部門、プロジェクトをすばやく整理しましょう。',
      'Giao việc và quản lý deadline': 'タスク割り当てと期限管理',
      'Theo dõi công việc rõ ràng, phân công đúng người và hoàn thành đúng thời hạn.':
          '作業を明確に追跡し、適切な人に割り当て、期限内に完了します。',
      'Theo dõi tiến độ và nhận thông báo': '進捗追跡と通知',
      'Luôn cập nhật tiến độ nhóm với thông báo thời gian thực và trạng thái công việc rõ ràng.':
          'リアルタイム通知と明確なタスク状態で進捗を把握します。',
      'Bắt đầu': '開始',
      'Tiếp theo': '次へ',
      'Bỏ qua': 'スキップ',
      'Thông báo': '通知',
      'Đánh dấu tất cả đã đọc': 'すべて既読にする',
      'Không có thông báo': '通知はありません',
      'Bạn đã chấp nhận lời mời này rồi': 'この招待は既に承認済みです',
      'Bạn đã từ chối lời mời này rồi': 'この招待は既に拒否済みです',
      'Lời mời tham gia nhóm': 'グループ招待',
      'Yêu cầu tham gia nhóm': 'グループ参加リクエスト',
      'Từ chối': '拒否',
      'Chấp nhận': '承認',
      'Yêu cầu này đã được chấp nhận rồi': 'このリクエストは既に承認済みです',
      'Yêu cầu này đã bị từ chối rồi': 'このリクエストは既に拒否済みです',
      'Nhóm': 'グループ',
      'Không gian làm việc của bạn': 'あなたのワークスペース',
      'Bạn chưa có nhóm nào': 'グループがありません',
      'Hãy tạo nhóm mới hoặc xin tham gia bằng mã nhóm.':
          '新しいグループを作成するか、コードで参加をリクエストしてください。',
      'Nhóm của tôi': 'マイグループ',
      'Nhóm gần đây': '最近のグループ',
      'Xem tất cả': 'すべて表示',
      'Nhóm làm việc': '作業グループ',
      'Không có mô tả': '説明なし',
      'Thành viên': 'メンバー',
      'Hoàn thành': '完了',
      'Quá hạn': '期限超過',
      'Tổng nhóm': 'グループ合計',
      'Tổng công việc': 'タスク合計',
      'Tìm kiếm nhóm...': 'グループを検索...',
      'Tạo nhóm': 'グループ作成',
      'Tham gia nhóm': 'グループ参加',
      'Thêm thành viên': 'メンバー追加',
      'Gửi lời mời': '招待を送信',
      'Tham gia nhóm bằng mã': 'コードでグループ参加',
      'Nhập mã nhóm': 'グループコードを入力',
      'Tìm nhóm': 'グループ検索',
      'Gửi yêu cầu tham gia': '参加リクエストを送信',
      'Lưu trữ nhóm': 'グループをアーカイブ',
      'Xóa nhóm': 'グループ削除',
      'Đã sao chép mã mời': '招待コードをコピーしました',
      'Đã lưu trữ nhóm': 'グループをアーカイブしました',
      'Đã xóa nhóm': 'グループを削除しました',
      'Lưu trữ': 'アーカイブ',
      'Xóa': '削除',
      'Không tải được thông tin nhóm': 'グループ情報を読み込めません',
      'Mời thành viên': 'メンバー招待',
      'Chỉnh sửa nhóm': 'グループ編集',
      'Nhập tên nhóm': 'グループ名を入力',
      'Nhập mô tả nhóm': 'グループ説明を入力',
      'Tên nhóm': 'グループ名',
      'Hình ảnh nhóm': 'グループ画像',
      'Màu chủ đạo': 'メインカラー',
      'Biểu tượng nhóm': 'グループアイコン',
      'Mã mời': '招待コード',
      'Vùng nguy hiểm': '危険エリア',
      'Chi tiết Nhóm': 'グループ詳細',
      'Tổng quan nhóm của bạn': 'グループ概要',
      'Tiến độ nhóm': 'グループ進捗',
      'Thành viên nổi bật': '注目メンバー',
      'Chưa có thành viên nào': 'メンバーはいません',
      'Khu vực quản trị': '管理エリア',
      'Công việc': 'タスク',
      'Công việc hôm nay': '今日のタスク',
      'Hôm nay không có công việc nào': '今日のタスクはありません',
      'Tất cả': 'すべて',
      'Cần làm': '未着手',
      'Đang thực hiện': '進行中',
      'Danh sách công việc': 'タスクリスト',
      'Tổng': '合計',
      'Đang làm': '進行中',
      'Xong': '完了',
      'Tạo công việc': 'タスク作成',
      'Sửa công việc': 'タスク編集',
      'Xóa công việc': 'タスク削除',
      'Tiêu đề công việc': 'タスクタイトル',
      'Mô tả': '説明',
      'Trạng thái': 'ステータス',
      'Độ ưu tiên': '優先度',
      'Thông tin chính': '基本情報',
      'Ngày bắt đầu': '開始日',
      'Hạn chót': '期限',
      'Tiến độ': '進捗',
      'bước đã hoàn thành': 'ステップ完了',
      'Người tạo': '作成者',
      'Người tạo đã tạo công việc': '作成者がタスクを作成しました',
      'Đã giao cho thành viên': 'メンバーに割り当て済み',
      'Thành viên đã nhận công việc': 'メンバーがタスクを受け取りました',
      'Thành viên đang thực hiện': 'メンバーが作業中',
      'Có thảo luận': 'ディスカッションあり',
      'Có tệp đính kèm': '添付ファイルあり',
      'Công việc hoàn thành': 'タスク完了',
      'Đang chờ người nhận': '担当者待ち',
      'Chưa bắt đầu': '未開始',
      'bình luận': 'コメント',
      'Chưa có bình luận': 'コメントはまだありません',
      'tệp': 'ファイル',
      'Chưa có tệp đính kèm': '添付ファイルはまだありません',
      'Đang chờ hoàn thành': '完了待ち',
      'Chưa giao': '未割り当て',
      'Chưa chọn': '未選択',
      'Chưa có mô tả': '説明がありません',
      'Đang lưu...': '保存中...',
      'Đã hoàn thành': '完了済み',
      'Trung bình': '中',
      'Ưu tiên vừa': '中優先度',
      'Vui lòng chọn nhóm': 'グループを選択してください',
      'Bạn chưa có nhóm nào. Hãy tạo hoặc tham gia nhóm trước.':
          'グループがありません。先に作成または参加してください。',
      'Hạn chót không được nhỏ hơn ngày bắt đầu': '期限は開始日より前にできません',
      'Đã cập nhật công việc': 'タスクを更新しました',
      'Đã chuyển sang hoàn thành': '完了に変更しました',
      'Bạn có chắc muốn xóa công việc này không?': 'このタスクを削除しますか？',
      'Đã thêm tệp đính kèm': '添付ファイルを追加しました',
      'Xóa tệp đính kèm': '添付ファイルを削除',
      'Đã xóa tệp đính kèm': '添付ファイルを削除しました',
      'Đã copy link tệp': 'ファイルリンクをコピーしました',
      'Viết bình luận...': 'コメントを書く...',
      'Thống kê / Tiến độ': '統計 / 進捗',
      'Ưu tiên cao': '高優先度',
      'Ưu tiên trung bình': '中優先度',
      'Ưu tiên thấp': '低優先度',
    },
  };

  String _text(String key) {
    final languageCode = Intl.canonicalizedLocale(locale.languageCode);
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['vi']![key]!;
  }

  String get appTitle => _text('appTitle');
  String get profileLoadError => _text('profileLoadError');
  String get retry => _text('retry');
  String get noData => _text('noData');
  String get activeTasks => _text('activeTasks');
  String get completedTasks => _text('completedTasks');
  String get generalSettings => _text('generalSettings');
  String get editProfile => _text('editProfile');
  String get changePassword => _text('changePassword');
  String get darkMode => _text('darkMode');
  String get language => _text('language');
  String get selectLanguage => _text('selectLanguage');
  String get logout => _text('logout');
  String get appVersion => _text('appVersion');
  String get vietnamese => _text('vietnamese');
  String get english => _text('english');
  String get japanese => _text('japanese');

  String selectedLanguage(String language) {
    return _text('selectedLanguage').replaceAll('{language}', language);
  }

  String translate(String source) {
    if (locale.languageCode == 'vi') return source;

    final values = _directValues[locale.languageCode];
    if (values == null) return source;

    final translated = values[source];
    if (translated != null) return translated;

    return _translatePrefix(source);
  }

  String _translatePrefix(String source) {
    final prefixes = {
      'Lỗi tải dữ liệu: ': 'Failed to load data: ',
      'Lỗi tải thành viên: ': 'Failed to load members: ',
      'Lưu công việc thất bại: ': 'Failed to save task: ',
      'Gửi bình luận thất bại: ': 'Failed to send comment: ',
      'Cập nhật trạng thái thất bại: ': 'Failed to update status: ',
      'Xóa công việc thất bại: ': 'Failed to delete task: ',
      'Thêm tệp thất bại: ': 'Failed to add file: ',
      'Xóa tệp thất bại: ': 'Failed to delete file: ',
    };

    final jaPrefixes = {
      'Lỗi tải dữ liệu: ': 'データ読み込み失敗: ',
      'Lỗi tải thành viên: ': 'メンバー読み込み失敗: ',
      'Lưu công việc thất bại: ': 'タスク保存失敗: ',
      'Gửi bình luận thất bại: ': 'コメント送信失敗: ',
      'Cập nhật trạng thái thất bại: ': 'ステータス更新失敗: ',
      'Xóa công việc thất bại: ': 'タスク削除失敗: ',
      'Thêm tệp thất bại: ': 'ファイル追加失敗: ',
      'Xóa tệp thất bại: ': 'ファイル削除失敗: ',
    };

    final selectedPrefixes = locale.languageCode == 'ja'
        ? jaPrefixes
        : prefixes;

    for (final entry in selectedPrefixes.entries) {
      if (source.startsWith(entry.key)) {
        return source.replaceFirst(entry.key, entry.value);
      }
    }

    return source;
  }
}

extension AppLocalizationsString on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)!.translate(this);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
