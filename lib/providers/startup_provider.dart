import 'package:flutter/material.dart';
import '../models/startup_model.dart';
import '../services/startup_service.dart';

class StartupProvider extends ChangeNotifier {
  final StartupService _service = StartupService();
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Stream<StartupModel?> watchStartup(String founderUid) =>
      _service.startupForFounder(founderUid);

  Future<void> saveProfile(StartupModel startup) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _service.saveStartupProfile(startup);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
