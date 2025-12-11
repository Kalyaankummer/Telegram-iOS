import Foundation
import UIKit

/// Example usage and demonstrations of Liquid Glass components
public final class LiquidGlassExamples {
    
    // MARK: - Example 1: Basic Glass View
    
    public static func createBasicGlassView() -> LiquidGlassView {
        let glassView = LiquidGlassView(style: .light)
        glassView.cornerRadius = 20.0
        glassView.blurIntensity = .medium
        glassView.refractionIntensity = 0.5
        glassView.showChromaticBorder = true
        glassView.showSpecularHighlights = true
        
        return glassView
    }
    
    // MARK: - Example 2: Action Button
    
    public static func createActionButton(icon: UIImage?, title: String?) -> LiquidGlassButton {
        let button = LiquidGlassButton(icon: icon, title: title, style: .light)
        button.buttonSize = .large
        button.iconTintColor = .white
        button.setBlurIntensity(.strong)
        button.setRefractionIntensity(0.6)
        button.setChromaticBorderEnabled(true)
        
        return button
    }
    
    // MARK: - Example 3: Settings Switch
    
    public static func createSettingsSwitch() -> LiquidGlassSwitchThumb {
        let switchControl = LiquidGlassSwitchThumb()
        switchControl.onTintColor = .systemBlue
        switchControl.offTintColor = .systemGray4
        switchControl.isOn = false
        
        return switchControl
    }
    
    // MARK: - Example 4: Volume Slider
    
    public static func createVolumeSlider() -> LiquidGlassSliderKnob {
        let slider = LiquidGlassSliderKnob()
        slider.sliderHeight = 200.0
        slider.trackColor = .systemGray5
        slider.fillColor = .systemBlue
        slider.value = 0.5
        
        return slider
    }
    
    // MARK: - Example 5: Tab Bar with Lens
    
    public static func createTabBar(tabCount: Int, containerWidth: CGFloat) -> LiquidGlassTabLens {
        let tabLens = LiquidGlassTabLens(style: .light)
        
        let frames = LiquidGlassTabLens.generateTabFrames(
            tabCount: tabCount,
            containerWidth: containerWidth,
            tabHeight: 44.0,
            spacing: 8.0
        )
        
        tabLens.setTabFrames(frames)
        tabLens.selectTab(at: 0, animated: false)
        
        return tabLens
    }
    
    // MARK: - Example 6: Animated Chromatic Border
    
    public static func createChromaticBorder() -> ChromaticBorderView {
        let border = ChromaticBorderView()
        border.borderWidth = 2.0
        border.animationDuration = 3.0
        border.startAnimation()
        
        return border
    }
    
    // MARK: - Example 7: Custom Blur Effect
    
    public static func createCustomBlurView(intensity: GlassBlurView.BlurIntensity) -> GlassBlurView {
        let blurView = GlassBlurView(style: .light, blurRadius: intensity.radius)
        blurView.setIntensity(intensity, animated: false)
        
        return blurView
    }
    
    // MARK: - Example 8: Spring Animation Demo
    
    public static func demonstrateSpringAnimations(on view: UIView) {
        // Tap animation
        GlassSpringAnimator.animateTap(view: view) {
            print("Tap animation completed")
        }
        
        // Bounce animation
        GlassSpringAnimator.animateBounce(view: view, intensity: 1.2) {
            print("Bounce animation completed")
        }
        
        // Stretch animation
        GlassSpringAnimator.animateStretch(
            view: view,
            from: 1.0,
            to: 1.3,
            axis: .horizontal,
            parameters: .bouncy
        ) {
            print("Stretch animation completed")
        }
    }
    
    // MARK: - Example 9: Complete UI Component
    
    public static func createCompleteExample(in containerView: UIView) {
        let glassView = createBasicGlassView()
        glassView.frame = CGRect(x: 20, y: 100, width: containerView.bounds.width - 40, height: 200)
        
        // Add a button inside
        if let icon = UIImage(systemName: "mic.fill") {
            let button = createActionButton(icon: icon, title: "Record")
            button.frame = CGRect(x: 20, y: 20, width: 72, height: 92)
            glassView.contentView.addSubview(button)
            
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        // Add a switch
        let switchControl = createSettingsSwitch()
        switchControl.frame = CGRect(x: glassView.bounds.width - 71, y: 20, width: 51, height: 31)
        glassView.contentView.addSubview(switchControl)
        
        containerView.addSubview(glassView)
    }
    
    @objc private static func buttonTapped() {
        print("Glass button tapped!")
    }
    
    // MARK: - Configuration Examples
    
    public static func checkConfiguration() -> [String: Bool] {
        let config = LiquidGlassConfiguration.shared
        
        return [
            "supportsFullEffects": config.supportsFullEffects,
            "supportsNativeLiquidLens": config.supportsNativeLiquidLens,
            "shouldEnableBlur": config.shouldEnableBlur,
            "shouldEnableRefraction": config.shouldEnableRefraction,
            "shouldEnableChromaticBorder": config.shouldEnableChromaticBorder,
            "shouldEnableSpringAnimations": config.shouldEnableSpringAnimations,
            "isLowPowerModeEnabled": config.isLowPowerModeEnabled,
            "isReduceTransparencyEnabled": config.isReduceTransparencyEnabled,
            "isReduceMotionEnabled": config.isReduceMotionEnabled
        ]
    }
}
