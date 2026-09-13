package com.example.floodwatch.ui


import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import com.example.floodwatch.data.local.ReportEntity
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@Composable
fun MapScreen(reports: List<ReportEntity>) {
    AndroidView(
        modifier = Modifier.fillMaxSize(),
        factory = { context ->
            MapView(context).apply {
                setMultiTouchControls(true)
                controller.setZoom(6.0)
                controller.setCenter(GeoPoint(31.5, 74.3)) // rough Pakistan-centered default
            }
        },
        update = { mapView ->
            mapView.overlays.clear()
            reports.forEach { report ->
                val marker = Marker(mapView)
                marker.position = GeoPoint(report.latitude, report.longitude)
                marker.title = report.type
                marker.snippet = report.waterLevelSeverity ?: report.notes
                mapView.overlays.add(marker)
            }
            mapView.invalidate()
        }
    )
}