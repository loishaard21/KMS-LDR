import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/regulation_model.dart';
import '../../admin/providers/regulation_provider.dart';

class GuestRegulationListScreen extends ConsumerStatefulWidget {
  const GuestRegulationListScreen({super.key});

  @override
  ConsumerState<GuestRegulationListScreen> createState() => _GuestRegulationListScreenState();
}

class _GuestRegulationListScreenState extends ConsumerState<GuestRegulationListScreen> {
  final List<String> _groupOrder = [
    'Undang-undang',
    'Peraturan Presiden',
    'Keputusan Presiden',
    'Peraturan Menteri',
    'Keputusan Menteri',
    'Peraturan Daerah',
    'Peraturan Gubernur',
    'Keputusan Gubernur',
    'SPBE',
    'Pemerintahan Digital'
  ];

  final Map<String, Color> _groupColors = {
    'Undang-undang': const Color(0xFFF59E0B),
    'Peraturan Presiden': const Color(0xFF0052CC),
    'Keputusan Presiden': const Color(0xFFF59E0B),
    'Peraturan Menteri': const Color(0xFF7C3AED),
    'Keputusan Menteri': const Color(0xFF00B4D8),
    'Peraturan Daerah': const Color(0xFFF59E0B),
    'Peraturan Gubernur': const Color(0xFFF59E0B),
    'Keputusan Gubernur': const Color(0xFFF59E0B),
    'SPBE': const Color(0xFF0052CC),
    'Pemerintahan Digital': const Color(0xFF7C3AED),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(regulationProvider.notifier).fetchAll();
    });
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    if (url.isEmpty || url == '#') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File regulasi tidak tersedia')),
      );
      return;
    }
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
    final regulationState = ref.watch(regulationProvider);

    // Grouping regulations locally
    final Map<String, List<RegulationModel>> groupedMap = {};
    for (var reg in regulationState.regulations) {
      final grp = reg.group;
      if (!groupedMap.containsKey(grp)) {
        groupedMap[grp] = [];
      }
      groupedMap[grp]!.add(reg);
    }

    // Sort the groups based on explicit order
    final sortedGroups = groupedMap.keys.toList()
      ..sort((a, b) {
        final idxA = _groupOrder.indexOf(a);
        final idxB = _groupOrder.indexOf(b);
        if (idxA == -1 && idxB == -1) return a.compareTo(b);
        if (idxA == -1) return 1;
        if (idxB == -1) return -1;
        return idxA.compareTo(idxB);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Regulasi & Kebijakan'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: regulationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sortedGroups.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada regulasi yang ditemukan.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(regulationProvider.notifier).fetchAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedGroups.length,
                    itemBuilder: (context, index) {
                      final grp = sortedGroups[index];
                      final items = groupedMap[grp]!;
                      final grpColor = _groupColors[grp] ?? const Color(0xFF0052CC);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: grpColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  grp,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A2332)),
                                ),
                              ],
                            ),
                          ),
                          ...items.map((item) => _buildRegulationCard(context, item, grpColor)),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildRegulationCard(BuildContext context, RegulationModel reg, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description_outlined, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reg.title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A2332), height: 1.3),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _downloadFile(context, reg.url),
              icon: const Icon(Icons.download, size: 12),
              label: const Text('UNDUH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
