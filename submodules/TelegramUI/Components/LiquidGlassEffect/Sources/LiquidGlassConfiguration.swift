import Foundation
import UIKit

/// Configuration and feature detection for Liquid Glass effects
public final class LiquidGlassConfiguration {
    
    // MARK: - Singleton
    public static let shared = LiquidGlassConfiguration()
    
    private init() {}
    
    // MARK: - iOS Version Detection
    
    /// Minimum iOS version for basic glass effects
    public var isSupported: Bool {
        if #available(iOS 13.0, *) {
            return !isReduceTransparencyEnabled
        }
        return false
    }
    
    /// iOS 15+ supports advanced Core Image filters for refraction
    public var supportsAdvancedRefraction: Bool {
        if #available(iOS 15.0, *) {
            return isSupported
        }
        return false
    }
    
    /// iOS 17+ supports more advanced blur configurations
    public var supportsAdvancedBlur: Bool {
        if #available(iOS 17.0, *) {
            return isSupported
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
    
    // MARK: - Power Management
    
    /// Check if Low Power Mode is enabled
    public var isLowPowerModeEnabled: Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    // MARK: - Feature Flags
    
    /// Whether to use self-refraction effect
    public var enableRefraction: Bool {
        return supportsAdvancedRefraction && !isLowPowerModeEnabled
    }
    
    /// Whether to use chromatic border effect
    public var enableChromaticBorder: Bool {
        return isSupported && !isLowPowerModeEnabled
    }
    
    /// Whether to use spring animations
    public var enableSpringAnimations: Bool {
        return isSupported && !isReduceMotionEnabled
    }
    
    /// Whether to use full quality blur
    public var enableHighQualityBlur: Bool {
        return isSupported && !isLowPowerModeEnabled
    }
    
    // MARK: - Default Values
    
    /// Default blur radius for glass effects
    public var defaultBlurRadius: CGFloat {
        if isLowPowerModeEnabled {
            return 8.0
        }
        return 12.0
    }
    
    /// Default refraction strength
    public var defaultRefractionStrength: CGFloat {
        if !enableRefraction {
            return 0.0
        }
        return 0.25
    }
    
    /// Default spring damping
    public var defaultSpringDamping: CGFloat {
        return 0.7
    }
    
    /// Default spring stiffness
    public var defaultSpringStiffness: CGFloat {
        return 300.0
    }
    
    /// Default spring mass
    public var defaultSpringMass: CGFloat {
        return 1.0
    }
    
    // MARK: - Notification Observers
    
    private var observers: [NSObjectProtocol] = []
    
    /// Start observing system changes
    public func startObserving(onChange: @escaping () -> Void) {
        let lowPowerObserver = NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { _ in
            onChange()
        }
        observers.append(lowPowerObserver)
        
        let reduceTransparencyObserver = NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            onChange()
        }
        observers.append(reduceTransparencyObserver)
        
        let reduceMotionObserver = NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            onChange()
        }
        observers.append(reduceMotionObserver)
    }
    
    /// Stop observing system changes
    public func stopObserving() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
    }
}
