<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">


  
</head>
<body>

<h1>FloodWatch</h1>
<p class="tagline">An offline-first community flood-reporting app built with Flutter, designed to work where connectivity and formal monitoring infrastructure can't be relied on.</p>

<div class="badges">
  <span class="badge">Flutter</span>
  <span class="badge">Dart</span>
  <span class="badge">SQLite</span>
  <span class="badge">Firebase Firestore</span>
  <span class="badge">WorkManager</span>
  <span class="badge">flutter_map</span>
</div>

<h2>Why this exists</h2>
<p>
  Pakistan has experienced recurrent, severe flooding over the past two decades, and part of what makes
  response and prediction harder is a genuine gap in ground-level data collection .Official monitoring
  infrastructure doesn't reach every affected community. FloodWatch is a small step toward closing that
  gap: a simple app that lets local residents log flood conditions ; water level, rainfall, drainage
  blockages from their own phones, with no assumption of internet access, formal training, or
  measurement equipment.
</p>

<h2>Core design decisions</h2>
<ul>
  <li><strong>Local-first, always.</strong> Every report saves to an on-device SQLite database immediately, with zero network dependency at the point of submission. A report can be filed in a total connectivity blackout.</li>
  <li><strong>Qualitative severity over false precision.</strong> Locals rarely have a measuring tape at a riverbank. Instead of a numeric cm/ft field, water level is reported on a plain-language severity scale (e.g. "Ankle to knee deep") data people can actually give reliably.</li>
  <li><strong>Sync is automatic and best-effort.</strong> Unsynced reports are queued and pushed to Firestore in the background via WorkManager on Android, and while the app is open on other platforms ,no manual "upload" step for the user.</li>
  <li><strong>No paid infrastructure required.</strong> Firebase's free tier and OpenStreetMap tiles (via flutter_map) avoid a required billing account or card ,deployment shouldn't be blocked by cost.</li>
</ul>

<h2>Features</h2>
<table>
  <tr><th>Screen</th><th>What it does</th></tr>
  <tr><td><strong>Report</strong></td><td>Submit a flood-condition report: type, conditional severity, notes, auto-captured GPS location and timestamp.</td></tr>
  <tr><td><strong>History</strong></td><td>Scrollable list of all local reports, newest first, each showing a sync-status indicator.</td></tr>
  <tr><td><strong>Map</strong></td><td>View report locations on a map, with separate markers for shared reports and reports waiting to sync.</td></tr>
</table>
<p>
  The map uses flutter_map with OpenStreetMap tiles. OSM's public tile server has usage policies and
  rate limits, so production deployments with significant traffic should use a tile provider suited to
  their expected usage. GPS coordinates are captured with every report.
</p>

<h3>Sync status indicator</h3>
<p>
  <span class="status-dot dot-orange"></span> Orange —> saved locally, not yet uploaded<br>
  <span class="status-dot dot-green"></span> Green —> confirmed synced to Firestore
</p>

<h2>Data collected per report</h2>
<table>
  <tr><th>Field</th><th>Description</th></tr>
  <tr><td><code>type</code></td><td>Water level reading / Rainfall observation / Drainage blockage / Other hazard</td></tr>
  <tr><td><code>waterLevelSeverity</code></td><td>Nullable. Only set when type is "Water level reading" — a plain-language severity level, not a numeric measurement.</td></tr>
  <tr><td><code>notes</code></td><td>Free-text field for anything not captured by the structured fields.</td></tr>
  <tr><td><code>latitude</code> / <code>longitude</code></td><td>Captured automatically via the device's location provider at submission time.</td></tr>
  <tr><td><code>timestamp</code></td><td>Captured automatically at submission time.</td></tr>
  <tr><td><code>synced</code></td><td>Local-only bookkeeping flag; not stored in Firestore.</td></tr>
</table>

<h2>Architecture</h2>
<pre><code>UI (Flutter, Material 3)
  ├─ ReportFormScreen / ReportFormRoute
  ├─ ReportListScreen
  └─ MapScreen

View models (Provider)
  ├─ ReportFormViewModel   (location, submit flow, sync trigger)
  ├─ ReportListViewModel   (loads local report history)
  └─ MapViewModel          (loads shared reports)

Data
  ├─ SQLite (local, offline-first)
  │    Report / ReportDao / AppDatabase
  └─ Remote (Firestore)
       FirestoreReportSync / SyncWorker (WorkManager on Android)
</code></pre>

<h2>Tech stack</h2>
<table>
  <tr><th>Layer</th><th>Choice</th><th>Why</th></tr>
  <tr><td>UI</td><td>Flutter, Material 3</td><td>Cross-platform declarative UI</td></tr>
  <tr><td>Local persistence</td><td>sqflite / SQLite</td><td>Reliable offline storage, works with zero connectivity</td></tr>
  <tr><td>Background sync</td><td>WorkManager on Android</td><td>Constraint-aware background execution; other platforms sync while the app is open</td></tr>
  <tr><td>Remote data</td><td>Firebase Firestore</td><td>Realtime sync, free tier, no server to host or maintain</td></tr>
  <tr><td>Location</td><td>Geolocator</td><td>Platform location access through a common Flutter API</td></tr>
  <tr><td>Maps</td><td>flutter_map, OpenStreetMap</td><td>Display report locations with open map tiles</td></tr>
</table>

<h2>Setup</h2>
<ol>
  <li>Install the Flutter SDK, clone the repository, and run <code>flutter pub get</code>.</li>
  <li>Configure a <a href="https://console.firebase.google.com" target="_blank" rel="noopener">Firebase project</a> for the Android app. Place its <code>google-services.json</code> in <code>android/app/</code> and configure the matching options in <code>lib/firebase_options.dart</code>.</li>
  <li>In the Firebase console, enable <strong>Firestore Database</strong> (production mode).</li>
  <li>Run <code>flutter run</code> on a connected device or emulator. Run the tests with <code>flutter test</code>.</li>
</ol>

<h2>Known limitations</h2>
<ul>
  <li>Water level severity is self-reported and qualitative by design ,not a substitute for instrumented gauge data.</li>
  <li>Location defaults to <code>(0.0, 0.0)</code> if both cached and fresh GPS lookups fail; an explicit error state would be preferable.</li>
  <li>Periodic background sync is configured for Android; on other platforms, reports sync while the app is open.</li>
</ul>

<h2>Possible next steps</h2>
<ul>
  <li>Choose a production-appropriate tile provider (e.g. CARTO, Mapbox free tier) if usage exceeds OpenStreetMap's public tile server policy.</li>
  <li>Community-installed physical staff gauges, cross-referenced against app reports for validation.</li>
  <li>Push notifications for nearby severe reports.</li>
  <li>Aggregate view showing report density/trends over time per region.</li>
</ul>

<footer>
  Built as part of a broader effort to explore how offline-first mobile tools can help close ground-level
  data-collection gaps in flood-prone, under-monitored regions.
</footer>

</body>
</html>
