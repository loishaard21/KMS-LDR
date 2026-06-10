import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/seminar_provider.dart';
import '../providers/participant_provider.dart';

class OperatorDashboard extends ConsumerStatefulWidget {
  const OperatorDashboard({super.key});

  @override
  ConsumerState<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends ConsumerState<OperatorDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(authProvider).user;
    await ref.read(seminarProvider.notifier).fetchAll(filterByAuthorId: user?.id);
    await ref.read(participantProvider.notifier).fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final seminarState = ref.watch(seminarProvider);
    final participantState = ref.watch(participantProvider);

    final seminars = seminarState.seminars;
    final seminarIds = seminars.map((s) => s.id).toSet();
    final myParticipants = participantState.participants
        .where((p) => p.seminarId != null && seminarIds.contains(p.seminarId))
        .toList();
    final certificatesCount = myParticipants
        .where((p) => p.status == 'Certificate Issued' || p.status == 'Attended')
        .length;

    final isLoading = seminarState.isLoading || participantState.isLoading;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${user?.name ?? 'Operator'} 👋',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kelola seminar & peserta instansi Anda',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF0052CC), Color(0xFF00B4D8)]),
                  ),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats
            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else ...[
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    label: 'Total Seminar',
                    value: seminars.length.toString(),
                    subtext: 'Data real-time',
                    icon: Icons.book_outlined,
                    iconColor: const Color(0xFF0052CC),
                    iconBgColor: const Color(0xFFEEF4FF),
                  ),
                  StatCard(
                    label: 'Total Peserta',
                    value: myParticipants.length.toString(),
                    subtext: 'Dari seminar Anda',
                    icon: Icons.people_outline,
                    iconColor: const Color(0xFF00B4D8),
                    iconBgColor: const Color(0xFFE0F7FA),
                  ),
                  StatCard(
                    label: 'Sertifikat Terbit',
                    value: certificatesCount.toString(),
                    subtext: 'Attended/Issued',
                    icon: Icons.workspace_premium_outlined,
                    iconColor: const Color(0xFF22C55E),
                    iconBgColor: const Color(0xFFF0FFF4),
                  ),
                  StatCard(
                    label: 'Kapasitas Rata²',
                    value: seminars.isNotEmpty
                        ? '${(seminars.fold<int>(0, (sum, s) => sum + s.registered) / seminars.length).round()}%'
                        : '0%',
                    subtext: 'Tingkat terisi',
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFFF59E0B),
                    iconBgColor: const Color(0xFFFFFBEB),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bar Chart
              _buildChartSection(),
              const SizedBox(height: 24),

              // Recent Seminars
              _buildRecentSeminars(seminars),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tren Peserta Bulanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 160,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final months = ['Okt', 'Nov', 'Des', 'Jan', 'Feb', 'Mar'];
                      return BarTooltipItem(
                        '${months[groupIndex]}\n${rod.toY.toInt()} peserta',
                        const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Okt', 'Nov', 'Des', 'Jan', 'Feb', 'Mar'];
                        if (value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(months[value.toInt()], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [42, 68, 35, 89, 120, 156].asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: const Color(0xFF0052CC),
                        width: 20,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      ),
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

  Widget _buildRecentSeminars(List seminars) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Konten Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
                Text('Seminar Anda', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          if (seminars.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Belum ada data seminar.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
            )
          else
            ...seminars.take(5).map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(s.category, style: const TextStyle(fontSize: 10, color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: s.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2332))),
                        const SizedBox(height: 3),
                        Text(s.date, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  // Capacity indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${s.registered}/${s.capacity}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: s.capacity > 0 ? s.registered / s.capacity : 0,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              s.registered >= s.capacity ? const Color(0xFFEF4444)
                                  : s.registered / s.capacity >= 0.8 ? const Color(0xFFF59E0B)
                                  : const Color(0xFF22C55E),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
