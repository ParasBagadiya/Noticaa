import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationService {
  
  // Loading Animation
  static Widget loadingAnimation({double size = 100}) {
    return Lottie.network(
      "https://lottie.host/c82f31a3-ada8-43d4-9c01-9fc0cb5ec7c5/nUOjfQPYQe.json",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  // Empty Notes Animation
  static Widget emptyNotesAnimation({double size = 200}) {
    return Lottie.network(
      "https://lottie.host/2d0661f0-66e0-44de-9e93-ba1132219563/kzoPSI07Fx.json",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  // Success Animation
  static Widget successAnimation({double size = 100}) {
    return Lottie.network(
      "https://lottie.host/5be7f663-5bd7-4424-9b5a-a59603a1130c/3Ai4VQnvRe.json",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  // Folder Empty Animation
  static Widget emptyFolderAnimation({double size = 150}) {
    return Lottie.network(
      "https://lottie.host/a2c46511-68dd-4014-9c55-524ce176f48e/ZJ6XZRP4JD.json",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  // Folder Empty Animation (when folder has no notes)
  static Widget emptyFolderAnimation1({double size = 150}) {
    return Lottie.network(
      "https://lottie.host/a2c46511-68dd-4014-9c55-524ce176f48e/ZJ6XZRP4JD.json",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  // Search Animation
  static Widget searchAnimation({double size = 150}) {
    return Lottie.network(
      "https://lottie.host/f013957d-63fe-4003-b7e5-a2d871169b03/93p8yJ9JnM.json",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  // Welcome Animation (for future onboarding)
  static Widget welcomeAnimation({double size = 250}) {
    return Lottie.network(
      "https://lottie.host/b88c34fd-2090-4bbf-9c8b-7a849c6e2df9/jdJvrDCYMY.lottie",
      // "https://lottie.host/8ea5b9b7-7d55-415a-a64a-1b5088d6f305/GegCkNCHSJ.lottie",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
