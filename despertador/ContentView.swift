//
//  ContentView.swift
//  despertador
//
//  Created by Rafael Guimarães on 16/02/24.
//

import SwiftUI
import CoreHaptics

let rectWidth: CGFloat = 9

struct ContentView: View {
    var body: some View {
        DefaultView()
            .background(.appBackground)
            .customFont()
    }
}

struct DefaultView: View {
    var body: some View {
        VStack(spacing: 0) {
            Group() {
                Text("amanhã (sexta) você acordará às ")
                +
                Text("7:30")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.appSecondary)
            .padding(.vertical, 24)
            
            VStack(spacing: 0) {
                Day(.monday)
                Day(.tuesday)
                Day(.wednesday)
                Day(.thursday)
                Day(.friday)
                Day(.saturday)
                Day(.sunday)
            }
            
            Spacer()
            
            LightSlider()
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 16)
    }
}

struct Day: View {
    let dayLabel: String
    var cornerRadii: RectangleCornerRadii = RectangleCornerRadii()
    
    init(_ weekDay: WeekDay) {
        switch weekDay {
        case .monday:
            dayLabel = "seg"
            cornerRadii = RectangleCornerRadii(topLeading: 16, topTrailing: 16)
        case .tuesday:
            dayLabel = "ter"
        case .wednesday:
            dayLabel = "qua"
        case .thursday:
            dayLabel = "qui"
        case .friday:
            dayLabel = "sex"
        case .saturday:
            dayLabel = "sáb"
        case .sunday:
            dayLabel = "dom"
            cornerRadii = RectangleCornerRadii(bottomLeading: 16, bottomTrailing: 16)
        }
    }
    
    @State private var currentID: Int?
    
    var body: some View {
        UnevenRoundedRectangle(cornerRadii: cornerRadii, style: .continuous)
            .stroke(.appBorder , lineWidth: 0.7)
            .fill(.appElevatedBackground)
            .frame(height: 65)
            .overlay {
                HStack(spacing: 0) {
                    Text(dayLabel)
                        .customFont(smallCaps: true)
                        .foregroundStyle(.appTertiary)
                        .frame(width: 36 + (2 * 8))
                    
                    CustomDivider()
                    
                    Text("\(((currentID ?? 0)/12) % 24):\(String(format: "%02d", ((currentID ?? 0)*5) % 60))")
                        .customFont(.Optima, size: .title1, weight: .bold)
                        .foregroundStyle(.appPrimary)
                        .contentTransition(.numericText())
                        .frame(width: 120)
                    
                    CustomDivider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(0...864, id: \.self) { index in
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(width: rectWidth, height: 30)
                                    .overlay() {
                                        RoundedRectangle(cornerRadius: 2)
                                            .foregroundStyle(.appSecondary)
                                            .frame(width: 2, height: index % 12 == 0 ? 28 : 20)
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .sensoryFeedback(trigger: $currentID.wrappedValue ?? 0) {oldValue, newValue in
                        if newValue % 12 == 0 {
                            return .impact(flexibility: .rigid, intensity: 1)
                        }
                        return .impact(flexibility: .solid, intensity: 0.4)
                    }
                    .scrollPosition(id: $currentID, anchor: .center)
                    .scrollTargetBehavior(.centered)
                    .onAppear() {
                        withAnimation() {
                            currentID = 372
                        }
                    }
                    .overlay() {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [.appElevatedBackground, .clear]), startPoint: .leading, endPoint: .trailing)
                                )
                            
                            Spacer(minLength: 30)
                                
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [.appElevatedBackground, .clear]), startPoint: .trailing, endPoint: .leading)
                                )
                        }
                        .allowsHitTesting(false)
                        .simultaneousGesture(TapGesture())
                        .frame(height: 30)
                    }
                    .padding(.trailing, 0.35)
                }
            }
    }
}

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
                            sliderFillWidth = gesture.location.x - gesture.startLocation.x + lastSliderFillWidth

                            if sliderFillWidth < 0 {
                                sliderDragVelocity = Float(gesture.velocity.width)
                                
                                sliderFillWidth = 0
                                
                                stopHaptics()
                            } else if sliderFillWidth > geo.size.width {
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

enum Typeface {
    case Optima, SourceSansPro
}

enum FontSize {
    case body, title3, title2, title1
}

extension View {
    func customFont(_ typeface: Typeface = .SourceSansPro, size fontSize: FontSize = .body, weight fontWeight: Font.Weight = .regular, smallCaps: Bool = false) -> some View {
        
        var fontSizeValue: CGFloat
        
        switch fontSize {
        case .body:
            fontSizeValue = 17
        case .title3:
            fontSizeValue = 20
        case .title2:
            fontSizeValue = 32
        case .title1:
            fontSizeValue = 40
        }
        
        if smallCaps {
            return font(.custom(typeface == .Optima ? "Optima" : "SourceSansPro-Regular", size: fontSizeValue).lowercaseSmallCaps())
                .fontWeight(fontWeight)
        }
        
        return font(.custom(typeface == .Optima ? "Optima" : "SourceSansPro-Regular", size: fontSizeValue))
            .fontWeight(fontWeight)
    }
}

extension ScrollTargetBehavior where Self == CenteredScrollTargetBehavior {
    static var centered: CenteredScrollTargetBehavior { .init() }
}

struct CenteredScrollTargetBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        var remainder: CGFloat = context.containerSize.width - ((context.containerSize.width/rectWidth).rounded(.down) * rectWidth)
        
        if ((context.containerSize.width / rectWidth).rounded(.down) / 2).rounded(.down) - ((context.containerSize.width / rectWidth).rounded(.down) / 2) == 0 {
            remainder -= rectWidth
        }
        
        target.rect.origin.x = ((target.rect.origin.x + remainder/2) / rectWidth).rounded() * rectWidth - remainder/2
    }
}

struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .frame(width: 0.7)
            .foregroundStyle(.appBorder)
    }
}

enum WeekDay {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}


#Preview {
    ContentView()
}
