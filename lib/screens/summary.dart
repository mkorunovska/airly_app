import 'dart:ui';

import 'package:airly_app/l10n/app_localizations.dart';
import 'package:airly_app/models/hourly_point.dart';
import 'package:airly_app/models/weather_bundle.dart';
import 'package:airly_app/services/app_state.dart';
import 'package:airly_app/services/weather_service.dart';
import 'package:airly_app/widgets/language_toggle.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  Future<WeatherBundle>? _future;

  @override
  void initState() {
    super.initState();
    final pos = AppState.instance.position.value;
    if (pos != null) {
      _future = WeatherService.fetchHourlyBundle(lat: pos.latitude, lon: pos.longitude);
    }
  }

  // ✅ Value closest to now
  double? _valueForNow(List<HourlyPoint>? series) {
    if (series == null || series.isEmpty) return null;

    final now = DateTime.now();
    HourlyPoint? best;

    for (final p in series) {
      if (p.time.isAfter(now)) break;
      best = p;
    }

    best ??= series.first;
    return best.value;
  }

  // 0=good, 1=moderate, 2=high, 3=very high
  int _pmLevel({required double pm25, required double pm10}) {
    int l25;
    if (pm25 <= 15) {
      l25 = 0;
    } else if (pm25 <= 35) l25 = 1;
    else if (pm25 <= 55) l25 = 2;
    else l25 = 3;

    int l10;
    if (pm10 <= 30) {
      l10 = 0;
    } else if (pm10 <= 60) l10 = 1;
    else if (pm10 <= 100) l10 = 2;
    else l10 = 3;

    return l25 > l10 ? l25 : l10;
  }

  String _pmEmoji(int level) {
    switch (level) {
      case 0:
        return "✅";
      case 1:
        return "🟡";
      case 2:
        return "🟠";
      default:
        return "🔴";
    }
  }

  String _pmTitle(int level, AppLocalizations t) {
    switch (level) {
      case 0:
        return " ${t.t('air_good')}";
      case 1:
        return " ${t.t('air_moderate')}";
      case 2:
        return " ${t.t('air_high')}";
      default:
        return " ${t.t('air_very_high')}";
    }
  }

  List<String> _pmAdviceLines(int level, AppLocalizations t) {
    if (level == 0) {
      return [t.t('air_good_line1'), t.t('air_good_line2'), t.t('air_good_line3')];
    }
    if (level == 1) {
      return [t.t('air_mod_line1'), t.t('air_mod_line2'), t.t('air_mod_line3')];
    }
    if (level == 2) {
      return [t.t('air_high_line1'), t.t('air_high_line2'), t.t('air_high_line3'), t.t('air_high_line4')];
    }
    return [t.t('air_vhigh_line1'), t.t('air_vhigh_line2'), t.t('air_vhigh_line3'), t.t('air_vhigh_line4')];
  }

  Widget _adviceCard({
    required int level,
    required AppLocalizations t,
    required double pm25,
    required double pm10,
  }) {
    final alpha = level >= 2 ? 0.22 : 0.14;
    final borderAlpha = level >= 3 ? 0.55 : (level == 2 ? 0.40 : 0.25);

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderAlpha),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _pmTitle(level, t),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                "PM2.5: ${pm25.toStringAsFixed(0)}   •   PM10: ${pm10.toStringAsFixed(0)} µg/m³",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 12),
              ..._pmAdviceLines(level, t).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 13,
                      fontWeight: FontWeight.w200,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======= Polar chart helpers =======

  double _thresholdNorm({required bool isPm25, required double maxVal}) {
    final thr = isPm25 ? 15.0 : 30.0; // "good" thresholds
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;
    return (thr / safeMax).clamp(0.0, 1.0);
  }

  Widget _singlePolarCard({
    required String title,
    required String centerLabel,
    required String ringNote,
    required List<HourlyPoint> series,
    required bool isPm25,
    required double nowValue,
    required int level,
  }) {
    final points = series.take(24).toList();
    if (points.isEmpty) {
      return _glassCard(child: const SizedBox(height: 260));
    }

    final n = points.length;
    final values = List.generate(n, (i) => points[i].value);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;

    final norm = values.map((x) => (x / safeMax).clamp(0.0, 1.0)).toList();
    final labels = List.generate(n, (i) {
      final dt = points[i].time;
      return (i % 3 == 0) ? dt.hour.toString().padLeft(2, '0') : '';
    });

    final thr = _thresholdNorm(isPm25: isPm25, maxVal: safeMax);

    List<RadarEntry> ring(double r) => List.generate(n, (_) => RadarEntry(value: r));

    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RadarChart(
                    RadarChartData(
                      radarBackgroundColor: Colors.transparent,
                      borderData: FlBorderData(show: false),
                      radarBorderData: BorderSide(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                      gridBorderData: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                      titleTextStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10,
                        fontWeight: FontWeight.w200,
                      ),
                      getTitle: (index, angle) => RadarChartTitle(text: labels[index]),
                      dataSets: [
                        // threshold ring
                        RadarDataSet(
                          fillColor: Colors.transparent,
                          borderColor: Colors.white.withValues(alpha: 0.14),
                          borderWidth: 1.2,
                          entryRadius: 0,
                          dataEntries: ring(thr),
                        ),
                        // the series
                        RadarDataSet(
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          borderColor: Colors.white.withValues(alpha: 0.75),
                          entryRadius: 0,
                          borderWidth: 2,
                          dataEntries: norm.map((v) => RadarEntry(value: v)).toList(),
                        ),
                      ],
                    ),
                  ),

                  // center label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_pmEmoji(level), style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          centerLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nowValue.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$ringNote • max ${safeMax.toStringAsFixed(0)}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pos = AppState.instance.position.value;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 9, 42),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 20),
        child: Stack(
          children: [
            Align(
              alignment: const AlignmentDirectional(10, -0.3),
              child: Container(
                height: 280,
                width: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 228, 234, 245),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-10, -0.2),
              child: Container(
                height: 260,
                width: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 227, 204, 167),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 150.0, sigmaY: 150.0),
              child: Container(decoration: const BoxDecoration(color: Colors.transparent)),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.t('summary_title'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            t.t('summary_subtitle'),
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),

                const SizedBox(height: 18),

                if (pos == null)
                  _glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        t.t('gps_not_ready'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: FutureBuilder<WeatherBundle>(
                      future: _future ?? WeatherService.fetchHourlyBundle(lat: pos.latitude, lon: pos.longitude),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.85)),
                            ),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return _glassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                t.t('weather_load_failed'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          );
                        }

                        final data = snapshot.data!;

                        final tempNow = _valueForNow(data.temperatureC) ?? 0;
                        final pm10Now = _valueForNow(data.pm10) ?? 0;
                        final pm25Now = _valueForNow(data.pm25) ?? 0;

                        final level = _pmLevel(pm25: pm25Now, pm10: pm10Now);

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _glassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${tempNow.toStringAsFixed(0)}℃',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 44,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${t.t('pm10')}: ${pm10Now.toStringAsFixed(0)}   •   ${t.t('pm25')}: ${pm25Now.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontWeight: FontWeight.w200,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.insights, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            _adviceCard(level: level, t: t, pm25: pm25Now, pm10: pm10Now),

                            const SizedBox(height: 14),

                            // ✅ TWO polar cards in ONE ROW (PM2.5 left, PM10 right)
                            Row(
                              children: [
                                Expanded(
                                  child: _singlePolarCard(
                                    title: t.t('pm25'),
                                    centerLabel: t.t('pm_now'),
                                    ringNote:' ',
                                    series: data.pm25,
                                    isPm25: true,
                                    nowValue: pm25Now,
                                    level: level,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _singlePolarCard(
                                    title: t.t('pm10'),
                                    centerLabel: t.t('pm_now'),
                                    ringNote:' ',
                                    series: data.pm10,
                                    isPm25: false,
                                    nowValue: pm10Now,
                                    level: level,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ✅ AFTER polar row -> show OLD charts ONLY for PM10 and PM2.5
                            _chartCard(title: t.t('pm10'), unit: 'µg/m³', series: data.pm10),
                            const SizedBox(height: 14),
                            _chartCard(title: t.t('pm25'), unit: 'µg/m³', series: data.pm25),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required String unit,
    required List<HourlyPoint> series,
  }) {
    final points = series.take(24).toList();

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].value));
    }

    final minY = points.isEmpty
        ? 0.0
        : points.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final maxY = points.isEmpty
        ? 1.0
        : points.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final pad = (maxY - minY).abs() * 0.15;
    final safePad = pad == 0 ? 1.0 : pad;

    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title  ($unit)',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: minY - safePad,
                  maxY: maxY + safePad,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
