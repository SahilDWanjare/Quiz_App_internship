import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/assessment.dart';

class AssessmentRepository {
  final FirebaseFirestore _firestore;

  AssessmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Assessment?> getAssessment(String assessmentId) async {
    try {
      final doc = await _firestore
          .collection('assessments')
          .doc(assessmentId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return Assessment(
        id: doc.id,
        title: data['title'] ?? 'Executive Capability Assessment',
        passage: data['passage'] ?? '',
        imageUrl: data['image_url'],
        durationMinutes: data['duration_minutes'] ?? 90,
        totalQuestions: data['total_questions'] ?? 30,
        createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error getting assessment: $e');
      return null;
    }
  }

  Future<List<Question>> getQuestions(String assessmentId) async {
    try {
      final snapshot = await _firestore
          .collection('assessments')
          .doc(assessmentId)
          .collection('questions')
          .orderBy('question_number')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          id: doc.id,
          questionText: data['question_text'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctIndex: data['correct_index'] ?? 0,
          questionNumber: data['question_number'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  Future<String> createAttempt({
    required String userId,
    required String assessmentId,
    required DateTime startTime,
  }) async {
    try {
      final attemptRef = await _firestore.collection('quiz_attempts').add({
        'user_id': userId,
        'assessment_id': assessmentId,
        'start_time': Timestamp.fromDate(startTime),
        'answers': {},
        'current_question_index': 0,
        'is_completed': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      return attemptRef.id;
    } catch (e) {
      print('Error creating attempt: $e');
      throw Exception('Failed to create attempt');
    }
  }

  Future<void> saveProgress({
    required String attemptId,
    required Map<int, int> answers,
    required int currentQuestionIndex,
  }) async {
    try {
      // Convert Map<int, int> to Map<String, dynamic> for Firestore
      final answersMap = answers.map(
            (key, value) => MapEntry(key.toString(), value),
      );

      await _firestore.collection('quiz_attempts').doc(attemptId).update({
        'answers': answersMap,
        'current_question_index': currentQuestionIndex,
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving progress: $e');
      throw Exception('Failed to save progress');
    }
  }

  Future<QuizAttempt> submitQuiz({
    required String attemptId,
    required Map<int, int> answers,
    required DateTime endTime,
    required int score,
    required int totalQuestions,
    required int timeSpentSeconds,
  }) async {
    try {
      // Convert Map<int, int> to Map<String, dynamic> for Firestore
      final answersMap = answers.map(
            (key, value) => MapEntry(key.toString(), value),
      );

      await _firestore.collection('quiz_attempts').doc(attemptId).update({
        'answers': answersMap,
        'end_time': Timestamp.fromDate(endTime),
        'score': score,
        'total_questions': totalQuestions,
        'is_completed': true,
        'time_spent_seconds': timeSpentSeconds,
        'completed_at': FieldValue.serverTimestamp(),
      });

      // Fetch the updated document
      final doc = await _firestore
          .collection('quiz_attempts')
          .doc(attemptId)
          .get();

      final data = doc.data()!;

      // Convert Firestore map back to Map<int, int>
      final answersFromDb = (data['answers'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(int.parse(key), value as int),
      );

      return QuizAttempt(
        id: doc.id,
        userId: data['user_id'],
        assessmentId: data['assessment_id'],
        answers: answersFromDb,
        startTime: (data['start_time'] as Timestamp).toDate(),
        endTime: (data['end_time'] as Timestamp).toDate(),
        score: data['score'],
        totalQuestions: data['total_questions'],
        isCompleted: data['is_completed'],
        timeSpentSeconds: data['time_spent_seconds'],
      );
    } catch (e) {
      print('Error submitting quiz: $e');
      throw Exception('Failed to submit quiz');
    }
  }

  Future<List<QuizAttempt>> getUserAttempts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_attempts')
          .where('user_id', isEqualTo: userId)
          .where('is_completed', isEqualTo: true)
          .orderBy('completed_at', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Convert Firestore map back to Map<int, int>
        final answers = (data['answers'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(int.parse(key), value as int),
        );

        return QuizAttempt(
          id: doc.id,
          userId: data['user_id'],
          assessmentId: data['assessment_id'],
          answers: answers,
          startTime: (data['start_time'] as Timestamp).toDate(),
          endTime: (data['end_time'] as Timestamp?)?.toDate(),
          score: data['score'] ?? 0,
          totalQuestions: data['total_questions'] ?? 0,
          isCompleted: data['is_completed'] ?? false,
          timeSpentSeconds: data['time_spent_seconds'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting user attempts: $e');
      return [];
    }
  }
}