import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wins/add_win_page.dart';
import 'database_helper.dart';

class WinTimelineScreen extends StatefulWidget {
  const WinTimelineScreen({super.key});

  @override
  _WinTimelineScreenState createState() => _WinTimelineScreenState();
}

class _WinTimelineScreenState extends State<WinTimelineScreen> {
  late ConfettiController _confettiController;
  final Color primaryNeon = const Color(0xFF13EC5B);
  final Color darkBg = const Color(0xFF102216);
  final Color lightBg = const Color(0xFFF6F8F6);

  // Local list to keep UI in sync with swiping
  List<Map<String, dynamic>>? _localWins;

  @override
  void initState() {
    super.initState();
    // Initialize confetti to last for 1 second
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _calculateStats(List<Map<String, dynamic>> wins) {
    if (wins.isEmpty) return {'count': 0, 'topTag': 'None'};
    final now = DateTime.now();
    final monthlyWins = wins.where((win) {
      final date = DateTime.parse(win['timestamp']);
      return date.month == now.month && date.year == now.year;
    }).toList();

    var tagCounts = <String, int>{};
    for (var win in wins) {
      String tag = win['tag'] ?? 'General';
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }

    var topTag = tagCounts.entries.isNotEmpty
        ? tagCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'None';

    return {'count': monthlyWins.length, 'topTag': topTag};
  }

  void _refreshData() {
    setState(() {
      _localWins = null; // Forces FutureBuilder to re-fetch fresh data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: const Text(
          "Your Wins",
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0D1B12), fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: Color(0xFF0D1B12)),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      // We use a Stack so the Confetti can float OVER the content
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper.instance.queryAllWins(),
            builder: (context, snapshot) {
              if (snapshot.hasData && _localWins == null) {
                _localWins = List.from(snapshot.data!);
              }

              if (_localWins == null && snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: primaryNeon));
              }

              if (_localWins == null || _localWins!.isEmpty) {
                return const Center(child: Text("No wins recorded yet. Start small! 🚀"));
              }

              final stats = _calculateStats(_localWins!);

              return Column(
                children: [
                  _buildSummaryHeader(stats['count'], stats['topTag']),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _localWins!.length,
                      itemBuilder: (context, index) {
                        final item = _localWins![index];
                        final int id = item['id'];
                        final date = DateTime.parse(item['timestamp']);
                        bool isFav = item['isFavorite'] == 1;

                        return Dismissible(
                          key: ValueKey(id), 
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            // 1. Local Sync: remove from memory immediately
                            setState(() {
                              _localWins!.removeAt(index);
                            });

                            // 2. Database Sync: delete from storage
                            DatabaseHelper.instance.deleteWin(id).then((_) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Win removed")),
                                );
                              }
                            });
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('MMM d, y').format(date).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[400],
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await DatabaseHelper.instance.toggleFavorite(id, isFav);
                                            _refreshData();
                                          },
                                          child: Icon(
                                            isFav ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                                            color: isFav ? primaryNeon : Colors.grey[200],
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          item['type'] == 'voice' ? Icons.mic : Icons.notes,
                                          size: 14,
                                          color: Colors.grey[300],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['content'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0D1B12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [primaryNeon, Colors.white, Colors.green],
              numberOfParticles: 15,
              gravity: 0.1,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWinPage()),
          );
          // When returning: refresh the list AND trigger confetti
          _refreshData();
          _confettiController.play();
        },
        backgroundColor: primaryNeon,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildSummaryHeader(int count, String topTag) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: primaryNeon, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$count WINS THIS MONTH",
                  style: TextStyle(color: primaryNeon, fontWeight: FontWeight.w800, fontSize: 12),
                ),
                Text(
                  "Crushing it in #$topTag",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}