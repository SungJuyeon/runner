// main.dart or any file where navigation functions are defined
import 'package:flutter/material.dart';

// Function to navigate to the Ranking page
void onRankingPressed(BuildContext context) {
  Navigator.pushNamed(context, '/ranking');
}

// Function to navigate to the Home page
void onHomePressed(BuildContext context) {
  Navigator.pushNamed(context, '/home');
}

// Function to navigate to the Profile page
void onProfilePressed(BuildContext context) {
  Navigator.pushNamed(context, '/profile');
}
