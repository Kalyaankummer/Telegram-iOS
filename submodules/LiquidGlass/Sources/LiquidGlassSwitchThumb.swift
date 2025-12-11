import Foundation
import UIKit

/// Glass switch toggle with refraction and spring animations
public final class LiquidGlassSwitchThumb: UIControl {
    
    // MARK: - Subviews
    
    private let trackView: UIView
    private let thumbGlassView: LiquidGlassView
    private var thumbCenterXConstraint: NSLayoutConstraint?
    
    // MARK: - State
    
    public var isOn: Bool = false {
        didSet {
            if oldValue != isOn {
                updateThumbPosition(animated: true)
                sendActions(for: .valueChanged)
            }
        }
    }
    
    // MARK: - Configuration
    
    public var onTintColor: UIColor = UIColor.systemGreen {
        didSet {
            updateTrackAppearance()
        }
    }
    
    public var offTintColor: UIColor = UIColor.systemGray4 {
        didSet {
            updateTrackAppearance()
        }
    }
    
    public var thumbDiameter: CGFloat = 27.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    private let trackHeight: CGFloat = 31.0
    private let trackWidth: CGFloat = 51.0
    
    // MARK: - Initialization
    
    public init() {
        self.trackView = UIView()
        self.thumbGlassView = LiquidGlassView(style: .light)
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Track background
        trackView.layer.cornerRadius = trackHeight / 2.0
        trackView.backgroundColor = offTintColor
        addSubview(trackView)
        
        // Glass thumb
        thumbGlassView.cornerRadius = thumbDiameter / 2.0
        thumbGlassView.showChromaticBorder = true
        thumbGlassView.blurIntensity = .medium
        addSubview(thumbGlassView)
        
        // Add shadow to thumb for depth
        thumbGlassView.layer.shadowColor = UIColor.black.cgColor
        thumbGlassView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thumbGlassView.layer.shadowRadius = 4
        thumbGlassView.layer.shadowOpacity = 0.2
        
        // Setup gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        // Initial state
        updateTrackAppearance()
        updateThumbPosition(animated: false)
    }
    
    private func updateTrackAppearance() {
        let targetColor = isOn ? onTintColor : offTintColor
        
        UIView.animate(withDuration: 0.3) {
            self.trackView.backgroundColor = targetColor
        }
    }
    
    private func updateThumbPosition(animated: Bool) {
        let thumbX: CGFloat
        let inset: CGFloat = 2.0
        
        if isOn {
            thumbX = trackWidth - thumbDiameter - inset
        } else {
            thumbX = inset
        }
        
        let updateBlock = {
            self.thumbGlassView.frame.origin.x = thumbX
        }
        
        if animated && LiquidGlassConfiguration.shared.shouldEnableSpringAnimations {
            GlassSpringAnimator.springAnimate(
                duration: 0.5,
                damping: 0.7,
                velocity: 0.5,
                animations: updateBlock
            )
            
            // Animate refraction intensity
            thumbGlassView.refractionIntensity = isOn ? 0.7 : 0.5
            
            // Toggle animation
            GlassSpringAnimator.animateToggle(view: thumbGlassView, isOn: isOn)
        } else {
            updateBlock()
        }
        
        updateTrackAppearance()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        isOn.toggle()
        
        // Add bounce effect
        thumbGlassView.animateBounce(intensity: 1.1)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let thumbFrame = thumbGlassView.frame
        
        switch gesture.state {
        case .began:
            thumbGlassView.pauseChromaticAnimation()
            
        case .changed:
            let inset: CGFloat = 2.0
            let minX = inset
            let maxX = trackWidth - thumbDiameter - inset
            let newX = min(max(thumbFrame.origin.x + translation.x, minX), maxX)
            
            thumbGlassView.frame.origin.x = newX
            gesture.setTranslation(.zero, in: self)
            
        case .ended, .cancelled:
            thumbGlassView.resumeChromaticAnimation()
            
            // Determine final position based on current position
            let midPoint = trackWidth / 2.0
            let shouldBeOn = thumbFrame.midX > midPoint
            
            if shouldBeOn != isOn {
                isOn = shouldBeOn
            } else {
                updateThumbPosition(animated: true)
            }
            
        default:
            break
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: trackWidth, height: trackHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Track layout
        trackView.frame = CGRect(x: 0, y: 0, width: trackWidth, height: trackHeight)
        
        // Thumb layout (position will be updated by updateThumbPosition)
        let thumbY = (trackHeight - thumbDiameter) / 2.0
        thumbGlassView.frame.size = CGSize(width: thumbDiameter, height: thumbDiameter)
        thumbGlassView.frame.origin.y = thumbY
    }
    
    // MARK: - Public API
    
    public func setOn(_ on: Bool, animated: Bool) {
        guard isOn != on else { return }
        
        isOn = on
        updateThumbPosition(animated: animated)
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
