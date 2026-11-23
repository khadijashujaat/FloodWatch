import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'report_form_screen.dart';

enum _LocationAccess { checking, granted, denied, deniedForever }

/// Equivalent of the Kotlin `ReportFormRoute`: asks for location permission
/// when it first appears and only shows the form once it is granted.
class ReportFormRoute extends StatefulWidget {
  const ReportFormRoute({super.key});

  @override
  State<ReportFormRoute> createState() => _ReportFormRouteState();
}

class _ReportFormRouteState extends State<ReportFormRoute>
    with WidgetsBindingObserver {
  _LocationAccess _access = _LocationAccess.checking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// If the user grants permission in system settings and comes back, pick
  /// that up without re-prompting (check only, never request, on resume).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _access != _LocationAccess.granted &&
        _access != _LocationAccess.checking) {
      _applyPermission(Geolocator.checkPermission());
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _access = _LocationAccess.checking);
    await _applyPermission(() async {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    }());
  }

  Future<void> _applyPermission(Future<LocationPermission> pending) async {
    LocationPermission permission;
    try {
      permission = await pending;
    } catch (_) {
      permission = LocationPermission.denied;
    }
    if (!mounted) return;
    setState(() {
      _access = switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => _LocationAccess.granted,
        LocationPermission.deniedForever => _LocationAccess.deniedForever,
        _ => _LocationAccess.denied,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_access) {
      case _LocationAccess.checking:
        return const Center(child: CircularProgressIndicator());
      case _LocationAccess.granted:
        return const ReportFormScreen();
      case _LocationAccess.denied:
        return _PermissionMessage(
          buttonLabel: 'Grant permission',
          onPressed: _requestPermission,
        );
      case _LocationAccess.deniedForever:
        // Browsers have no "app settings" screen to open.
        return kIsWeb
            ? const _PermissionMessage(
                message:
                    'Location is blocked for this site. Click the lock '
                    'icon next to the address, allow Location, then reload '
                    'the page.',
              )
            : _PermissionMessage(
                buttonLabel: 'Open app settings',
                onPressed: Geolocator.openAppSettings,
              );
    }
  }
}

class _PermissionMessage extends StatelessWidget {
  const _PermissionMessage({
    this.message =
        'Location permission is needed to tag reports with GPS coordinates.',
    this.buttonLabel,
    this.onPressed,
  });

  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
