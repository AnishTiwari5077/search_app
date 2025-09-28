import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SearchProvider())],
      child: const MyApp(),
    ),
  );
}

/// Main App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search + Add + Display Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SearchScreen(),
    );
  }
}

/// Screen with Search + Add + Display
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchController controller = SearchController();

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search + Add + Display Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🔹 Search bar
          SearchAnchor.bar(
            searchController: controller,
            barHintText: "Search items...",
            suggestionsBuilder: (context, controller) {
              searchProvider.search(controller.text);

              if (searchProvider.results.isEmpty) {
                return [const ListTile(title: Text("No results"))];
              }

              return searchProvider.results.map((item) {
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    // Navigate to the details screen for this item
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailScreen(itemName: item),
                      ),
                    );
                  },
                );
              }).toList();
            },
          ),

          const SizedBox(height: 10),

          /// 🔹 Display all items from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchProvider.getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No items added yet."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final name = docs[index]["name"];
                    return ListTile(
                      leading: const Icon(Icons.label),

                      // Navigate to other section
                      title: Text(name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog to add new item
  void _showAddDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Item"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Enter item name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await searchProvider.addItem(name);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Item added successfully!")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

/// Provider for search + add + fetch items
class SearchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> results = [];

  /// Search items in Firestore
  Future<void> search(String query) async {
    if (query.isEmpty) {
      results = [];
      notifyListeners();
      return;
    }

    final snapshot = await _firestore
        .collection("items")
        .where("name", isGreaterThanOrEqualTo: query)
        .where("name", isLessThanOrEqualTo: "$query\uf8ff")
        .limit(10)
        .get();

    results = snapshot.docs.map((doc) => doc["name"].toString()).toList();
    notifyListeners();
  }

  /// Add new item to Firestore
  Future<void> addItem(String name) async {
    await _firestore.collection("items").add({"name": name});
    notifyListeners();
  }

  /// Stream of all items for display
  Stream<QuerySnapshot> getItems() {
    return _firestore.collection("items").orderBy("name").snapshots();
  }
}

class ItemDetailScreen extends StatelessWidget {
  final String itemName;

  const ItemDetailScreen({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Item Details - $itemName")));
  }
}
