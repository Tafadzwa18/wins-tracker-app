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
  Map<String, dynamic> _calculateStats(List<Map<String, dynamic>> wins) {
    if (wins.isEmpty) return {'count': 0, 'topTag': 'None'};

    final now = DateTime.now();

    // 1. Filter wins for the current month
    final monthlyWins = wins.where((win) {
      final date = DateTime.parse(win['timestamp']);
      return date.month == now.month && date.year == now.year;
    }).toList();

    // 2. Find the most frequent tag
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

  Widget _buildSummaryHeader(int count, String topTag) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B8E23).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6B8E23).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF6B8E23), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This month, you've captured $count wins!",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're thriving in #$topTag. Keep it up! ",
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          "Your Wins",
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.queryAllWins(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B8E23)),
            );
          }

          final allWins = snapshot.data!;

          if (allWins.isEmpty) {
            return const Center(
              child: Text("No wins recorded yet. Start small"),
            );
          }

          // 1. Calculate stats from the data we just fetched
          final stats = _calculateStats(allWins);

          return Column(
            children: [
              // 2. Add the Summary Header at the top
              _buildSummaryHeader(stats['count'], stats['topTag']),

              // 3. The List of Wins
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: allWins.length,
                  itemBuilder: (context, index) {
                    final item = allWins[index];
                    final int id = item['id'];
                    bool isFav = item['isFavorite'] == 1;
                    final date = DateTime.parse(item['timestamp']);

                    return Dismissible(
                      key: Key(id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await DatabaseHelper.instance.deleteWin(id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Win removed from timeline"),
                              backgroundColor: Colors.black87,
                            ),
                          );
                          // Trigger a rebuild to update the Summary Header count
                          setState(() {});
                        }
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMMM d, y',
                                    ).format(date).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFav
                                              ? Colors.redAccent
                                              : Colors.grey[300],
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          await DatabaseHelper.instance
                                              .toggleFavorite(id, isFav);
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        item['type'] == 'voice'
                                            ? Icons.mic_none
                                            : Icons.edit_document,
                                        size: 16,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['content'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              if (item['tag'] != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6B8E23,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "#${item['tag']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B8E23),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
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

      // Float action button to go to the "Add Win" screen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWinPage()),
          );
        },
        backgroundColor: Color(0xFF6B8E23),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
