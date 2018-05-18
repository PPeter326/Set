//
//  Card.swift
//  Set
//
//  Created by Peter Wu on 4/23/18.
//  Copyright © 2018 Zero. All rights reserved.
//

import Foundation

struct Card: Hashable {
    let color: Color
    let symbol: Symbol
    let numberOfSymbols: NumberOfSymbols
    let shading: Shading
    private let identifier: Int
    private static var identifier: Int = 0
    static var all: [Card] {
        var cards = [Card]()
        for color in Color.all {
            for symbol in Symbol.all {
                for shading in Shading.all {
                    for numberOfSymbols in NumberOfSymbols.all {
                        cards.append(Card(color: color, symbol: symbol, numberOfSymbols: numberOfSymbols, shading: shading, identifier: makeIdentifier()))
                    }
                }
            }
        }
        return cards
    }
    enum NumberOfSymbols: Int {
        case oneSymbol = 1
        case twoSymbol = 2
        case threeSymbol = 3
        static var all: [NumberOfSymbols] {
            return [NumberOfSymbols.oneSymbol, .twoSymbol, .threeSymbol]
        }
    }
    
    enum Color {
        case color1
        case color2
        case color3
        static var all: [Color] {
                return [Color.color1, .color2, .color3]
        }
    }
    
    enum Symbol {
        case symbol1
        case symbol2
        case symbol3
        static var all: [Symbol] {
                return [Symbol.symbol1, .symbol2, .symbol3]
        }
    }
    
    enum Shading {
        case shading1
        case shading2
        case shading3
        static var all: [Shading] {
                return [Shading.shading1, .shading2, .shading3]
        }
    }
    
    init(color: Color, symbol: Symbol, numberOfSymbols: NumberOfSymbols, shading: Shading, identifier: Int) {
        self.color = color
        self.symbol = symbol
        self.numberOfSymbols = numberOfSymbols
        self.shading = shading
        self.identifier = identifier
    }
    
    private static func makeIdentifier() -> Int {
        identifier += 1
        return identifier
    }
    
}


