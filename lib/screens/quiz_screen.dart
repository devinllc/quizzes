import 'dart:async';
import 'package:flutter/material.dart';
import '/services/api_service.dart';
import '/screens/summary_screen.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int totalScore = 0;
  late Timer _timer;
  int _totalTimeLeft = 150; // Total quiz time (150 seconds)
  bool isAnswered = false;
  int? selectedOptionIndex;

  // New variables to track statistics
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int skippedQuestions = 0;

  // New variable to track if summary has already been shown
  bool isQuizCompleted = false;

  @override
  void initState() {
    super.initState();
    loadQuizData();
  }

  void loadQuizData() async {
    try {
      final quizData = await apiService.fetchQuizData();
      setState(() {
        questions = List.from(quizData['questions']);
        questions.shuffle(); // Randomize questions
        _startTimer(); // Start the total timer
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load quiz data')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_totalTimeLeft == 0) {
        _timer.cancel();
        // Quiz is over, move to summary screen
        _navigateToSummary();
      } else {
        setState(() {
          _totalTimeLeft--;
        });
      }
    });
  }

  void _moveToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOptionIndex = null; // Reset the selected option
      });
    } else {
      _timer.cancel();
      _navigateToSummary(); // Navigate to summary after the last question
    }
  }

  void _navigateToSummary() {
    // Ensure that the quiz summary is shown only once
    if (!isQuizCompleted) {
      isQuizCompleted = true; // Mark quiz as completed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(
            score: totalScore,
            questions: questions,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            skippedQuestions: skippedQuestions,
          ),
        ),
      );
    }
  }

  void answerQuestion(int score, bool isCorrect) {
    setState(() {
      totalScore += score;
      isAnswered = true;
      if (isCorrect) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      _moveToNextQuestion();
    });
  }

  void skipQuestion() {
    setState(() {
      skippedQuestions++;
      isAnswered = true; // Skip the current question
    });

    Future.delayed(Duration(seconds: 1), () {
      _moveToNextQuestion();
    });
  }

  // Show a confirmation dialog when the user clicks submit
  void showSubmitConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to submit the quiz?'),
          content: Text(
              'You will not be able to change your answers once submitted.'),
          actions: [
            TextButton(
              onPressed: () {
                // Cancel the submission and resume the quiz
                Navigator.pop(context);
                _startTimer(); // Resume the timer
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Stop the timer and go to the summary screen
                _timer.cancel();
                _navigateToSummary();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[200]!, Colors.green[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar inside Body (without its own background)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quiz',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Time left: $_totalTimeLeft s',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(question['description'], style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            ...question['options'].map((option) {
              final optionIndex = question['options'].indexOf(option);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    minimumSize: Size(double.infinity, 60),
                    backgroundColor: Colors.blue, // Default color for options
                  ),
                  onPressed: isAnswered
                      ? null
                      : () {
                          setState(() {
                            selectedOptionIndex = optionIndex;
                          });
                          answerQuestion(
                            option['is_correct'] ? 4 : -1,
                            option['is_correct'],
                          );
                        },
                  child: Text(option['description'],
                      style: TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
            Spacer(),
            // Skip and Submit buttons with different colors
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: skipQuestion,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          backgroundColor: Colors.red,
                          minimumSize: Size(
                              double.infinity, 60), // Skip button color (red)
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: isAnswered
                            ? null
                            : () {
                                showSubmitConfirmation(); // Show submit confirmation
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.infinity,
                              60), // Submit button color (green)
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
