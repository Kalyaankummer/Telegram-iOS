import Foundation
import UIKit
import CoreImage

/// A CALayer subclass that implements lens distortion/magnification effect
/// Uses CIBumpDistortion filter for refraction on iOS 15+
/// Falls back to scale transform on iOS 13-14
public final class SelfRefractionLayer: CALayer {
    
    // MARK: - Properties
    
    /// Strength of the refraction effect (0.0 - 1.0)
    public var refractionStrength: CGFloat = 0.25 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The radius of the distortion effect
    public var distortionRadius: CGFloat = 50.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Whether refraction is currently enabled
    public var isRefractionEnabled: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var capturedImage: UIImage?
    private var ciContext: CIContext?
    private let refractionQueue = DispatchQueue(label: "com.telegram.liquidglass.refraction", qos: .userInteractive)
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        setupContext()
        commonInit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let refractionLayer = layer as? SelfRefractionLayer {
            self.refractionStrength = refractionLayer.refractionStrength
            self.distortionRadius = refractionLayer.distortionRadius
            self.isRefractionEnabled = refractionLayer.isRefractionEnabled
            self.capturedImage = refractionLayer.capturedImage
        }
        setupContext()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContext()
        commonInit()
    }
    
    private func setupContext() {
        if #available(iOS 15.0, *) {
            ciContext = CIContext(options: [
                .useSoftwareRenderer: false,
                .priorityRequestLow: false
            ])
        }
    }
    
    private func commonInit() {
        contentsScale = UIScreen.main.scale
        allowsEdgeAntialiasing = true
        isOpaque = false
        backgroundColor = UIColor.clear.cgColor
    }
    
    // MARK: - Content Capture
    
    /// Capture content from a view to apply refraction effect
    public func captureContent(from view: UIView?) {
        guard let view = view, isRefractionEnabled else {
            capturedImage = nil
            setNeedsDisplay()
            return
        }
        
        refractionQueue.async { [weak self] in
            let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
            let image = renderer.image { context in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            }
            
            DispatchQueue.main.async {
                self?.capturedImage = image
                self?.setNeedsDisplay()
            }
        }
    }
    
    /// Capture content from a specific rect in a view
    public func captureContent(from view: UIView?, rect: CGRect) {
        guard let view = view, isRefractionEnabled else {
            capturedImage = nil
            setNeedsDisplay()
            return
        }
        
        refractionQueue.async { [weak self] in
            let renderer = UIGraphicsImageRenderer(bounds: rect)
            let image = renderer.image { context in
                context.cgContext.translateBy(x: -rect.origin.x, y: -rect.origin.y)
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            }
            
            DispatchQueue.main.async {
                self?.capturedImage = image
                self?.setNeedsDisplay()
            }
        }
    }
    
    // MARK: - Drawing
    
    public override func draw(in ctx: CGContext) {
        guard isRefractionEnabled, let image = capturedImage else {
            super.draw(in: ctx)
            return
        }
        
        if #available(iOS 15.0, *) {
            drawWithCoreImage(in: ctx, image: image)
        } else {
            drawWithFallback(in: ctx, image: image)
        }
    }
    
    @available(iOS 15.0, *)
    private func drawWithCoreImage(in ctx: CGContext, image: UIImage) {
        guard let cgImage = image.cgImage,
              let ciContext = ciContext else {
            drawWithFallback(in: ctx, image: image)
            return
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Apply bump distortion for lens effect
        guard let bumpFilter = CIFilter(name: "CIBumpDistortion") else {
            drawWithFallback(in: ctx, image: image)
            return
        }
        
        let center = CIVector(x: bounds.midX * contentsScale, y: bounds.midY * contentsScale)
        
        bumpFilter.setValue(ciImage, forKey: kCIInputImageKey)
        bumpFilter.setValue(center, forKey: kCIInputCenterKey)
        bumpFilter.setValue(distortionRadius * contentsScale, forKey: kCIInputRadiusKey)
        bumpFilter.setValue(refractionStrength, forKey: kCIInputScaleKey)
        
        guard let outputImage = bumpFilter.outputImage else {
            drawWithFallback(in: ctx, image: image)
            return
        }
        
        // Render the distorted image
        if let finalCGImage = ciContext.createCGImage(outputImage, from: ciImage.extent) {
            ctx.saveGState()
            ctx.translateBy(x: 0, y: bounds.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.draw(finalCGImage, in: bounds)
            ctx.restoreGState()
        }
    }
    
    private func drawWithFallback(in ctx: CGContext, image: UIImage) {
        // Fallback: simple scale transform for magnification effect
        guard let cgImage = image.cgImage else { return }
        
        ctx.saveGState()
        
        // Apply subtle scale for magnification illusion
        let scale = 1.0 + (refractionStrength * 0.1)
        let scaledWidth = bounds.width * scale
        let scaledHeight = bounds.height * scale
        let offsetX = (bounds.width - scaledWidth) / 2
        let offsetY = (bounds.height - scaledHeight) / 2
        
        let scaledRect = CGRect(x: offsetX, y: offsetY, width: scaledWidth, height: scaledHeight)
        
        ctx.translateBy(x: 0, y: bounds.height)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(cgImage, in: scaledRect)
        
        ctx.restoreGState()
    }
    
    // MARK: - Animation Support
    
    public override class func needsDisplay(forKey key: String) -> Bool {
        if key == "refractionStrength" || key == "distortionRadius" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    /// Animate the refraction strength
    public func animateRefractionStrength(to value: CGFloat, duration: TimeInterval = 0.3) {
        let animation = CABasicAnimation(keyPath: "refractionStrength")
        animation.fromValue = refractionStrength
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        refractionStrength = value
        add(animation, forKey: "refractionStrengthAnimation")
    }
    
    // MARK: - Performance
    
    /// Temporarily disable refraction for performance during scrolling
    public func setPerformanceMode(_ enabled: Bool) {
        if enabled {
            isRefractionEnabled = false
            contents = nil
        } else {
            isRefractionEnabled = LiquidGlassConfiguration.shared.enableRefraction
        }
    }
    
    /// Clear cached content to free memory
    public func clearCache() {
        capturedImage = nil
        contents = nil
    }
}
