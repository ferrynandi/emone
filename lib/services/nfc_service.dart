import 'package:nfc_manager/nfc_manager.dart';
import '../models/card_data.dart';
import '../services/emoney_parser.dart';

class NfcService {
  Future<void> startSession({
    required Function(CardData) onDiscovered,
    required Function(String) onError,
  }) async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      onError("NFC tidak tersedia di perangkat ini.");
      return;
    }

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          final cardData = await EmoneyParser.parse(tag);
          await NfcManager.instance.stopSession();
          onDiscovered(cardData);
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: e.toString());
          onError(e.toString().replaceFirst("Exception: ", ""));
        }
      },
    );
  }

  Future<void> stopSession() async {
    await NfcManager.instance.stopSession();
  }
}
