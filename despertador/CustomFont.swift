//
//  CustomFont.swift
//  despertador
//
//  Created by Rafael Guimarães on 14/03/24.
//

import SwiftUI

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
