import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/foreground_sync.dart';
import 'map/map_screen.dart';
import 'report_form/report_form_route.dart';
import 'report_list/report_list_screen.dart';
import 'report_list/report_list_view_model.dart';

/// Equivalent of the Kotlin `Scaffold` + `NavigationBar` in `MainActivity`,
/// now with three tabs: Report, History and Map.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _tab = 0;
  bool _mapOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back in the foreground: pick up rows the background job synced, and try
  /// to upload anything still waiting.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ReportListViewModel>().load();
      context.read<ForegroundSync>().syncNow();
    }
  }

  void _selectTab(int index) {
    setState(() {
      _tab = index;
      if (index == 2) _mapOpened = true; // build the map lazily, once
    });
    if (index == 1) context.read<ReportListViewModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the form (and anything typed in it) alive while
      // another tab is showing.
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            const ReportFormRoute(),
            const ReportListScreen(),
            if (_mapOpened) const MapScreen() else const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.list), label: 'History'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
        ],
      ),
    );
  }
}
