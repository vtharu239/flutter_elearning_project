import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/circular_container.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgeWidget(
      child: Container(
        color: Color(0xFF00A2FF),

        /// -- [size.isFinite': is not true in Stack] error occurred -> Read README.md file at [DESIGN ERRORS] # 1
        child: Stack(
          children: [
            /// -- Background Custom Shapes
            Positioned(
                top: -150,
                right: -250,
                child: TCircularContainer(
                    backgroundColor: TColors.textWhite.withValues(alpha: 0.1))),
            Positioned(
                top: 10,
                right: -300,
                child: TCircularContainer(
                    backgroundColor: TColors.textWhite.withValues(alpha: 0.1))),
            child,
          ],
        ),
      ),
    );
  }
}
