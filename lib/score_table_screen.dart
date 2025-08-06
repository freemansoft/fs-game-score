import 'package:flutter/material.dart';
import 'package:fs_score_card/app_bar.dart';
import 'package:fs_score_card/score_table.dart';

class ScoreTableScreen extends StatelessWidget {
  const ScoreTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Phase10AppBar(),
      body: const Padding(padding: EdgeInsets.all(4.0), child: ScoreTable()),
    );
  }
}
