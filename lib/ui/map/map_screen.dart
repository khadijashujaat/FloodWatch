import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../data/map_report.dart';
import '../../util/format.dart';
import 'map_config.dart';
import 'map_view_model.dart';

/// Map of flood reports: green pins are shared reports, orange pins are
/// reports on this device that haven't been uploaded yet. Tap a pin for
/// details. The button in the corner fits the view to all pins.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color _sharedColor = Color(0xFF4CAF50);
  static const Color _pendingColor = Color(0xFFFF9800);

  final MapController _controller = MapController();
  bool _mapReady = false;
  bool _didAutoFit = false;

  @override
  void initState() {
    super.initState();
    context.read<MapViewModel>().start();
  }

  /// Zoom to the first batch of reports once, as soon as both the map and
  /// some data exist. (Controller calls aren't allowed inside onMapReady
  /// itself, hence the post-frame callback.)
  void _maybeAutoFit(List<MapReport> reports) {
    if (_didAutoFit || !_mapReady || reports.isEmpty) return;
    _didAutoFit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitAll(reports);
    });
  }

  void _fitAll(List<MapReport> reports) {
    if (reports.isEmpty) {
      _controller.move(MapConfig.defaultCenter, MapConfig.defaultZoom);
      return;
    }
    final points = [for (final r in reports) LatLng(r.latitude, r.longitude)];
    if (points.length == 1) {
      _controller.move(points.first, 13);
      return;
    }
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(56),
        maxZoom: 15,
      ),
    );
  }

  void _showDetails(MapReport report) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.type,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (report.waterLevelSeverity != null)
                Text(report.waterLevelSeverity!),
              if (report.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(report.notes, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 8),
              Text(
                '${formatTimestamp(report.timestamp)}  •  '
                '${report.latitude.toStringAsFixed(4)}, '
                '${report.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                report.pendingUpload
                    ? 'Saved on this device — waiting to upload'
                    : 'Shared',
                style: TextStyle(
                  color: report.pendingUpload ? _pendingColor : _sharedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final reports = vm.plottable;
    _maybeAutoFit(reports);

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: MapConfig.defaultCenter,
            initialZoom: MapConfig.defaultZoom,
            minZoom: 2,
            onMapReady: () {
              _mapReady = true;
              _maybeAutoFit(context.read<MapViewModel>().plottable);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: MapConfig.tileUrlTemplate,
              userAgentPackageName: MapConfig.userAgentPackageName,
            ),
            MarkerLayer(
              markers: [
                for (final report in reports)
                  Marker(
                    point: LatLng(report.latitude, report.longitude),
                    width: 40,
                    height: 40,
                    // Pin tip (bottom centre of the icon) sits on the point.
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => _showDetails(report),
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: report.pendingUpload
                            ? _pendingColor
                            : _sharedColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(source: Text(MapConfig.attribution)),
          ],
        ),
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Column(
            children: [
              if (vm.remoteProblem != null) _Banner(text: vm.remoteProblem!),
              if (vm.withoutLocation > 0)
                _Banner(
                  text:
                      '${vm.withoutLocation} report(s) without a GPS '
                      'location are not shown on the map.',
                ),
            ],
          ),
        ),
        const Positioned(left: 8, bottom: 24, child: _Legend()),
        Positioned(
          right: 12,
          bottom: 40,
          child: FloatingActionButton.small(
            heroTag: null,
            tooltip: 'Show all reports',
            onPressed: () => _fitAll(reports),
            child: const Icon(Icons.zoom_out_map),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            item(_MapScreenState._sharedColor, 'Shared'),
            const SizedBox(height: 4),
            item(_MapScreenState._pendingColor, 'Not uploaded yet'),
          ],
        ),
      ),
    );
  }
}
