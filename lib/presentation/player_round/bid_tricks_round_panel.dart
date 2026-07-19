import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';

/// Round editor for bid/tricks trick-taking games (Oh Hell, Wizard).
///
/// Emits an updated [BidTricksRoundAttributes] whenever the bid or tricks
/// field changes; the calculated round score is derived elsewhere from the
/// mode's `RoundInput` (see `bidTricksScore`).
class BidTricksRoundPanel extends StatefulWidget {
  const BidTricksRoundPanel({
    super.key,
    required this.attributes,
    required this.onChanged,
  });

  final BidTricksRoundAttributes attributes;
  final ValueChanged<BidTricksRoundAttributes> onChanged;

  static const ValueKey<String> bidFieldKey = ValueKey<String>('bt_bid_field');
  static const ValueKey<String> tricksFieldKey = ValueKey<String>(
    'bt_tricks_field',
  );
  static const ValueKey<String> zeroBidNoteKey = ValueKey<String>(
    'bt_zero_bid_note',
  );

  @override
  State<BidTricksRoundPanel> createState() => _BidTricksRoundPanelState();
}

class _BidTricksRoundPanelState extends State<BidTricksRoundPanel> {
  late final TextEditingController _bidController;
  late final TextEditingController _tricksController;

  @override
  void initState() {
    super.initState();
    _bidController = TextEditingController(
      text: widget.attributes.bid.toString(),
    );
    _tricksController = TextEditingController(
      text: widget.attributes.tricksTaken.toString(),
    );
  }

  @override
  void dispose() {
    _bidController.dispose();
    _tricksController.dispose();
    super.dispose();
  }

  void _emit({int? bid, int? tricksTaken}) {
    widget.onChanged(
      widget.attributes.copyWith(bid: bid, tricksTaken: tricksTaken),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: BidTricksRoundPanel.bidFieldKey,
                controller: _bidController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.bidLabel),
                onChanged: (v) => _emit(bid: int.tryParse(v) ?? 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: BidTricksRoundPanel.tricksFieldKey,
                controller: _tricksController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.tricksTakenLabel),
                onChanged: (v) => _emit(tricksTaken: int.tryParse(v) ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Stopgap for known defect D1: a made 0-bid is not yet scored. Explain
        // the current behavior in-line until the fix lands (see the roadmap).
        Text(
          key: BidTricksRoundPanel.zeroBidNoteKey,
          l10n.bidTricksZeroBidNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
