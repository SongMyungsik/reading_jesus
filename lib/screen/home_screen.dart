import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'video_screen.dart';

// ─────────────────────────────────────────────
// 데이터 모델
// ─────────────────────────────────────────────
class VideoEntry {
  final String date;
  final String book;
  final String link;

  const VideoEntry({
    required this.date,
    required this.book,
    required this.link,
  });

  factory VideoEntry.fromJson(Map<String, dynamic> json) {
    return VideoEntry(
      date: json['date'] as String,
      book: json['book'] as String,
      link: json['link'] as String,
    );
  }

  int get month => int.parse(date.split('/')[0]);
  int get day => int.parse(date.split('/')[1]);
}

// ─────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<int, Map<int, VideoEntry>>> _futureData;
  int _currentMonth = 1;
  static const int _year = 2026;
  final ScrollController _scrollController = ScrollController();
  bool _scrolledToToday = false;

  static const List<String> _weekdayNames = [
    '',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일'
  ];

  @override
  void initState() {
    super.initState();
    // 오늘 날짜에 맞는 월로 초기화 (2026년 범위 내)
    final now = DateTime.now();
    if (now.year == _year && now.month >= 1 && now.month <= 12) {
      _currentMonth = now.month;
    }
    _futureData = _loadData();
  }

  Future<Map<int, Map<int, VideoEntry>>> _loadData() async {
    final raw = await rootBundle.loadString('assets/url.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => VideoEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final Map<int, Map<int, VideoEntry>> result = {};
    for (final v in list) {
      result.putIfAbsent(v.month, () => {})[v.day] = v;
    }
    return result;
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  // 오늘 날짜로 스크롤 (아이템 높이 약 72px 기준)
  void _scrollToToday() {
    final now = DateTime.now();
    if (now.year != _year || now.month != _currentMonth) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        const itemHeight = 72.0; // 아이템 높이(62) + 마진(6) + 여유(4)
        final offset = (now.day - 1) * itemHeight;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _prevMonth() {
    if (_currentMonth > 1) {
      setState(() => _currentMonth--);
      _scrollToTop();
    }
  }

  void _nextMonth() {
    if (_currentMonth < 12) {
      setState(() => _currentMonth++);
      _scrollToTop();
    }
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  String _weekdayName(int year, int month, int day) =>
      _weekdayNames[DateTime(year, month, day).weekday];

  bool _isSunday(int year, int month, int day) =>
      DateTime(year, month, day).weekday == 7;

  bool _isSaturday(int year, int month, int day) =>
      DateTime(year, month, day).weekday == 6;

  // 오늘 날짜인지 확인
  bool _isToday(int year, int month, int day) {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: FutureBuilder<Map<int, Map<int, VideoEntry>>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('JSON 로드 오류:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final data = snapshot.data!;
          final videoMap = data[_currentMonth] ?? {};
          final totalDays = _daysInMonth(_year, _currentMonth);

          // 최초 1회만 오늘로 스크롤
          if (!_scrolledToToday) {
            _scrolledToToday = true;
            _scrollToToday();
          }

          return Column(
            children: [
              // ── 상단 헤더 ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  bottom: 8,
                ),
                child: Column(
                  children: [
                    // 앱 타이틀
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '리딩지저스 성경읽기',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    // 월 이동
                    Row(
                      children: [
                        IconButton(
                          onPressed: _currentMonth > 1 ? _prevMonth : null,
                          icon: const Icon(Icons.chevron_left, size: 36),
                          color:
                              _currentMonth > 1 ? Colors.white : Colors.white24,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '$_year년 $_currentMonth월',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _currentMonth < 12 ? _nextMonth : null,
                          icon: const Icon(Icons.chevron_right, size: 36),
                          color: _currentMonth < 12
                              ? Colors.white
                              : Colors.white24,
                        ),
                      ],
                    ),
                    // 이번 달 링크 개수 요약
                    Text(
                      '이번 달 영상 ${videoMap.length}개',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ── 날짜 리스트 ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    14,
                    10,
                    14,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  itemCount: totalDays,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final weekday = _weekdayName(_year, _currentMonth, day);
                    final isSun = _isSunday(_year, _currentMonth, day);
                    final isSat = _isSaturday(_year, _currentMonth, day);
                    final isToday = _isToday(_year, _currentMonth, day);
                    final entry = videoMap[day];

                    return _DayRow(
                      month: _currentMonth,
                      day: day,
                      weekday: weekday,
                      isSunday: isSun,
                      isSaturday: isSat,
                      isToday: isToday,
                      entry: entry,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 날짜 행
// ─────────────────────────────────────────────
class _DayRow extends StatelessWidget {
  final int month;
  final int day;
  final String weekday;
  final bool isSunday;
  final bool isSaturday;
  final bool isToday;
  final VideoEntry? entry;

  const _DayRow({
    required this.month,
    required this.day,
    required this.weekday,
    required this.isSunday,
    required this.isSaturday,
    required this.isToday,
    this.entry,
  });

  void _openVideo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoScreen(
          title: entry!.book,
          date: entry!.date,
          url: entry!.link,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color dateColor = const Color(0xFF212121);
    if (isSunday) dateColor = const Color(0xFFE53935);
    if (isSaturday) dateColor = const Color(0xFF1565C0);

    final bool hasLink = entry != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFFFFF9C4) // 오늘 날짜 강조
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFBC02D)
              : hasLink
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFFE0E0E0),
          width: (isToday || hasLink) ? 1.5 : 0.8,
        ),
        boxShadow: hasLink || isToday
            ? [
                BoxShadow(
                  color: (isToday
                          ? const Color(0xFFFBC02D)
                          : const Color(0xFF1565C0))
                      .withValues(alpha: 0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: GestureDetector(
        onTap: hasLink ? () => _openVideo(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              // ── 날짜 + 요일 ──
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 오늘 표시 뱃지 (날짜 위에 별도 배치)
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBC02D),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '오늘',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$month/$day',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: dateColor,
                            ),
                          ),
                          TextSpan(
                            text: '($weekday)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: dateColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 구분선
              Container(width: 1.2, height: 20, color: const Color(0xFFE0E0E0)),

              const SizedBox(width: 12),

              // ── 성경 범위 ──
              Expanded(
                child: hasLink
                    ? Row(
                        children: [
                          const Icon(Icons.play_circle_fill,
                              size: 18, color: Color(0xFF1565C0)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry!.book,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 18, color: Color(0xFF90CAF9)),
                        ],
                      )
                    : const Text(
                        ' -',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
