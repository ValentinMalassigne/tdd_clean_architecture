import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_controls.dart';
import '../widgets/trivia_display.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Number Trivia"),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            //top half

            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                if (state.numberTriviaStatus == NumberTriviaStatus.empty) {
                  return const MessageDisplay(
                    message: "Start searching !",
                  );
                } else if (state.numberTriviaStatus ==
                    NumberTriviaStatus.loaded) {
                  return TriviaDisplay(numberTrivia: state.trivia!);
                } else if (state.numberTriviaStatus ==
                    NumberTriviaStatus.loading) {
                  return const LoadingWidget();
                } else if (state.numberTriviaStatus ==
                    NumberTriviaStatus.error) {
                  return MessageDisplay(
                    message: state.errorMessage!,
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: const Placeholder(),
                );
              },
            ),

            const SizedBox(height: 20),
            //bottom half
            const TriviaControls(),
          ],
        ),
      ),
    );
  }
}
