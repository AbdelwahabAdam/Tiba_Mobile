import 'package:flutter/material.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller must be injected ONCE by GetPage
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
