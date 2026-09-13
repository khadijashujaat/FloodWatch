package com.example.floodwatch.ui



import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

private val reportTypes = listOf(
    "Water level reading", "Rainfall observation", "Drainage blockage", "Other hazard"
)

private val severityOptions = listOf(
    "Below normal", "Rising, not yet a concern",
    "Ankle to knee deep", "Knee to waist deep", "Waist deep or higher"
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReportFormScreen(
    onSubmit: (type: String, severity: String?, notes: String) -> Unit,
    isSubmitting: Boolean = false

) {
    var selectedType by remember { mutableStateOf(reportTypes.first()) }
    var typeMenuExpanded by remember { mutableStateOf(false) }
    var selectedSeverity by remember { mutableStateOf(severityOptions.first()) }
    var severityMenuExpanded by remember { mutableStateOf(false) }
    var notes by remember { mutableStateOf("") }

    Column(Modifier.padding(16.dp)) {
        Text("Report type")
        ExposedDropdownMenuBox(
            expanded = typeMenuExpanded,
            onExpandedChange = { typeMenuExpanded = it }
        ) {
            TextField(
                value = selectedType,
                onValueChange = {},
                readOnly = true,
                modifier = Modifier.menuAnchor()
            )
            ExposedDropdownMenu(
                expanded = typeMenuExpanded,
                onDismissRequest = { typeMenuExpanded = false }
            ) {
                reportTypes.forEach { option ->
                    DropdownMenuItem(
                        text = { Text(option) },
                        onClick = {
                            selectedType = option
                            typeMenuExpanded = false
                        }
                    )
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        if (selectedType == "Water level reading") {
            Text("Water level severity")
            ExposedDropdownMenuBox(
                expanded = severityMenuExpanded,
                onExpandedChange = { severityMenuExpanded = it }
            ) {
                TextField(
                    value = selectedSeverity,
                    onValueChange = {},
                    readOnly = true,
                    modifier = Modifier.menuAnchor()
                )
                ExposedDropdownMenu(
                    expanded = severityMenuExpanded,
                    onDismissRequest = { severityMenuExpanded = false }
                ) {
                    severityOptions.forEach { option ->
                        DropdownMenuItem(
                            text = { Text(option) },
                            onClick = {
                                selectedSeverity = option
                                severityMenuExpanded = false
                            }
                        )
                    }
                }
            }
            Spacer(Modifier.height(16.dp))
        }

        Text("Notes")
        TextField(
            value = notes,
            onValueChange = { notes = it },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(Modifier.height(24.dp))


        Button(
            onClick = {
                val severity = if (selectedType == "Water level reading") selectedSeverity else null
                onSubmit(selectedType, severity, notes)
            },
            enabled = !isSubmitting,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(if (isSubmitting) "Saving..." else "Submit Report")
        }
    }
}