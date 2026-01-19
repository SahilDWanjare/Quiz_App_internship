// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:test_app_project/features/assessment/domain/entities/assessment.dart';
// import '../../data/repository/assessment_repository.dart';
// import '../../domain/entities/quiz_result.dart';
// import '../widgets/circular_percentage_indicator.dart';
// import '../widgets/stat_badge.dart';
// import '../widgets/category_score_card.dart';
// import '../widgets/history_item_card.dart';
//
// class ResultScreen extends StatefulWidget {
//   final QuizResult result;
//   final int correctAnswers;
//   final int totalQuestions;
//   final int attempt;
//
//
//   const ResultScreen({
//     Key? key,
//     required this.result,
//     required this.correctAnswers,
//     required this.totalQuestions,
//     required this.attempt,
//   }) : super(key: key);
//
//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<AttemptHistory> _history = [];
//   bool _loadingHistory = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadHistory();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadHistory() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final repository = AssessmentRepository();
//       final attempts = await repository.getUserAttempts(user.uid);
//
//       setState(() {
//         _history = attempts
//             .asMap()
//             .entries
//             .map((entry) => AttemptHistory(
//           attemptId: entry.value.id,
//           attemptNumber: 'ATTEMPT: ${(entry.key + 1).toString().padLeft(2, '0')}',
//           date: entry.value.endTime ?? entry.value.startTime,
//           scorePercentage: entry.value.percentage,
//           correctAnswers: entry.value.score,
//           totalQuestions: entry.value.totalQuestions,
//         ))
//             .toList();
//         _loadingHistory = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               const Color(0xFFF5F5DC).withOpacity(0.3),
//               Colors.grey.shade50,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(),
//               _buildResultCard(),
//               const SizedBox(height: 24),
//               _buildTabBar(),
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildSummaryTab(),
//                     _buildHistoryTab(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const SizedBox(width: 40),
//           const Text(
//             'RESULT SCREEN',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF0D121F),
//               letterSpacing: 0.5,
//             ),
//           ),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.home, size: 20),
//               color: const Color(0xFF0D121F),
//               onPressed: () {
//                 Navigator.of(context).popUntil((route) => route.isFirst);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResultCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           CircularPercentageIndicator(
//             percentage: widget.result.percentage,
//             size: 120,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             widget.result.isPassed
//                 ? 'CONGRATULATIONS!'
//                 : 'KEEP TRYING!',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: widget.result.isPassed
//                   ? const Color(0xFF00C853)
//                   : const Color(0xFFD4AF37),
//               letterSpacing: 0.5,
//             ),
//           ),
//           Text(
//             widget.result.isPassed
//                 ? 'You have passed the test!'
//                 : 'You need 90% to pass',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               StatBadge(
//                 icon: Icons.help_outline,
//                 iconColor: const Color(0xFF7B3FF2),
//                 value: widget.result.totalQuestions.toString(),
//                 label: 'TOTAL QUESTIONS',
//               ),
//               StatBadge(
//                 icon: Icons.check_circle_outline,
//                 iconColor: const Color(0xFF00C853),
//                 value: widget.result.correctAnswers.toString(),
//                 label: 'CORRECT',
//               ),
//               StatBadge(
//                 icon: Icons.cancel_outlined,
//                 iconColor: const Color(0xFFFF3D00),
//                 value: widget.result.incorrectAnswers.toString(),
//                 label: 'INCORRECT',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: TabBar(
//         controller: _tabController,
//         indicator: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         labelColor: const Color(0xFF0D121F),
//         unselectedLabelColor: Colors.grey.shade600,
//         labelStyle: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           letterSpacing: 0.5,
//         ),
//         tabs: const [
//           Tab(text: 'SUMMERY'),
//           Tab(text: 'HISTORY'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryTab() {
//     return ListView(
//       padding: const EdgeInsets.all(20),
//       children: [
//         ...widget.result.categoryScores.map((category) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: CategoryScoreCard(category: category),
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   Widget _buildHistoryTab() {
//     if (_loadingHistory) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: Color(0xFF0D121F),
//         ),
//       );
//     }
//
//     if (_history.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.history,
//               size: 64,
//               color: Colors.grey.shade300,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No previous attempts',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return ListView(
//       padding: const EdgeInsets.all(20),
//       children: [
//         ..._history.map((attempt) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: HistoryItemCard(attempt: attempt),
//           );
//         }).toList(),
//       ],
//     );
//   }
// }