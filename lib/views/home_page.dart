import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'LandingPage.dart';

class NemoWidget extends StatelessWidget {
  final String imagePath;
  final String text;
  final Size screenSize;
  final VoidCallback? onTap;

  const NemoWidget({
    super.key,
    required this.imagePath,
    required this.text,
    required this.screenSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: screenSize.width * 0.4,
            height: screenSize.height * 0.2,
            child: Center(child: Image.asset(imagePath)),
          ),
          Text(text),
        ],
      ),
    );
  }
}

class DinnerSection extends StatefulWidget {
  final Size screenSize;
  final dynamic houseId;

  const DinnerSection({super.key, required this.screenSize, required this.houseId});

  @override
  State<DinnerSection> createState() => _DinnerSectionState();
}

class _DinnerSectionState extends State<DinnerSection> {
  bool _isProcessing = false;

  Map<String, dynamic> _getMealInfo() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 8) {
      return {'type': 'breakfast', 'name': '조식', 'isOpen': true};
    } else if (hour >= 10 && hour < 12) {
      return {'type': '중식', 'name': '중식', 'isOpen': true};
    } else if (hour >= 16 && hour < 18) {
      return {'type': 'dinner', 'name': '석식', 'isOpen': true};
    }

    String nextMeal;
    if (hour < 5) {
      nextMeal = "조식(06~07시)";
    } else if (hour < 9) {
      nextMeal = "중식(10~11시)";
    } else if (hour < 15) {
      nextMeal = "석식(16~17시)";
    } else {
      nextMeal = "내일 조식(05~07시)";
    }
    
    return {'type': '', 'name': '', 'isOpen': false, 'next': nextMeal};
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final mealInfo = _getMealInfo();
    final today = DateTime.now().toIso8601String().split('T')[0];

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('meal_applications')
          .stream(primaryKey: ['id'])
          .eq('house_id', widget.houseId),
      builder: (context, snapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: Supabase.instance.client
              .from('profiles')
              .stream(primaryKey: ['id'])
              .eq('house', widget.houseId),
          builder: (context, profileSnapshot) {
            if (!snapshot.hasData || !profileSnapshot.hasData) return const SizedBox.shrink();

            final allMembersCount = profileSnapshot.data!.length;
            final currentApps = snapshot.data!.where((app) => 
              app['meal_date'] == today && 
              app['meal_type'] == mealInfo['type']
            ).toList();
            
            final List<String> eatingNames = currentApps.map((app) {
              final member = profileSnapshot.data!.firstWhere((m) => m['id'] == app['user_id'], orElse: () => {});
              return (member['name'] ?? '알 수 없음').toString();
            }).toList();

            final bool isMeApplied = currentApps.any((app) => app['user_id'] == user?.id);

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _isProcessing ? null : () async {
                      if (!mealInfo['isOpen']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("신청 시간이 아닙니다. 다음 신청: ${mealInfo['next']}")),
                        );
                        return;
                      }

                      setState(() => _isProcessing = true);
                      try {
                        if (isMeApplied) {
                          await Supabase.instance.client
                              .from('meal_applications')
                              .delete()
                              .eq('user_id', user!.id)
                              .eq('meal_type', mealInfo['type'])
                              .eq('meal_date', today);
                        } else {
                          await Supabase.instance.client.from('meal_applications').insert({
                            'user_id': user!.id,
                            'house_id': widget.houseId,
                            'meal_type': mealInfo['type'],
                            'meal_date': today,
                          });
                        }
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류: $e")));
                      } finally {
                        if (mounted) setState(() => _isProcessing = false);
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: widget.screenSize.width * 0.4,
                          height: widget.screenSize.height * 0.2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset("assets/dinner.jpg", 
                              fit: BoxFit.cover,
                              color: mealInfo['isOpen'] ? null : Colors.grey,
                              colorBlendMode: mealInfo['isOpen'] ? null : BlendMode.saturation,
                            ),
                          ),
                        ),
                        if (_isProcessing)
                          const CircularProgressIndicator(color: Colors.white)
                        else if (isMeApplied)
                          Container(
                            width: widget.screenSize.width * 0.4,
                            height: widget.screenSize.height * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check_circle, color: Colors.white, size: 40),
                          ),
                        if (!mealInfo['isOpen'])
                          Container(
                            width: widget.screenSize.width * 0.4,
                            height: widget.screenSize.height * 0.2,
                            alignment: Alignment.center,
                            child: Text(mealInfo['next'].split('(')[0], 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mealInfo['isOpen'] 
                    ? "${mealInfo['name']} 신청 (${currentApps.length}/$allMembersCount)" 
                    : "신청 시간 아님",
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                SizedBox(
                  width: widget.screenSize.width * 0.4,
                  child: Text(
                    eatingNames.isEmpty ? "신청자 없음" : eatingNames.join(', '),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class WashingMachineSection extends StatefulWidget {
  final Size screenSize;
  final dynamic houseId;

  const WashingMachineSection({super.key, required this.screenSize, required this.houseId});

  @override
  State<WashingMachineSection> createState() => _WashingMachineSectionState();
}

class _WashingMachineSectionState extends State<WashingMachineSection> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startUsing(int minutes) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final endTime = DateTime.now().add(Duration(minutes: minutes)).toUtc().toIso8601String();
    try {
      await Supabase.instance.client.from('washing_machine_status').upsert({
        'house_id': widget.houseId,
        'user_id': user.id,
        'end_time': endTime,
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류: $e")));
    }
  }

  Future<void> _stopUsing() async {
    try {
      await Supabase.instance.client.from('washing_machine_status').update({
        'end_time': DateTime.now().subtract(const Duration(seconds: 1)).toUtc().toIso8601String(),
      }).eq('house_id', widget.houseId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류: $e")));
    }
  }

  void _showTimeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("세탁기 사용 시간 설정"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "분 단위 입력 (예: 60)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          TextButton(
            onPressed: () {
              final mins = int.tryParse(controller.text);
              if (mins != null && mins > 0) {
                _startUsing(mins);
                Navigator.pop(context);
              }
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  void _showStopDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("세탁 종료"),
        content: const Text("세탁기 사용을 지금 종료하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          TextButton(
            onPressed: () {
              _stopUsing();
              Navigator.pop(context);
            },
            child: const Text("종료", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('washing_machine_status')
          .stream(primaryKey: ['house_id'])
          .eq('house_id', widget.houseId),
      builder: (context, snapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: Supabase.instance.client.from('profiles').stream(primaryKey: ['id']).eq('house', widget.houseId),
          builder: (context, profileSnapshot) {
            if (!snapshot.hasData || !profileSnapshot.hasData) return const SizedBox.shrink();

            final statusData = snapshot.data!.isEmpty ? null : snapshot.data!.first;
            bool isUsing = false;
            bool isMeUsing = false;
            String userName = "";
            int remaining = 0;

            if (statusData != null) {
              final endTime = DateTime.parse(statusData['end_time']).toLocal();
              final now = DateTime.now();
              if (endTime.isAfter(now)) {
                isUsing = true;
                isMeUsing = statusData['user_id'] == user?.id;
                remaining = endTime.difference(now).inMinutes;
                final userProfile = profileSnapshot.data!.firstWhere((p) => p['id'] == statusData['user_id'], orElse: () => {});
                userName = userProfile['name'] ?? "사용자";
              }
            }

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isUsing 
                        ? (isMeUsing ? _showStopDialog : null) 
                        : _showTimeDialog,
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: widget.screenSize.width * 0.4,
                          height: widget.screenSize.height * 0.2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset("assets/washclothes.jpg", fit: BoxFit.cover, color: isUsing ? Colors.black54 : null, colorBlendMode: isUsing ? BlendMode.darken : null),
                          ),
                        ),
                        if (isUsing)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer, color: Colors.white, size: 40),
                              Text("${remaining}분 남음", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              if (isMeUsing)
                                const Text("터치하여 종료", style: TextStyle(color: Colors.yellow, fontSize: 10)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(isUsing ? "$userName 사용 중" : "세탁기", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(isUsing ? "사용 중" : "사용 가능", style: TextStyle(fontSize: 11, color: isUsing ? Colors.red : Colors.green)),
              ],
            );
          },
        );
      },
    );
  }
}

class EmptySpace extends StatelessWidget {
  final Size screenSize;
  const EmptySpace({super.key, required this.screenSize});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SizedBox(
        width: screenSize.width * 0.07,
        height: screenSize.height * 0.07,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B1E),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: FutureBuilder<Map<String, dynamic>>(
          future: Supabase.instance.client
              .from('profiles')
              .select('house_info:house(name)')
              .eq('id', user?.id ?? '')
              .single(),
          builder: (context, snapshot) {
            String houseName = "";
            if (snapshot.hasData && snapshot.data != null) {
              final houseInfo = snapshot.data!['house_info'];
              if (houseInfo != null && houseInfo is Map) {
                houseName = houseInfo['name'] ?? "";
              }
            }
            return Text(
              houseName.isEmpty ? "하숙생활" : "$houseName 하숙생활",
              style: GoogleFonts.notoSerifKr(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1A1B1E)),
              child: Center(
                child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            FutureBuilder<Map<String, dynamic>?>(
              future: Supabase.instance.client.from('house').select().eq('owner_id', user?.id ?? '').maybeSingle(),
              builder: (context, houseSnapshot) {
                if (houseSnapshot.hasData && houseSnapshot.data != null) {
                  final houseId = houseSnapshot.data!['id'];
                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Supabase.instance.client.from('profiles').stream(primaryKey: ['id']).eq('house', houseId),
                    builder: (context, profilesSnapshot) {
                      final pendingCount = profilesSnapshot.hasData ? profilesSnapshot.data!.where((u) => u['status'] == 'pending').length : 0;
                      return ListTile(
                        leading: const Icon(Icons.person_add_alt_1),
                        title: const Text('식구 승인 관리'),
                        trailing: pendingCount > 0 ? Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))) : null,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MemberApprovalPage(houseId: houseId)));
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('하숙집 나가기', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('하숙집 나가기'),
                    content: const Text('정말 이 하숙집에서 나가시겠습니까?\n다시 입장하려면 코드를 입력하고 승인을 받아야 합니다.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('나가기', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  final userId = Supabase.instance.client.auth.currentUser!.id;
                  await Supabase.instance.client.from('profiles').update({'status': 'wait', 'house': null}).eq('id', userId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              onTap: () async { await Supabase.instance.client.auth.signOut(); },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Supabase.instance.client.from('profiles').select('house').eq('id', user?.id ?? '') .single(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final houseId = snapshot.data!['house'];
          return Container(
            color: Colors.white,
            width: double.infinity,
            child: Column(
              children: [
                Row(children: [SizedBox(width: screenSize.width * 0.125, height: screenSize.height * 0.17)]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmptySpace(screenSize: screenSize),
                    DinnerSection(screenSize: screenSize, houseId: houseId),
                    EmptySpace(screenSize: screenSize),
                    WashingMachineSection(screenSize: screenSize, houseId: houseId),
                  ],
                ),
                EmptySpace(screenSize: screenSize),
                Row(
                  children: [
                    EmptySpace(screenSize: screenSize),
                    NemoWidget(
                      imagePath: "assets/siren.jpg",
                      text: "비상호출",
                      screenSize: screenSize,
                      onTap: () async {
                        // 테스트용 번호로 변경했습니다.
                        final Uri url = Uri.parse('tel:119');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("전화 기능을 실행할 수 없습니다.")),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 30),
                    Column(children: [SizedBox(width: screenSize.width * 0.4, height: screenSize.height * 0.2, child: const Center(child: Text("건의")))]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
