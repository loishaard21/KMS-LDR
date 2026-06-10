import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/material_model.dart';
import '../../admin/providers/material_provider.dart';

class GuestMaterialListScreen extends ConsumerStatefulWidget {
  const GuestMaterialListScreen({super.key});

  @override
  ConsumerState<GuestMaterialListScreen> createState() => _GuestMaterialListScreenState();
}

class _GuestMaterialListScreenState extends ConsumerState<GuestMaterialListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(materialProvider.notifier).fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka link: $url')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialState = ref.watch(materialProvider);
    final query = _searchController.text.toLowerCase();

    final filtered = materialState.materials.where((m) {
      return m.title.toLowerCase().contains(query) ||
          (m.description != null && m.description!.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Materi & Dokumen'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Cari materi...',
                prefixIcon: Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Materials grid/list
          Expanded(
            child: materialState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada materi yang ditemukan.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(materialProvider.notifier).fetchAll(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final mat = filtered[index];
                            return _buildMaterialGridItem(context, mat);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialGridItem(BuildContext context, MaterialModel mat) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon / Emoji
                Text(
                  mat.icon.isNotEmpty ? mat.icon : '📄',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  mat.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A2332), height: 1.3),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  mat.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
            // Footer with size + download button
            Column(
              children: [
                const Divider(height: 12, color: Color(0xFFF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${mat.type} · ${mat.size}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _downloadFile(context, mat.url),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.download, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
