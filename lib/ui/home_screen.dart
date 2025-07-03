import '/models/card_data.dart';
import '/services/nfc_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NfcService _nfcService = NfcService();
  String _status = "Menunggu kartu e-money...";
  CardData? _cardData;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan(); // Mulai saat widget dibuka
  }

  @override
  void dispose() {
    _nfcService.stopSession();
    super.dispose();
  }

  void _startScan() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _status = "Tempelkan kartu ke belakang ponsel...";
      _cardData = null;
    });

    _nfcService.startSession(
      onDiscovered: (cardData) async {
        setState(() {
          _cardData = cardData;
          _status = "Berhasil membaca kartu!";
        });

        await Future.delayed(const Duration(seconds: 3));
        _nfcService.stopSession();
        setState(() => _isScanning = false);
        _startScan(); // Scan ulang otomatis
      },
      onError: (error) async {
        setState(() {
          _status = "Gagal membaca: $error";
        });

        await Future.delayed(const Duration(seconds: 2));
        _nfcService.stopSession();
        setState(() => _isScanning = false);
        _startScan(); // Scan ulang otomatis
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembaca Saldo E-Moneeeeeeeee'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/nfc-icon.png',
                height: 120,
                color: _isScanning ? Colors.deepPurple : Colors.grey,
              ),
              const SizedBox(height: 30),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              if (_cardData != null)
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          _cardData!.cardType,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currencyFormatter.format(_cardData!.balance),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
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
}
