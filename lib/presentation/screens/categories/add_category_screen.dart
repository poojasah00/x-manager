import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import '../../../data/local/category_database.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../core/providers/transaction_type_provider.dart';
import '../../../data/models/transaction_type.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final CategoryDatabase database;
  const AddCategoryScreen({Key? key, required this.database}) : super(key: key);

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _transactionType = 'income';
  String _iconPath = '';

  List<String> _transactionTypeValues(List<TransactionType> types) =>
      types.map((t) => t.id).toList();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final repo = CategoryRepository(widget.database);
      await repo.insertCategory(
        DbCategoriesCompanion.insert(
          name: _nameController.text,
          svgIcon: _iconPath, // store file path or content
          transactionType: _transactionType,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Write...',
                  filled: true,
                  fillColor: Colors.green[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              // transaction type dropdown
              Consumer(
                builder: (context, ref, child) {
                  final typesAsync = ref.watch(transactionTypesProvider);
                  return typesAsync.when(
                    data: (types) {
                      // ensure default value is valid
                      if (!_transactionTypeValues(
                        types,
                      ).contains(_transactionType)) {
                        _transactionType = types.first.id;
                      }
                      return DropdownButtonFormField<String>(
                        value: _transactionType,
                        items: types
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _transactionType = v);
                        },
                        decoration: InputDecoration(
                          hintText: 'Type',
                          filled: true,
                          fillColor: Colors.green[50],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, s) => Text('Error: $e'),
                  );
                },
              ),

              const SizedBox(height: 12),
              // icon picker
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: _iconPath.isEmpty ? 'Select icon' : _iconPath,
                  filled: true,
                  fillColor: Colors.green[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      final XFile? result = await openFile(
                        // only SVG allowed; other types will still be selectable on
                        // some platforms but we validate below
                        acceptedTypeGroups: [
                          XTypeGroup(label: 'svg', extensions: ['svg']),
                        ],
                      );
                      if (result != null) {
                        final path = result.path.toLowerCase();
                        if (!path.endsWith('.svg')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Only SVG files are allowed for icons',
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            _iconPath = result.path;
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C48C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.transparent),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
