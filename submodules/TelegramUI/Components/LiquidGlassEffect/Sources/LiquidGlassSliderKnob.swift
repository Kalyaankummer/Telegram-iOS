import Foundation
import UIKit

/// Vertical pill-shaped glass slider knob
public final class LiquidGlassSliderKnob: UIView {
    
    private let glassView: LiquidGlassView
    private let animator: GlassSpringAnimator
    
    public var knobSize: CGSize = CGSize(width: 22, height: 28) {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }
    
    private var isDragging: Bool = false
    
    public init() {
        self.glassView = LiquidGlassView(configuration: .sliderKnob)
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
        layer.shadowOpacity = 0.15
    }
    
    public override var intrinsicContentSize: CGSize { return knobSize }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
    public func beginDragging() {
        isDragging = true
        animator.animateDragStart(view: self, scale: 1.15)
    }
    
    public func endDragging() {
        isDragging = false
        animator.animateDragEnd(view: self)
    }
    
    public func setContentSource(_ view: UIView?) { glassView.setContentSource(view) }
    public func setDarkMode(_ isDark: Bool) { glassView.setDarkMode(isDark) }
    public func updateRefraction() { glassView.updateRefraction() }
}

/// Complete glass slider control with track and knob
public final class LiquidGlassSlider: UIControl {
    
    private let trackView: UIView
    private let filledTrackView: UIView
    private let knobView: LiquidGlassSliderKnob
    private let animator: GlassSpringAnimator
    
    private let trackHeight: CGFloat = 4
    private let knobWidth: CGFloat = 22
    private let knobHeight: CGFloat = 28
    
    public var value: CGFloat = 0.0 {
        didSet { 
            let clampedValue = max(minimumValue, min(maximumValue, value))
            if clampedValue != value { value = clampedValue }
            updateKnobPosition(animated: false) 
        }
    }
    
    public var minimumValue: CGFloat = 0.0
    public var maximumValue: CGFloat = 1.0
    
    public var minimumTrackTintColor: UIColor = .systemBlue {
        didSet { filledTrackView.backgroundColor = minimumTrackTintColor }
    }
    
    public var maximumTrackTintColor: UIColor = .systemGray4 {
        didSet { trackView.backgroundColor = maximumTrackTintColor }
    }
    
    private var isDragging: Bool = false
    
    public override init(frame: CGRect) {
        self.trackView = UIView()
        self.filledTrackView = UIView()
        self.knobView = LiquidGlassSliderKnob()
        self.animator = GlassSpringAnimator(config: .bouncy)
        super.init(frame: frame)
        setupViews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        trackView.backgroundColor = maximumTrackTintColor
        trackView.layer.cornerRadius = trackHeight / 2
        addSubview(trackView)
        
        filledTrackView.backgroundColor = minimumTrackTintColor
        filledTrackView.layer.cornerRadius = trackHeight / 2
        addSubview(filledTrackView)
        
        knobView.knobSize = CGSize(width: knobWidth, height: knobHeight)
        addSubview(knobView)
        
        updateKnobPosition(animated: false)
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: knobHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let trackY = (bounds.height - trackHeight) / 2
        trackView.frame = CGRect(x: knobWidth / 2, y: trackY, width: bounds.width - knobWidth, height: trackHeight)
        updateKnobPosition(animated: false)
    }
    
    private func updateKnobPosition(animated: Bool) {
        let range = maximumValue - minimumValue
        let normalizedValue = range > 0 ? (value - minimumValue) / range : 0
        let trackWidth = bounds.width - knobWidth
        let knobX = knobWidth / 2 + normalizedValue * trackWidth
        let knobCenter = CGPoint(x: knobX, y: bounds.height / 2)
        
        knobView.center = knobCenter
        knobView.bounds = CGRect(origin: .zero, size: CGSize(width: knobWidth, height: knobHeight))
        
        let filledWidth = knobX - knobWidth / 2
        let trackY = (bounds.height - trackHeight) / 2
        filledTrackView.frame = CGRect(x: knobWidth / 2, y: trackY, width: max(0, filledWidth), height: trackHeight)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            isDragging = true
            knobView.beginDragging()
        case .changed:
            let trackWidth = bounds.width - knobWidth
            let progress = (location.x - knobWidth / 2) / trackWidth
            let clampedProgress = max(0, min(1, progress))
            value = minimumValue + clampedProgress * (maximumValue - minimumValue)
            sendActions(for: .valueChanged)
        case .ended, .cancelled:
            isDragging = false
            knobView.endDragging()
        default: break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let trackWidth = bounds.width - knobWidth
        let progress = (location.x - knobWidth / 2) / trackWidth
        let clampedProgress = max(0, min(1, progress))
        value = minimumValue + clampedProgress * (maximumValue - minimumValue)
        sendActions(for: .valueChanged)
    }
    
    public func setContentSource(_ view: UIView?) { knobView.setContentSource(view) }
    public func setDarkMode(_ isDark: Bool) { knobView.setDarkMode(isDark) }
}