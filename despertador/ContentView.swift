//
//  ContentView.swift
//  despertador
//
//  Created by Rafael Guimarães on 16/02/24.
//

import SwiftUI

let rectWidth: CGFloat = 8

struct ContentView: View {
    var body: some View {
        VStack {
            Text("amanhã (sexta) você acordará às 7:30")
                .font(.body)
                .padding(.vertical, 24)
            
            VStack(spacing: 0) {
                Day(.monday)
                Day(.tuesday)
                Day(.wednesday)
                Day(.thursday)
                Day(.friday)
                Day(.saturday)
                Day(.sunday)
                
//                Text(String(currentID ?? 0))
//                
//                Rectangle()
//                    .frame(width: rectWidth, height: 300)
//                    .foregroundStyle(.black)
//                    .overlay() {
//                        Rectangle()
//                            .frame(width: 1)
//                            .foregroundStyle(.background)
//                    }
//                                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    LazyHStack(spacing: 0) {
//                        ForEach(rects, id: \.self) { rect in
//                            Rectangle()
//                                .frame(width: rectWidth)
//                                .foregroundStyle(rect % 2 == 0 ? .black : .red)
////                                .id(index)
////                                .onAppear() {
////                                    if rect == min + 10 {
////                                        min -= 2
////                                        rects.insert(min+1, at: 0)
////                                        rects.insert(min, at: 0)
////                                    } else if rect == max - 10 {
////                                        max += 2
////                                        rects.append(max-1)
////                                        rects.append(max)
////                                    }
////                                }
//                        }
//                    }
//                    .scrollTargetLayout()
//                }
//                .scrollPosition(id: $currentID, anchor: .center)
//                .scrollTargetBehavior(.centered)
//                .defaultScrollAnchor(.center)
//                .background() {
//                    Rectangle()
//                        .foregroundStyle(.blue)
//                }
//                .frame(height: 90)
//                .animation(.linear(duration: 1))
            }
            
            Spacer()
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
            .stroke(.black, lineWidth: 0.7)
            .foregroundStyle(.background)
            .frame(height: 65)
            .overlay {
                HStack(spacing: 0) {
                    Text(dayLabel)
                        .frame(width: 36 + (2 * 8))
                        .font(.title3.lowercaseSmallCaps())
                    
                    CustomDivider()
                    
                    Text(String(currentID ?? 0))
                        .frame(width: 120)
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText())
                                        
                    CustomDivider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(0...864, id: \.self) { index in
                                Rectangle()
                                    .frame(width: rectWidth, height: 30)
                                    .foregroundStyle(.clear)
                                    .overlay() {
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .foregroundStyle(.foreground)
                                            .frame(width: 2, height: index % 12 == 0 ? 30 : index % 6 == 0 ? 22 : 16)
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $currentID, anchor: .center)
                    .scrollTargetBehavior(.centered)
                    .onAppear() {
                        withAnimation(.spring) {
                            currentID = 240
                        }
                    }
//                    .defaultScrollAnchor(.center)
//                    .frame(height: 30)
                }
            }
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
            .foregroundStyle(.black)
    }
}

enum WeekDay {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}


#Preview {
    ContentView()
}
