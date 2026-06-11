import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/regulation_model.dart';
import '../providers/regulation_provider.dart';

class KelolaRegulasiScreen extends ConsumerStatefulWidget {
  const KelolaRegulasiScreen({super.key});

  @override
  ConsumerState<KelolaRegulasiScreen> createState() => _KelolaRegulasiScreenState();
}

class _KelolaRegulasiScreenState extends ConsumerState<KelolaRegulasiScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(regulationProvider.notifier).fetchAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(regulationProvider.notifier).fetchAll();
  }

  Future<void> _showFormDialog({RegulationModel? regulation}) async {
    final titleCtrl = TextEditingController(text: regulation?.title ?? '');
    final groupCtrl = TextEditingController(text: regulation?.group ?? '');
    final urlCtrl = TextEditingController(text: regulation?.url ?? '');

    final groups = ['Undang-Undang', 'Peraturan Pemerintah', 'Peraturan Menteri', 'Peraturan Daerah', 'Keputusan'];
    String selectedGroup = groups.contains(regulation?.group) ? regulation!.group : groups.first;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                      regulation == null ? 'Tambah Regulasi' : 'Edit Regulasi',
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
                      _buildLabel('Judul Regulasi'),
                      _buildTextField(titleCtrl, 'Masukkan judul regulasi'),
                      const SizedBox(height: 16),
                      _buildLabel('Kelompok'),
                      DropdownButtonFormField<String>(
                        value: selectedGroup,
                        decoration: _inputDecoration('Pilih kelompok'),
                        items: groups.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) {
                          setModalState(() {
                            selectedGroup = v!;
                            groupCtrl.text = v;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('URL Dokumen'),
                      _buildTextField(urlCtrl, 'https://...', icon: Icons.link),
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
                              'group': selectedGroup,
                              'url': urlCtrl.text.isEmpty ? '#' : urlCtrl.text,
                            };
                            bool success;
                            if (regulation == null) {
                              success = await ref.read(regulationProvider.notifier).create(data);
                            } else {
                              success = await ref.read(regulationProvider.notifier).update(regulation.id, data);
                            }
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await _refresh();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(regulation == null ? 'Regulasi berhasil ditambahkan' : 'Regulasi berhasil diperbarui'),
                                  backgroundColor: const Color(0xFF22C55E),
                                ));
                              }
                            }
                          },
                          child: Text(
                            regulation == null ? 'Simpan Regulasi' : 'Perbarui Regulasi',
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

  Future<void> _confirmDelete(RegulationModel regulation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Regulasi'),
        content: Text('Hapus "${regulation.title}"?'),
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
      final success = await ref.read(regulationProvider.notifier).delete(regulation.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Regulasi berhasil dihapus'), backgroundColor: Color(0xFF22C55E)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(regulationProvider);

    // Group regulations by 'group'
    final allRegs = state.regulations
        .where((r) => r.title.toLowerCase().contains(_search.toLowerCase()) ||
            r.group.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    final grouped = <String, List<RegulationModel>>{};
    for (final r in allRegs) {
      grouped.putIfAbsent(r.group, () => []).add(r);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Kelola Regulasi',
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
                hintText: 'Cari regulasi...',
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
                    : allRegs.isEmpty
                        ? const Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.gavel_outlined, color: Color(0xFFCBD5E1), size: 64),
                              SizedBox(height: 12),
                              Text('Belum ada regulasi', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
                            ]),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: grouped.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF4FF),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              entry.key,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0052CC)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${entry.value.length} dokumen',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...entry.value.map((r) => Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                            boxShadow: [
                                              BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                                            ],
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            leading: Container(
                                              width: 40, height: 40,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF5F3FF),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(Icons.description_outlined, color: Color(0xFF7C3AED), size: 20),
                                            ),
                                            title: Text(
                                              r.title,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A2332)),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: r.url != '#'
                                                ? Text(r.url, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis)
                                                : null,
                                            trailing: PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              onSelected: (v) {
                                                if (v == 'edit') _showFormDialog(regulation: r);
                                                if (v == 'delete') _confirmDelete(r);
                                              },
                                              itemBuilder: (_) => [
                                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0052CC)), SizedBox(width: 8), Text('Edit')])),
                                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Color(0xFFEF4444)))])),
                                              ],
                                            ),
                                          ),
                                        )),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }).toList(),
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
