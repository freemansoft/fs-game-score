import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/presentation/in_game_app_bar.dart';
import 'package:fs_score_card/presentation/score_table.dart';
import 'package:fs_score_card/provider/game_sync_host_provider.dart';

class ScoreTableScreen extends ConsumerStatefulWidget {
  const ScoreTableScreen({super.key});

  @override
  ConsumerState<ScoreTableScreen> createState() => _ScoreTableScreenState();
}

class _ScoreTableScreenState extends ConsumerState<ScoreTableScreen> {
  @override
  void deactivate() {
    unawaited(ref.read(gameSyncHostProvider.notifier).stopHosting());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: InGameAppBar(),
      body: Padding(padding: EdgeInsets.all(4), child: ScoreTable()),
    );
  }
}
