import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/seminar_model.dart';
import '../providers/seminar_provider.dart';
import '../../auth/providers/auth_provider.dart';

class KelolaSeminarScreen extends ConsumerStatefulWidget {
  const KelolaSeminarScreen({super.key});

  @override
  ConsumerState<KelolaSeminarScreen> createState() => _KelolaSeminarScreenState();
}

class _KelolaSeminarScreenState extends ConsumerState<KelolaSeminarScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      ref.read(seminarProvider.notifier).fetchAll(filterByAuthorId: user?.id);
    });
  }

  Future<void> _refresh() async {
    final user = ref.read(authProvider).user;
    await ref.read(seminarProvider.notifier).fetchAll(filterByAuthorId: user?.id);
  }

  Future<void> _showFormDialog({SeminarModel? seminar}) async {
    final titleCtrl = TextEditingController(text: seminar?.title ?? '');
    final dateCtrl = TextEditingController(text: seminar?.date ?? '');
    final locationCtrl = TextEditingController(text: seminar?.location ?? '');
    final capacityCtrl = TextEditingController(text: seminar?.capacity.toString() ?? '');
    String selectedCategory = seminar?.category ?? 'Teknis';
    String selectedStatus = seminar?.status ?? 'Pendaftaran Dibuka';

    final categories = ['Teknis', 'Manajerial', 'Fungsional', 'Soft Skill'];
    final statuses = ['Pendaftaran Dibuka', 'Pendaftaran Ditutup', 'Selesai', 'Dibatalkan'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      seminar == null ? 'Tambah Seminar' : 'Edit Seminar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Judul Seminar'),
                      _buildTextField(titleCtrl, 'Masukkan judul seminar'),
                      const SizedBox(height: 16),
                      _buildLabel('Kategori'),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: _inputDecoration('Pilih kategori'),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Tanggal'),
                      _buildTextField(dateCtrl, 'YYYY-MM-DD', icon: Icons.calendar_today_outlined),
                      const SizedBox(height: 16),
                      _buildLabel('Lokasi'),
                      _buildTextField(locationCtrl, 'Masukkan lokasi'),
                      const SizedBox(height: 16),
                      _buildLabel('Kapasitas'),
                      _buildTextField(capacityCtrl, '0', keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildLabel('Status'),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: _inputDecoration('Pilih status'),
                        items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setModalState(() => selectedStatus = v!),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (titleCtrl.text.isEmpty) return;
                            final user = ref.read(authProvider).user;
                            final data = {
                              'title': titleCtrl.text,
                              'category': selectedCategory,
                              'date': dateCtrl.text,
                              'location': locationCtrl.text,
                              'capacity': int.tryParse(capacityCtrl.text) ?? 0,
                              'status': selectedStatus,
                              'authorId': user?.id,
                            };
                            bool success;
                            if (seminar == null) {
                              success = await ref.read(seminarProvider.notifier).create(data);
                            } else {
                              success = await ref.read(seminarProvider.notifier).update(seminar.id, data);
                            }
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await _refresh();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(seminar == null ? 'Seminar berhasil ditambahkan' : 'Seminar berhasil diperbarui'),
                                    backgroundColor: const Color(0xFF22C55E),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            seminar == null ? 'Simpan Seminar' : 'Perbarui Seminar',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SeminarModel seminar) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Seminar'),
        content: Text('Hapus "${seminar.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ref.read(seminarProvider.notifier).delete(seminar.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seminar berhasil dihapus'), backgroundColor: Color(0xFF22C55E)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seminarProvider);
    final filtered = state.seminars
        .where((s) => s.title.toLowerCase().contains(_search.toLowerCase()) ||
            s.category.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Kelola Seminar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0052CC)),
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF0052CC),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Cari seminar...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0052CC)),
                ),
              ),
            ),
          ),
          // Stats banner
          if (!state.isLoading)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} seminar',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? _buildError(state.errorMessage!)
                    : filtered.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _SeminarCard(
                                  seminar: filtered[index],
                                  onEdit: () => _showFormDialog(seminar: filtered[index]),
                                  onDelete: () => _confirmDelete(filtered[index]),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 12),
              Text(msg, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _refresh, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, color: Color(0xFFCBD5E1), size: 64),
            SizedBox(height: 12),
            Text('Belum ada seminar', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text('Tekan tombol + untuk menambahkan', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
          ],
        ),
      );
}

class _SeminarCard extends StatelessWidget {
  final SeminarModel seminar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SeminarCard({required this.seminar, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isOpen = seminar.status == 'Pendaftaran Dibuka';
    final fillRatio = seminar.capacity > 0 ? seminar.registered / seminar.capacity : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052CC).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    seminar.category,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF0052CC), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen ? const Color(0xFFF0FFF4) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOpen ? 'Aktif' : 'Tutup',
                    style: TextStyle(
                      fontSize: 11,
                      color: isOpen ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0052CC)),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              seminar.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  seminar.date.length > 10 ? seminar.date.substring(0, 10) : seminar.date,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    seminar.location,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Capacity bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Peserta: ${seminar.registered}/${seminar.capacity}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          Text(
                            '${(fillRatio * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fillRatio.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            fillRatio >= 1
                                ? const Color(0xFFEF4444)
                                : fillRatio >= 0.8
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF22C55E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
    );

Widget _buildTextField(
  TextEditingController ctrl,
  String hint, {
  IconData? icon,
  TextInputType keyboardType = TextInputType.text,
}) =>
    TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint, icon: icon),
    );

InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF94A3B8)) : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0052CC)),
      ),
    );
