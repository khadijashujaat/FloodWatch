import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/report.dart';
import '../../util/format.dart';
import 'report_list_view_model.dart';

/// Equivalent of the Kotlin `ReportListScreen`: newest reports first, each
/// with a sync-status dot (orange = saved locally, green = uploaded).
class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportListViewModel>();

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ListView (even when empty) so pull-to-refresh always works.
    return RefreshIndicator(
      onRefresh: vm.load,
      child: vm.reports.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        vm.error ??
                            'No reports yet — submit one from the Report tab.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: vm.reports.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _ReportRow(report: vm.reports[index]),
            ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.report});

  final Report report;

  static const Color _syncedColor = Color(0xFF4CAF50);
  static const Color _pendingColor = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final severity = report.waterLevelSeverity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Semantics(
            label: report.synced ? 'Synced' : 'Not yet synced',
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: report.synced ? _syncedColor : _pendingColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.type,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (severity != null) Text(severity),
              if (report.notes.isNotEmpty)
                Text(report.notes, style: const TextStyle(color: Colors.grey)),
              Text(
                formatTimestamp(report.timestamp),
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
