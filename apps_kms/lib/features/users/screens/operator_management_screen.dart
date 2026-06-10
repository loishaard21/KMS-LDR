import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/operator_provider.dart';

class OperatorManagementScreen extends ConsumerStatefulWidget {
  const OperatorManagementScreen({super.key});

  @override
  ConsumerState<OperatorManagementScreen> createState() => _OperatorManagementScreenState();
}

class _OperatorManagementScreenState extends ConsumerState<OperatorManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Operator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.successColor),
            onPressed: () => _showOperatorModal(context, null),
            tooltip: 'Tambah Operator',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(operatorProvider.notifier).loadOperators(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0052CC).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.check_circle_outline, color: Color(0xFF0052CC), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hanya Super Admin yang dapat menambah, mengedit, atau menghapus akun operator. Tidak tersedia fitur registrasi mandiri.',
                      style: TextStyle(
                        color: Color(0xFF0052CC),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: AppTheme.dangerColor, fontSize: 13),
                ),
              ),

            // Operator List
            Expanded(
              child: state.isLoading && state.operators.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.operators.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada operator terdaftar.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.operators.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final op = state.operators[index];
                            final initial = op.name.isNotEmpty ? op.name[0].toUpperCase() : 'O';

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: op.role == 'superadmin'
                                        ? const Color(0xFFF5F3FF)
                                        : const Color(0xFFEEF4FF),
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: op.role == 'superadmin'
                                            ? const Color(0xFF7C3AED)
                                            : const Color(0xFF0052CC),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          op.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A2332),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          op.email,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            StatusBadge(status: op.role == 'superadmin' ? 'Super Admin' : 'Operator'),
                                            const SizedBox(width: 6),
                                            StatusBadge(status: op.status),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 18),
                                        onPressed: () => _showOperatorModal(context, op),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppTheme.dangerColor, size: 18),
                                        onPressed: () => _confirmDelete(op),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(UserModel op) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: Text('Apakah Anda yakin ingin menghapus akun operator "${op.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppTheme.dangerColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(operatorProvider.notifier).removeOperator(op.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operator berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  void _showOperatorModal(BuildContext context, UserModel? operator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _OperatorFormModal(operator: operator);
      },
    );
  }
}

class _OperatorFormModal extends ConsumerStatefulWidget {
  final UserModel? operator;

  const _OperatorFormModal({this.operator});

  @override
  ConsumerState<_OperatorFormModal> createState() => _OperatorFormModalState();
}

class _OperatorFormModalState extends ConsumerState<_OperatorFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late String _role;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.operator?.name ?? '';
    _emailController.text = widget.operator?.email ?? '';
    _role = widget.operator?.role == 'superadmin' ? 'Super Admin' : 'Operator';
    _status = widget.operator?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final payload = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'role': _role == 'Super Admin' ? 'superadmin' : 'operator',
      'status': _status,
    };

    if (_passwordController.text.isNotEmpty) {
      payload['password'] = _passwordController.text;
    }

    bool success;
    if (widget.operator != null) {
      success = await ref.read(operatorProvider.notifier).editOperator(widget.operator!.id, payload);
    } else {
      // Default password if blank
      payload['password'] = _passwordController.text.isNotEmpty ? _passwordController.text : 'operator123';
      success = await ref.read(operatorProvider.notifier).addOperator(payload);
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.operator != null ? 'Operator berhasil diperbarui' : 'Operator berhasil ditambahkan'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.operator != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Operator' : 'Tambah Operator',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameController,
                labelText: 'Nama Lengkap',
                hintText: 'Nama lengkap operator...',
                validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'email@lampungprov.go.id',
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                labelText: isEdit ? 'Password Baru (kosongkan jika tidak diubah)' : 'Password Sementara',
                hintText: isEdit ? 'Biarkan kosong jika tidak diubah...' : 'Minimal 8 karakter...',
                isPassword: true,
                validator: (val) {
                  if (!isEdit && (val == null || val.isEmpty)) {
                    return 'Password wajib diisi untuk operator baru';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Role',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _role,
                    dropdownColor: Colors.white,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1A2332)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.lightBorder),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Operator', child: Text('Operator')),
                      DropdownMenuItem(value: 'Super Admin', child: Text('Super Admin')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _role = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _status,
                    dropdownColor: Colors.white,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1A2332)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.lightBorder),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _status = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Simpan',
                isLoading: _isLoading,
                onPressed: _submit,
                icon: Icons.save_outlined,
                color: AppTheme.successColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
