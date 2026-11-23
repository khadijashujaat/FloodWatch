import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/report_options.dart';
import 'report_form_view_model.dart';

/// Equivalent of the Kotlin `ReportFormScreen`: report type dropdown, a
/// severity dropdown that only appears for water-level reports, notes, and a
/// submit button that disables itself while saving (prevents double submits).
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  String _type = reportTypes.first;
  String _severity = severityOptions.first;
  final TextEditingController _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<ReportFormViewModel>();
    final severity = _type == waterLevelType ? _severity : null;

    final saved = await vm.submitReport(
      type: _type,
      severity: severity,
      notes: _notes.text,
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (saved) {
      _notes.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Saved. Will sync when online.')),
      );
    } else if (vm.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<ReportFormViewModel, bool>(
      (vm) => vm.isSubmitting,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report type'),
            const SizedBox(height: 4),
            DropdownMenu<String>(
              initialSelection: _type,
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              enableSearch: false,
              dropdownMenuEntries: [
                for (final option in reportTypes)
                  DropdownMenuEntry(value: option, label: option),
              ],
              onSelected: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),
            if (_type == waterLevelType) ...[
              const Text('Water level severity'),
              const SizedBox(height: 4),
              DropdownMenu<String>(
                initialSelection: _severity,
                expandedInsets: EdgeInsets.zero,
                requestFocusOnTap: false,
                enableSearch: false,
                dropdownMenuEntries: [
                  for (final option in severityOptions)
                    DropdownMenuEntry(value: option, label: option),
                ],
                onSelected: (value) {
                  if (value != null) setState(() => _severity = value);
                },
              ),
              const SizedBox(height: 16),
            ],
            const Text('Notes'),
            const SizedBox(height: 4),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : _submit,
                child: Text(isSubmitting ? 'Saving...' : 'Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
