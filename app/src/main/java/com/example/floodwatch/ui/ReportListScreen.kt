package com.example.floodwatch.ui


import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.floodwatch.data.local.ReportEntity
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun ReportListScreen(reports: List<ReportEntity>) {
    if (reports.isEmpty()) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("No reports yet — submit one from the Report tab.")
        }
        return
    }

    LazyColumn(Modifier.fillMaxSize().padding(16.dp)) {
        items(reports, key = { it.id }) { report ->
            ReportRow(report)
            Spacer(Modifier.height(12.dp))
        }
    }
}

@Composable
private fun ReportRow(report: ReportEntity) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top
    ) {
        // sync status dot
        Box(
            modifier = Modifier
                .padding(top = 4.dp)
                .size(10.dp)
                .clip(CircleShape)
                .background(if (report.synced) Color(0xFF4CAF50) else Color(0xFFFF9800))
        )

        Spacer(Modifier.width(12.dp))

        Column {
            Text(report.type, fontWeight = FontWeight.Bold)

            report.waterLevelSeverity?.let { severity ->
                Text(severity)
            }

            if (report.notes.isNotBlank()) {
                Text(report.notes, color = Color.Gray)
            }

            val formatter = remember { SimpleDateFormat("dd MMM yyyy, HH:mm", Locale.getDefault()) }
            Text(
                formatter.format(Date(report.timestamp)),
                style = MaterialTheme.typography.bodySmall,
                color = Color.Gray
            )
        }
    }
}