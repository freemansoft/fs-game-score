import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/french_driving_round_attributes.dart';
import 'package:fs_score_card/model/score_filters.dart';

class FrenchDrivingRoundPanel extends StatefulWidget {
  const FrenchDrivingRoundPanel({
    super.key,
    required this.attributes,
    required this.onChanged,
  });

  final FrenchDrivingRoundAttributes attributes;
  final ValueChanged<FrenchDrivingRoundAttributes> onChanged;

  static const ValueKey<String> milesFieldKey = ValueKey<String>(
    'mb_miles_field',
  );
  static const ValueKey<String> safetiesDropdownKey = ValueKey<String>(
    'mb_safeties_dropdown',
  );
  static const ValueKey<String> coupFourreDropdownKey = ValueKey<String>(
    'mb_coup_fourre_dropdown',
  );
  static const ValueKey<String> delayedActionKey = ValueKey<String>(
    'mb_delayed_action_checkbox',
  );
  static const ValueKey<String> safeTripKey = ValueKey<String>(
    'mb_safe_trip_checkbox',
  );
  static const ValueKey<String> shutOutKey = ValueKey<String>(
    'mb_shut_out_checkbox',
  );

  @override
  State<FrenchDrivingRoundPanel> createState() =>
      _FrenchDrivingRoundPanelState();
}

class _FrenchDrivingRoundPanelState extends State<FrenchDrivingRoundPanel> {
  late FrenchDrivingRoundAttributes _localAttributes;
  late TextEditingController _milesController;
  late FocusNode _milesFocusNode;
  bool _milesHasValidationError = false;

  @override
  void initState() {
    super.initState();
    _localAttributes = widget.attributes;
    _milesController = TextEditingController(
      text: _localAttributes.miles.toString(),
    );
    _milesFocusNode = FocusNode();
    _milesFocusNode.addListener(_onMilesFocusChange);
  }

  @override
  void dispose() {
    _milesController.dispose();
    _milesFocusNode.dispose();
    super.dispose();
  }

  void _validateMiles(String value) {
    if (value.isEmpty) {
      setState(() {
        _milesHasValidationError = false;
      });
      return;
    }
    final regex = RegExp(ScoreFilters.endsWith0or5);
    setState(() {
      _milesHasValidationError = !regex.hasMatch(value);
    });
  }

  void _onMilesFocusChange() {
    // If focus is lost while there's a validation error, re-request focus
    if (!_milesFocusNode.hasFocus &&
        _milesHasValidationError &&
        _milesController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _milesFocusNode.requestFocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidScoreForRound),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _updateAttributes(FrenchDrivingRoundAttributes newAttributes) {
    setState(() {
      _localAttributes = newAttributes;
    });
    widget.onChanged(newAttributes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMilesSection(l10n, compact: true),
              const SizedBox(width: 16),
              Expanded(child: _buildSafetiesSection(l10n)),
            ],
          ),
          _buildBonusesSection(l10n),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMilesSection(l10n),
        const SizedBox(height: 12),
        _buildSafetiesSection(l10n),
        const SizedBox(height: 12),
        _buildBonusesSection(l10n),
      ],
    );
  }

  Widget _buildMilesSection(AppLocalizations l10n, {bool compact = false}) {
    final textField = Semantics(
      label: 'Miles Driven',
      child: TextField(
        key: FrenchDrivingRoundPanel.milesFieldKey,
        controller: _milesController,
        focusNode: _milesFocusNode,
        keyboardType: TextInputType.number,
        autofocus: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: InputDecoration(
          hintText: l10n.miles,
          isDense: true,
          errorText: _milesHasValidationError
              ? l10n.invalidScoreForRound
              : null,
        ),
        onChanged: (val) {
          _validateMiles(val);
          if (!_milesHasValidationError) {
            final miles = int.tryParse(val) ?? 0;
            _updateAttributes(_localAttributes.copyWith(miles: miles));
          }
        },
      ),
    );

    if (compact) {
      // Landscape: constrained width, no label above
      return Row(
        children: [
          Tooltip(
            message: l10n.milesTooltip,
            child: Text(
              '${l10n.miles}: ',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          SizedBox(width: 100, child: textField),
        ],
      );
    }

    // Portrait: label above, full width
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: l10n.milesTooltip,
          child: Text(
            l10n.miles,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 4),
        textField,
      ],
    );
  }

  Widget _buildSafetiesSection(AppLocalizations l10n) {
    final numSafeties = _localAttributes.safetyCards.where((s) => s).length;
    final numCoupFourre = _localAttributes.coupFourre.where((c) => c).length;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final safetiesRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: l10n.safetiesTooltip,
          child: Text('${l10n.safeties}: '),
        ),
        Semantics(
          button: true,
          label: 'Number of Safeties',
          child: Tooltip(
            message: l10n.safetiesTooltip,
            child: DropdownButton<int>(
              key: FrenchDrivingRoundPanel.safetiesDropdownKey,
              value: numSafeties,
              items:
                  List.generate(
                        5,
                        (i) => i,
                      )
                      .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  final newSafeties = List.filled(4, false);
                  for (int i = 0; i < val; i++) {
                    newSafeties[i] = true;
                  }
                  _updateAttributes(
                    _localAttributes.copyWith(safetyCards: newSafeties),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );

    final coupFourreRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: l10n.coupFourreTooltip,
          child: Text('${l10n.coupFourre}: '),
        ),
        Semantics(
          button: true,
          label: 'Number of Coup Fourre',
          child: Tooltip(
            message: l10n.coupFourreTooltip,
            child: DropdownButton<int>(
              key: FrenchDrivingRoundPanel.coupFourreDropdownKey,
              value: numCoupFourre,
              items: List.generate(5, (i) => i)
                  .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  final newCoupFourre = List.filled(4, false);
                  for (int i = 0; i < val; i++) {
                    newCoupFourre[i] = true;
                  }
                  _updateAttributes(
                    _localAttributes.copyWith(coupFourre: newCoupFourre),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isPortrait)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              safetiesRow,
              coupFourreRow,
            ],
          )
        else
          Row(
            children: [
              safetiesRow,
              const SizedBox(width: 24),
              coupFourreRow,
            ],
          ),
      ],
    );
  }

  Widget _buildBonusesSection(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      children: [
        Semantics(
          label: 'Delayed Action Bonus',
          child: Tooltip(
            message: l10n.delayedActionTooltip,
            child: _buildCheckbox(
              l10n.delayedAction,
              _localAttributes.delayedAction,
              (val) => _updateAttributes(
                _localAttributes.copyWith(delayedAction: val),
              ),
              FrenchDrivingRoundPanel.delayedActionKey,
            ),
          ),
        ),
        Semantics(
          label: 'Safe Trip Bonus',
          child: Tooltip(
            message: l10n.safeTripTooltip,
            child: _buildCheckbox(
              l10n.safeTrip,
              _localAttributes.safeTrip,
              (val) =>
                  _updateAttributes(_localAttributes.copyWith(safeTrip: val)),
              FrenchDrivingRoundPanel.safeTripKey,
            ),
          ),
        ),
        Semantics(
          label: 'Shut Out Bonus',
          child: Tooltip(
            message: l10n.shutOutTooltip,
            child: _buildCheckbox(
              l10n.shutOut,
              _localAttributes.shutOut,
              (val) =>
                  _updateAttributes(_localAttributes.copyWith(shutOut: val)),
              FrenchDrivingRoundPanel.shutOutKey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
    Key key,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          key: key,
          value: value,
          onChanged: onChanged,
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
