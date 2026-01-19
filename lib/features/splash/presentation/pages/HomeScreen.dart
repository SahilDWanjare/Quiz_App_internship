// import 'package:flutter/material.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ID Aspire'),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(32),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF0D121F),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Icon(
//                   Icons.check_circle_outline,
//                   size: 80,
//                   color: Color(0xFF50C878),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               const Text(
//                 'Welcome to ID Aspire!',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0D121F),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Your registration is complete.\nGet ready to test your knowledge!',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF9E9E9E),
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 48),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Navigate to quiz or main dashboard
//                   },
//                   child: const Text('GET STARTED'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }