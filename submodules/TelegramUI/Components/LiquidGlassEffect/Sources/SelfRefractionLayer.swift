import Foundation
import UIKit
import CoreImage

public final class SelfRefractionLayer: CALayer {
    private var refractionIntensity: CGFloat = 0.5
    private let useFallback: Bool
    
    public override init() {
        self.useFallback = !LiquidGlassConfiguration.shared.supportsSelfRefraction
        super.init()
        setupRefraction()
    }
    
    public override init(layer: Any) {
        self.useFallback = !LiquidGlassConfiguration.shared.supportsSelfRefraction
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        self.useFallback = !LiquidGlassConfiguration.shared.supportsSelfRefraction
        super.init(coder: coder)
        setupRefraction()
    }
    
    private func setupRefraction() {
        if useFallback {
            // Fallback: use subtle scale transform for older iOS versions
            return
        }
        
        guard LiquidGlassConfiguration.shared.supportsCoreImageFilters else { return }
        
        // Use CIBumpDistortion for lens effect on iOS 15+
        if let classValue = NSClassFromString("CAFilter") as AnyObject as? NSObjectProtocol {
            let makeSelector = NSSelectorFromString("filterWithType:")
            if classValue.responds(to: makeSelector) {
                // Create bump distortion filter
                if let filter = classValue.perform(makeSelector, with: "bumpDistortion")?.takeUnretainedValue() as? NSObject {
                    filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputCenter")
                    filter.setValue(50.0, forKey: "inputRadius")
                    filter.setValue(refractionIntensity, forKey: "inputScale")
                    self.filters = [filter]
                }
            }
        }
    }
    
    public func setRefractionIntensity(_ intensity: CGFloat, animated: Bool) {
        self.refractionIntensity = intensity
        
        if useFallback {
            // Fallback: apply subtle scale
            let scale = 1.0 + (intensity * 0.05)
            if animated {
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.fromValue = self.value(forKeyPath: "transform.scale")
                animation.toValue = scale
                animation.duration = 0.3
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.add(animation, forKey: "scaleAnimation")
            }
            self.transform = CATransform3DMakeScale(scale, scale, 1.0)
        } else {
            // Update filter intensity
            if let filters = self.filters as? [NSObject], let filter = filters.first {
                if animated {
                    let animation = CABasicAnimation(keyPath: "filters.bumpDistortion.inputScale")
                    animation.fromValue = filter.value(forKey: "inputScale")
                    animation.toValue = intensity
                    animation.duration = 0.3
                    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    self.add(animation, forKey: "refractionAnimation")
                }
                filter.setValue(intensity, forKey: "inputScale")
            }
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        // Update filter center to match layer center
        if !useFallback, let filters = self.filters as? [NSObject], let filter = filters.first {
            filter.setValue(CIVector(x: bounds.width / 2, y: bounds.height / 2), forKey: "inputCenter")
        }
    }
}
