import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/material_model.dart';
import '../providers/material_provider.dart';

class KelolaMateriScreen extends ConsumerStatefulWidget {
  const KelolaMateriScreen({super.key});

  @override
  ConsumerState<KelolaMateriScreen> createState() => _KelolaMateriScreenState();
}

class _KelolaMateriScreenState extends ConsumerState<KelolaMateriScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(materialProvider.notifier).fetchAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(materialProvider.notifier).fetchAll();
  }

  Future<void> _showFormDialog({MaterialModel? material}) async {
    final titleCtrl = TextEditingController(text: material?.title ?? '');
    final descCtrl = TextEditingController(text: material?.description ?? '');
    final urlCtrl = TextEditingController(text: material?.url ?? '');
    final sizeCtrl = TextEditingController(text: material?.size ?? '');
    String selectedType = material?.type ?? 'PDF';

    final types = ['PDF', 'PPT', 'DOC', 'Video', 'Lainnya'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      material == null ? 'Tambah Materi' : 'Edit Materi',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20, right: 20, top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Judul Materi'),
                      _buildTextField(titleCtrl, 'Masukkan judul materi'),
                      const SizedBox(height: 16),
                      _buildLabel('Tipe File'),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: _inputDecoration('Pilih tipe'),
                        items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setModalState(() => selectedType = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Deskripsi'),
                      TextField(controller: descCtrl, maxLines: 3, decoration: _inputDecoration('Deskripsi singkat...')),
                      const SizedBox(height: 16),
                      _buildLabel('URL / Link Dokumen'),
                      _buildTextField(urlCtrl, 'https://...', icon: Icons.link),
                      const SizedBox(height: 16),
                      _buildLabel('Ukuran File'),
                      _buildTextField(sizeCtrl, 'cth: 2.5 MB'),
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
                            final data = {
                              'title': titleCtrl.text,
                              'type': selectedType,
                              'description': descCtrl.text,
                              'url': urlCtrl.text.isEmpty ? '#' : urlCtrl.text,
                              'size': sizeCtrl.text.isEmpty ? '1.0 MB' : sizeCtrl.text,
                            };
                            bool success;
                            if (material == null) {
                              success = await ref.read(materialProvider.notifier).create(data);
                            } else {
                              success = await ref.read(materialProvider.notifier).update(material.id, data);
                            }
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await _refresh();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(material == null ? 'Materi berhasil ditambahkan' : 'Materi berhasil diperbarui'),
                                  backgroundColor: const Color(0xFF22C55E),
                                ));
                              }
                            }
                          },
                          child: Text(
                            material == null ? 'Simpan Materi' : 'Perbarui Materi',
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

  Future<void> _confirmDelete(MaterialModel material) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Materi'),
        content: Text('Hapus "${material.title}"?'),
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
      final success = await ref.read(materialProvider.notifier).delete(material.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materi berhasil dihapus'), backgroundColor: Color(0xFF22C55E)),
        );
      }
    }
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return const Color(0xFFEF4444);
      case 'PPT': return const Color(0xFFF59E0B);
      case 'DOC': return const Color(0xFF0052CC);
      case 'VIDEO': return const Color(0xFF7C3AED);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return Icons.picture_as_pdf_outlined;
      case 'PPT': return Icons.slideshow_outlined;
      case 'VIDEO': return Icons.play_circle_outline;
      default: return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(materialProvider);
    final filtered = state.materials
        .where((m) => m.title.toLowerCase().contains(_search.toLowerCase()) ||
            m.type.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Kelola Materi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0052CC)), onPressed: _refresh),
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Cari materi...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0052CC))),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? Center(child: Text(state.errorMessage!, style: const TextStyle(color: Color(0xFF94A3B8))))
                    : filtered.isEmpty
                        ? const Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.folder_open_outlined, color: Color(0xFFCBD5E1), size: 64),
                              SizedBox(height: 12),
                              Text('Belum ada materi', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
                            ]),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final m = filtered[index];
                                final typeColor = _typeColor(m.type);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: [BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      width: 48, height: 48,
                                      decoration: BoxDecoration(
                                        color: typeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_typeIcon(m.type), color: typeColor, size: 24),
                                    ),
                                    title: Text(m.title,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Text(m.type, style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(m.size, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                        ]),
                                        if (m.description != null && m.description!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(m.description!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      onSelected: (v) {
                                        if (v == 'edit') _showFormDialog(material: m);
                                        if (v == 'delete') _confirmDelete(m);
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0052CC)), SizedBox(width: 8), Text('Edit')])),
                                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Color(0xFFEF4444)))])),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
    );

Widget _buildTextField(TextEditingController ctrl, String hint, {IconData? icon}) => TextField(
      controller: ctrl,
      decoration: _inputDecoration(hint, icon: icon),
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
