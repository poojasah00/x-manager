import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_manager/core/providers.dart';
import 'package:x_manager/data/local/app_database.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: catsAsync.when(
        data: (cats) {
          return ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = cats[index];
              return ListTile(
                title: Text(c.name),
                subtitle: Text(c.type),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await showDialog<CategoriesCompanion>(
                      context: context,
                      builder: (_) => _CategoryDialog(cat: c),
                    );
                    if (result != null) {
                      await ref
                          .read(databaseProvider)
                          .updateCategory(c.id, result);
                      final _ = ref.refresh(categoriesProvider);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<CategoriesCompanion>(
            context: context,
            builder: (_) => const _CategoryDialog(),
          );
          if (result != null) {
            await ref.read(databaseProvider).insertCategory(result);
            final _ = ref.refresh(categoriesProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final Category? cat;
  const _CategoryDialog({this.cat});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameController;
  String _type = 'expense';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cat?.name ?? '');
    _type = widget.cat?.type ?? 'expense';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cat == null ? 'Add Category' : 'Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          DropdownButtonFormField<String>(
            value: _type,
            items: [
              'income',
              'expense',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            final companion = CategoriesCompanion.insert(
              name: name,
              type: _type,
            );
            Navigator.of(context).pop(companion);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
