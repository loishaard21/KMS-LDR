import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/guide_model.dart';
import '../../admin/providers/guide_provider.dart';

class GuestGuideListScreen extends ConsumerStatefulWidget {
  const GuestGuideListScreen({super.key});

  @override
  ConsumerState<GuestGuideListScreen> createState() => _GuestGuideListScreenState();
}

class _GuestGuideListScreenState extends ConsumerState<GuestGuideListScreen> {
  String _activeKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(guideProvider.notifier).fetchAll().then((_) {
        final state = ref.read(guideProvider);
        if (state.guides.isNotEmpty) {
          setState(() {
            _activeKey = state.guides[0].key;
          });
        }
      });
    });
  }

  String _stripHtml(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final guideState = ref.watch(guideProvider);

    // Sort guides by order/index
    final sortedGuides = [...guideState.guides]..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Panduan KMS'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: guideState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sortedGuides.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada panduan yang tersedia.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(guideProvider.notifier).fetchAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedGuides.length,
                    itemBuilder: (context, index) {
                      final item = sortedGuides[index];
                      final isOpen = _activeKey == item.key;

                      return _buildGuideAccordionItem(context, item, index, isOpen);
                    },
                  ),
                ),
    );
  }

  Widget _buildGuideAccordionItem(BuildContext context, GuideModel item, int index, bool isOpen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOpen ? const Color(0xFF0052CC) : const Color(0xFFE2E8F0),
          width: isOpen ? 1.5 : 1.0,
        ),
      ),
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: isOpen ? const Color(0xFF0052CC) : const Color(0xFFE2E8F0),
              child: Text(
                '${item.order > 0 ? item.order : index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOpen ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isOpen ? const Color(0xFF0052CC) : const Color(0xFF1E293B),
              ),
            ),
            trailing: Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isOpen ? const Color(0xFF0052CC) : const Color(0xFF64748B),
            ),
            onTap: () {
              setState(() {
                _activeKey = isOpen ? '' : item.key;
              });
            },
          ),
          if (isOpen) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFFF8FAFC),
              child: Text(
                _stripHtml(item.content),
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
