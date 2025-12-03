import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  List<Map<String, String>> results = [];

 
  bool isLoading = false;

 
  String? errorMessage;

 
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

 
  Future<void> deleteItem(String itemId) async {
    try {
      await _db.collection("items").doc(itemId).delete();
    } catch (e) {
      debugPrint('Delete item error: $e');
      rethrow;
    }
  }

 
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


  Stream<QuerySnapshot> getItems() {
    return _db.collection("items").orderBy("name").snapshots();
  }


  Future<DocumentSnapshot?> getItemById(String itemId) async {
    try {
      return await _db.collection("items").doc(itemId).get();
    } catch (e) {
      debugPrint('Get item error: $e');
      return null;
    }
  }


  void clearSearch() {
    results = [];
    errorMessage = null;
    notifyListeners();
  }
}
