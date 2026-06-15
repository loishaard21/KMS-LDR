import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/seminar_model.dart';
import '../providers/seminar_provider.dart';
import '../../auth/providers/auth_provider.dart';

const _categoryOptions = ['SPBE', 'Kompetensi', 'Kepemimpinan', 'Teknis', 'Fungsional'];
const _modeOptions = ['Hybrid', 'Online', 'Offline'];
const _statusOptions = ['Pendaftaran Dibuka', 'Kuota Penuh', 'Selesai'];
const _daftarTypes = ['Google Form', 'Link Eksternal', 'Teks/Info', 'Nonaktif'];

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
    final timeCtrl = TextEditingController(text: seminar?.time ?? '');
    final locationCtrl = TextEditingController(text: seminar?.location ?? '');
    final capacityCtrl = TextEditingController(text: seminar?.capacity.toString() ?? '100');
    final registeredCtrl = TextEditingController(text: seminar?.registered.toString() ?? '0');
    final speakerCtrl = TextEditingController(text: seminar?.speaker ?? '');
    final speakerRoleCtrl = TextEditingController(text: seminar?.speakerRole ?? '');
    final organizerCtrl = TextEditingController(text: seminar?.organizer ?? '');
    final descriptionCtrl = TextEditingController(text: seminar?.description ?? '');
    final daftarUrlCtrl = TextEditingController(text: seminar?.daftarUrl ?? '');
    final certificateUrlCtrl = TextEditingController(text: seminar?.certificateUrl ?? '');

    String selectedCategory = seminar?.category != null && _categoryOptions.contains(seminar!.category)
        ? seminar.category
        : _categoryOptions.first;
    String selectedMode = seminar?.mode != null && _modeOptions.contains(seminar!.mode)
        ? seminar.mode
        : _modeOptions.first;
    String selectedStatus = seminar?.status != null && _statusOptions.contains(seminar!.status)
        ? seminar.status
        : _statusOptions.first;
    String selectedDaftarType = seminar?.daftarType != null && _daftarTypes.contains(seminar!.daftarType)
        ? seminar.daftarType!
        : 'Google Form';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Text(
                      seminar == null ? 'Tambah Seminar' : 'Edit Seminar',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20, right: 20, top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Judul
                      _buildLabel('Judul Seminar *'),
                      _buildTextField(titleCtrl, 'Judul seminar...'),
                      const SizedBox(height: 14),

                      // ── Kategori & Mode
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Kategori'),
                                DropdownButtonFormField<String>(
                                  value: selectedCategory,
                                  decoration: _inputDecoration('Pilih kategori'),
                                  items: _categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                  onChanged: (v) => setModalState(() => selectedCategory = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Mode'),
                                DropdownButtonFormField<String>(
                                  value: selectedMode,
                                  decoration: _inputDecoration('Mode'),
                                  items: _modeOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                  onChanged: (v) => setModalState(() => selectedMode = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Status
                      _buildLabel('Status'),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: _inputDecoration('Pilih status'),
                        items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setModalState(() => selectedStatus = v!),
                      ),
                      const SizedBox(height: 14),

                      // ── Tanggal & Waktu
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Tanggal *'),
                                _buildTextField(dateCtrl, 'Cth: 25 April 2025', icon: Icons.calendar_today_outlined),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Waktu *'),
                                _buildTextField(timeCtrl, 'Cth: 09.00 - 12.00 WIB', icon: Icons.access_time_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Narasumber
                      _buildLabel('Narasumber *'),
                      _buildTextField(speakerCtrl, 'Nama narasumber...', icon: Icons.person_outline),
                      const SizedBox(height: 14),

                      // ── Jabatan Narasumber
                      _buildLabel('Jabatan Narasumber *'),
                      _buildTextField(speakerRoleCtrl, 'Cth: Kepala Dinas Kominfo', icon: Icons.badge_outlined),
                      const SizedBox(height: 14),

                      // ── Lokasi
                      _buildLabel('Lokasi *'),
                      _buildTextField(locationCtrl, 'Lokasi kegiatan...', icon: Icons.location_on_outlined),
                      const SizedBox(height: 14),

                      // ── Kapasitas & Terdaftar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Kapasitas'),
                                _buildTextField(capacityCtrl, '100', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Jumlah Terdaftar'),
                                _buildTextField(registeredCtrl, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Penyelenggara
                      _buildLabel('Penyelenggara *'),
                      _buildTextField(organizerCtrl, 'Cth: Dinas Kominfo Pemprov Lampung', icon: Icons.apartment_outlined),
                      const SizedBox(height: 14),

                      // ── Deskripsi
                      _buildLabel('Deskripsi'),
                      TextField(
                        controller: descriptionCtrl,
                        maxLines: 3,
                        decoration: _inputDecoration('Deskripsi seminar...'),
                      ),
                      const SizedBox(height: 14),

                      // ── Konfigurasi Tombol Daftar
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Konfigurasi Tombol Daftar',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                            ),
                            const SizedBox(height: 10),
                            _buildLabel('Tipe Tombol Daftar'),
                            DropdownButtonFormField<String>(
                              value: selectedDaftarType,
                              decoration: _inputDecoration('Pilih tipe'),
                              items: _daftarTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) => setModalState(() => selectedDaftarType = v!),
                            ),
                            if (selectedDaftarType != 'Nonaktif') ...[
                              const SizedBox(height: 10),
                              _buildLabel(selectedDaftarType == 'Teks/Info' ? 'Isi Teks/Pesan' : 'URL Tautan'),
                              if (selectedDaftarType == 'Teks/Info')
                                TextField(
                                  controller: daftarUrlCtrl,
                                  maxLines: 2,
                                  decoration: _inputDecoration('Tulis pesan/informasi...'),
                                )
                              else
                                _buildTextField(daftarUrlCtrl, 'https://...', icon: Icons.link_outlined),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── URL Sertifikat
                      _buildLabel('URL Sertifikat (Google Drive)'),
                      _buildTextField(certificateUrlCtrl, 'https://drive.google.com/...', icon: Icons.workspace_premium_outlined),
                      const SizedBox(height: 24),

                      // ── Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (titleCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Judul seminar wajib diisi.'),
                                  backgroundColor: Color(0xFFEF4444),
                                ),
                              );
                              return;
                            }
                            final user = ref.read(authProvider).user;
                            final cap = int.tryParse(capacityCtrl.text) ?? 0;
                            final reg = int.tryParse(registeredCtrl.text) ?? 0;
                            // Auto-suggest status
                            String finalStatus = selectedStatus;
                            if (reg >= cap && cap > 0) finalStatus = 'Kuota Penuh';

                            final data = {
                              'title': titleCtrl.text,
                              'category': selectedCategory,
                              'mode': selectedMode,
                              'status': finalStatus,
                              'date': dateCtrl.text,
                              'time': timeCtrl.text,
                              'speaker': speakerCtrl.text,
                              'speakerRole': speakerRoleCtrl.text,
                              'location': locationCtrl.text,
                              'capacity': cap,
                              'registered': reg,
                              'organizer': organizerCtrl.text,
                              'description': descriptionCtrl.text,
                              'daftarType': selectedDaftarType,
                              'daftarUrl': daftarUrlCtrl.text,
                              'certificateUrl': certificateUrlCtrl.text,
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
                                    content: Text(seminar == null
                                        ? 'Seminar berhasil ditambahkan'
                                        : 'Seminar berhasil diperbarui'),
                                    backgroundColor: const Color(0xFF22C55E),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            seminar == null ? 'Simpan Seminar' : 'Perbarui Seminar',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
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
        content: Text('Apakah Anda yakin ingin menghapus seminar "${seminar.title}"?'),
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
        .where((s) =>
            s.title.toLowerCase().contains(_search.toLowerCase()) ||
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
        backgroundColor: const Color(0xFF22C55E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Seminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Header info
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Seminar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                ),
                const Text(
                  'Manajemen seminar, pelatihan, dan workshop.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                // Search bar
                TextField(
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
                const SizedBox(height: 10),
                if (!state.isLoading)
                  Text(
                    '${filtered.length} seminar',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                const SizedBox(height: 8),
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
            Text('Belum ada data seminar.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text('Klik tombol + untuk menambahkan.', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SEMINAR CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SeminarCard extends StatelessWidget {
  final SeminarModel seminar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SeminarCard({required this.seminar, required this.onEdit, required this.onDelete});

  Color get _statusColor {
    switch (seminar.status) {
      case 'Pendaftaran Dibuka':
        return const Color(0xFF22C55E);
      case 'Kuota Penuh':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color get _statusBg {
    switch (seminar.status) {
      case 'Pendaftaran Dibuka':
        return const Color(0xFFF0FFF4);
      case 'Kuota Penuh':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get _modeColor {
    switch (seminar.mode) {
      case 'Online':
        return const Color(0xFF0052CC);
      case 'Offline':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Badge row
            Row(
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
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _modeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    seminar.mode,
                    style: TextStyle(fontSize: 11, color: _modeColor, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    seminar.status,
                    style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600),
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

            // Title
            Text(
              seminar.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Date, Time, Location row
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _infoItem(Icons.calendar_today_outlined,
                    seminar.date.length > 10 ? seminar.date.substring(0, 10) : seminar.date),
                if (seminar.time != null && seminar.time!.isNotEmpty)
                  _infoItem(Icons.access_time_outlined, seminar.time!),
                _infoItem(Icons.location_on_outlined, seminar.location),
              ],
            ),

            // Speaker
            if (seminar.speaker.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoItem(Icons.person_outline, '${seminar.speaker}${seminar.speakerRole.isNotEmpty ? ' · ${seminar.speakerRole}' : ''}'),
            ],

            // Daftar type badge
            if (seminar.daftarType != null && seminar.daftarType!.isNotEmpty && seminar.daftarType != 'Nonaktif') ...[
              const SizedBox(height: 6),
              _infoItem(Icons.how_to_reg_outlined, 'Pendaftaran: ${seminar.daftarType}'),
            ],

            const SizedBox(height: 12),

            // Capacity progress bar
            Column(
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
                      '${(fillRatio * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: fillRatio >= 1
                            ? const Color(0xFFEF4444)
                            : fillRatio >= 0.8
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF22C55E),
                      ),
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
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

// ─── Helper widgets ────────────────────────────────────────────────────────────
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
