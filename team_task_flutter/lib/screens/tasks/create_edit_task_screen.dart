import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';

class CreateEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const CreateEditTaskScreen({super.key, this.task});

  bool get isEdit => task != null;

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  final TaskService _taskService = TaskService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _members = [];

  String? _selectedGroupId;
  String? _selectedAssignedTo;
  String _selectedStatus = 'todo';
  String _selectedPriority = 'medium';

  DateTime? _startDate;
  DateTime? _dueDate;

  static const List<Map<String, String>> _statusOptions = [
    {'value': 'todo', 'label': 'Cần làm'},
    {'value': 'doing', 'label': 'Đang làm'},
    {'value': 'done', 'label': 'Hoàn thành'},
  ];

  static const List<Map<String, String>> _priorityOptions = [
    {'value': 'low', 'label': 'Thấp'},
    {'value': 'medium', 'label': 'Trung bình'},
    {'value': 'high', 'label': 'Cao'},
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final groups = await _taskService.getMyGroupsForTaskForm();

      String? initialGroupId = widget.task?.groupId;

      if (initialGroupId == null && groups.isNotEmpty) {
        initialGroupId = groups.first['groupId'].toString();
      }

      List<Map<String, dynamic>> members = [];

      if (initialGroupId != null && initialGroupId.isNotEmpty) {
        members = await _taskService.getGroupMembersForTaskForm(initialGroupId);
      }

      if (widget.task != null) {
        _titleController.text = widget.task!.title;
        _descriptionController.text = widget.task!.description;
        _selectedGroupId = widget.task!.groupId;
        _selectedAssignedTo = widget.task!.assignedTo;
        _selectedStatus = widget.task!.status;
        _selectedPriority = widget.task!.priority;
        _startDate = widget.task!.startDate;
        _dueDate = widget.task!.dueDate;
      } else {
        _selectedGroupId = initialGroupId;
      }

      if (!mounted) return;

      setState(() {
        _groups = groups;
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Lỗi tải dữ liệu: $e');
    }
  }

  Future<void> _onGroupChanged(String? groupId) async {
    if (groupId == null || groupId.isEmpty) return;

    setState(() {
      _selectedGroupId = groupId;
      _selectedAssignedTo = null;
      _members = [];
      _isLoading = true;
    });

    try {
      final members = await _taskService.getGroupMembersForTaskForm(groupId);

      if (!mounted) return;

      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Lỗi tải thành viên: $e');
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      _startDate = picked;

      if (_dueDate != null && _dueDate!.isBefore(picked)) {
        _dueDate = picked;
      }
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      _dueDate = picked;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa chọn';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.tr(context),
          style: const TextStyle(fontFamily: _bodyFont),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedGroupId == null || _selectedGroupId!.isEmpty) {
      _showSnackBar('Vui lòng chọn nhóm');
      return;
    }

    if (_groups.isEmpty && !widget.isEdit) {
      _showSnackBar('Bạn chưa có nhóm nào. Hãy tạo hoặc tham gia nhóm trước.');
      return;
    }

    if (_dueDate != null &&
        _startDate != null &&
        _dueDate!.isBefore(_startDate!)) {
      _showSnackBar('Hạn chót không được nhỏ hơn ngày bắt đầu');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.isEdit) {
        await _taskService.updateTask(
          taskId: widget.task!.taskId,
          groupId: widget.task!.groupId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          assignedTo: _selectedAssignedTo,
          startDate: _startDate,
          dueDate: _dueDate,
        );
      } else {
        await _taskService.createTask(
          groupId: _selectedGroupId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          assignedTo: _selectedAssignedTo,
          startDate: _startDate,
          dueDate: _dueDate,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Lưu công việc thất bại: ${_cleanError(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSectionCard({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: _bodyFont,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildStatusItems() {
    return _statusOptions
        .map(
          (item) => DropdownMenuItem<String>(
            value: item['value'],
            child: Text(
              item['label']!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem<String>> _buildPriorityItems() {
    return _priorityOptions
        .map(
          (item) => DropdownMenuItem<String>(
            value: item['value'],
            child: Text(
              item['label']!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildSelectedStatusItems() {
    return _statusOptions
        .map(
          (item) => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item['label']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildSelectedPriorityItems() {
    return _priorityOptions
        .map(
          (item) => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item['label']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildCompactDropdowns() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 430;
        final itemWidth = useSingleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildSectionCard(
                label: 'Trạng thái',
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items: _buildStatusItems(),
                  selectedItemBuilder: (_) => _buildSelectedStatusItems(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildSectionCard(
                label: 'Độ ưu tiên',
                child: DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items: _buildPriorityItems(),
                  selectedItemBuilder: (_) => _buildSelectedPriorityItems(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedPriority = value;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chính',
            style: TextStyle(
              fontFamily: _headlineFont,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(fontFamily: _bodyFont),
            decoration: InputDecoration(
              labelText: 'Tiêu đề công việc'.tr(context),
              labelStyle: const TextStyle(fontFamily: _bodyFont),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tiêu đề';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(fontFamily: _bodyFont),
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Mô tả'.tr(context),
              labelStyle: const TextStyle(fontFamily: _bodyFont),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection() {
    if (_groups.isEmpty && !widget.isEdit) {
      return _buildSectionCard(
        label: 'Nhóm',
        child: Text(
          'Bạn chưa có nhóm nào. Hãy tạo hoặc tham gia nhóm trước khi tạo công việc.',
          style: TextStyle(fontFamily: _bodyFont, fontWeight: FontWeight.w600),
        ),
      );
    }

    return _buildSectionCard(
      label: 'Nhóm',
      child: DropdownButtonFormField<String>(
        value: _selectedGroupId,
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          helperText: widget.isEdit
              ? 'Không được chuyển công việc sang nhóm khác'
              : null,
          helperStyle: const TextStyle(fontFamily: _bodyFont),
        ),
        items: _groups
            .map(
              (group) => DropdownMenuItem<String>(
                value: group['groupId'].toString(),
                child: Text(
                  group['groupName'].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _bodyFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: widget.isEdit ? null : _onGroupChanged,
      ),
    );
  }

  Widget _buildAssigneeSection() {
    return _buildSectionCard(
      label: 'Giao cho',
      child: DropdownButtonFormField<String?>(
        value: _selectedAssignedTo,
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text(
              'Chưa giao',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ..._members.map(
            (member) => DropdownMenuItem<String?>(
              value: member['userId'].toString(),
              child: Text(
                member['name'].toString(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedAssignedTo = value;
          });
        },
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Ngày bắt đầu',
              style: TextStyle(
                fontFamily: _headlineFont,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              _formatDate(_startDate),
              style: const TextStyle(fontFamily: _bodyFont),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_startDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                const Icon(Icons.calendar_today_outlined),
              ],
            ),
            onTap: _pickStartDate,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Hạn chót',
              style: TextStyle(
                fontFamily: _headlineFont,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              _formatDate(_dueDate),
              style: const TextStyle(fontFamily: _bodyFont),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_dueDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                const Icon(Icons.event_busy_outlined),
              ],
            ),
            onTap: _pickDueDate,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Sửa công việc' : 'Tạo công việc',
          style: const TextStyle(
            fontFamily: _headlineFont,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  _buildMainInfoCard(),
                  const SizedBox(height: 16),
                  _buildGroupSection(),
                  const SizedBox(height: 16),
                  _buildAssigneeSection(),
                  const SizedBox(height: 16),
                  _buildCompactDropdowns(),
                  const SizedBox(height: 16),
                  _buildDateSection(),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: _isSaving || (_groups.isEmpty && !widget.isEdit)
              ? null
              : _save,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            _isSaving
                ? 'Đang lưu...'
                : isEdit
                ? 'Lưu thay đổi'
                : 'Tạo công việc',
            style: const TextStyle(
              fontFamily: _bodyFont,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
