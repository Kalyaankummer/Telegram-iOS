# LiquidGlassEffect Module

A comprehensive iOS 13-18+ compatible module for creating stunning liquid glass visual effects in Telegram iOS.

## Overview

The LiquidGlassEffect module provides advanced visual effects including:
- **Self-refraction** - Lens distortion using CIBumpDistortion (iOS 15+) with fallback
- **Chromatic borders** - Animated rainbow prismatic gradients
- **Spring animations** - Physics-based animations with customizable damping and stiffness
- **Glass blur** - Adjustable blur radius using UIVisualEffectView with CAFilter

## Components

### Core Components

#### LiquidGlassConfiguration
Central configuration and feature detection system.

```swift
let config = LiquidGlassConfiguration.shared
print(config.iosVersion) // Current iOS version
print(config.supportsSelfRefraction) // true on iOS 15+
```

**Properties:**
- `iosVersion: Int` - Detected iOS major version
- `supportsSelfRefraction: Bool` - Whether device supports advanced refraction
- `springDamping: CGFloat` - Default 0.7
- `springStiffness: CGFloat` - Default 300.0
- `tapScaleDown: CGFloat` - Default 0.92
- `tapScaleBounce: CGFloat` - Default 1.02

#### GlassBlurView
Custom blur view with adjustable radius.

```swift
let blurView = GlassBlurView(blurRadius: 20.0, isDark: false)
blurView.setBlurRadius(30.0, animated: true)
```

#### SelfRefractionLayer
Lens distortion layer for self-refraction effects.

```swift
let refractionLayer = SelfRefractionLayer()
layer.addSublayer(refractionLayer)
refractionLayer.setRefractionIntensity(0.5, animated: true)
```

**Features:**
- Uses CIBumpDistortion on iOS 15+
- Falls back to scale transform on iOS 13-14
- Adjustable intensity (0.0 - 1.0)

#### ChromaticBorderView
Animated rainbow gradient border.

```swift
let border = ChromaticBorderView()
border.borderWidth = 2.0
border.cornerRadius = 16.0
border.setAnimated(true) // Enable gradient animation
```

**Colors:** Cyan → Blue → Purple → Magenta → Pink-Magenta → Cyan

#### GlassSpringAnimator
Spring physics animation utilities.

```swift
// Tap scale animation
GlassSpringAnimator.animateTapScale(view: button) {
    print("Animation complete")
}

// Custom spring animation
GlassSpringAnimator.animateSpring(
    duration: 0.5,
    dampingRatio: 0.7,
    animations: {
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
)

// Pulse animation
GlassSpringAnimator.animatePulse(view: icon, scale: 1.1, duration: 0.6)

// Stretch animation (for lens effects)
GlassSpringAnimator.animateStretch(
    view: lens,
    scaleX: 1.15,
    scaleY: 0.9,
    duration: 0.4
)
```

#### LiquidGlassView
Main container combining all effects.

```swift
let glassView = LiquidGlassView(blurRadius: 20.0)
glassView.cornerRadius = 16.0
glassView.isDark = false
glassView.showsChromaticBorder = true
glassView.refractionIntensity = 0.5

// Add content
glassView.contentView.addSubview(myContentView)

// Animate
glassView.animateTap()
glassView.animatePulse()
```

### UI Components

#### LiquidGlassButton
Pre-built glass button with tap animations.

```swift
let button = LiquidGlassButton(style: .circular)
button.icon = UIImage(systemName: "star")
button.title = "Favorite"
button.isDark = false
button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
```

**Styles:**
- `.circular` - Round button (automatically sized)
- `.rounded` - Rounded rectangle (cornerRadius: 16.0)
- `.pill` - Pill-shaped (cornerRadius: height/2)

#### LiquidGlassSwitchThumb
Glass thumb for UISwitch replacement.

```swift
let thumb = LiquidGlassSwitchThumb()
thumb.isDark = false
thumb.setOn(true, animated: true)
thumb.animateTransition() // Pulse animation on state change
```

#### LiquidGlassSliderKnob
Vertical pill-shaped slider knob.

```swift
let knob = LiquidGlassSliderKnob()
knob.isDark = false
knob.isTracking = true // Scales up during drag
knob.animateValueChange() // Wobble animation
```

#### LiquidGlassTabLens
Tab bar selection lens with stretch animation.

```swift
let lens = LiquidGlassTabLens()
lens.isDark = false
lens.setSelected(true, animated: true) // Stretch + bounce animation
lens.animateToPosition(CGPoint(x: 100, y: 0), animated: true)
```

## Integration with Existing Components

### TabBarComponent
```swift
// In TabBarComponent initialization
liquidLensView.enableSelfRefraction = true
liquidLensView.enableChromaticBorder = true
```

### SwitchComponent
```swift
SwitchComponent(
    tintColor: .blue,
    value: true,
    useGlassThumb: true, // Enable glass thumb
    valueUpdated: { isOn in
        print("Switch changed: \(isOn)")
    }
)
```

### SliderComponent
```swift
SliderComponent(
    content: .continuous(.init(
        value: 0.5,
        valueUpdated: { value in
            print("Slider: \(value)")
        }
    )),
    useGlassKnob: true, // Enable glass knob
    trackBackgroundColor: .gray,
    trackForegroundColor: .blue
)
```

## iOS Version Compatibility

| Feature | iOS 13 | iOS 14 | iOS 15+ |
|---------|--------|--------|---------|
| Glass Blur | ✅ | ✅ | ✅ |
| Chromatic Border | ✅ | ✅ | ✅ |
| Spring Animations | ✅ | ✅ | ✅ |
| Self-Refraction (full) | ❌ | ❌ | ✅ |
| Self-Refraction (fallback) | ✅ | ✅ | N/A |

**Fallback behavior:**
- iOS 13-14: Self-refraction uses subtle scale transform
- iOS 15+: Full CIBumpDistortion lens effect

## Technical Details

### Private APIs Used
- **CAFilter** - For custom blur radius adjustment
- **CIBumpDistortion** - For lens distortion effect (iOS 15+)

These are allowed per Telegram iOS codebase conventions.

### Performance
- All animations use UIViewPropertyAnimator for optimal performance
- Display link used only when necessary (lifted tab lens)
- Layer-backed rendering for complex effects

### Threading
All UI operations must be called on the main thread.

## Build Integration

Add dependency to your BUILD file:

```python
deps = [
    "//submodules/TelegramUI/Components/LiquidGlassEffect",
]
```

Import in Swift:

```swift
import LiquidGlassEffect
```

## Examples

### Custom Glass Card
```swift
let card = LiquidGlassView(blurRadius: 25.0)
card.cornerRadius = 20.0
card.showsChromaticBorder = true
card.refractionIntensity = 0.6

let label = UILabel()
label.text = "Glass Card"
label.font = .systemFont(ofSize: 18, weight: .medium)
card.contentView.addSubview(label)

// Animate on tap
let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
card.addGestureRecognizer(tapGesture)

@objc func cardTapped() {
    card.animateTap {
        // Handle tap completion
    }
}
```

### Custom Animated Border
```swift
let borderView = ChromaticBorderView()
borderView.borderWidth = 2.0
borderView.cornerRadius = 12.0
view.addSubview(borderView)

// Start animation
borderView.setAnimated(true)
```

## Troubleshooting

**Q: Refraction effect not visible on iOS 14?**  
A: This is expected. iOS 14 uses a fallback scale effect. Full refraction requires iOS 15+.

**Q: Build error about missing Display module?**  
A: Ensure your BUILD file includes all required dependencies as shown above.

**Q: Border animation not smooth?**  
A: Check that `setAnimated(true)` is called after the view is added to the view hierarchy.

## Future Enhancements

Possible future additions:
- Frosted glass intensity control
- Additional border styles (gradient patterns)
- Interaction response effects (hover, long press)
- Haptic feedback integration
- Metal-accelerated effects for better performance

## License

Part of Telegram iOS codebase.
