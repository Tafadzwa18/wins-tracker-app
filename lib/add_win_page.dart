import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:wins/database_helper.dart';

class AddWinPage extends StatefulWidget {
  const AddWinPage({super.key});

  @override
  _AddWinPageState createState() => _AddWinPageState();
}

class _AddWinPageState extends State<AddWinPage> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final List<String> _categories = ['General', 'Work', 'Health', 'Learning', 'Social', 'Personal'];
  String _selectedTag = 'General';
  String _captureType ='text';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

 // Voice Dictation Logic
 void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _captureType = 'voice'; // Mark this as a voice entry
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleSave() async {
    if (_controller.text.isEmpty) return;

    Map<String, dynamic> row = {
      'content': _controller.text,
      'timestamp': DateTime.now().toIso8601String(),
      'type': _captureType, 
      'tag': _selectedTag,
      'isFavorite': 0,
    };

    await DatabaseHelper.instance.insertWin(row);

    _controller.clear();
    setState((){
      _captureType = 'text';
      _selectedTag = 'General';
    }); // Reset for next entry

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Win recorded! ✨"), backgroundColor: Color(0xFF6B8E23)),
    );
  }

Widget _buildTagSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Category", style: TextStyle(color: Colors.grey, fontSize: 14)),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((tag) {
            bool isSelected = _selectedTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTag = tag);
                },
                selectedColor: const Color(0xFF6B8E23).withOpacity(0.2),
                checkmarkColor: const Color(0xFF6B8E23),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF6B8E23) : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6B8E23) : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Capture the moment", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300)),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(hintText: "What went well today?", border: InputBorder.none),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            _buildTagSelector(),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // The Mic Button
                FloatingActionButton(
                  onPressed: _listen,
                  backgroundColor: _isListening ? Colors.redAccent : const Color(0xFF6B8E23),
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
                ),
                // The Save Button
                ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23)),
                  child: const Text("Save Win", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}