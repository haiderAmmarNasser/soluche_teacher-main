import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Function onRefreshCallback;
  final double displacement;
  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.displacement,
    required this.onRefreshCallback,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: displacement,
      onRefresh: () async {
        onRefreshCallback();
      },
      child: child,
    );
  }
}
