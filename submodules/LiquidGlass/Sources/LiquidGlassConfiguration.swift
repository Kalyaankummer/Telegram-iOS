import Foundation
import UIKit

/// Configuration and feature detection for Liquid Glass effects
public final class LiquidGlassConfiguration {
    
    /// Singleton instance
    public static let shared = LiquidGlassConfiguration()
    
    private init() {}
    
    // MARK: - iOS Version Detection
    
    /// Returns true if running on iOS 15 or later (supports CIBumpDistortion)
    public var supportsFullEffects: Bool {
        if #available(iOS 15.0, *) {
            return true
        }
        return false
    }
    
    /// Returns true if running on iOS 26 or later (supports native liquid lens)
    public var supportsNativeLiquidLens: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
    
    /// Returns true if running on iOS 13 or later (minimum supported version)
    public var isSupported: Bool {
        if #available(iOS 13.0, *) {
            return true
        }
        return false
    }
    
    // MARK: - Accessibility
    
    /// Check if Reduce Transparency is enabled
    public var isReduceTransparencyEnabled: Bool {
        return UIAccessibility.isReduceTransparencyEnabled
    }
    
    /// Check if Reduce Motion is enabled
    public var isReduceMotionEnabled: Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    /// Check if accessibility features require simplified effects
    public var shouldSimplifyEffects: Bool {
        return isReduceTransparencyEnabled || isReduceMotionEnabled
    }
    
    // MARK: - Power Mode
    
    /// Check if Low Power Mode is enabled
    public var isLowPowerModeEnabled: Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    /// Check if effects should be disabled due to power constraints
    public var shouldDisableEffects: Bool {
        return isLowPowerModeEnabled
    }
    
    // MARK: - Feature Flags
    
    /// Enable blur effects (respects accessibility and power settings)
    public var shouldEnableBlur: Bool {
        return !shouldDisableEffects && !isReduceTransparencyEnabled
    }
    
    /// Enable refraction effects (respects accessibility and power settings)
    public var shouldEnableRefraction: Bool {
        return supportsFullEffects && !shouldDisableEffects && !isReduceTransparencyEnabled
    }
    
    /// Enable chromatic border effects (respects accessibility and power settings)
    public var shouldEnableChromaticBorder: Bool {
        return !shouldDisableEffects && !isReduceMotionEnabled
    }
    
    /// Enable spring animations (respects accessibility settings)
    public var shouldEnableSpringAnimations: Bool {
        return !isReduceMotionEnabled
    }
    
    /// Enable specular highlights
    public var shouldEnableSpecularHighlights: Bool {
        return !shouldDisableEffects
    }
    
    // MARK: - Performance
    
    /// Temporarily disable effects during scroll or other performance-critical operations
    private var isScrolling = false
    
    public func setScrolling(_ scrolling: Bool) {
        isScrolling = scrolling
    }
    
    public var shouldDisableEffectsDuringScroll: Bool {
        return isScrolling
    }
}
