import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MutasiScreen extends StatefulWidget {
  const MutasiScreen({super.key});

  @override
  State<MutasiScreen> createState() => _MutasiScreenState();
}

class _MutasiScreenState extends State<MutasiScreen> {
  List<dynamic> _mutasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMutasi();
  }

  void _loadMutasi() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getMutasi();
    if (res['success'] == true) {
      setState(() {
        _mutasi = res['mutasi'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buku Mutasi Tabungan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mutasi.isEmpty
              ? const Center(child: Text('Belum ada riwayat mutasi transaksi.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: () async => _loadMutasi(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _mutasi.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _mutasi[index];
                      final isSetor = item['jenis'] == 'setor';

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: isSetor ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                            child: Icon(
                              isSetor ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isSetor ? const Color(0xFF166534) : const Color(0xFF991B1B),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            item['jenis_label'] ?? '',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item['tanggal']} • ${item['keterangan']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                          trailing: Text(
                            '${isSetor ? '+' : '-'} ${item['nominal_formatted']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSetor ? const Color(0xFF166534) : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

