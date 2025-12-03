import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Search results with ID and name
  List<Map<String, String>> results = [];

  // Loading state
  bool isLoading = false;

  // Error state
  String? errorMessage;

  /// Search Firestore with query (case-insensitive)
  Future<void> search(String query) async {
    if (query.isEmpty) {
      results = [];
      errorMessage = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final lowerQuery = query.toLowerCase();

      final snapshot = await _db
          .collection("items")
          .where("name_lowercase", isGreaterThanOrEqualTo: lowerQuery)
          .where("name_lowercase", isLessThanOrEqualTo: "$lowerQuery\uf8ff")
          .limit(10)
          .get();

      results = snapshot.docs.map((doc) {
        return {'id': doc.id, 'name': doc["name"].toString()};
      }).toList();
    } catch (e) {
      results = [];
      errorMessage = 'Search failed: ${e.toString()}';
      debugPrint('Search error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Add Item to Firestore
  Future<void> addItem(String name) async {
    try {
      await _db.collection("items").add({
        "name": name,
        "name_lowercase": name.toLowerCase(),
        "created_at": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Add item error: $e');
      rethrow;
    }
  }

  /// Delete Item from Firestore
  Future<void> deleteItem(String itemId) async {
    try {
      await _db.collection("items").doc(itemId).delete();
    } catch (e) {
      debugPrint('Delete item error: $e');
      rethrow;
    }
  }

  /// Update Item in Firestore
  Future<void> updateItem(String itemId, String newName) async {
    try {
      await _db.collection("items").doc(itemId).update({
        "name": newName,
        "name_lowercase": newName.toLowerCase(),
        "updated_at": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Update item error: $e');
      rethrow;
    }
  }

  /// Get all items as a stream
  Stream<QuerySnapshot> getItems() {
    return _db.collection("items").orderBy("name").snapshots();
  }

  /// Get single item by ID
  Future<DocumentSnapshot?> getItemById(String itemId) async {
    try {
      return await _db.collection("items").doc(itemId).get();
    } catch (e) {
      debugPrint('Get item error: $e');
      return null;
    }
  }

  /// Clear search results
  void clearSearch() {
    results = [];
    errorMessage = null;
    notifyListeners();
  }
}
