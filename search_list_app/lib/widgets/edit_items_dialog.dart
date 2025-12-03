import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:search_list_app/provider/search_provider.dart';

void showEditItemDialog(
  BuildContext context, {
  required String itemId,
  required String currentName,
}) {
  showDialog(
    context: context,
    builder: (ctx) => EditItemDialog(itemId: itemId, currentName: currentName),
  );
}

class EditItemDialog extends StatefulWidget {
  final String itemId;
  final String currentName;

  const EditItemDialog({
    super.key,
    required this.itemId,
    required this.currentName,
  });

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _controller.text.trim();

    // Check if name actually changed
    if (newName == widget.currentName) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    final searchProvider = context.read<SearchProvider>();

    try {
      await searchProvider.updateItem(widget.itemId, newName);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Updated to "$newName" successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
                showEditItemDialog(
                  context,
                  itemId: widget.itemId,
                  currentName: widget.currentName,
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.edit_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text("Edit Item"),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current name: ${widget.currentName}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter new item name",
                prefixIcon: const Icon(Icons.label),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              autofocus: true,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an item name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                if (value.trim().length > 100) {
                  return 'Name must be less than 100 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => _updateItem(),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _updateItem,
          icon: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(_isLoading ? "Updating..." : "Update"),
        ),
      ],
    );
  }
}
