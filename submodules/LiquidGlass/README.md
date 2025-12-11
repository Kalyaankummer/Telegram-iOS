# LiquidGlass Component Library

A reusable component library implementing Apple's iOS 26 "Liquid Glass" design language for Telegram iOS.

## Overview

The LiquidGlass library provides a complete set of UI components with translucent, glassy aesthetics featuring blur effects, lens refraction, chromatic borders, and spring physics animations.

## Components

### Core Effect Layers

#### LiquidGlassConfiguration
- iOS version detection (iOS 13+, iOS 15+, iOS 26+)
- Accessibility support (Reduce Transparency, Reduce Motion)
- Power mode handling (Low Power Mode detection)
- Feature flags for conditional effect enablement

#### GlassBlurView
- Custom blur view with adjustable radius
- CAFilter manipulation for fine-tuned blur control
- Multiple intensity presets (light, medium, strong, extraStrong)
- Animated blur transitions

#### SelfRefractionLayer
- CIBumpDistortion lens distortion effect (iOS 15+)
- Graceful degradation for iOS 13-14
- Animated refraction with spring physics
- Configurable intensity and radius

#### ChromaticBorderView
- Animated rainbow/prismatic border effect
- Conic gradient with smooth color transitions
- Configurable animation speed
- Pause/resume/stop controls

#### GlassSpringAnimator
- Spring physics for bouncy, responsive interactions
- Preset configurations (gentle, bouncy, snappy, smooth)
- Animation types:
  - Tap: Subtle scale and alpha change
  - Bounce: Playful bounce effect
  - Stretch: Elastic stretch and snap back
  - Toggle: Smooth state transition
- Generic spring animation API

### UI Components

#### LiquidGlassView
Main glass container combining all effects:
- Background blur layer
- Self-refraction layer
- Chromatic border (optional)
- Specular highlights (optional)
- Content container
- Performance-aware effect management

**Usage:**
```swift
let glassView = LiquidGlassView(style: .light)
glassView.cornerRadius = 20.0
glassView.blurIntensity = .medium
glassView.refractionIntensity = 0.5
glassView.showChromaticBorder = true
glassView.showSpecularHighlights = true
```

#### LiquidGlassButton
Circular glass buttons for action controls:
- Multiple sizes (small: 44pt, medium: 56pt, large: 72pt)
- Icon and optional title label
- Touch interaction animations
- Configurable tint colors

**Usage:**
```swift
let button = LiquidGlassButton(icon: icon, title: "Record", style: .light)
button.buttonSize = .large
button.iconTintColor = .white
button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
```

#### LiquidGlassSwitchThumb
Glass switch toggle with spring animations:
- Smooth on/off transitions
- Tap and pan gesture support
- Configurable tint colors
- Spring physics animations

**Usage:**
```swift
let switchControl = LiquidGlassSwitchThumb()
switchControl.onTintColor = .systemBlue
switchControl.offTintColor = .systemGray4
switchControl.isOn = false
```

#### LiquidGlassSliderKnob
Vertical pill-shaped slider with drag interactions:
- Smooth vertical dragging
- Fill indicator from bottom to knob
- Stretch effect while dragging
- Spring physics snap-back

**Usage:**
```swift
let slider = LiquidGlassSliderKnob()
slider.sliderHeight = 200.0
slider.trackColor = .systemGray5
slider.fillColor = .systemBlue
slider.value = 0.5
```

#### LiquidGlassTabLens
Tab bar selection lens with stretch animation:
- Smooth transitions between tabs
- Elastic stretch effect
- Configurable tab frames
- Tap gesture support

**Usage:**
```swift
let tabLens = LiquidGlassTabLens(style: .light)
let frames = LiquidGlassTabLens.generateTabFrames(
    tabCount: 4,
    containerWidth: view.bounds.width,
    tabHeight: 44.0
)
tabLens.setTabFrames(frames)
tabLens.selectTab(at: 0, animated: false)
```

## Key Features

1. **Multi-layer glass effect**: Combines blur, refraction, chromatic borders, and specular highlights
2. **Spring physics animations**: Bouncy, responsive interactions with proper damping and stiffness
3. **Accessibility support**: Respects Reduce Transparency and Reduce Motion settings
4. **Performance optimization**: Disables effects during Low Power Mode and scroll operations
5. **iOS version compatibility**: Full effects on iOS 15+, graceful degradation on iOS 13-14

## Integration

### Bazel Build

Add as a dependency in your BUILD file:

```python
swift_library(
    name = "YourTarget",
    deps = [
        "//submodules/LiquidGlass:LiquidGlass",
    ],
)
```

### Import

```swift
import LiquidGlass
```

## Performance Considerations

- Effects automatically disable in Low Power Mode
- Refraction effects are iOS 15+ only
- Chromatic border animation can be paused during scroll
- Configuration checks are cached for performance

## Accessibility

The library automatically respects iOS accessibility settings:

- **Reduce Transparency**: Disables blur and refraction effects
- **Reduce Motion**: Disables animations and chromatic border
- **Low Power Mode**: Disables all effects

Check current configuration:
```swift
let config = LiquidGlassConfiguration.shared
if config.shouldEnableBlur {
    // Blur is enabled
}
```

## Examples

See `LiquidGlassExamples.swift` for complete usage examples of all components.

## Requirements

- iOS 13.0+
- Swift 5.0+
- UIKit

## License

Part of Telegram iOS project.
