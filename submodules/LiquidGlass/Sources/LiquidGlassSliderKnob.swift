import Foundation
import UIKit

/// Vertical pill-shaped slider knob with drag animations
public final class LiquidGlassSliderKnob: UIControl {
    
    // MARK: - Subviews
    
    private let trackView: UIView
    private let knobGlassView: LiquidGlassView
    private let fillView: UIView
    
    // MARK: - State
    
    public var value: CGFloat = 0.5 {
        didSet {
            value = min(max(value, 0.0), 1.0)
            if oldValue != value {
                updateKnobPosition(animated: true)
                sendActions(for: .valueChanged)
            }
        }
    }
    
    // MARK: - Configuration
    
    public var trackColor: UIColor = UIColor.systemGray5 {
        didSet {
            trackView.backgroundColor = trackColor
        }
    }
    
    public var fillColor: UIColor = UIColor.systemBlue {
        didSet {
            fillView.backgroundColor = fillColor
        }
    }
    
    public var knobWidth: CGFloat = 36.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    public var knobHeight: CGFloat = 52.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let trackWidth: CGFloat = 4.0
    public var sliderHeight: CGFloat = 200.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    // MARK: - Initialization
    
    public init() {
        self.trackView = UIView()
        self.fillView = UIView()
        self.knobGlassView = LiquidGlassView(style: .light)
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Track background (vertical pill)
        trackView.layer.cornerRadius = trackWidth / 2.0
        trackView.backgroundColor = trackColor
        addSubview(trackView)
        
        // Fill view (shows current value)
        fillView.layer.cornerRadius = trackWidth / 2.0
        fillView.backgroundColor = fillColor
        trackView.addSubview(fillView)
        
        // Glass knob (pill-shaped)
        knobGlassView.cornerRadius = knobWidth / 2.0
        knobGlassView.showChromaticBorder = true
        knobGlassView.blurIntensity = .strong
        knobGlassView.refractionIntensity = 0.6
        addSubview(knobGlassView)
        
        // Add shadow to knob for depth
        knobGlassView.layer.shadowColor = UIColor.black.cgColor
        knobGlassView.layer.shadowOffset = CGSize(width: 0, height: 2)
        knobGlassView.layer.shadowRadius = 6
        knobGlassView.layer.shadowOpacity = 0.25
        
        // Setup gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        // Initial state
        updateKnobPosition(animated: false)
    }
    
    private func updateKnobPosition(animated: Bool) {
        let trackRange = sliderHeight - knobHeight
        let knobY = (1.0 - value) * trackRange // Inverted: 0 at bottom, 1 at top
        
        let updateBlock = {
            self.knobGlassView.frame.origin.y = knobY
            self.updateFillHeight()
        }
        
        if animated && LiquidGlassConfiguration.shared.shouldEnableSpringAnimations {
            GlassSpringAnimator.springAnimate(
                duration: 0.4,
                damping: 0.75,
                velocity: 0.3,
                animations: updateBlock
            )
        } else {
            updateBlock()
        }
    }
    
    private func updateFillHeight() {
        // Fill from bottom to knob position
        let knobCenterY = knobGlassView.frame.midY
        let fillHeight = sliderHeight - knobCenterY
        
        fillView.frame = CGRect(
            x: 0,
            y: knobCenterY,
            width: trackWidth,
            height: max(0, fillHeight)
        )
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        // Calculate value from tap position
        let trackRange = sliderHeight - knobHeight
        let tappedY = location.y - knobHeight / 2.0
        let newValue = 1.0 - (tappedY / trackRange) // Inverted
        
        value = min(max(newValue, 0.0), 1.0)
        
        // Bounce effect
        knobGlassView.animateBounce(intensity: 1.08)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let knobFrame = knobGlassView.frame
        
        switch gesture.state {
        case .began:
            knobGlassView.pauseChromaticAnimation()
            
            // Scale up slightly when dragging starts
            GlassSpringAnimator.animate(
                view: knobGlassView,
                keyPath: "transform.scale",
                from: 1.0,
                to: 1.05,
                parameters: .snappy
            )
            
        case .changed:
            let minY: CGFloat = 0.0
            let maxY = sliderHeight - knobHeight
            let newY = min(max(knobFrame.origin.y + translation.y, minY), maxY)
            
            knobGlassView.frame.origin.y = newY
            updateFillHeight()
            
            // Update value based on position (inverted)
            let trackRange = sliderHeight - knobHeight
            value = 1.0 - (newY / trackRange)
            
            gesture.setTranslation(.zero, in: self)
            
            // Stretch effect while dragging
            let velocity = gesture.velocity(in: self).y
            let stretchFactor = min(abs(velocity) / 1000.0, 0.1)
            
            GlassSpringAnimator.animateStretch(
                view: knobGlassView,
                from: 1.0,
                to: 1.0 + stretchFactor,
                axis: .vertical,
                parameters: .snappy
            )
            
        case .ended, .cancelled:
            knobGlassView.resumeChromaticAnimation()
            
            // Scale back to normal
            GlassSpringAnimator.animate(
                view: knobGlassView,
                keyPath: "transform.scale",
                from: 1.05,
                to: 1.0,
                parameters: .bouncy
            )
            
            // Snap to position with spring
            updateKnobPosition(animated: true)
            
        default:
            break
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: knobWidth, height: sliderHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Track layout (centered vertically)
        let trackX = (bounds.width - trackWidth) / 2.0
        trackView.frame = CGRect(x: trackX, y: 0, width: trackWidth, height: sliderHeight)
        
        // Knob layout (position will be updated by updateKnobPosition)
        knobGlassView.frame.size = CGSize(width: knobWidth, height: knobHeight)
        knobGlassView.frame.origin.x = (bounds.width - knobWidth) / 2.0
        
        updateKnobPosition(animated: false)
    }
    
    // MARK: - Public API
    
    public func setValue(_ newValue: CGFloat, animated: Bool) {
        let clampedValue = min(max(newValue, 0.0), 1.0)
        guard value != clampedValue else { return }
        
        value = clampedValue
        updateKnobPosition(animated: animated)
    }
    
    public override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isEnabled ? 1.0 : 0.5
            }
            isUserInteractionEnabled = isEnabled
        }
    }
}
