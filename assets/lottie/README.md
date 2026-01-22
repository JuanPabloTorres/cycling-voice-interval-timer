# Lottie Animations

This folder contains Lottie animation files (.json) for the RidePulse app.

## Suggested Animations

You can download free Lottie animations from:
- [LottieFiles](https://lottiefiles.com/)
- [Iconscout](https://iconscout.com/lottie-animations)

### Recommended animations for this app:
- **success.json** - Checkmark or success animation (for plan completion)
- **delete.json** - Delete or trash animation (for delete confirmation)
- **loading.json** - Loading spinner (for async operations)
- **cycling.json** - Bicycle or cycling animation (for timer running)

## Usage Example

```dart
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/lottie/success.json',
  width: 200,
  height: 200,
  repeat: false,
)
```

## File Requirements
- Format: JSON
- Recommended size: < 100KB per file
- Optimize animations at [LottieFiles Tools](https://lottiefiles.com/tools)
