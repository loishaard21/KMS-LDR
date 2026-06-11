import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/seminar_provider.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seminarProvider.notifier).fetchAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(seminarProvider.notifier).fetchAll();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pendaftaran Dibuka':
        return const Color(0xFF22C55E);
      case 'Selesai':
        return const Color(0xFF94A3B8);
      case 'Dibatalkan':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seminarProvider);

    // Sort by date
    final sorted = [...state.seminars]
      ..sort((a, b) => a.date.compareTo(b.date));

    // Group by month
    final grouped = <String, List<dynamic>>{};
    for (final s in sorted) {
      final key = s.date.length >= 7 ? s.date.substring(0, 7) : s.date;
      grouped.putIfAbsent(key, () => []).add(s);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Agenda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0052CC)), onPressed: _refresh),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.seminars.isEmpty
              ? const Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.calendar_month_outlined, color: Color(0xFFCBD5E1), size: 64),
                    SizedBox(height: 12),
                    Text('Belum ada agenda', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: grouped.entries.map((entry) {
                      // Parse month header
                      final parts = entry.key.split('-');
                      final year = parts.length > 0 ? parts[0] : '';
                      final month = parts.length > 1
                          ? _monthName(int.tryParse(parts[1]) ?? 1)
                          : '';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0052CC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$month $year',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.value.length} kegiatan',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          ...entry.value.map((s) {
                            final statusColor = _statusColor(s.status);
                            return Container(
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
                                    // Date indicator
                                    Container(
                                      width: 48,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF4FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            s.date.length >= 10 ? s.date.substring(8, 10) : '-',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0052CC)),
                                          ),
                                          Text(
                                            s.date.length >= 7 ? _monthShort(int.tryParse(s.date.substring(5, 7)) ?? 1) : '',
                                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(6)),
                                              child: Text(s.category, style: const TextStyle(fontSize: 10, color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                              child: Text(s.status, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                                            ),
                                          ]),
                                          const SizedBox(height: 6),
                                          Text(s.title,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
                                              maxLines: 2, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(s.location,
                                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ),
                                          ]),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            const Icon(Icons.people_outline, size: 12, color: Color(0xFF94A3B8)),
                                            const SizedBox(width: 3),
                                            Text('${s.registered}/${s.capacity} peserta',
                                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  String _monthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
  }

  String _monthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
  }
}
