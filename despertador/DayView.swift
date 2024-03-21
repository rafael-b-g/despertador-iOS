//
//  DayView.swift
//  despertador
//
//  Created by Rafael Guimarães on 14/03/24.
//

import SwiftUI

let rectWidth: CGFloat = 9

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
    @State private var isOn: Bool = true
    
    var body: some View {
        UnevenRoundedRectangle(cornerRadii: cornerRadii, style: .continuous)
            .fill(isOn ? .appElevatedBackground : .appBackground)
            .stroke(.appBorder , lineWidth: 0.7)
            .frame(height: 65)
            .overlay {
                HStack(spacing: 0) {
                    Group {
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
                            .opacity(isOn ? 1 : 0)
                            .blur(radius: isOn ? 0 : 5)
                            .background() {
                                Text("desativado")
                                    .customFont(.SourceSansPro, size: .body, weight: .regular, smallCaps: true)
                                    .foregroundStyle(.appSecondary)
                                    .opacity(isOn ? 0 : 1)
                                    .blur(radius: isOn ? 5 : 0)
                            }
                    }
                    .frame(height: 65)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.25)) {
                            isOn.toggle()
                        }
                    }
                    
                    CustomDivider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(0...864, id: \.self) { index in
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(width: rectWidth, height: 30)
                                    .overlay() {
                                        RoundedRectangle(cornerRadius: 2)
                                            .foregroundStyle(isOn ? .appSecondary : .appTertiary)
                                            .frame(width: 2, height: isOn ? index % 12 == 0 ? 28 : 20 : 14)
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .sensoryFeedback(trigger: $currentID.wrappedValue ?? 0) {oldValue, newValue in
                        if !isOn {
                            withAnimation(.easeOut(duration: 0.25)) {
                                isOn = true
                            }
                        }
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
                                .fill(LinearGradient(gradient: Gradient(colors: [isOn ? .appElevatedBackground : .appBackground, .clear]), startPoint: .leading, endPoint: .trailing)
                                )
                            
                            Spacer(minLength: 30)
                            
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [isOn ? .appElevatedBackground : .appBackground, .clear]), startPoint: .trailing, endPoint: .leading)
                                )
                        }
                        .allowsHitTesting(false)
                        .frame(height: 30)
                    }
                    .padding(.trailing, 0.35)
                }
            }
    }
}

enum WeekDay {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
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
