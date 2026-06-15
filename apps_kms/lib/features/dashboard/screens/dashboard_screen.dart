import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/admin_drawer.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../shared/models/seminar_model.dart';
import '../../admin/providers/seminar_provider.dart';

// Import management screens
import '../../users/screens/operator_management_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../guest/screens/guest_seminar_detail_screen.dart';

// Admin feature screens
import '../../admin/screens/admin_post_list_screen.dart';
import '../../admin/screens/admin_add_post_screen.dart';
import '../../admin/screens/kelola_panduan_screen.dart';
import '../../admin/screens/kelola_regulasi_screen.dart';
import '../../admin/screens/agenda_screen.dart';
import '../../admin/screens/contact_screen.dart';

// Operator feature screens
import '../../admin/screens/kelola_seminar_screen.dart';
import '../../admin/screens/kelola_materi_screen.dart';
import '../../admin/screens/kelola_artikel_screen.dart';
import '../../admin/screens/kelola_evaluasi_screen.dart';
import '../../admin/screens/data_peserta_screen.dart';

// Monthly chart data matching the Next.js reference
const _monthlyData = [
  {'month': 'Okt', 'peserta': 42},
  {'month': 'Nov', 'peserta': 68},
  {'month': 'Des', 'peserta': 35},
  {'month': 'Jan', 'peserta': 89},
  {'month': 'Feb', 'peserta': 120},
  {'month': 'Mar', 'peserta': 156},
];

/// Main admin scaffold with drawer navigation matching the Next.js admin layout
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Drawer index — directly maps to MenuItem.index in admin_drawer.dart
  int _drawerIndex = 0;

  // ─── Admin screens (index 0–7 matching adminMenuItems) ───────────────────
  // 0: Dashboard
  // 1: All Posts
  // 2: Add Post
  // 3: Kelola Panduan
  // 4: Kelola Regulasi
  // 5: Agenda
  // 6: Kontak
  // 7: Akun Operator
  static const List<Widget> _adminScreens = [
    _SuperAdminDashboard(),         // 0
    AdminPostListScreen(),           // 1
    AdminAddPostScreen(),            // 2
    KelolaPanduanScreen(),          // 3
    KelolaRegulasiScreen(),         // 4
    AgendaScreen(),                  // 5
    ContactScreen(),                 // 6
    OperatorManagementScreen(),      // 7
  ];

  // ─── Operator screens (index 0–7 matching operatorMenuItems) ─────────────
  // 0: Dashboard
  // 1: Kelola Seminar
  // 2: Kelola Materi
  // 3: Kelola Artikel
  // 4: Kelola Regulasi
  // 5: Kelola Evaluasi
  // 6: Data Peserta
  // 7: Profil Saya
  static const List<Widget> _operatorScreens = [
    _OperatorDashboardContent(),    // 0
    KelolaSeminarScreen(),          // 1
    KelolaMateriScreen(),           // 2
    KelolaArtikelScreen(),          // 3
    KelolaRegulasiScreen(),         // 4
    KelolaEvaluasiScreen(),         // 5
    DataPesertaScreen(),            // 6
    ProfileScreen(),                // 7
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin = user.role == 'superadmin';
    final screens = isAdmin ? _adminScreens : _operatorScreens;

    // Clamp index to valid range for current role
    final safeIndex = _drawerIndex.clamp(0, screens.length - 1);

    // Bottom nav items — only Dashboard shown; rest via drawer
    final List<BottomNavigationBarItem> navItems = isAdmin
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Posts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Agenda',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Seminar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper),
              label: 'Artikel',
            ),
          ];

    // Map bottom nav tap to drawer index
    void onBottomNavTap(int navIdx) {
      if (isAdmin) {
        // 0→Dashboard(0), 1→AllPosts(1), 2→Agenda(5)
        const map = [0, 1, 5];
        setState(() => _drawerIndex = map[navIdx]);
      } else {
        // 0→Dashboard(0), 1→KelolaSeminar(1), 2→KelolaArtikel(3)
        const map = [0, 1, 3];
        setState(() => _drawerIndex = map[navIdx]);
      }
    }

    // Compute current bottom nav index from drawer index
    int bottomNavIndex = 0;
    if (isAdmin) {
      if (_drawerIndex == 1) bottomNavIndex = 1;
      if (_drawerIndex == 5) bottomNavIndex = 2;
    } else {
      if (_drawerIndex == 1) bottomNavIndex = 1;
      if (_drawerIndex == 3) bottomNavIndex = 2;
    }

    // App bar title changes based on selected screen
    final titles = isAdmin
        ? ['Dashboard', 'All Posts', 'Add Post', 'Kelola Panduan', 'Kelola Regulasi', 'Agenda', 'Kontak', 'Akun Operator']
        : ['Dashboard', 'Kelola Seminar', 'Kelola Materi', 'Kelola Artikel', 'Kelola Regulasi', 'Kelola Evaluasi', 'Data Peserta', 'Profil Saya'];

    final currentTitle = titles[safeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF1A2332)),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2332),
              ),
            ),
            const Text(
              'KMS Pemprov Lampung',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF0052CC), Color(0xFF00B4D8)],
              ),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D0052CC),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: AdminDrawer(
        currentIndex: safeIndex,
        onItemSelected: (index) {
          setState(() => _drawerIndex = index);
        },
      ),
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: bottomNavIndex,
          onTap: onBottomNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0052CC),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: navItems,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPER ADMIN DASHBOARD — matches SuperAdminDashboard.tsx
// ─────────────────────────────────────────────────────────────────────────────
class _SuperAdminDashboard extends ConsumerStatefulWidget {
  const _SuperAdminDashboard();

  @override
  ConsumerState<_SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<_SuperAdminDashboard> {
  static const _pieColors = [
    Color(0xFF0052CC),
    Color(0xFF00B4D8),
    Color(0xFF7C3AED),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).user;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            _buildWelcomeHeader(user?.name ?? 'SuperAdmin', 'Dashboard Super Admin Portal KMS'),

            const SizedBox(height: 24),

            // Error
            if (state.errorMessage != null) _buildErrorBanner(state.errorMessage!),

            // Responsive stat cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Seminar',
                          value: state.isLoading ? '...' : state.totalSeminars.toString(),
                          sub: '+3 bulan ini',
                          icon: Icons.book_outlined,
                          iconColor: const Color(0xFF0052CC),
                          iconBg: const Color(0xFFEEF4FF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Total Peserta',
                          value: state.isLoading ? '...' : state.totalParticipants.toString(),
                          sub: '+89 bulan ini',
                          icon: Icons.people_outline,
                          iconColor: const Color(0xFF00B4D8),
                          iconBg: const Color(0xFFE0F7FA),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Sertifikat Diterbitkan',
                          value: state.isLoading ? '...' : state.certificatesCount.toString(),
                          sub: '+12 bulan ini',
                          icon: Icons.workspace_premium_outlined,
                          iconColor: const Color(0xFF22C55E),
                          iconBg: const Color(0xFFF0FFF4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Total Artikel',
                          value: state.isLoading ? '...' : state.totalArticles.toString(),
                          sub: '+5 bulan ini',
                          icon: Icons.description_outlined,
                          iconColor: const Color(0xFF7C3AED),
                          iconBg: const Color(0xFFF5F3FF),
                        ),
                      ),
                    ],
                  );
                }
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    _StatCard(
                      label: 'Total Seminar',
                      value: state.isLoading ? '...' : state.totalSeminars.toString(),
                      sub: '+3 bulan ini',
                      icon: Icons.book_outlined,
                      iconColor: const Color(0xFF0052CC),
                      iconBg: const Color(0xFFEEF4FF),
                    ),
                    _StatCard(
                      label: 'Total Peserta',
                      value: state.isLoading ? '...' : state.totalParticipants.toString(),
                      sub: '+89 bulan ini',
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFF00B4D8),
                      iconBg: const Color(0xFFE0F7FA),
                    ),
                    _StatCard(
                      label: 'Sertifikat Diterbitkan',
                      value: state.isLoading ? '...' : state.certificatesCount.toString(),
                      sub: '+12 bulan ini',
                      icon: Icons.workspace_premium_outlined,
                      iconColor: const Color(0xFF22C55E),
                      iconBg: const Color(0xFFF0FFF4),
                    ),
                    _StatCard(
                      label: 'Total Artikel',
                      value: state.isLoading ? '...' : state.totalArticles.toString(),
                      sub: '+5 bulan ini',
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFF5F3FF),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Responsive Charts Row: Bar Chart + Pie Chart
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bar Chart (2/3 width)
                      Expanded(
                        flex: 2,
                        child: _buildBarChartCard(),
                      ),
                      const SizedBox(width: 24),
                      // Pie / Category chart (1/3 width)
                      Expanded(
                        flex: 1,
                        child: _buildCategoryCard(state.categoryDistribution),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildBarChartCard(),
                    const SizedBox(height: 24),
                    _buildCategoryCard(state.categoryDistribution),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Seminar table
            _buildSeminarTable(
              seminars: state.recentSeminars,
              isLoading: state.isLoading,
              isSuper: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, double> dist) {
    final colors = _pieColors;
    final entries = dist.entries.toList();

    List<PieChartSectionData> sections;
    if (entries.isEmpty) {
      sections = [
        PieChartSectionData(
          value: 100,
          color: const Color(0xFF94A3B8),
          title: '',
          radius: 50,
        ),
      ];
    } else {
      sections = entries.asMap().entries.map((e) {
        return PieChartSectionData(
          value: e.value.value,
          color: colors[e.key % colors.length],
          title: '',
          radius: 50,
        );
      }).toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Kategori',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 0,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text('Belum ada data', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
          else
            ...entries.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value.key,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${e.value.value.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildSeminarTable({
    required List<SeminarModel> seminars,
    required bool isLoading,
    required bool isSuper,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Konten Terbaru',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                ),
                Text(
                  isSuper ? 'Semua OPD' : 'Seminar Anda',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Table header
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _tableHeader('Kategori', flex: 2),
                _tableHeader('Judul', flex: 3),
                _tableHeader('Status', flex: 2),
                if (isSuper) _tableHeader('Oleh', flex: 2),
                _tableHeader('Tanggal', flex: 2),
                _tableHeader('Aksi', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Table body
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Memuat konten...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ),
            )
          else if (seminars.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Belum ada data seminar.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ),
            )
          else
            ...seminars.take(5).map((s) => _SeminarTableRow(seminar: s, isSuper: isSuper)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPERATOR DASHBOARD CONTENT — matches OperatorDashboard.tsx
// ─────────────────────────────────────────────────────────────────────────────
class _OperatorDashboardContent extends ConsumerStatefulWidget {
  const _OperatorDashboardContent();

  @override
  ConsumerState<_OperatorDashboardContent> createState() =>
      _OperatorDashboardContentState();
}

class _OperatorDashboardContentState extends ConsumerState<_OperatorDashboardContent> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).user;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            _buildWelcomeHeader(
                user?.name ?? 'Operator', 'Kelola seminar & peserta instansi Anda'),

            const SizedBox(height: 24),

            // Error
            if (state.errorMessage != null) _buildErrorBanner(state.errorMessage!),

            // Responsive stats cards for Operator
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Seminar',
                          value: state.isLoading ? '...' : state.totalSeminars.toString(),
                          sub: '+3 bulan ini',
                          icon: Icons.book_outlined,
                          iconColor: const Color(0xFF0052CC),
                          iconBg: const Color(0xFFEEF4FF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Total Peserta',
                          value: state.isLoading ? '...' : state.totalParticipants.toString(),
                          sub: '+89 bulan ini',
                          icon: Icons.people_outline,
                          iconColor: const Color(0xFF00B4D8),
                          iconBg: const Color(0xFFE0F7FA),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Sertifikat Diterbitkan',
                          value: state.isLoading ? '...' : state.certificatesCount.toString(),
                          sub: '+124 bulan ini',
                          icon: Icons.workspace_premium_outlined,
                          iconColor: const Color(0xFF22C55E),
                          iconBg: const Color(0xFFF0FFF4),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _StatCard(
                      label: 'Total Seminar',
                      value: state.isLoading ? '...' : state.totalSeminars.toString(),
                      sub: '+3 bulan ini',
                      icon: Icons.book_outlined,
                      iconColor: const Color(0xFF0052CC),
                      iconBg: const Color(0xFFEEF4FF),
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      label: 'Total Peserta',
                      value: state.isLoading ? '...' : state.totalParticipants.toString(),
                      sub: '+89 bulan ini',
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFF00B4D8),
                      iconBg: const Color(0xFFE0F7FA),
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      label: 'Sertifikat Diterbitkan',
                      value: state.isLoading ? '...' : state.certificatesCount.toString(),
                      sub: '+124 bulan ini',
                      icon: Icons.workspace_premium_outlined,
                      iconColor: const Color(0xFF22C55E),
                      iconBg: const Color(0xFFF0FFF4),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Chart left + Table right (stacked on small screen)
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildBarChartCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 3, child: _buildOperatorTable(state.recentSeminars, state.isLoading)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildBarChartCard(),
                  const SizedBox(height: 24),
                  _buildOperatorTable(state.recentSeminars, state.isLoading),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorTable(List<SeminarModel> seminars, bool isLoading) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              'Konten Terbaru',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Table header
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _tableHeader('Kategori', flex: 2),
                _tableHeader('Judul', flex: 3),
                _tableHeader('Status', flex: 2),
                _tableHeader('Dibuat', flex: 2),
                _tableHeader('Aksi', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Memuat konten...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
            )
          else if (seminars.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Belum ada data seminar.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
            )
          else
            ...seminars.take(4).map((s) => _SeminarTableRow(seminar: s, isSuper: false)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildWelcomeHeader(String name, String subtitle) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $name 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildErrorBanner(String message) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFEE2E2)),
    ),
    child: Text(message, style: const TextStyle(color: AppTheme.dangerColor, fontSize: 13)),
  );
}

Widget _buildBarChartCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Tren Peserta Bulanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
            ),
            Text('6 bulan terakhir', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 180,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final months = ['Okt', 'Nov', 'Des', 'Jan', 'Feb', 'Mar'];
                    return BarTooltipItem(
                      '${months[groupIndex]}\n${rod.toY.toInt()} peserta',
                      const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
                      final idx = value.toInt();
                      if (idx >= 0 && idx < months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(months[idx],
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value == 60 || value == 120 || value == 180) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFF1F5F9),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _monthlyData.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: (entry.value['peserta'] as int).toDouble(),
                      color: const Color(0xFF0052CC),
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
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


BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0052CC).withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

Widget _tableHeader(String text, {required int flex}) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475569),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SEMINAR TABLE ROW — shared by both dashboards
// ─────────────────────────────────────────────────────────────────────────────
class _SeminarTableRow extends ConsumerWidget {
  final SeminarModel seminar;
  final bool isSuper;

  const _SeminarTableRow({required this.seminar, required this.isSuper});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Seminar'),
        content: const Text('Apakah Anda yakin ingin menghapus seminar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ref.read(dashboardProvider.notifier).deleteSeminarItem(seminar.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seminar berhasil dihapus'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = seminar.status == 'Pendaftaran Dibuka';
    final authorName = seminar.author?['name'] as String? ?? 'Superadmin';

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GuestSeminarDetailScreen(seminar: seminar),
              ),
            );
          },
          hoverColor: const Color(0xFFFAFBFC),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Kategori
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      seminar.category,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF0052CC), fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Judul
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      seminar.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A2332), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                // Status
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFF0FFF4) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'Aktif' : 'Penuh',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Dibuat Oleh (SuperAdmin only)
                if (isSuper)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        authorName,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                // Tanggal
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      seminar.date.length > 10 ? seminar.date.substring(0, 10) : seminar.date,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                ),
                // Aksi buttons
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      _ActionBtn(
                        icon: Icons.visibility_outlined,
                        color: const Color(0xFF0052CC),
                        bg: const Color(0xFFEEF4FF),
                        tooltip: 'Lihat',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuestSeminarDetailScreen(seminar: seminar),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      _ActionBtn(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFFD97706),
                        bg: const Color(0xFFFFFBEB),
                        tooltip: 'Kelola',
                        onTap: () => _showEditSeminarDialog(context, ref),
                      ),
                      const SizedBox(width: 4),
                      _ActionBtn(
                        icon: Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        bg: const Color(0xFFFEF2F2),
                        tooltip: 'Hapus',
                        onTap: () => _confirmDelete(context, ref),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditSeminarDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController(text: seminar.title);
    final dateCtrl = TextEditingController(text: seminar.date);
    final locationCtrl = TextEditingController(text: seminar.location);
    final capacityCtrl = TextEditingController(text: seminar.capacity.toString());
    String selectedCategory = seminar.category.isNotEmpty ? seminar.category : 'Teknis';
    String selectedStatus = seminar.status.isNotEmpty ? seminar.status : 'Pendaftaran Dibuka';

    final categories = ['SPBE', 'Kompetensi', 'Kepemimpinan', 'Teknis', 'Fungsional'];
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }
    final statuses = ['Pendaftaran Dibuka', 'Kuota Penuh', 'Selesai'];
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
                    const Text(
                      'Edit Seminar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Judul Seminar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleCtrl,
                        decoration: _dialogInputDecoration('Masukkan judul seminar'),
                      ),
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
                      TextField(
                        controller: dateCtrl,
                        decoration: _dialogInputDecoration('YYYY-MM-DD', icon: Icons.calendar_today_outlined),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lokasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: locationCtrl,
                        decoration: _dialogInputDecoration('Masukkan lokasi'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Kapasitas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: capacityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _dialogInputDecoration('0'),
                      ),
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
                              'mode': seminar.mode,
                              'status': selectedStatus,
                              'date': dateCtrl.text,
                              'time': seminar.time,
                              'speaker': seminar.speaker,
                              'speakerRole': seminar.speakerRole,
                              'location': locationCtrl.text,
                              'capacity': int.tryParse(capacityCtrl.text) ?? 0,
                              'registered': seminar.registered,
                              'organizer': seminar.organizer,
                              'description': seminar.description,
                              'daftarType': seminar.daftarType,
                              'daftarUrl': seminar.daftarUrl,
                              'certificateUrl': seminar.certificateUrl,
                              'authorId': seminar.authorId,
                            };
                            final success = await ref.read(seminarProvider.notifier).update(seminar.id, data);
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              await ref.read(dashboardProvider.notifier).loadDashboard();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Seminar berhasil diperbarui'),
                                    backgroundColor: Color(0xFF22C55E),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Perbarui Seminar',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE STAT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Color(0xFF22C55E), size: 12),
              const SizedBox(width: 4),
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: Color(0xFF22C55E), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

