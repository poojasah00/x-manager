import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_manager/core/providers.dart';
import 'package:x_manager/data/local/app_database.dart';
import 'package:drift/drift.dart' show Value;

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      body: walletsAsync.when(
        data: (wallets) {
          return ListView.separated(
            itemCount: wallets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final w = wallets[index];
              return ListTile(
                title: Text(w.name),
                subtitle: Text('Balance: ${w.balance.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await showDialog<WalletsCompanion>(
                      context: context,
                      builder: (_) => _WalletDialog(wallet: w),
                    );
                    if (result != null) {
                      await ref
                          .read(databaseProvider)
                          .updateWallet(w.id, result);
                      final _ = ref.refresh(walletsProvider);
                      ref.invalidate(balancesProvider);
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
          final result = await showDialog<WalletsCompanion>(
            context: context,
            builder: (_) => const _WalletDialog(),
          );
          if (result != null) {
            await ref.read(databaseProvider).insertWallet(result);
            final _ = ref.refresh(walletsProvider);
            ref.invalidate(balancesProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WalletDialog extends StatefulWidget {
  final Wallet? wallet;
  const _WalletDialog({this.wallet});

  @override
  State<_WalletDialog> createState() => _WalletDialogState();
}

class _WalletDialogState extends State<_WalletDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  String _type = 'bank';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet?.balance.toString() ?? '0.0',
    );
    _type = widget.wallet?.type ?? 'bank';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.wallet == null ? 'Add Wallet' : 'Edit Wallet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _balanceController,
            decoration: const InputDecoration(labelText: 'Balance'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          DropdownButtonFormField<String>(
            value: _type,
            items: [
              'bank',
              'cash',
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
            final balance = double.tryParse(_balanceController.text) ?? 0.0;
            if (name.isEmpty) return;
            final companion = WalletsCompanion(
              name: Value(name),
              balance: Value(balance),
              type: Value(_type),
            );
            Navigator.of(context).pop(companion);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
