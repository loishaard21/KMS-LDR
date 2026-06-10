import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/article_model.dart';
import '../../admin/providers/article_provider.dart';
import 'guest_article_detail_screen.dart';

class GuestArticleListScreen extends ConsumerStatefulWidget {
  const GuestArticleListScreen({super.key});

  @override
  ConsumerState<GuestArticleListScreen> createState() => _GuestArticleListScreenState();
}

class _GuestArticleListScreenState extends ConsumerState<GuestArticleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Berita', 'Sosialisasi', 'Regulasi', 'Panduan SPBE'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleProvider.notifier).fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleState = ref.watch(articleProvider);

    final query = _searchController.text.trim().toLowerCase();
    final filteredArticles = articleState.articles.where((a) {
      final matchSearch = a.title.toLowerCase().contains(query) ||
          (a.excerpt != null && a.excerpt!.toLowerCase().contains(query));
      final matchCategory = _selectedCategory == 'Semua' || a.category == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Artikel & Berita'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter & Search Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari artikel...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Buttons Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            cat, 
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0052CC),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Articles List
          Expanded(
            child: articleState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredArticles.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada artikel yang ditemukan.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(articleProvider.notifier).fetchAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = filteredArticles[index];
                            return _buildArticleCard(context, article);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GuestArticleDetailScreen(article: article)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            if (article.cover != null && article.cover!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: Image.network(
                  article.cover!,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: const Color(0xFFEEF4FF),
                    child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 36),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF0052CC), fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        article.date,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A2332), height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.excerpt ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text(
                        'Baca Selengkapnya',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0052CC)),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 12, color: Color(0xFF0052CC)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
