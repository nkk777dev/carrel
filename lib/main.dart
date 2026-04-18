import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const CarrelApp());
}

class CarrelApp extends StatelessWidget {
  const CarrelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9FB), // 明るく淡いオフホワイト
        fontFamily: 'Georgia', // 美しいセリフ体の代替として
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2C2C2C),
          secondary: Color(0xFF8B8B8B),
          surface: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

enum ScreenState { moodInput, manifestation, bookDetails }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ScreenState _currentState = ScreenState.moodInput;
  Color? _selectedMoodColor;

  void _onMoodSelected(Color color) {
    setState(() {
      _selectedMoodColor = color;
      _currentState = ScreenState.manifestation;
    });
  }

  void _onBookTapped() {
    setState(() {
      _currentState = ScreenState.bookDetails;
    });
  }

  void _reset() {
    setState(() {
      _currentState = ScreenState.moodInput;
      _selectedMoodColor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景の静かなグラデーション
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFEBECEF),
                ],
              ),
            ),
          ),
          
          // 状態に応じた画面切り替え（クロスフェード）
          AnimatedSwitcher(
            duration: _currentState == ScreenState.moodInput ? Duration.zero : const Duration(seconds: 2),
            reverseDuration: _currentState == ScreenState.moodInput ? Duration.zero : const Duration(seconds: 2),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _buildCurrentScreen(),
          ),

          // 上部のCarrelロゴ（タップで最初に戻る）
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: MouseRegion(
                cursor: _currentState != ScreenState.moodInput ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: GestureDetector(
                  onTap: _currentState != ScreenState.moodInput ? _reset : null,
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _currentState == ScreenState.moodInput ? 1.0 : 0.4,
                    child: const Text(
                      'Carrel',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 6.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentState) {
      case ScreenState.moodInput:
        return MoodInputScreen(
          key: const ValueKey('moodInput'),
          onMoodTap: _onMoodSelected,
        );
      case ScreenState.manifestation:
        return ManifestationScreen(
          key: const ValueKey('manifestation'),
          moodColor: _selectedMoodColor ?? Colors.blue,
          onTapBook: _onBookTapped,
        );
      case ScreenState.bookDetails:
        return BookDetailsScreen(
          key: const ValueKey('bookDetails'),
          moodColor: _selectedMoodColor ?? Colors.blue, // 選択した色のトーンを引き継ぐ
        );
    }
  }
}

// ----------------------------------------------------
// 【フェーズ1】気分入力: 漂う抽象イメージ
// ----------------------------------------------------
class MoodInputScreen extends StatelessWidget {
  final Function(Color) onMoodTap;

  const MoodInputScreen({super.key, required this.onMoodTap});

  @override
  Widget build(BuildContext context) {
    // 強調したパステルカラーとダミーテキスト群
    final List<Map<String, dynamic>> moods = [
      {'color': const Color(0xFFFFB347).withOpacity(0.85), 'text': '静かな情熱'},
      {'color': const Color(0xFF6CB4EE).withOpacity(0.85), 'text': '深い休息'},
      {'color': const Color(0xFFC8A2C8).withOpacity(0.85), 'text': '現実逃避'},
      {'color': const Color(0xFFFFD700).withOpacity(0.8), 'text': '新しい発見'},
      {'color': const Color(0xFF98FF98).withOpacity(0.8), 'text': '穏やかな時間'},
    ];

    return Stack(
      children: [
        // ガイドテキスト
        const Center(
          child: Text(
            '今の心に触れてください',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black38,
              letterSpacing: 2.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        
        // 漂うカラー円
        ...List.generate(
          moods.length,
          (index) => DriftingMoodNode(
            seed: index,
            color: moods[index]['color'],
            text: moods[index]['text'],
            onTap: () => onMoodTap(moods[index]['color'].withOpacity(1.0)),
          ),
        ),
      ],
    );
  }
}

class DriftingMoodNode extends StatefulWidget {
  final int seed;
  final Color color;
  final String text;
  final VoidCallback onTap;

  const DriftingMoodNode({
    super.key,
    required this.seed,
    required this.color,
    required this.text,
    required this.onTap,
  });

  @override
  State<DriftingMoodNode> createState() => _DriftingMoodNodeState();
}

class _DriftingMoodNodeState extends State<DriftingMoodNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Random _random;
  late double _leftPos;
  late double _topPos;
  late double _size;

  @override
  void initState() {
    super.initState();
    _random = Random(widget.seed + DateTime.now().millisecondsSinceEpoch);
    _randomizeProperties();

    final durationSec = 15 + _random.nextInt(15);

    _controller = AnimationController(
       vsync: this,
       duration: Duration(seconds: durationSec),
    )..repeat(reverse: true);

    _controller.addListener(() {
       if (mounted) setState(() {});
    });
  }

  void _randomizeProperties() {
    // 中央に集まりすぎないように配置
    do {
      _leftPos = _random.nextDouble();
      _topPos = _random.nextDouble();
    } while ( (_leftPos - 0.5).abs() < 0.2 && (_topPos - 0.5).abs() < 0.2 );
    
    _size = 180 + _random.nextDouble() * 150; // テキストが入るため少し大きめに
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ゆったりとした呼吸のような移動と拡大縮小
    final moveOffset = sin(_controller.value * pi * 2) * 20;
    final scale = 0.9 + sin(_controller.value * pi) * 0.15;

    return Align(
      alignment: Alignment(-1.0 + (_leftPos * 2), -1.0 + (_topPos * 2)),
      child: Transform.translate(
        offset: Offset(moveOffset, moveOffset * 0.5),
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 【フェーズ2】書籍の顕現: 謎めいた表紙が浮かび上がる
// ----------------------------------------------------
class ManifestationScreen extends StatefulWidget {
  final Color moodColor;
  final VoidCallback onTapBook;

  const ManifestationScreen({
    super.key,
    required this.moodColor,
    required this.onTapBook,
  });

  @override
  State<ManifestationScreen> createState() => _ManifestationScreenState();
}

class _ManifestationScreenState extends State<ManifestationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    // 画面切り替え後、少し待ってから表紙がゆっくり顕現する
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: GestureDetector(
                onTap: widget.onTapBook,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: _MockBookCover(color: widget.moodColor, width: 220, height: 330),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------
// 【フェーズ3】開扉と詳細表示: タイトル、あらすじなどの情報が表示される
// ----------------------------------------------------
class BookDetailsScreen extends StatelessWidget {
  final Color moodColor;
  const BookDetailsScreen({super.key, required this.moodColor});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 700;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
          constraints: const BoxConstraints(maxWidth: 800),
          child: Flex(
            direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              // 書影
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _MockBookCover(color: moodColor, width: 240, height: 360),
              ),
              
              if (isSmallScreen) const SizedBox(height: 40) else const SizedBox(width: 60),

              // 書籍情報
              Expanded(
                flex: isSmallScreen ? 0 : 1, // small時はFlexの影響を消す
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(
                        '静かなる海',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '著者: アンナ・カヴァル',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '誰の記憶にも残っていない小さな港町。ある日、色彩を失った主人公は、海辺で見知らぬ古い手紙を拾う。\n\nそこには、未来の自分からの静かな警告が記されていた。他者との境界が曖昧に溶けていくような、神秘的で心洗われる読書体験。今のあなたに寄り添う、静謐な物語です。',
                        textAlign: isSmallScreen ? TextAlign.center : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 2.0,
                          color: Color(0xFF4A4A4A),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      // モックアップのAmazonリンク
                      InkWell(
                        onTap: () {
                          // Action
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.black87),
                              SizedBox(width: 12),
                              Text(
                                'Amazonで詳細を見る',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _MockBookCover extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _MockBookCover({required this.color, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
           topRight: Radius.circular(8),
           bottomRight: Radius.circular(8),
           topLeft: Radius.circular(3),
           bottomLeft: Radius.circular(3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withOpacity(0.08),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.08],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topLeft: Radius.circular(3),
                bottomLeft: Radius.circular(3),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 本の「背表紙の溝」を表現する微妙なライン
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: 14,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
