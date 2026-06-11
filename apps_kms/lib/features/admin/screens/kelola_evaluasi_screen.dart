import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/evaluation_model.dart';
import '../providers/evaluation_provider.dart';

class KelolaEvaluasiScreen extends ConsumerStatefulWidget {
  const KelolaEvaluasiScreen({super.key});

  @override
  ConsumerState<KelolaEvaluasiScreen> createState() => _KelolaEvaluasiScreenState();
}

class _KelolaEvaluasiScreenState extends ConsumerState<KelolaEvaluasiScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(evaluationProvider.notifier).fetchAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(evaluationProvider.notifier).fetchAll();
  }

  Color _scoreColor(double score) {
    if (score >= 80) return const Color(0xFF22C55E);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai': return const Color(0xFF22C55E);
      case 'Dalam Proses': return const Color(0xFFF59E0B);
      case 'Belum Dimulai': return const Color(0xFF94A3B8);
      default: return const Color(0xFF94A3B8);
    }
  }

  Future<void> _showFormDialog({EvaluationModel? evaluation}) async {
    final activityCtrl = TextEditingController(text: evaluation?.activity ?? '');
    final periodCtrl = TextEditingController(text: evaluation?.period ?? '');
    final scoreCtrl = TextEditingController(text: evaluation?.score.toString() ?? '');
    String selectedCategory = evaluation?.category ?? 'Seminar';
    String selectedStatus = evaluation?.status ?? 'Dalam Proses';

    final categories = ['Seminar', 'Pelatihan', 'Workshop', 'Webinar'];
    final statuses = ['Belum Dimulai', 'Dalam Proses', 'Selesai'];

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
                      evaluation == null ? 'Tambah Evaluasi' : 'Edit Evaluasi',
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
                      _buildLabel('Nama Kegiatan'),
                      _buildTextField(activityCtrl, 'Masukkan nama kegiatan'),
                      const SizedBox(height: 16),
                      _buildLabel('Kategori'),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: _inputDecoration('Pilih kategori'),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Periode'),
                      _buildTextField(periodCtrl, 'cth: 2024-Q1', icon: Icons.calendar_today_outlined),
                      const SizedBox(height: 16),
                      _buildLabel('Skor (0-100)'),
                      _buildTextField(scoreCtrl, '0', keyboardType: TextInputType.number),
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
                            if (activityCtrl.text.isEmpty) return;
                            final data = {
                              'activity': activityCtrl.text,
                              'category': selectedCategory,
                              'period': periodCtrl.text,
                              'score': double.tryParse(scoreCtrl.text) ?? 0,
                              'status': selectedStatus,
                            };
                            bool success;
                            if (evaluation == null) {
                              success = await ref.read(evaluationProvider.notifier).create(data);
                            } else {
                              success = await ref.read(evaluationProvider.notifier).update(evaluation.id, data);
                            }
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await _refresh();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(evaluation == null ? 'Evaluasi berhasil ditambahkan' : 'Evaluasi berhasil diperbarui'),
                                  backgroundColor: const Color(0xFF22C55E),
                                ));
                              }
                            }
                          },
                          child: Text(
                            evaluation == null ? 'Simpan Evaluasi' : 'Perbarui Evaluasi',
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

  Future<void> _confirmDelete(EvaluationModel evaluation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Evaluasi'),
        content: Text('Hapus "${evaluation.activity}"?'),
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
      final success = await ref.read(evaluationProvider.notifier).delete(evaluation.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evaluasi berhasil dihapus'), backgroundColor: Color(0xFF22C55E)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(evaluationProvider);
    final filtered = state.evaluations
        .where((e) => e.activity.toLowerCase().contains(_search.toLowerCase()) ||
            e.category.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Kelola Evaluasi',
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
                hintText: 'Cari evaluasi...',
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
                              Icon(Icons.bar_chart_outlined, color: Color(0xFFCBD5E1), size: 64),
                              SizedBox(height: 12),
                              Text('Belum ada evaluasi', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
                            ]),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final e = filtered[index];
                                final scoreColor = _scoreColor(e.score);
                                final statusColor = _statusColor(e.status);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: [BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(8)),
                                              child: Text(e.category, style: const TextStyle(fontSize: 11, color: Color(0xFF0052CC), fontWeight: FontWeight.w600)),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(e.status, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                                            ),
                                            const Spacer(),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              onSelected: (v) {
                                                if (v == 'edit') _showFormDialog(evaluation: e);
                                                if (v == 'delete') _confirmDelete(e);
                                              },
                                              itemBuilder: (_) => [
                                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0052CC)), SizedBox(width: 8), Text('Edit')])),
                                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Color(0xFFEF4444)))])),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(e.activity,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
                                            maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF94A3B8)),
                                            const SizedBox(width: 4),
                                            Text(e.period, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Score bar
                                        Row(
                                          children: [
                                            const Text('Skor:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: e.score / 100,
                                                  minHeight: 8,
                                                  backgroundColor: const Color(0xFFF1F5F9),
                                                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              e.score.toStringAsFixed(0),
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: scoreColor),
                                            ),
                                          ],
                                        ),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0052CC))),
    );
