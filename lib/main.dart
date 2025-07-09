import 'package:flutter/material.dart';
import 'package:spammsg_nb_detector/spammsg_detector.dart';
import 'spammsg_detector.dart';

void main() {
  runApp(SpamApp());
}

class SpamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spam Detector',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SpamHomePage(),
    );
  }
}

class SpamHomePage extends StatefulWidget {
  @override
  _SpamHomePageState createState() => _SpamHomePageState();
}

class _SpamHomePageState extends State<SpamHomePage> {
  final TextEditingController _controller = TextEditingController();
  String result = '';
  bool isButtonEnabled = false;

  late NaiveBayesClassifier detector;

  @override
  void initState() {
    super.initState();
    detector = NaiveBayesClassifier();
    detector.loadModel('assets/naive_bayes_model.json');
    _controller.addListener(() {
      setState(() {
        isButtonEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  void _checkSpam() async {
    final inputText = _controller.text;
    final prediction = await detector.predict(inputText);
    setState(() {
      result = prediction == "spam" ? "🚨 Spam Detected!" : "✅ Message is Safe.";
    });
  }

  void _clearText() async {
    var inputText = _controller.text;
    final prediction = await detector.predict(inputText);
    setState(() {
      result =  "Please Enter Something to Predict☝️️";
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Spam Detector',
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 28.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your message',
                labelStyle: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? _checkSpam : null,
                    child: Text(
                      'Check Spam',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearText,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              result,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: result.contains('Spam') ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

