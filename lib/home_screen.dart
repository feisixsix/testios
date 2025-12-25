import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime? _beijingTime;
  bool _isLoading = true;
  String _errorMessage = '';
  List<PointData> _points = [];
  Timer? _timer;
  Timer? _checkTimer;
  late AnimationController _pulseController;

  // 定位点数据类
  class PointData {
    Offset position;
    int id;
    Color color;
    bool isTapped;
    DateTime? lastTapTime;

    PointData({
      required this.id,
      required this.position,
      this.color = Colors.red,
      this.isTapped = false,
      this.lastTapTime,
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBeijingTime();
    _generateRandomPoints();
    _startTimers();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // 获取北京时间
  Future<void> _fetchBeijingTime() async {
    try {
      // 方法1: 通过网络时间协议API获取
      final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Shanghai'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final datetime = data['datetime'] as String;
        setState(() {
          _beijingTime = DateTime.parse(datetime).toLocal();
          _isLoading = false;
        });
      } else {
        // 备用方法: 使用本地时间+时区
        _useLocalTimeWithOffset();
      }
    } catch (e) {
      // 备用方法: 使用本地时间+时区
      _useLocalTimeWithOffset();
    }
  }

  void _useLocalTimeWithOffset() {
    setState(() {
      // 北京时间 = 本地时间 + 8小时偏移 (如果是国内环境通常已经是北京时间)
      _beijingTime = DateTime.now().toLocal();
      _isLoading = false;
    });
  }

  // 生成随机定位点
  void _generateRandomPoints() {
    final random = Random();
    for (int i = 0; i < 5; i++) {
      _points.add(PointData(
        id: i,
        position: Offset(
          50 + random.nextDouble() * 200,
          100 + random.nextDouble() * 300,
        ),
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
      ));
    }
  }

  // 启动定时器
  void _startTimers() {
    // 每秒更新时间显示
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _beijingTime = DateTime.now().toLocal();
      });
    });

    // 每100毫秒检查是否到00秒
    _checkTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now().toLocal();
      if (now.second == 0) {
        _autoTapPoints();
      }
    });
  }

  // 自动点击定位点
  void _autoTapPoints() {
    setState(() {
      for (var point in _points) {
        if (!point.isTapped) {
          point.isTapped = true;
          point.lastTapTime = DateTime.now().toLocal();
        }
      }
    });

    // 2秒后重置点击状态
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          for (var point in _points) {
            point.isTapped = false;
          }
        });
      }
    });
  }

  // 手动点击定位点
  void _tapPoint(PointData point) {
    setState(() {
      point.isTapped = !point.isTapped;
      if (point.isTapped) {
        point.lastTapTime = DateTime.now().toLocal();
      }
    });

    // 2秒后重置
    if (point.isTapped) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            point.isTapped = false;
          });
        }
      });
    }
  }

  // 添加新定位点
  void _addNewPoint(Offset position) {
    setState(() {
      _points.add(PointData(
        id: _points.length,
        position: position,
        color: Colors.primaries[_points.length % Colors.primaries.length],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tapper'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 在屏幕中心添加新点
              final screenSize = MediaQuery.of(context).size;
              _addNewPoint(Offset(screenSize.width / 2, screenSize.height / 2));
            },
            tooltip: '添加定位点',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBeijingTime,
            tooltip: '刷新时间',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
            ),
          ),
          // 时间显示
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: _buildTimeDisplay(),
          ),
          // 定位点
          ..._points.map((point) => _buildPoint(point)).toList(),
          // 操作提示
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildInfoCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '北京时间',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_beijingTime?.hour.toString().padLeft(2, '0')}:'
                    '${_beijingTime?.minute.toString().padLeft(2, '0')}:'
                    '${_beijingTime?.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (_beijingTime?.second == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '自动点击!',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              _beijingTime != null
                  ? '${_beijingTime!.year}-${_beijingTime!.month.toString().padLeft(2, '0')}-${_beijingTime!.day.toString().padLeft(2, '0')} ${_weekdayToChinese(_beijingTime!.weekday)}'
                  : '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoint(PointData point) {
    return Positioned(
      left: point.position.dx,
      top: point.position.dy,
      child: GestureDetector(
        onTap: () => _tapPoint(point),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + 0.2 * _pulseController.value;
            return Transform.scale(
              scale: point.isTapped ? 1.3 : scale,
              child: child,
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: point.isTapped ? Colors.green : point.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (point.isTapped ? Colors.green : point.color).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '${point.id + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(Icons.location_on, '定位点', '${_points.length}'),
                _buildInfoItem(Icons.access_time, '状态', _beijingTime?.second == 0 ? '自动点击中' : '等待中'),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '提示：每分钟 00 秒会自动点击所有定位点\n点击定位点可手动触发',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _weekdayToChinese(int weekday) {
    const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday];
  }
}
