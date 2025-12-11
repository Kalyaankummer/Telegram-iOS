import Foundation
import UIKit

public final class LiquidGlassConfiguration {
    public static let shared = LiquidGlassConfiguration()
    
    private init() {}
    
    // iOS version detection
    public var iosVersion: Int {
        let systemVersion = (UIDevice.current.systemVersion as NSString)
        let majorVersion = systemVersion.components(separatedBy: ".").first ?? "13"
        return Int(majorVersion) ?? 13
    }
    
    // Feature flags based on iOS version
    public var supportsSelfRefraction: Bool {
        return iosVersion >= 15
    }
    
    public var supportsAdvancedBlur: Bool {
        return iosVersion >= 13
    }
    
    public var supportsCAFilters: Bool {
        return iosVersion >= 13
    }
    
    public var supportsCoreImageFilters: Bool {
        return iosVersion >= 13
    }
    
    // Spring animation constants
    public let springDamping: CGFloat = 0.7
    public let springStiffness: CGFloat = 300.0
    public let springMass: CGFloat = 1.0
    
    // Scale animation constants
    public let tapScaleDown: CGFloat = 0.92
    public let tapScaleBounce: CGFloat = 1.02
    
    // Blur constants
    public let defaultBlurRadius: CGFloat = 20.0
    public let maxBlurRadius: CGFloat = 40.0
    
    // Border constants
    public let defaultBorderWidth: CGFloat = 1.5
    public let chromaticBorderWidth: CGFloat = 2.0
}
