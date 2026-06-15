import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/article_model.dart';
import '../providers/article_provider.dart';
import '../../auth/providers/auth_provider.dart';

class KelolaArtikelScreen extends ConsumerStatefulWidget {
  const KelolaArtikelScreen({super.key});

  @override
  ConsumerState<KelolaArtikelScreen> createState() => _KelolaArtikelScreenState();
}

class _KelolaArtikelScreenState extends ConsumerState<KelolaArtikelScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleProvider.notifier).fetchAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(articleProvider.notifier).fetchAll();
  }

  Future<void> _showFormDialog({ArticleModel? article}) async {
    final titleCtrl = TextEditingController(text: article?.title ?? '');
    final excerptCtrl = TextEditingController(text: article?.excerpt ?? '');
    final contentCtrl = TextEditingController(text: article?.content ?? '');
    String selectedCategory = article?.category ?? 'Berita';

    final categories = ['Form', 'Berita', 'Sosialisasi', 'Regulasi', 'Panduan SPBE'];

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
                      article == null ? 'Tambah Artikel' : 'Edit Artikel',
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
                      _buildLabel('Judul Artikel'),
                      _buildTextField(titleCtrl, 'Masukkan judul artikel'),
                      const SizedBox(height: 16),
                      _buildLabel('Kategori'),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: _inputDecoration('Pilih kategori'),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Ringkasan'),
                      TextField(
                        controller: excerptCtrl,
                        maxLines: 3,
                        decoration: _inputDecoration('Ringkasan artikel...'),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Konten'),
                      TextField(
                        controller: contentCtrl,
                        maxLines: 6,
                        decoration: _inputDecoration('Isi konten artikel...'),
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
                              'excerpt': excerptCtrl.text,
                              'content': contentCtrl.text,
                              'date': DateTime.now().toIso8601String().substring(0, 10),
                              'authorId': user?.id,
                            };
                            bool success;
                            if (article == null) {
                              success = await ref.read(articleProvider.notifier).create(data);
                            } else {
                              success = await ref.read(articleProvider.notifier).update(article.id, data);
                            }
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await _refresh();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(article == null ? 'Artikel berhasil ditambahkan' : 'Artikel berhasil diperbarui'),
                                  backgroundColor: const Color(0xFF22C55E),
                                ));
                              }
                            }
                          },
                          child: Text(
                            article == null ? 'Simpan Artikel' : 'Perbarui Artikel',
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

  Future<void> _confirmDelete(ArticleModel article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Artikel'),
        content: Text('Hapus "${article.title}"?'),
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
      final success = await ref.read(articleProvider.notifier).delete(article.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus'), backgroundColor: Color(0xFF22C55E)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleProvider);
    final filtered = state.articles
        .where((a) => a.title.toLowerCase().contains(_search.toLowerCase()) ||
            a.category.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Kelola Artikel',
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
                hintText: 'Cari artikel...',
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
                              Icon(Icons.newspaper_outlined, color: Color(0xFFCBD5E1), size: 64),
                              SizedBox(height: 12),
                              Text('Belum ada artikel', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
                            ]),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final a = filtered[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2)),
                                    ],
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
                                              child: Text(a.category, style: const TextStyle(fontSize: 11, color: Color(0xFF0052CC), fontWeight: FontWeight.w600)),
                                            ),
                                            const Spacer(),
                                            Text(
                                              a.date.length > 10 ? a.date.substring(0, 10) : a.date,
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              onSelected: (v) {
                                                if (v == 'edit') _showFormDialog(article: a);
                                                if (v == 'delete') _confirmDelete(a);
                                              },
                                              itemBuilder: (_) => [
                                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0052CC)), SizedBox(width: 8), Text('Edit')])),
                                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Color(0xFFEF4444)))])),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(a.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        if (a.excerpt != null && a.excerpt!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(a.excerpt!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        ],
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

Widget _buildTextField(TextEditingController ctrl, String hint) => TextField(
      controller: ctrl,
      decoration: _inputDecoration(hint),
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
