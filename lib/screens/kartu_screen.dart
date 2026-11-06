import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class KartuScreen extends StatelessWidget {
  final Map<String, dynamic> nasabah;
  const KartuScreen({super.key, required this.nasabah});

  @override
  Widget build(BuildContext context) {
    final noRek = nasabah['no_rekening'] ?? '-';
    final nama = nasabah['nama_siswa'] ?? '-';
    final nis = nasabah['nis'] ?? '-';
    final kelas = nasabah['kelas'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Kartu Tabungan Digital')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 380),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
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
                              Text('BANK MINI SEKOLAH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                              Text('SMK NEGERI 1 BANTUL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                        QrImageView(
                          data: noRek,
                          version: QrVersions.auto,
                          size: 150.0,
                        ),
                        const SizedBox(height: 10),
                        const Text('Tunjukkan QR ini ke Teller Loket', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                        const SizedBox(height: 16),
                        Text(noRek, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF1E3A8A))),
                        const SizedBox(height: 4),
                        Text('$nis • $nama', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(kelas, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                    const Divider(height: 24),
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
            ],
          ),
        ),
      ),
    );
  }
}

