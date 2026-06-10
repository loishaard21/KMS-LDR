import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/evaluation_model.dart';
import '../../admin/providers/evaluation_provider.dart';

class GuestEvaluationListScreen extends ConsumerStatefulWidget {
  const GuestEvaluationListScreen({super.key});

  @override
  ConsumerState<GuestEvaluationListScreen> createState() => _GuestEvaluationListScreenState();
}

class _GuestEvaluationListScreenState extends ConsumerState<GuestEvaluationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(evaluationProvider.notifier).fetchAll();
    });
  }

  void _showDetailDialog(BuildContext context, EvaluationModel item) {
    final scoreColor = item.score >= 85 ? const Color(0xFF22C55E) : item.score >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    final scoreLabel = item.score >= 85 ? "Sangat Baik" : item.score >= 70 ? "Cukup Baik" : item.score > 0 ? "Perlu Perhatian" : "Belum Ada Skor";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.only(top: 16, left: 20, right: 20),
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart_outlined, color: Color(0xFF0052CC), size: 20),
                SizedBox(width: 8),
                Text('Detail Evaluasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Name
            const Text(
              'NAMA KEGIATAN',
              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),
            Text(
              item.activity,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
            ),
            const SizedBox(height: 16),

            // Category & Period
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kategori', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF4FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(fontSize: 9, color: Color(0xFF0052CC), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Periode', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 4),
                        Text(
                          item.period,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Score Panel
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SKOR EVALUASI', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.score > 0 ? scoreColor.withOpacity(0.15) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          scoreLabel,
                          style: TextStyle(fontSize: 9, color: item.score > 0 ? scoreColor : const Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (item.score > 0) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.score.toString(),
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: scoreColor),
                        ),
                        const SizedBox(width: 4),
                        const Text('/ 100', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 2.2)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.score / 100,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        minHeight: 6,
                      ),
                    ),
                  ] else ...[
                    const Row(
                      children: [
                        Icon(Icons.remove, color: Color(0xFF94A3B8), size: 14),
                        SizedBox(width: 6),
                        Text('Belum ada skor evaluasi', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('STATUS', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.status == 'Selesai' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: item.status == 'Selesai' ? const Color(0xFF15803D) : const Color(0xFFA16207),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tutup Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF4FF),
                  foregroundColor: const Color(0xFF0052CC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final evaluationState = ref.watch(evaluationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Evaluasi Kegiatan'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Rekap hasil evaluasi kegiatan seminar dan pelatihan Pemprov Lampung. Halaman ini bersifat read-only.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: evaluationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : evaluationState.evaluations.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada data evaluasi.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(evaluationProvider.notifier).fetchAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: evaluationState.evaluations.length,
                          itemBuilder: (context, index) {
                            final item = evaluationState.evaluations[index];
                            return _buildEvaluationCard(context, item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(BuildContext context, EvaluationModel item) {
    final scoreColor = item.score >= 85 ? const Color(0xFF22C55E) : item.score >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () => _showDetailDialog(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
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
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(fontSize: 9, color: Color(0xFF0052CC), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    item.period,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.activity,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A2332), height: 1.3),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Skor: ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      if (item.score > 0)
                        Text(
                          item.score.toString(),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scoreColor),
                        )
                      else
                        const Text('—', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.status == 'Selesai' ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: item.status == 'Selesai' ? const Color(0xFF15803D) : const Color(0xFFA16207),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
