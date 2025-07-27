# Design System - Krishibodha Agentic AI

This document outlines the design system constants and components used throughout the app.

## Colors (`lib/constants/app_colors.dart`)

### Primary Colors

- **Primary Dark**: `#427662` - Main brand color
- **Primary Light**: `#A0BAB0` - Secondary brand color

### Background Colors

- **Background Primary**: `#FFFFFF` (White) - Main background
- **Background Secondary**: `#F2F3F2` - Secondary background for gradients

### Text Colors

- **Text Primary**: `#0D1814` - Main text color
- **Text Secondary**: `#427662` - Secondary text (same as primary dark)
- **Text On Primary**: `#FFFFFF` - Text on primary colored backgrounds

### Gradients

- **Primary Gradient**: Linear gradient from `#427662` to `#A0BAB0`
- **Secondary Gradient**: Linear gradient from `#FFFFFF` to `#F2F3F2`

## Typography (`lib/constants/app_text_styles.dart`)

All text styles use **DM Sans** font family via Google Fonts.

### Heading Styles

- `heading1`: 32px, Bold
- `heading2`: 24px, Bold
- `heading3`: 20px, Semi-bold

### Body Text Styles

- `bodyLarge`: 16px, Normal
- `bodyMedium`: 14px, Normal
- `bodySmall`: 12px, Normal

### Button Styles

- `buttonLarge`: 16px, Semi-bold
- `buttonMedium`: 14px, Semi-bold

### Special Styles

- `appBarTitle`: 20px, Semi-bold
- `counterLarge`: 48px, Bold
- `caption`: 12px, Normal

## Theme (`lib/constants/app_theme.dart`)

The app theme combines all colors and typography into a cohesive Material 3 theme.

## Custom Widgets (`lib/widgets/gradient_button.dart`)

### GradientButton

A custom button with primary gradient background.

```dart
GradientButton(
  text: 'Click Me',
  onPressed: () {},
  width: 200,
  height: 48,
)
```

### GradientFloatingActionButton

A custom floating action button with gradient background.

```dart
GradientFloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
)
```

## Usage

Import the constants in your files:

```dart
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'constants/app_theme.dart';
import 'widgets/gradient_button.dart';
```

Or import everything at once:

```dart
import 'constants/constants.dart';
```

## Design Principles

1. **Consistent Colors**: Use only defined colors from AppColors
2. **Typography Hierarchy**: Use predefined text styles
3. **White Background**: Primary background is always white
4. **Gradient Accents**: Use gradients for buttons and highlights
5. **Accessible Contrast**: Text colors provide good contrast
6. **Material 3**: Following Material Design 3 guidelines

## Examples

### Using Colors

```dart
Container(
  color: AppColors.backgroundPrimary,
  child: Text(
    'Hello',
    style: AppTextStyles.bodyLarge,
  ),
)
```

### Using Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
  child: // your content
)
```

### Using Custom Buttons

```dart
GradientButton(
  text: 'Save',
  onPressed: () => save(),
)
```
