/// Dropdown options shared by the form UI and any future validation.
/// Mirrors the options used in the Kotlin version.
const String waterLevelType = 'Water level reading';

const List<String> reportTypes = [
  waterLevelType,
  'Rainfall observation',
  'Drainage blockage',
  'Other hazard',
];

const List<String> severityOptions = [
  'Below normal',
  'Rising, not yet a concern',
  'Ankle to knee deep',
  'Knee to waist deep',
  'Waist deep or higher',
];
