import 'package:flutter/material.dart';
import '/screens/start_quiz_screen.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final List<dynamic> questions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;

  SummaryScreen({
    required this.score,
    required this.questions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[200]!,
              Colors.green[200]!
            ], // Same gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Custom AppBar without its own background, blended with the body
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
                    10, // Margin for status bar
                left: 16,
                right: 16,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quiz Summary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Completed!',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    // Custom Card with no elevation, sharing the same gradient background
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.transparent
                          ], // Same gradient as body
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(40), // More curve on top-left
                          topRight:
                              Radius.circular(40), // More curve on top-right
                          bottomLeft: Radius.circular(
                              20), // Slight curve on bottom-left
                          bottomRight: Radius.circular(
                              20), // Slight curve on bottom-right
                        ),
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Score: $score',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total Questions: ${questions.length}',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Correct Answers: $correctAnswers',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Wrong Answers: $wrongAnswers',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Skipped Questions: $skippedQuestions',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Questions and Answers List
                    Text(
                      'Questions & Answers:',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    // List of questions with answers
                    ...questions.map((question) {
                      final correctAnswer = question['options'].firstWhere(
                        (option) => option['is_correct'] == true,
                      )['description'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q: ${question['description']}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Correct Answer: $correctAnswer',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Restart Quiz Button aligned to the bottom with margin
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartQuizScreen()),
                    (route) => false,
                  );
                },
                child: Text('Restart Quiz', style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold,)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor:
                      Colors.blue[700], // Button color that matches theme
                ),
              ),
            ),
              SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
