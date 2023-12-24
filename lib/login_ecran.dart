import 'package:atelier4_o_erraouidate_iir5g2/ListeProduits.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class login_ecran extends StatelessWidget {
  const login_ecran({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
           if ( ! snapshot.hasData) {
            return SignInScreen();
        
      }
return ListProduit();       
      },      
      );
  }
  
}