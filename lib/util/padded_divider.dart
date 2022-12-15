import "package:flutter/material.dart";

class PaddedDivider extends StatelessWidget {
  const PaddedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(""),
        Divider(),
        Text(""),
      ],
    );
  }
}
