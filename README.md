<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>FloodWatch — README</title>
<style>
  :root {
    --accent: #4a6fa5;
    --bg: #ffffff;
    --text: #1e1e1e;
    --muted: #5c6470;
    --code-bg: #f4f6f8;
    --border: #e2e5e9;
  }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    max-width: 860px;
    margin: 0 auto;
    padding: 40px 24px 80px;
    color: var(--text);
    line-height: 1.6;
    background: var(--bg);
  }
  h1 { font-size: 2rem; margin-bottom: 4px; }
  h2 {
    font-size: 1.3rem;
    margin-top: 2.5rem;
    padding-bottom: 6px;
    border-bottom: 2px solid var(--border);
  }
  h3 { font-size: 1.05rem; margin-top: 1.6rem; }
  .tagline { color: var(--muted); font-size: 1.05rem; margin-top: 0; }
  .badges { margin: 14px 0 28px; }
  .badge {
    display: inline-block;
    background: var(--code-bg);
    border: 1px solid var(--border);
    color: var(--muted);
    font-size: 0.78rem;
    padding: 3px 10px;
    border-radius: 999px;
    margin-right: 6px;
    margin-bottom: 6px;
  }
  code, pre {
    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
    font-size: 0.88rem;
  }
  code {
    background: var(--code-bg);
    padding: 2px 6px;
    border-radius: 4px;
  }
  pre {
    background: var(--code-bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 14px 16px;
    overflow-x: auto;
  }
  pre code { background: none; padding: 0; }
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 14px 0;
    font-size: 0.92rem;
  }
  th, td {
    text-align: left;
    padding: 8px 10px;
    border-bottom: 1px solid var(--border);
  }
  th { color: var(--muted); font-weight: 600; }
  ul, ol { padding-left: 22px; }
  li { margin-bottom: 4px; }
  .status-dot {
    display: inline-block;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    margin-right: 6px;
    vertical-align: middle;
  }
  .dot-green { background: #4CAF50; }
  .dot-orange { background: #FF9800; }
  .note {
    background: #fff8e6;
    border: 1px solid #f0dca0;
    border-radius: 8px;
    padding: 12px 16px;
    margin: 16px 0;
    font-size: 0.92rem;
  }
  footer {
    margin-top: 60px;
    padding-top: 20px;
    border-top: 1px solid var(--border);
    color: var(--muted);
    font-size: 0.85rem;
  }
</style>
</head>
<body>

<h1>FloodWatch</h1>
<p class="tagline">An offline-first community flood-reporting app for Android, built to work where connectivity and formal monitoring infrastructure can't be relied on.</p>

<div class="badges">
  <span class="badge">Kotlin</span>
  <span class="badge">Jetpack Compose</span>
  <span class="badge">Room</span>
  <span class="badge">Firebase Firestore</span>
  <span class="badge">WorkManager</span>
  <span class="badge">osmdroid</span>
</div>

<h2>Why this exists</h2>
<p>
  Pakistan has experienced recurrent, severe flooding over the past two decades, and part of what makes
  response and prediction harder is a genuine gap in ground-level data collection — official monitoring
  infrastructure doesn't reach every affected community. FloodWatch is a small step toward closing that
  gap: a simple app that lets local residents log flood conditions — water level, rainfall, drainage
  blockages — from their own phones, with no assumption of internet access, formal training, or
  measurement equipment.
</p>

<h2>Core design decisions</h2>
<ul>
  <li><strong>Local-first, always.</strong> Every report saves to an on-device Room database immediately, with zero network dependency at the point of submission. A report can be filed in a total connectivity blackout.</li>
  <li><strong>Qualitative severity over false precision.</strong> Locals rarely have a measuring tape at a riverbank. Instead of a numeric cm/ft field, water level is reported on a plain-language severity scale (e.g. "Ankle to knee deep") — data people can actually give reliably.</li>
  <li><strong>Sync is automatic and best-effort.</strong> Unsynced reports are queued and pushed to Firestore in the background via WorkManager, the moment connectivity returns — no manual "upload" step for the user.</li>
  <li><strong>No paid infrastructure required.</strong> Firebase's free tier and OpenStreetMap tiles (via osmdroid) were chosen specifically to avoid any dependency on a billing account or card — deployment shouldn't be blocked by cost.</li>
</ul>

<h2>Features</h2>
<table>
  <tr><th>Screen</th><th>What it does</th></tr>
  <tr><td><strong>Report</strong></td><td>Submit a flood-condition report: type, conditional severity, notes, auto-captured GPS location and timestamp.</td></tr>
  <tr><td><strong>History</strong></td><td>Scrollable list of all local reports, newest first, each showing a sync-status indicator.</td></tr>
</table>
<p>
  A map view was prototyped using osmdroid + OpenStreetMap tiles, but was cut from this version — OSM's
  public tile server enforces strict rate limits and usage-policy requirements not well suited to reliable
  field use without a dedicated tile provider. GPS coordinates are still captured with every report, so a
  map view remains straightforward to reintroduce with a more production-appropriate tile source.
</p>

<h3>Sync status indicator</h3>
<p>
  <span class="status-dot dot-orange"></span> Orange — saved locally, not yet uploaded<br>
  <span class="status-dot dot-green"></span> Green — confirmed synced to Firestore
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
<pre><code>UI (Jetpack Compose)
  ├─ ReportFormScreen / ReportFormRoute
  ├─ ReportListScreen
  └─ MapScreen

ViewModel
  ├─ ReportFormViewModel   (permission handling, submit flow, sync trigger)
  ├─ ReportListViewModel   (exposes Room data as StateFlow)
  └─ MapViewModel          (exposes synced-only reports)

Data
  ├─ Room (local, offline-first)
  │    ReportEntity / ReportDao / AppDatabase
  └─ Remote (Firestore, background)
       FirestoreReportSync / SyncWorker (WorkManager)
</code></pre>

<h2>Tech stack</h2>
<table>
  <tr><th>Layer</th><th>Choice</th><th>Why</th></tr>
  <tr><td>UI</td><td>Jetpack Compose, Material 3</td><td>Modern declarative UI, consistent with the rest of the codebase</td></tr>
  <tr><td>Local persistence</td><td>Room / SQLite</td><td>Reliable offline storage, works with zero connectivity</td></tr>
  <tr><td>Background sync</td><td>WorkManager</td><td>Guaranteed, constraint-aware background execution, survives process death</td></tr>
  <tr><td>Remote data</td><td>Firebase Firestore</td><td>Realtime sync, free tier, no server to host or maintain</td></tr>
  <tr><td>Location</td><td>FusedLocationProviderClient</td><td>Standard, battery-efficient location access</td></tr>
</table>

<h2>Setup</h2>
<ol>
  <li>Clone the repository and open it in Android Studio.</li>
  <li>Create a free <a href="https://console.firebase.google.com" target="_blank" rel="noopener">Firebase project</a>, add an Android app with package name <code>com.example.floodwatch</code>, and download <code>google-services.json</code> into <code>app/</code>.</li>
  <li>In the Firebase console, enable <strong>Firestore Database</strong> (production mode) and <strong>Authentication → Anonymous</strong> if applicable.</li>
  <li>Sync Gradle and run on a physical device or emulator (Android 7.0 / API 24+).</li>
</ol>

<h2>Known limitations</h2>
<ul>
  <li>Water level severity is self-reported and qualitative by design — not a substitute for instrumented gauge data.</li>
  <li>Location defaults to <code>(0.0, 0.0)</code> if no cached GPS fix is available at submission time; this is a known gap to improve (show an explicit error state instead).</li>
  <li>No in-app map view in this version (see below) — reports can still be viewed and cross-referenced by their stored coordinates externally.</li>
</ul>

<h2>Possible next steps</h2>
<ul>
  <li>Reintroduce a map view backed by a production-appropriate tile provider (e.g. CARTO, Mapbox free tier) rather than OSM's rate-limited public server.</li>
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
