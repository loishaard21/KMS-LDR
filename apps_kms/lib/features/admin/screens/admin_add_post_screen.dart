import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/article_provider.dart';
import '../providers/seminar_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AdminAddPostScreen extends ConsumerStatefulWidget {
  const AdminAddPostScreen({super.key});

  @override
  ConsumerState<AdminAddPostScreen> createState() => _AdminAddPostScreenState();
}

class _AdminAddPostScreenState extends ConsumerState<AdminAddPostScreen> {
  String _postType = 'Artikel';
  final _titleCtrl = TextEditingController();
  final _excerptCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String _selectedCategory = 'Berita';
  String _selectedStatus = 'Pendaftaran Dibuka';
  bool _isLoading = false;

  final _articleCategories = ['Berita', 'Artikel', 'Opini', 'Pengumuman'];
  final _seminarCategories = ['Teknis', 'Manajerial', 'Fungsional', 'Soft Skill'];
  final _seminarStatuses = ['Pendaftaran Dibuka', 'Pendaftaran Ditutup', 'Selesai', 'Dibatalkan'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _excerptCtrl.dispose();
    _contentCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(authProvider).user;
    bool success;

    if (_postType == 'Artikel') {
      final data = {
        'title': _titleCtrl.text,
        'category': _selectedCategory,
        'excerpt': _excerptCtrl.text,
        'content': _contentCtrl.text,
        'date': _dateCtrl.text.isEmpty ? DateTime.now().toIso8601String().substring(0, 10) : _dateCtrl.text,
        'authorId': user?.id,
      };
      success = await ref.read(articleProvider.notifier).create(data);
    } else {
      final data = {
        'title': _titleCtrl.text,
        'category': _selectedCategory,
        'date': _dateCtrl.text.isEmpty ? DateTime.now().toIso8601String().substring(0, 10) : _dateCtrl.text,
        'location': _locationCtrl.text,
        'capacity': int.tryParse(_capacityCtrl.text) ?? 0,
        'status': _selectedStatus,
        'authorId': user?.id,
      };
      success = await ref.read(seminarProvider.notifier).create(data);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_postType berhasil ditambahkan'),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
      );

  InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF94A3B8)) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0052CC))),
      );

  @override
  Widget build(BuildContext context) {
    final categories = _postType == 'Artikel' ? _articleCategories : _seminarCategories;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Add Post',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post type selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['Artikel', 'Seminar'].map((type) {
                  final isSelected = _postType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _postType = type;
                        _selectedCategory = (type == 'Artikel' ? _articleCategories : _seminarCategories).first;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type == 'Artikel' ? Icons.newspaper_outlined : Icons.book_outlined,
                              size: 16,
                              color: isSelected ? const Color(0xFF0052CC) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? const Color(0xFF0052CC) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Form fields
            _buildLabel('Judul'),
            TextField(controller: _titleCtrl, decoration: _inputDecoration('Masukkan judul...')),
            const SizedBox(height: 12),

            _buildLabel('Kategori'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration('Pilih kategori'),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 12),

            _buildLabel('Tanggal'),
            TextField(
              controller: _dateCtrl,
              decoration: _inputDecoration('YYYY-MM-DD', icon: Icons.calendar_today_outlined),
            ),
            const SizedBox(height: 12),

            if (_postType == 'Artikel') ...[
              _buildLabel('Ringkasan'),
              TextField(controller: _excerptCtrl, maxLines: 3, decoration: _inputDecoration('Ringkasan singkat...')),
              const SizedBox(height: 12),
              _buildLabel('Konten'),
              TextField(controller: _contentCtrl, maxLines: 8, decoration: _inputDecoration('Tulis konten artikel...')),
            ] else ...[
              _buildLabel('Lokasi'),
              TextField(controller: _locationCtrl, decoration: _inputDecoration('Masukkan lokasi', icon: Icons.location_on_outlined)),
              const SizedBox(height: 12),
              _buildLabel('Kapasitas'),
              TextField(controller: _capacityCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('0')),
              const SizedBox(height: 12),
              _buildLabel('Status'),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: _inputDecoration('Pilih status'),
                items: _seminarStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Publikasikan $_postType',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
