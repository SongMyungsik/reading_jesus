import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoScreen extends StatefulWidget {
  final String title;
  final String date;
  final String url;

  const VideoScreen({
    super.key,
    required this.title,
    required this.date,
    required this.url,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 자동으로 바로 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openInAppBrowser();
    });
  }

  String _formatDate(String date) {
    final parts = date.split('/');
    return '${parts[0]}월 ${parts[1]}일';
  }

  // Chrome Custom Tab (앱 안에서 브라우저처럼 열기)
  Future<void> _openInAppBrowser() async {
    setState(() => _isOpening = true);
    final uri = Uri.parse(widget.url);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView, // 앱 안 크롬 탭
      );
    } catch (_) {
      // 실패 시 외부 앱으로 대체
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatDate(widget.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // 썸네일 영역 (재생 버튼 포함)
            GestureDetector(
              onTap: _openInAppBrowser,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.4),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 배경 아이콘
                    Icon(
                      Icons.menu_book_rounded,
                      size: 80,
                      color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                    ),
                    // 재생 버튼
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isOpening
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                    ),
                    // 하단 탭 안내
                    Positioned(
                      bottom: 14,
                      child: Text(
                        '탭하여 재생',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 정보 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: Color(0xFF90CAF9), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📅 ${_formatDate(widget.date)} 성경 읽기',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 안내 문구
            Text(
              '위 재생 버튼을 탭하면 앱 안 브라우저로 열립니다.\n뒤로가기로 앱으로 돌아올 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 12,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
