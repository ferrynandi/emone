import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import '../models/card_data.dart';
import 'apdu_commands.dart';

class EmoneyParser {
  static Future<CardData> parse(NfcTag tag) async {
    final isoDep = IsoDep.from(tag);

    if (isoDep != null) {
      try {
        Future<Uint8List> transceive(Uint8List data) async {
          return await isoDep.transceive(data: data);
        }

        for (final card in Apdu.all) {
          try {
            final sel = await transceive(card['select']);
            print('${card['name']} SELECT: ${_toHex(sel)}');

            if (_isSuccess(sel)) {
              final bal = await transceive(card['read']);
              print('${card['name']} READ: ${_toHex(bal)}');

              if (_isSuccess(bal)) {
                final value = _parseBalance(card['name'], bal);
                return CardData(cardType: card['name'], balance: value);
              }
            }
          } catch (e) {
            // continue ke jenis kartu berikutnya
          }
        }
      } catch (e) {
        print('Gagal kirim APDU: $e');
      }
    }

    // Jika tidak berhasil dengan IsoDep, fallback ke native
    print('APDU gagal, mencoba baca native TapCash...');
    return await _readNativeTapCash();
  }

  static Future<CardData> _readNativeTapCash() async {
    try {
      const platform = MethodChannel('com.ferry.emone/emoney');
      final List<dynamic> blockData = await platform.invokeMethod('readTapCashBlock');

      if (blockData.length >= 4) {
        final bytes = Uint8List.fromList(blockData.cast<int>());
        print('Blok 4 (native): ${_toHex(bytes)}');

        final value = ByteData.sublistView(bytes).getUint32(0, Endian.little);

        return CardData(
          cardType: 'BNI TapCash (Native)',
          balance: value,
        );
      } else {
        throw Exception('Data blok tidak valid');
      }
    } on PlatformException catch (e) {
      print('Gagal baca native TapCash: ${e.message}');
      throw Exception('Gagal membaca TapCash secara native: ${e.message}');
    }
  }

  static bool _isSuccess(Uint8List res) =>
      res.length >= 2 && res[res.length - 2] == 0x90 && res[res.length - 1] == 0x00;

  static int _parseBalance(String cardName, Uint8List data) {
    try {
      if (cardName == 'Mandiri e-Money') {
        final b = data.sublist(data.length - 6, data.length - 2);
        return ByteData.sublistView(b).getUint32(0, Endian.big);
      } else if (cardName == 'BCA Flazz') {
        final b = data.sublist(data.length - 5, data.length - 1);
        return ByteData.sublistView(b).getUint32(0, Endian.little);
      } else {
        final b = data.sublist(0, 4);
        return ByteData.sublistView(b).getUint32(0, Endian.little);
      }
    } catch (e) {
      print('Gagal parsing saldo: $e');
      return 0;
    }
  }

  static String _toHex(Uint8List data) =>
      data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
}
