import Foundation
import UIKit
import CoreImage

/// Lens distortion effect using CIBumpDistortion (iOS 15+) with fallback for older versions
public final class SelfRefractionLayer: CALayer {
    
    public var refractionIntensity: CGFloat = 0.5 {
        didSet {
            updateRefraction()
        }
    }
    
    public var refractionRadius: CGFloat = 50.0 {
        didSet {
            updateRefraction()
        }
    }
    
    private var context: CIContext?
    private var sourceImage: CIImage?
    
    public override init() {
        super.init()
        setup()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let refractionLayer = layer as? SelfRefractionLayer {
            self.refractionIntensity = refractionLayer.refractionIntensity
            self.refractionRadius = refractionLayer.refractionRadius
        }
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        guard LiquidGlassConfiguration.shared.shouldEnableRefraction else { return }
        
        if #available(iOS 15.0, *) {
            context = CIContext(options: [.useSoftwareRenderer: false])
        }
        
        needsDisplayOnBoundsChange = true
    }
    
    public override func display() {
        super.display()
        updateRefraction()
    }
    
    private func updateRefraction() {
        guard LiquidGlassConfiguration.shared.shouldEnableRefraction else {
            // Fallback: no refraction
            return
        }
        
        if #available(iOS 15.0, *) {
            applyBumpDistortion()
        } else {
            // Graceful degradation for iOS 13-14
            applyFallbackEffect()
        }
    }
    
    @available(iOS 15.0, *)
    private func applyBumpDistortion() {
        guard let context = context else { return }
        
        // Create a simple distortion effect using CIBumpDistortion
        if let filter = CIFilter(name: "CIBumpDistortion") {
            // Get the center point of the layer
            let center = CIVector(x: bounds.midX, y: bounds.midY)
            
            filter.setValue(center, forKey: kCIInputCenterKey)
            filter.setValue(refractionRadius, forKey: kCIInputRadiusKey)
            filter.setValue(refractionIntensity * 10.0, forKey: kCIInputScaleKey)
            
            // Note: In a real implementation, you would capture the layer's content
            // and apply the filter. This is a simplified version that demonstrates
            // the concept. The actual rendering would need to be integrated with
            // the view's rendering pipeline.
        }
    }
    
    private func applyFallbackEffect() {
        // For iOS 13-14, we can use a simple scale transform as a fallback
        // This provides a subtle effect without the full distortion
        
        let scale: CGFloat = 1.0 + (refractionIntensity * 0.05)
        let transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0)
        
        // Apply subtle transform
        if let sublayers = sublayers {
            for sublayer in sublayers {
                sublayer.transform = transform
            }
        }
    }
    
    /// Animates refraction effect with spring physics
    public func animateRefraction(to intensity: CGFloat, duration: TimeInterval = 0.3) {
        guard LiquidGlassConfiguration.shared.shouldEnableSpringAnimations else {
            refractionIntensity = intensity
            return
        }
        
        let animation = CASpringAnimation(keyPath: "refractionIntensity")
        animation.damping = 15.0
        animation.stiffness = 300.0
        animation.mass = 1.0
        animation.duration = duration
        animation.fromValue = refractionIntensity
        animation.toValue = intensity
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        add(animation, forKey: "refractionAnimation")
        refractionIntensity = intensity
    }
}

/// UIView wrapper for SelfRefractionLayer
public final class SelfRefractionView: UIView {
    
    private var refractionLayer: SelfRefractionLayer {
        return layer as! SelfRefractionLayer
    }
    
    public override class var layerClass: AnyClass {
        return SelfRefractionLayer.self
    }
    
    public var refractionIntensity: CGFloat {
        get { return refractionLayer.refractionIntensity }
        set { refractionLayer.refractionIntensity = newValue }
    }
    
    public var refractionRadius: CGFloat {
        get { return refractionLayer.refractionRadius }
        set { refractionLayer.refractionRadius = newValue }
    }
    
    public func animateRefraction(to intensity: CGFloat, duration: TimeInterval = 0.3) {
        refractionLayer.animateRefraction(to: intensity, duration: duration)
    }
}
