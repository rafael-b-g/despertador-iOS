//
//  LightSliderView.swift
//  despertador
//
//  Created by Rafael Guimarães on 14/03/24.
//

import SwiftUI
import CoreHaptics

struct LightSlider: View {
    @State private var sliderFillWidth: CGFloat = 0
    @State private var lastSliderFillWidth: CGFloat = CGFloat.zero
    @State private var engine: CHHapticEngine?
    @State private var hapticPlayer: CHHapticAdvancedPatternPlayer?
    @State private var isPlayingHaptics: Bool = false
    @State private var sliderDragVelocity: Float = 0
    private let isCapable = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    
    func prepareHaptics() {
        guard isCapable else {
            return
        }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
                                               value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
                                               value: 0)
        let continuousHaptic = CHHapticEvent(eventType: .hapticContinuous,
                                            parameters: [intensity, sharpness],
                                            relativeTime: CHHapticTimeImmediate,
                                            duration: 10)

        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = {
                do {
                    try self.engine?.start()
                    
                    let pattern = try CHHapticPattern(events: [continuousHaptic], parameters: [])
                    
                    hapticPlayer = try engine?.makeAdvancedPlayer(with: pattern)
                    hapticPlayer?.loopEnabled = true
                } catch {
                    print("Failed to restart the engine: \(error)")
                }
            }
            engine?.stoppedHandler = { _ in
                do {
                    try self.engine?.start()
                    
                    let pattern = try CHHapticPattern(events: [continuousHaptic], parameters: [])
                    
                    hapticPlayer = try engine?.makeAdvancedPlayer(with: pattern)
                    hapticPlayer?.loopEnabled = true
                } catch {
                    print("Failed to restart the engine: \(error)")
                }
            }


            try engine?.start()
            
            let pattern = try CHHapticPattern(events: [continuousHaptic], parameters: [])

            hapticPlayer = try engine?.makeAdvancedPlayer(with: pattern)
            hapticPlayer?.loopEnabled = true
        } catch {
            print("Failed: \(error.localizedDescription).")
        }
    }
    
    func playHaptics() {
        guard isCapable else {
            return
        }
        
        do {
            try engine?.start()
            try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
            isPlayingHaptics = true
        } catch {
            print("Failed: \(error.localizedDescription).")
            isPlayingHaptics = false
        }
    }

    func updateHaptics(intensity: Float, sharpness: Float) {
        guard isCapable else {
            return
        }
        
        let newIntensity = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                    value: intensity,
                                                    relativeTime: 0)
        let newSharpness = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl,
                                                    value: sharpness,
                                                    relativeTime: 0)
        
        do {
            try hapticPlayer?.sendParameters([newIntensity, newSharpness], atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed: \(error.localizedDescription).")
            isPlayingHaptics = false
        }
    }

    func stopHaptics() {
        if isPlayingHaptics {
            guard isCapable else {
                return
            }
            
            do {
                try hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
                isPlayingHaptics = false
            } catch {
                print("Failed: \(error.localizedDescription).")
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.appBorder, lineWidth: 0.7)
                .background() {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundStyle(.appElevatedBackground)
                            .overlay(alignment: .trailing) {
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .frame(width: 1, height: 30)
                                        .foregroundStyle(.appBorder)
                                    .padding(.trailing, 8)
                                    
                                    CustomDivider()
                                }
                            }
                            .frame(width: sliderFillWidth)
                        
                        Rectangle()
                            .foregroundStyle(.appBackground)
                    }
                    .clipShape(.rect(cornerRadius: 16, style: .continuous), style: .init(antialiased: true))
                }
                .gesture(
                    DragGesture()
                        .onChanged() { gesture in
                            if abs(gesture.location.x - gesture.startLocation.x + lastSliderFillWidth - lastSliderFillWidth) > 5 && sliderFillWidth == lastSliderFillWidth{
                                lastSliderFillWidth -= gesture.location.x - gesture.startLocation.x + lastSliderFillWidth - lastSliderFillWidth
                            }
                            
                            sliderFillWidth = gesture.location.x - gesture.startLocation.x + lastSliderFillWidth

                            if sliderFillWidth <= 0 {
                                sliderDragVelocity = Float(gesture.velocity.width)
                                
                                sliderFillWidth = 0
                                
                                stopHaptics()
                            } else if sliderFillWidth >= geo.size.width {
                                sliderDragVelocity = Float(gesture.velocity.width)

                                sliderFillWidth = geo.size.width
                                
                                stopHaptics()
                            } else {
                                if !isPlayingHaptics {
                                    playHaptics()
                                }
                                updateHaptics(intensity: Float(sliderFillWidth / geo.size.width * 0.2 + 0.25), sharpness: Float(sliderFillWidth / geo.size.width * 0.7))
                            }
                        }
                        .onEnded() { _ in
                            stopHaptics()
                            lastSliderFillWidth = sliderFillWidth
                        }
                )
                .sensoryFeedback(trigger: sliderFillWidth) {oldValue, newValue in
                    if newValue == 0 {
                        return .impact(flexibility: .rigid, intensity: (abs(Double($sliderDragVelocity.wrappedValue)) / 800 * 0.8 + 0.2))
                    } else if newValue == geo.size.width {
                        return .impact(flexibility: .rigid, intensity: (abs(Double($sliderDragVelocity.wrappedValue)) / 700 * 0.3 + 0.7))
                    }
                    return .none
                }
        }
        .onAppear() {
            prepareHaptics()
        }
        .frame(height: 65)
    }
}
