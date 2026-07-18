import 'package:flutter/material.dart';

extension DirectionalIconExtension on BuildContext {
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  IconData get backIcon => isRTL
      ? Icons.arrow_forward_rounded
      : Icons.arrow_back_rounded;

  IconData get backIconIos => isRTL
      ? Icons.arrow_forward_ios_rounded
      : Icons.arrow_back_ios_rounded;

  IconData get forwardIconIos => isRTL
      ? Icons.arrow_back_ios_rounded
      : Icons.arrow_forward_ios_rounded;

  IconData get chevronRight => isRTL
      ? Icons.chevron_left_rounded
      : Icons.chevron_right_rounded;

  IconData get chevronLeft => isRTL
      ? Icons.chevron_right_rounded
      : Icons.chevron_left_rounded;
}
