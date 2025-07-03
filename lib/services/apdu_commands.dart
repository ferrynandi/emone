import 'dart:typed_data';
import '../utils/hex_converter.dart';

class Apdu {
  static final mandiri = {
    'name': 'Mandiri e-Money',
    'select': hexToBytes("00A4040009A00000000300000101"),
    'read': hexToBytes("04D684000C"),
  };

  static final flazz = {
    'name': 'BCA Flazz',
    'select': hexToBytes("00A4040007A0000000030000"),
    'read': hexToBytes("00B08C0009"),
  };

  static final tapcash_v1 = {
    'name': 'BNI TapCash',
    'select': hexToBytes("00A4040007A0000006020001"),
    'read': hexToBytes("00B0840004"),
  };

  static final tapcash_v2 = {
    'name': 'BNI TapCash',
    'select': hexToBytes("00A4040007A0000006020101"),
    'read': hexToBytes("00B0840004"),
  };

  static final brizzi = {
    'name': 'BRI Brizzi',
    'select': hexToBytes("00A4040008A000000003010101"),
    'read': hexToBytes("00B09A0004"),
  };

  static final kai = {
    'name': 'KAI Commuter',
    'select': hexToBytes("00A40400084B43492E434F4D4D"),
    'read': hexToBytes("04B09A0004"),
  };

  static final List<Map<String, dynamic>> all = [
    mandiri, flazz, tapcash_v1, tapcash_v2, brizzi, kai,
  ];
}
