//
//  ContentView.swift
//  despertador
//
//  Created by Rafael Guimarães on 16/02/24.
//

import SwiftUI

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


#Preview {
    ContentView()
}
