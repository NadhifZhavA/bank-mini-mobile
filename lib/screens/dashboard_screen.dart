import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'lupa_pin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _nasabah;
  List<dynamic> _allMutasi = [];
  List<dynamic> _filteredMutasi = [];
  String _mutasiFilter = 'semua'; // 'semua', 'setor', 'tarik'
  bool _isLoading = true;

  // Target Tabungan
  String _targetTitle = 'Tabungan Masa Depan';
  int _targetAmount = 500000;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadTargetSettings();
  }

  Future<void> _loadTargetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetTitle = prefs.getString('target_title') ?? 'Beli Perlengkapan Sekolah';
      _targetAmount = prefs.getInt('target_amount') ?? 500000;
    });
  }

  Future<void> _saveTargetSettings(String title, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('target_title', title);
    await prefs.setInt('target_amount', amount);
    setState(() {
      _targetTitle = title;
      _targetAmount = amount;
    });
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final resProfile = await ApiService.getProfile();
    final resMutasi = await ApiService.getMutasi();

    if (mounted) {
      setState(() {
        if (resProfile['success'] == true) {
          _nasabah = resProfile['nasabah'];
        }
        if (resMutasi['success'] == true) {
          _allMutasi = resMutasi['mutasi'] as List<dynamic>? ?? [];
          _applyMutasiFilter();
        }
        _isLoading = false;
      });
    }
  }

  void _applyMutasiFilter() {
    setState(() {
      if (_mutasiFilter == 'setor') {
        _filteredMutasi = _allMutasi.where((m) => m['jenis'] == 'setor').toList();
      } else if (_mutasiFilter == 'tarik') {
        _filteredMutasi = _allMutasi.where((m) => m['jenis'] == 'tarik').toList();
      } else {
        _filteredMutasi = List.from(_allMutasi);
      }
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari sistem?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showEditTargetDialog() {
    final titleCtrl = TextEditingController(text: _targetTitle);
    final amountCtrl = TextEditingController(text: _targetAmount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur Target Tabungan Impian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tentukan tujuan menabung Anda untuk memotivasi diri:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Nama Target (contoh: Laptop Praktik, UKK)', isDense: true),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Nominal (Rp)', isDense: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleCtrl.text.trim();
              final newAmount = int.tryParse(amountCtrl.text.trim()) ?? _targetAmount;
              if (newTitle.isNotEmpty && newAmount > 0) {
                _saveTargetSettings(newTitle, newAmount);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            child: const Text('Simpan Target'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo-smkn1bantul.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, size: 28, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-TELLER BANK MINI',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A), letterSpacing: 0.5),
                ),
                Text(
                  'SMK NEGERI 1 BANTUL',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF4B5563)),
            onPressed: _loadAllData,
            tooltip: 'Segarkan Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: Color(0xFF991B1B)),
            onPressed: _logout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(),
                _buildMutasiTab(),
                _buildKartuTab(),
                _buildTargetFinansialTab(),
                _buildAkunTab(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedFontSize: 11,
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Mutasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_outlined),
              activeIcon: Icon(Icons.qr_code_2),
              label: 'Kartu QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: 'Finansial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 1: BERANDA ----------------
  Widget _buildHomeTab() {
    final saldo = _nasabah?['saldo'] ?? 0;
    final progress = _targetAmount > 0 ? (saldo / _targetAmount).clamp(0.0, 1.0) : 0.0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sapaan Siswa
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portal Mandiri Siswa / Nasabah',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Selamat datang, ${_nasabah?['nama_siswa'] ?? 'Siswa'} (Kelas: ${_nasabah?['kelas'] ?? '-'}).',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Saldo Box Mirip Persis Web
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFF1E3A8A), width: 4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Berjalan Tabungan Anda',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _nasabah?['saldo_formatted'] ?? 'Rp 0',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Diperbarui secara waktu nyata (Real-Time)',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Actions 4 Menu Grid
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionBtn(
                    icon: Icons.qr_code_2,
                    label: 'Kartu QR',
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionBtn(
                    icon: Icons.history,
                    label: 'Mutasi',
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionBtn(
                    icon: Icons.track_changes,
                    label: 'Target',
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionBtn(
                    icon: Icons.shield_outlined,
                    label: 'PIN',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LupaPinScreen(nis: _nasabah?['nis'] ?? '')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mini Target Progress Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag_outlined, size: 16, color: Color(0xFF1E3A8A)),
                          const SizedBox(width: 6),
                          Text(
                            _targetTitle,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Terkumpul: Rp ${saldo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                      Text('Target: Rp ${_targetAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5 Mutasi Terakhir
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mutasi Terakhir Tabungan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () => setState(() => _currentIndex = 1),
                          child: const Text(
                            'Buku Tabungan Lengkap →',
                            style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_allMutasi.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text('Belum ada catatan mutasi tabungan.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _allMutasi.take(4).length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      itemBuilder: (ctx, i) {
                        final trx = _allMutasi[i];
                        final isSetor = trx['jenis'] == 'setor';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSetor ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  isSetor ? 'SETOR' : 'TARIK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSetor ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trx['keterangan'] ?? '-',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      trx['tanggal'] ?? '-',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isSetor ? '+' : '-'} ${trx['nominal_formatted']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSetor ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '© 2026 SMK Negeri 1 Bantul • Bank Mini Sekolah',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 2: BUKU TABUNGAN (MUTASI) ----------------
  Widget _buildMutasiTab() {
    int totalSetor = 0;
    int totalTarik = 0;
    for (var m in _allMutasi) {
      if (m['jenis'] == 'setor') totalSetor += (m['nominal'] as int? ?? 0);
      if (m['jenis'] == 'tarik') totalTarik += (m['nominal'] as int? ?? 0);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Buku Mutasi Tabungan Lengkap', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text('Riwayat lengkap pencatatan transaksi masuk dan keluar tabungan.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 14),

          // Total Ringkasan Kas Siswa
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Setoran', style: TextStyle(fontSize: 11, color: Color(0xFF166534), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('+ Rp ${totalSetor.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF166534), fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Penarikan', style: TextStyle(fontSize: 11, color: Color(0xFF991B1B), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('- Rp ${totalTarik.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter Tab Bar
          Row(
            children: [
              _buildFilterChip('Semua Transaksi', 'semua'),
              const SizedBox(width: 6),
              _buildFilterChip('Setoran (+)', 'setor'),
              const SizedBox(width: 6),
              _buildFilterChip('Penarikan (-)', 'tarik'),
            ],
          ),
          const SizedBox(height: 12),

          // Daftar Mutasi
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _filteredMutasi.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('Tidak ada mutasi yang sesuai filter.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredMutasi.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (ctx, i) {
                      final trx = _filteredMutasi[i];
                      final isSetor = trx['jenis'] == 'setor';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSetor ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                isSetor ? 'SETOR' : 'TARIK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSetor ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trx['keterangan'] ?? '-',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Waktu: ${trx['tanggal']}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isSetor ? '+' : '-'} ${trx['nominal_formatted']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSetor ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _mutasiFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _mutasiFilter = value;
          _applyMutasiFilter();
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  // ---------------- TAB 3: KARTU & QR DIGITAL ----------------
  Widget _buildKartuTab() {
    final noRek = _nasabah?['no_rekening'] ?? '-';
    final nama = _nasabah?['nama_siswa'] ?? '-';
    final nis = _nasabah?['nis'] ?? '-';
    final kelas = _nasabah?['kelas'] ?? '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Header Kartu
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo-smkn1bantul.png',
                    height: 38,
                    width: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 36, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BANK MINI SEKOLAH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A), letterSpacing: 0.5)),
                        Text('SMK NEGERI 1 BANTUL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1.5, color: Color(0xFF1E3A8A)),

              // Identitas & QR
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: QrImageView(
                      data: noRek,
                      version: QrVersions.auto,
                      size: 150.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tunjukkan QR ini ke Teller Loket', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        noRek,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF1E3A8A), fontFamily: 'monospace'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16, color: Color(0xFF6B7280)),
                        tooltip: 'Salin No. Rekening',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: noRek));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nomor rekening berhasil disalin!')),
                          );
                        },
                      ),
                    ],
                  ),
                  Text('$nis • $nama', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(kelas, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Simpanan Pelajar Terpadu', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                  Text('Otentikasi Cepat E-Teller', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TAB 4: TARGET & ANALISIS FINANSIAL (FITUR MENARIK) ----------------
  Widget _buildTargetFinansialTab() {
    final saldo = _nasabah?['saldo'] ?? 0;
    final progress = _targetAmount > 0 ? (saldo / _targetAmount).clamp(0.0, 1.0) : 0.0;
    final sisa = (_targetAmount - saldo) > 0 ? (_targetAmount - saldo) : 0;

    int totalSetor = 0;
    int countSetor = 0;
    for (var m in _allMutasi) {
      if (m['jenis'] == 'setor') {
        totalSetor += (m['nominal'] as int? ?? 0);
        countSetor++;
      }
    }
    final rataSetor = countSetor > 0 ? (totalSetor / countSetor).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target & Analisis Finansial', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('Kelola tujuan tabungan dan pantau kebiasaan menabung.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1E3A8A)),
                tooltip: 'Ubah Target',
                onPressed: _showEditTargetDialog,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kartu Target Utama
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _targetTitle,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: progress >= 1.0 ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        progress >= 1.0 ? 'TERCAPAI 🎉' : '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: progress >= 1.0 ? const Color(0xFF166534) : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? const Color(0xFF166534) : const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terkumpul: Rp ${saldo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                    ),
                    Text(
                      'Target: Rp ${_targetAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (progress < 1.0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Kurang Rp ${sisa.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} lagi untuk mencapai target Anda!',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Statistik Pintar Menabung Siswa
          const Text('Statistik Kebiasaan Menabung', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Frekuensi Setoran', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text('$countSetor Kali', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 2),
                      const Text('Tercatat di teller loket', style: TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rata-rata Setoran', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text('Rp ${rataSetor.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontFamily: 'monospace')),
                      const SizedBox(height: 2),
                      const Text('Per transaksi setoran', style: TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Panduan & Tips Keuangan Pelajar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF1E3A8A)),
                    SizedBox(width: 8),
                    Text('Ketentuan & Tips Menabung UKK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Setoran minimal di loket teller adalah Rp 10.000.\n'
                  '• Saldo mengendap minimal Rp 10.000 wajib dijaga agar rekening tetap aktif.\n'
                  '• Jagalah kerahasiaan 6-digit PIN keamanan otorisasi Anda.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TAB 5: AKUN & KEAMANAN ----------------
  Widget _buildAkunTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pengaturan Profil & Keamanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text('Kelola akun siswa, otorisasi PIN penarikan, dan koneksi server.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 14),

          // Detail Akun Siswa
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Identitas Rekening Siswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Divider(height: 16, color: Color(0xFFE5E7EB)),
                _buildInfoRow('Nama Lengkap', _nasabah?['nama_siswa'] ?? '-'),
                _buildInfoRow('Nomor Rekening', _nasabah?['no_rekening'] ?? '-'),
                _buildInfoRow('NIS Siswa', _nasabah?['nis'] ?? '-'),
                _buildInfoRow('Kelas / Jurusan', _nasabah?['kelas'] ?? '-'),
                _buildInfoRow('Status Rekening', (_nasabah?['status'] ?? 'aktif').toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Keamanan PIN
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keamanan & Otorisasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Divider(height: 16, color: Color(0xFFE5E7EB)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.pin_outlined, color: Color(0xFF1E3A8A)),
                  title: const Text('Ubah PIN 6-Digit Mandiri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Ganti PIN penarikan kas dengan verifikasi kata sandi', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LupaPinScreen(nis: _nasabah?['nis'] ?? '')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tombol Keluar
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 16, color: Color(0xFF991B1B)),
            label: const Text('Keluar dari Akun Siswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              backgroundColor: const Color(0xFFFEF2F2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: _logout,
          ),
          const SizedBox(height: 24),

          const Text(
            '© 2026 SMK Negeri 1 Bantul • Bank Mini Sekolah',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
