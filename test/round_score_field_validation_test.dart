import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/round_score_field.dart';

void main() {
  group('RoundScoreField Score Filter Validation Tests', () {
    late int? capturedScore;
    late VoidCallback onScoreChanged;

    setUp(() {
      capturedScore = null;
      onScoreChanged = () {
        // This will be called when a valid score is entered
      };
    });

    Widget createTestWidget({
      String scoreFilter = '',
      int? initialScore,
      bool enabled = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RoundScoreField(
            score: initialScore,
            onChanged: (score) {
              capturedScore = score;
            },
            enabled: enabled,
            scoreFilter: scoreFilter,
          ),
        ),
      );
    }

    group('Score Filter: Any Score (Empty String)', () {
      testWidgets('should accept any valid number', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(scoreFilter: ''));

        // Enter various numbers
        await tester.enterText(find.byType(TextFormField), '7');
        await tester.pump();

        // Should accept any number when no filter is set
        expect(find.text('7'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);

        // No error should be shown
        expect(find.text('Score must end in 5 or 0'), findsNothing);
      });

      testWidgets('should accept numbers ending in 0 or 5', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(scoreFilter: ''));

        // Enter numbers ending in 0 or 5
        await tester.enterText(find.byType(TextFormField), '10');
        await tester.pump();
        expect(find.text('10'), findsOneWidget);
        expect(find.text('Must end in 5 or 0'), findsNothing);

        await tester.enterText(find.byType(TextFormField), '15');
        await tester.pump();
        expect(find.text('15'), findsOneWidget);
        expect(find.text('Must end in 5 or 0'), findsNothing);
      });
    });

    group('Score Filter: Numbers Ending in 0 or 5', () {
      testWidgets('should accept valid scores ending in 0 or 5', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(scoreFilter: r'^[0-9]*[05]$'));

        // Test single digits ending in 0 or 5
        await tester.enterText(find.byType(TextFormField), '0');
        await tester.pump();
        expect(find.text('0'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        await tester.enterText(find.byType(TextFormField), '5');
        await tester.pump();
        expect(find.text('5'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        // Test double digits ending in 0 or 5
        await tester.enterText(find.byType(TextFormField), '10');
        await tester.pump();
        expect(find.text('10'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        await tester.enterText(find.byType(TextFormField), '15');
        await tester.pump();
        expect(find.text('15'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        await tester.enterText(find.byType(TextFormField), '20');
        await tester.pump();
        expect(find.text('20'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        await tester.enterText(find.byType(TextFormField), '25');
        await tester.pump();
        expect(find.text('25'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        // Test larger numbers ending in 0 or 5
        await tester.enterText(find.byType(TextFormField), '100');
        await tester.pump();
        expect(find.text('100'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        await tester.enterText(find.byType(TextFormField), '105');
        await tester.pump();
        expect(find.text('105'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsNothing);
      });

      testWidgets('should reject invalid scores not ending in 0 or 5', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(scoreFilter: r'^[0-9]*[05]$'));

        // Test single digits not ending in 0 or 5
        await tester.enterText(find.byType(TextFormField), '1');
        await tester.pump();
        expect(find.text('1'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '2');
        await tester.pump();
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '3');
        await tester.pump();
        expect(find.text('3'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '4');
        await tester.pump();
        expect(find.text('4'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '6');
        await tester.pump();
        expect(find.text('6'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '7');
        await tester.pump();
        expect(find.text('7'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '8');
        await tester.pump();
        expect(find.text('8'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '9');
        await tester.pump();
        expect(find.text('9'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        // Test double digits not ending in 0 or 5
        await tester.enterText(find.byType(TextFormField), '11');
        await tester.pump();
        expect(find.text('11'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '12');
        await tester.pump();
        expect(find.text('12'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '13');
        await tester.pump();
        expect(find.text('13'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '14');
        await tester.pump();
        expect(find.text('14'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '16');
        await tester.pump();
        expect(find.text('16'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '17');
        await tester.pump();
        expect(find.text('17'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '18');
        await tester.pump();
        expect(find.text('18'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '19');
        await tester.pump();
        expect(find.text('19'), findsOneWidget);
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);
      });

      testWidgets(
        'should clear error when entering valid score after invalid',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(scoreFilter: r'^[0-9]*[05]$'),
          );

          // Enter invalid score
          await tester.enterText(find.byType(TextFormField), '7');
          await tester.pump();
          expect(find.text('Score must end in 5 or 0'), findsOneWidget);

          // Enter valid score
          await tester.enterText(find.byType(TextFormField), '10');
          await tester.pump();
          expect(find.text('10'), findsOneWidget);
          expect(find.text('Score must end in 5 or 0'), findsNothing);
        },
      );

      testWidgets('should clear error when clearing field', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(scoreFilter: r'^[0-9]*[05]$'));

        // Enter invalid score
        await tester.enterText(find.byType(TextFormField), '7');
        await tester.pump();
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        // Clear field
        await tester.enterText(find.byType(TextFormField), '');
        await tester.pump();
        expect(find.text('Score must end in 5 or 0'), findsNothing);
      });
    });

    group('Field Behavior Tests', () {
      testWidgets('should maintain focus when trying to submit invalid score', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(scoreFilter: r'^[0-9]*[05]$'));

        // Enter invalid score
        await tester.enterText(find.byType(TextFormField), '7');
        await tester.pump();
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);

        // Try to submit (press Enter)
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Field should still have focus and show error
        expect(find.text('Score must end in 5 or 0'), findsOneWidget);
        // Note: Focus testing is limited in widget tests, but error should persist
      });

      testWidgets('should allow submission when score is valid', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(scoreFilter: r'^[0-9]*[05]$'));

        // Enter valid score
        await tester.enterText(find.byType(TextFormField), '15');
        await tester.pump();
        expect(find.text('Score must end in 5 or 0'), findsNothing);

        // Submit (press Enter)
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // No error should be shown
        expect(find.text('Score must end in 5 or 0'), findsNothing);
      });
    });
  });
}
