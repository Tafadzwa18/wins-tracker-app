import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart'; 

class WinTimelineScreen extends StatefulWidget {
  const WinTimelineScreen({super.key});

  @override
  _WinTimelineScreenState createState() => _WinTimelineScreenState();
}

class _WinTimelineScreenState extends State<WinTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text("Your Wins", style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.queryAllWins(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
          }

          if (snapshot.data!.isEmpty) {
            return Center(child: Text("No wins recorded yet. Start small! 🌱"));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              final date = DateTime.parse(item['timestamp']);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM d, y').format(date).toUpperCase(),
                            style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
                          ),
                          Icon(
                            item['type'] == 'voice' ? Icons.mic_none : Icons.edit_note,
                            size: 16,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        item['content'],
                        style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.4),
                      ),
                      if (item['tag'] != null) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF6B8E23).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "#${item['tag']}",
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B8E23)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Float action button to go to the "Add Win" screen
      floatingActionButton: FloatingActionButton(
        onPressed: () => /* Navigate to AddWinPage */ {},
        backgroundColor: Color(0xFF6B8E23),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}