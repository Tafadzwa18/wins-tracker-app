import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'database_helper.dart';

class AddWinPage extends StatefulWidget {
  const AddWinPage({super.key});

  @override
  _AddWinPageState createState() => _AddWinPageState();
}

class _AddWinPageState extends State<AddWinPage> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _selectedTag = 'General';

  // Design System Colors
  final Color primaryNeon = const Color(0xFF13EC5B);
  final Color darkBg = const Color(0xFF102216);
  final Color lightSurface = const Color(0xFFFFFFFF);

  final List<String> _tags = [
    'General',
    'Work',
    'Health',
    'Learning',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _saveWin() async {
    if (_controller.text.isEmpty) return;

    await DatabaseHelper.instance.insertWin({
      'content': _controller.text,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'text',
      'tag': _selectedTag,
      'isFavorite': 0,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0D1B12)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "New Win",
          style: TextStyle(
            color: Color(0xFF0D1B12),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag Selector
            const Text(
              "CATEGORY",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Color(0xFF4C6654),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _tags.map((tag) {
                  bool isSelected = _selectedTag == tag;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTag = tag),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryNeon : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryNeon : Colors.black12,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "#$tag",
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Main Input Area
            Container(
              decoration: BoxDecoration(
                color: lightSurface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: "What happened today?",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(height: 40),

                  // Voice Button
                  GestureDetector(
                    onTap: _listen,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isListening ? primaryNeon : darkBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isListening)
                            BoxShadow(
                              color: primaryNeon.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.black : primaryNeon,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isListening ? "Listening..." : "Tap to speak",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _isListening ? primaryNeon : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Save Button (Matching Onboarding Continue Button)
            ElevatedButton(
              onPressed: _saveWin,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryNeon,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: primaryNeon.withOpacity(0.4),
              ),
              child: const Text(
                "Save Win",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
