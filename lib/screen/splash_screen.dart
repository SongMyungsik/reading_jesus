import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  int? _loadCount;

  // 모든 사용자의 누적 접속 수를 세는 무료 카운터 API (가입/설정 불필요)
  static const String _counterUrl =
      'https://abacus.jasoncameron.dev/hit/reading-jesus-bible/app-loads';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _incrementLoadCount();
  }

  Future<void> _incrementLoadCount() async {
    try {
      final response = await http
          .get(Uri.parse(_counterUrl))
          .timeout(const Duration(seconds: 5));
      final count = jsonDecode(response.body)['value'] as int;
      if (mounted) setState(() => _loadCount = count);
    } catch (_) {
      // 카운터 API에 접속할 수 없으면 조용히 표시를 생략한다.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 12, 47, 246),
                  Color.fromARGB(255, 240, 211, 245),
                  Color.fromARGB(255, 250, 230, 255),
                ],
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 아이콘
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      'assets/Reading_Jesus_logo.png', // 이미지 경로
                      width: 110, // 너비 조절
                      height: 27, // 높이 조절
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 앱 이름
                  const Text(
                    'ReadingJesusBible',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 13, 195),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 부제목
                  Text(
                    '2026년 성경 일독 계획',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0)
                          .withValues(alpha: 0.8),
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 시작하기 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/church_logo.png', // 이미지 경로
                    width: 150, // 너비 조절
                    height: 40, // 높이 조절
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ReadingJesusBible ver. 1.1',
                    style: TextStyle(
                      fontSize: 12.0, // 글자 크기를 크게 설정
                      //  fontWeight: FontWeight.bold,   // 글자를 굵게 설정
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_loadCount != null)
            Positioned(
              top: 12,
              right: 16,
              child: SafeArea(
                child: Text(
                  '$_loadCount',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
