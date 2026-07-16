import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';

class OpportunityProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> addOpportunity(OpportunityModel opportunity) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('opportunities').add(opportunity.toMap());
    } catch (e) {
      debugPrint("Error posting opportunity: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setOpportunityOpen(String id, bool isOpen) async {
    await _firestore.collection('opportunities').doc(id).update({'isOpen': isOpen});
  }

  Future<void> deleteOpportunity(String id) async {
    await _firestore.collection('opportunities').doc(id).delete();
  }

  /// All opportunities, newest first. Search/category filtering happens
  /// client-side in the UI so we don't need composite Firestore indexes
  /// for a small-scale campus platform.
  Stream<List<OpportunityModel>> allOpportunities() {
    return _firestore
        .collection('opportunities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OpportunityModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Stream<List<OpportunityModel>> opportunitiesForStartup(String startupId) {
    return _firestore
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OpportunityModel.fromFirestore(d.data(), d.id))
            .toList());
  }
}
