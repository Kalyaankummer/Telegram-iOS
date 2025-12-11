import Foundation
import UIKit

/// Glass switch thumb with refraction and chromatic border
public final class LiquidGlassSwitchThumb: UIView {
    
    private let glassView: LiquidGlassView
    private let animator: GlassSpringAnimator
    
    public var thumbSize: CGSize = CGSize(width: 27, height: 27) {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }
    
    public var isOn: Bool = false {
        didSet { updateOnState(animated: true) }
    }
    
    public var onColor: UIColor = UIColor.systemGreen
    public var offColor: UIColor = UIColor.systemGray4
    
    public init() {
        self.glassView = LiquidGlassView(configuration: .switchThumb)
        self.animator = GlassSpringAnimator(config: .bouncy)
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        addSubview(glassView)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
    }
    
    public override var intrinsicContentSize: CGSize { return thumbSize }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    private func updateOnState(animated: Bool) {
        if animated {
            animator.animateTapBounce(view: self, completion: nil)
        }
    }
    
    public func animateToPosition(_ position: CGPoint, completion: (() -> Void)? = nil) {
        animator.animateToggleWithBounce(view: self, to: position, completion: completion)
    }
    
    public func setContentSource(_ view: UIView?) { glassView.setContentSource(view) }
    public func setDarkMode(_ isDark: Bool) { glassView.setDarkMode(isDark) }
    public func updateRefraction() { glassView.updateRefraction() }
}

/// Complete glass switch control with track and thumb
public final class LiquidGlassSwitch: UIControl {
    
    private let trackView: UIView
    private let thumbView: LiquidGlassSwitchThumb
    private let animator: GlassSpringAnimator
    
    private let trackWidth: CGFloat = 51
    private let trackHeight: CGFloat = 31
    private let thumbDiameter: CGFloat = 27
    private let thumbPadding: CGFloat = 2
    
    public var isOn: Bool = false {
        didSet { if oldValue != isOn { updateThumbPosition(animated: true) } }
    }
    
    public var onTintColor: UIColor = UIColor.systemGreen {
        didSet { updateTrackColor() }
    }
    
    public var offTintColor: UIColor = UIColor.systemGray4 {
        didSet { updateTrackColor() }
    }
    
    public override init(frame: CGRect) {
        self.trackView = UIView()
        self.thumbView = LiquidGlassSwitchThumb()
        self.animator = GlassSpringAnimator(config: .bouncy)
        super.init(frame: frame)
        setupViews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        trackView.backgroundColor = offTintColor
        trackView.layer.cornerRadius = trackHeight / 2
        addSubview(trackView)
        
        thumbView.thumbSize = CGSize(width: thumbDiameter, height: thumbDiameter)
        addSubview(thumbView)
        
        updateThumbPosition(animated: false)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: trackWidth, height: trackHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        trackView.frame = bounds
        updateThumbPosition(animated: false)
    }
    
    private func updateThumbPosition(animated: Bool) {
        let offX = thumbPadding + thumbDiameter / 2
        let onX = bounds.width - thumbPadding - thumbDiameter / 2
        let targetX = isOn ? onX : offX
        let targetCenter = CGPoint(x: targetX, y: bounds.height / 2)
        
        if animated {
            thumbView.animateToPosition(targetCenter) { [weak self] in
                self?.sendActions(for: .valueChanged)
            }
            UIView.animate(withDuration: 0.25) { self.updateTrackColor() }
        } else {
            thumbView.center = targetCenter
            thumbView.bounds = CGRect(origin: .zero, size: CGSize(width: thumbDiameter, height: thumbDiameter))
            updateTrackColor()
        }
    }
    
    private func updateTrackColor() {
        trackView.backgroundColor = isOn ? onTintColor : offTintColor
    }
    
    @objc private func handleTap() {
        isOn.toggle()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .changed:
            let progress = (location.x - thumbPadding) / (bounds.width - thumbPadding * 2 - thumbDiameter)
            let clampedProgress = max(0, min(1, progress))
            let thumbX = thumbPadding + thumbDiameter / 2 + clampedProgress * (bounds.width - thumbPadding * 2 - thumbDiameter)
            thumbView.center = CGPoint(x: thumbX, y: bounds.height / 2)
        case .ended, .cancelled:
            let midPoint = bounds.width / 2
            isOn = thumbView.center.x > midPoint
        default: break
        }
    }
    
    public func setContentSource(_ view: UIView?) { thumbView.setContentSource(view) }
    public func setDarkMode(_ isDark: Bool) { thumbView.setDarkMode(isDark) }
}
