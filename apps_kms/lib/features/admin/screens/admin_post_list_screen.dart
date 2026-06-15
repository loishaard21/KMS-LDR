import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/article_provider.dart';
import '../providers/seminar_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'kelola_artikel_screen.dart' as artikel;
import '../../guest/screens/guest_seminar_detail_screen.dart';
import '../../guest/screens/guest_article_detail_screen.dart';
import '../../../shared/models/article_model.dart';
import '../../../shared/models/seminar_model.dart';

// Unified Post model for display
class _Post {
  final String id;
  final String title;
  final String category;
  final String date;
  final String status;
  final String createdBy;
  final String type; // 'Artikel' or 'Seminar'

  const _Post({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.status,
    required this.createdBy,
    required this.type,
  });
}

class AdminPostListScreen extends ConsumerStatefulWidget {
  const AdminPostListScreen({super.key});

  @override
  ConsumerState<AdminPostListScreen> createState() => _AdminPostListScreenState();
}

class _AdminPostListScreenState extends ConsumerState<AdminPostListScreen> {
  String _search = '';
  String _filterType = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleProvider.notifier).fetchAll();
      ref.read(seminarProvider.notifier).fetchAll();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(articleProvider.notifier).fetchAll(),
      ref.read(seminarProvider.notifier).fetchAll(),
    ]);
  }

  List<_Post> _getMergedPosts(ArticleState articleState, SeminarState seminarState) {
    final posts = <_Post>[];

    for (final a in articleState.articles) {
      posts.add(_Post(
        id: a.id,
        title: a.title,
        category: a.category,
        date: a.date,
        status: 'Aktif',
        createdBy: (a.author?['name'] as String?) ?? 'System',
        type: 'Artikel',
      ));
    }

    for (final s in seminarState.seminars) {
      posts.add(_Post(
        id: s.id,
        title: s.title,
        category: s.category,
        date: s.date,
        status: s.status == 'Pendaftaran Dibuka' ? 'Aktif' : 'Tutup',
        createdBy: (s.author?['name'] as String?) ?? 'Operator',
        type: 'Seminar',
      ));
    }

    return posts;
  }

  void _handleView(_Post p) {
    if (p.type == 'Artikel') {
      final article = ref.read(articleProvider).articles.firstWhere((a) => a.id == p.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuestArticleDetailScreen(article: article),
        ),
      );
    } else {
      final seminar = ref.read(seminarProvider).seminars.firstWhere((s) => s.id == p.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuestSeminarDetailScreen(seminar: seminar),
        ),
      );
    }
  }

  void _handleEdit(_Post p) {
    if (p.type == 'Artikel') {
      final article = ref.read(articleProvider).articles.firstWhere((a) => a.id == p.id);
      _showEditArticleDialog(article);
    } else {
      final seminar = ref.read(seminarProvider).seminars.firstWhere((s) => s.id == p.id);
      _showEditSeminarDialog(seminar);
    }
  }

  Future<void> _confirmDelete(_Post p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus ${p.type}'),
        content: Text('Apakah Anda yakin ingin menghapus ${p.type.toLowerCase()} "${p.title}"?'),
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
      bool success;
      if (p.type == 'Artikel') {
        success = await ref.read(articleProvider.notifier).delete(p.id);
      } else {
        success = await ref.read(seminarProvider.notifier).delete(p.id);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${p.type} berhasil dihapus'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        _refresh();
      }
    }
  }

  Future<void> _showEditArticleDialog(ArticleModel article) async {
    final titleCtrl = TextEditingController(text: article.title);
    final excerptCtrl = TextEditingController(text: article.excerpt ?? '');
    final contentCtrl = TextEditingController(text: article.content ?? '');
    String selectedCategory = article.category.isNotEmpty ? article.category : 'Berita';

    final categories = ['Form', 'Berita', 'Sosialisasi', 'Regulasi', 'Panduan SPBE'];
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }

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
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('Edit Artikel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
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
                      const Text('Judul Artikel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(controller: titleCtrl, decoration: _dialogInputDecoration('Masukkan judul artikel')),
                      const SizedBox(height: 16),
                      const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: Colors.white,
                        decoration: _dialogInputDecoration('Pilih kategori'),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      const Text('Ringkasan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(controller: excerptCtrl, maxLines: 3, decoration: _dialogInputDecoration('Ringkasan artikel...')),
                      const SizedBox(height: 16),
                      const Text('Konten', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(controller: contentCtrl, maxLines: 6, decoration: _dialogInputDecoration('Isi konten artikel...')),
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
                              'category': selectedCategory,
                              'excerpt': excerptCtrl.text,
                              'content': contentCtrl.text,
                              'date': article.date,
                            };
                            final success = await ref.read(articleProvider.notifier).update(article.id, data);
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await _refresh();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Artikel berhasil diperbarui'),
                                  backgroundColor: Color(0xFF22C55E),
                                ));
                              }
                            }
                          },
                          child: const Text('Perbarui Artikel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

  Future<void> _showEditSeminarDialog(SeminarModel seminar) async {
    final titleCtrl = TextEditingController(text: seminar.title);
    final dateCtrl = TextEditingController(text: seminar.date);
    final locationCtrl = TextEditingController(text: seminar.location);
    final capacityCtrl = TextEditingController(text: seminar.capacity.toString());
    String selectedCategory = seminar.category.isNotEmpty ? seminar.category : 'Teknis';
    String selectedStatus = seminar.status.isNotEmpty ? seminar.status : 'Pendaftaran Dibuka';

    final categories = ['Teknis', 'Manajerial', 'Fungsional', 'Soft Skill'];
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }
    final statuses = ['Pendaftaran Dibuka', 'Pendaftaran Ditutup', 'Selesai', 'Dibatalkan'];
    if (!statuses.contains(selectedStatus)) {
      statuses.add(selectedStatus);
    }

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
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('Edit Seminar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
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
                      const Text('Judul Seminar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(controller: titleCtrl, decoration: _dialogInputDecoration('Masukkan judul seminar')),
                      const SizedBox(height: 16),
                      const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: Colors.white,
                        decoration: _dialogInputDecoration('Pilih kategori'),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tanggal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(controller: dateCtrl, decoration: _dialogInputDecoration('YYYY-MM-DD', icon: Icons.calendar_today_outlined)),
                      const SizedBox(height: 16),
                      const Text('Lokasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(controller: locationCtrl, decoration: _dialogInputDecoration('Masukkan lokasi')),
                      const SizedBox(height: 16),
                      const Text('Kapasitas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: _dialogInputDecoration('0')),
                      const SizedBox(height: 16),
                      const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        dropdownColor: Colors.white,
                        decoration: _dialogInputDecoration('Pilih status'),
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
                            final data = {
                              'title': titleCtrl.text,
                              'category': selectedCategory,
                              'date': dateCtrl.text,
                              'location': locationCtrl.text,
                              'capacity': int.tryParse(capacityCtrl.text) ?? 0,
                              'status': selectedStatus,
                            };
                            final success = await ref.read(seminarProvider.notifier).update(seminar.id, data);
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await _refresh();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Seminar berhasil diperbarui'),
                                  backgroundColor: Color(0xFF22C55E),
                                ));
                              }
                            }
                          },
                          child: const Text('Perbarui Seminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

  InputDecoration _dialogInputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
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
  }

  @override
  Widget build(BuildContext context) {
    final articleState = ref.watch(articleProvider);
    final seminarState = ref.watch(seminarProvider);
    final isLoading = articleState.isLoading || seminarState.isLoading;

    final allPosts = _getMergedPosts(articleState, seminarState);
    final filtered = allPosts.where((p) {
      final matchSearch = p.title.toLowerCase().contains(_search.toLowerCase()) ||
          p.category.toLowerCase().contains(_search.toLowerCase());
      final matchType = _filterType == 'Semua' || p.type == _filterType;
      return matchSearch && matchType;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('All Posts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0052CC)), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          // Search + filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Cari post...',
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
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Semua', 'Artikel', 'Seminar'].map((type) {
                      final isActive = _filterType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filterType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF0052CC) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Stats row
          if (!isLoading)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('${filtered.length} post', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ),
          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.article_outlined, color: Color(0xFFCBD5E1), size: 64),
                          SizedBox(height: 12),
                          Text('Tidak ada post', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
                        ]),
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final p = filtered[index];
                            final isActive = p.status == 'Aktif';
                            final isArticle = p.type == 'Artikel';
                            return GestureDetector(
                              onTap: () => _handleView(p),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Type icon
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(
                                          color: isArticle ? const Color(0xFFF5F3FF) : const Color(0xFFEEF4FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isArticle ? Icons.newspaper_outlined : Icons.book_outlined,
                                          color: isArticle ? const Color(0xFF7C3AED) : const Color(0xFF0052CC),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isArticle ? const Color(0xFFF5F3FF) : const Color(0xFFEEF4FF),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    p.type,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: isArticle ? const Color(0xFF7C3AED) : const Color(0xFF0052CC),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isActive ? const Color(0xFFF0FFF4) : const Color(0xFFFEF2F2),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    p.status,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(p.title,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
                                                maxLines: 2, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 4),
                                            Row(children: [
                                              const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF94A3B8)),
                                              const SizedBox(width: 3),
                                              Text(
                                                p.date.length > 10 ? p.date.substring(0, 10) : p.date,
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(Icons.person_outline, size: 11, color: Color(0xFF94A3B8)),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(p.createdBy,
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        onSelected: (v) {
                                          if (v == 'view') _handleView(p);
                                          if (v == 'edit') _handleEdit(p);
                                          if (v == 'delete') _confirmDelete(p);
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                            value: 'view',
                                            child: Row(children: [
                                              Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF0052CC)),
                                              SizedBox(width: 8),
                                              Text('Lihat'),
                                            ]),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(children: [
                                              Icon(Icons.edit_outlined, size: 16, color: Color(0xFFD97706)),
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
