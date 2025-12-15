import 'package:flutter/material.dart';
import 'package:fs_score_card/app_bar.dart';
import 'package:fs_score_card/presentation/score_table.dart';

class ScoreTableScreen extends StatelessWidget {
  const ScoreTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Phase10AppBar(),
      body: Padding(padding: EdgeInsets.all(4.0), child: ScoreTable()),
    );
  }
}
