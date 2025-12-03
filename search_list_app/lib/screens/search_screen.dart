import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_list_app/provider/search_provider.dart';

import 'package:search_list_app/screens/items_details_screen.dart';

import 'package:search_list_app/widgets/add_items_dialog.dart';

import 'package:search_list_app/widgets/emptystate_widget.dart';
import 'package:search_list_app/widgets/error_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchController searchController = SearchController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Manage Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Item',
            onPressed: () => showAddItemDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          _buildSearchBar(searchProvider),

          const Divider(height: 1),

          /// 📄 ITEMS LIST
          Expanded(child: _buildItemsList(searchProvider)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SearchProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SearchAnchor.bar(
        barHintText: "Search items...",
        searchController: searchController,
        barLeading: const Icon(Icons.search),
        suggestionsBuilder: (context, controller) async {
          if (controller.text.isEmpty) {
            return [
              ListTile(
                leading: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: const Text("Start typing to search..."),
                subtitle: const Text("Search by item name"),
              ),
            ];
          }

          // Trigger search and wait for completion
          await provider.search(controller.text);

          if (provider.errorMessage != null) {
            return [
              ListTile(
                leading: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text("Search failed"),
                subtitle: Text(provider.errorMessage!),
              ),
            ];
          }

          if (provider.results.isEmpty) {
            return [
              ListTile(
                leading: Icon(Icons.search_off, color: Colors.grey.shade400),
                title: const Text("No results found"),
                subtitle: Text('Try searching for "${controller.text}"'),
              ),
            ];
          }

          return provider.results.map((result) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.label,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(result['name']!),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
              ),
              onTap: () {
                controller.closeView(null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailScreen(
                      itemName: result['name']!,
                      itemId: result['id']!,
                    ),
                  ),
                );
              },
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildItemsList(SearchProvider provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplayWidget(
            message: snapshot.error.toString(),
            onRetry: () => setState(() {}),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyStateWidget(onAddItem: () => showAddItemDialog(context));
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (_, index) {
            final doc = docs[index];
            final name = doc["name"] as String;
            final docId = doc.id;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.label,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ItemDetailScreen(itemName: name, itemId: docId),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
