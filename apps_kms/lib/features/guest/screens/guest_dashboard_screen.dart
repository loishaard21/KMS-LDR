import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/seminar_model.dart';
import '../../../shared/models/article_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../admin/providers/seminar_provider.dart';
import '../../admin/providers/article_provider.dart';
import '../../admin/providers/material_provider.dart';
import 'guest_seminar_list_screen.dart';
import 'guest_seminar_detail_screen.dart';
import 'guest_article_list_screen.dart';
import 'guest_article_detail_screen.dart';
import 'guest_material_list_screen.dart';
import 'guest_regulation_list_screen.dart';
import 'guest_evaluation_list_screen.dart';
import 'guest_guide_list_screen.dart';

class GuestDashboardScreen extends ConsumerStatefulWidget {
  const GuestDashboardScreen({super.key});

  @override
  ConsumerState<GuestDashboardScreen> createState() => _GuestDashboardScreenState();
}

class _GuestDashboardScreenState extends ConsumerState<GuestDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch seminars, articles, and materials in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seminarProvider.notifier).fetchAll();
      ref.read(articleProvider.notifier).fetchAll();
      ref.read(materialProvider.notifier).fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final seminarState = ref.watch(seminarProvider);
    final articleState = ref.watch(articleProvider);
    final materialState = ref.watch(materialProvider);

    final recentSeminars = seminarState.seminars.take(3).toList();
    final recentArticles = articleState.articles.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052CC), Color(0xFF00B4D8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KMS Portal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2332),
                  ),
                ),
                Text(
                  'Pemprov Lampung',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: authState.user != null
                ? ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.dashboard, size: 14),
                    label: const Text('Panel Admin', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                : TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login, size: 14, color: AppTheme.primaryColor),
                    label: const Text(
                      'Login Admin',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(seminarProvider.notifier).fetchAll();
          await ref.read(articleProvider.notifier).fetchAll();
          await ref.read(materialProvider.notifier).fetchAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              _buildHeroSection(context, seminarState.seminars.length, materialState.materials.length),

              const SizedBox(height: 24),

              // Services/Features
              _buildServicesSection(context),

              const SizedBox(height: 24),

              // Recent Seminars
              _buildRecentSeminarsSection(context, seminarState.isLoading, recentSeminars),

              const SizedBox(height: 24),

              // Recent Articles
              _buildRecentArticlesSection(context, articleState.isLoading, recentArticles),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, int totalSeminars, int totalMaterials) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0052CC), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Portal Resmi Pemerintah Provinsi Lampung',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Knowledge Management System',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const Text(
            'Pemerintahan Digital',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFD6EFFF), fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Platform terpadu manajemen pengetahuan, seminar, dan pelatihan ASN Pemerintah Provinsi Lampung.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuestSeminarListScreen(initialSearchQuery: val.trim()),
                    ),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: 'Cari seminar, materi, artikel...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Color(0xFF0052CC)),
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GuestSeminarListScreen(initialSearchQuery: query),
                        ),
                      );
                    }
                  },
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mini Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeroStatCard('Seminar', totalSeminars > 0 ? totalSeminars.toString() : '48', Icons.book_outlined),
              _buildHeroStatCard('Materi', totalMaterials > 0 ? totalMaterials.toString() : '124', Icons.file_present_outlined),
              _buildHeroStatCard('Sertifikat', '3.892', Icons.workspace_premium_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatCard(String label, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan Kami',
            style: TextStyle(color: Color(0xFF0052CC), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Fitur Unggulan Platform',
            style: TextStyle(color: Color(0xFF1A2332), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildServiceCard(
                  context,
                  title: 'Jadwal',
                  desc: 'Pantau seluruh agenda seminar yang akan datang.',
                  icon: Icons.calendar_today_outlined,
                  color: const Color(0xFF0052CC),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuestSeminarListScreen()),
                  ),
                ),
                _buildServiceCard(
                  context,
                  title: 'Regulasi',
                  desc: 'Akses kebijakan SPBE dan Pergub Lampung.',
                  icon: Icons.gavel_outlined,
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuestRegulationListScreen()),
                  ),
                ),
                _buildServiceCard(
                  context,
                  title: 'Materi',
                  desc: 'Unduh modul, panduan, dan template.',
                  icon: Icons.book_outlined,
                  color: const Color(0xFF22C55E),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuestMaterialListScreen()),
                  ),
                ),
                _buildServiceCard(
                  context,
                  title: 'Evaluasi',
                  desc: 'Rekap hasil evaluasi kegiatan.',
                  icon: Icons.bar_chart_outlined,
                  color: const Color(0xFF7C3AED),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuestEvaluationListScreen()),
                  ),
                ),
                _buildServiceCard(
                  context,
                  title: 'Panduan',
                  desc: 'Langkah-langkah penggunaan portal.',
                  icon: Icons.help_outline,
                  color: const Color(0xFF00B4D8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuestGuideListScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 140,
      height: 130,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A2332)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), height: 1.2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSeminarsSection(BuildContext context, bool isLoading, List<SeminarModel> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agenda Terkini',
                    style: TextStyle(color: Color(0xFF0052CC), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Seminar & Pelatihan',
                    style: TextStyle(color: Color(0xFF1A2332), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuestSeminarListScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Color(0xFF0052CC))),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF0052CC)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
          else if (list.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Belum ada seminar terbaru.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))))
          else
            Column(
              children: list.map((s) => _buildSeminarRowCard(context, s)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSeminarRowCard(BuildContext context, SeminarModel seminar) {
    final pct = (seminar.registered / seminar.capacity * 100).clamp(0, 100).round();
    final isFull = seminar.status == 'Kuota Penuh';
    final isOffline = seminar.mode.toLowerCase() == 'offline';
    final isOnline = seminar.mode.toLowerCase() == 'online';
    final modeColor = isOffline ? Colors.orange : isOnline ? Colors.blue : Colors.purple;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GuestSeminarDetailScreen(seminar: seminar)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Thumbnail
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(12),
                      image: seminar.cover != null && seminar.cover!.isNotEmpty
                          ? DecorationImage(image: NetworkImage(seminar.cover!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: seminar.cover == null || seminar.cover!.isEmpty
                        ? const Icon(Icons.image, color: Color(0xFF94A3B8), size: 28)
                        : null,
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
                                color: modeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                seminar.mode,
                                style: TextStyle(fontSize: 9, color: modeColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isFull ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                seminar.status,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isFull ? const Color(0xFFEF4444) : const Color(0xFF15803D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          seminar.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A2332), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Speaker Info
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${seminar.speaker} (${seminar.speakerRole})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Date & Location Info
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    seminar.date,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      seminar.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: seminar.registered / seminar.capacity,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pct >= 90 ? const Color(0xFFEF4444) : pct >= 60 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${seminar.registered}/${seminar.capacity} ($pct%)',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentArticlesSection(BuildContext context, bool isLoading, List<ArticleModel> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Terkini',
                    style: TextStyle(color: Color(0xFF0052CC), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Artikel & Berita',
                    style: TextStyle(color: Color(0xFF1A2332), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuestArticleListScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Color(0xFF0052CC))),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF0052CC)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
          else if (list.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Belum ada artikel terbaru.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final a = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  elevation: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GuestArticleDetailScreen(article: a)),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF4FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        a.category,
                                        style: const TextStyle(fontSize: 9, color: Color(0xFF0052CC), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      a.date,
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  a.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A2332), height: 1.3),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  a.excerpt ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                                ),
                              ],
                            ),
                          ),
                          if (a.cover != null && a.cover!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: NetworkImage(a.cover!), fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
