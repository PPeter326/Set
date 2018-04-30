//
//  ViewController.swift
//  Set
//
//  Created by Peter Wu on 4/17/18.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Elements -
    @IBOutlet var cardButtons: [UIButton]! {
        didSet {
            // Initial set up - hide all buttons
            for cardButton in cardButtons {
                cardButton.layer.borderColor = nil
                cardButton.isEnabled = false
                cardButton.isHidden = true
                cardButton.layer.cornerRadius = 8.0
            }
        }
    }
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealCardButton: UIButton! {
        didSet {
            dealCardButton.layer.cornerRadius = 8.0
        }
    }
    private var lastButtonsToHide = [UIButton]()
    // MARK: - Game Properties -
    private var set = Set()
    
    // MARK: Card Attributes
    private let colorDictionary: [Card.Color: UIColor] = [
        .color1: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1),
        .color2: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1),
        .color3: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
    ]
    
    private let symbolDiciontary: [Card.Symbol: Character] = [
        .symbol1: "▲",
        .symbol2: "◼︎",
        .symbol3: "✦"
    ]
    
    private let shadingDictionary: [Card.Shading: ShadingType] = [
        .shading1: .filled,
        .shading2: .striped,
        .shading3: .outlined
    ]
    
    private enum ShadingType {
        case filled
        case striped
        case outlined
    }
    // MARK: - View Config -
    override func viewDidLoad() {
        // Display the cards that were drawn
        displayPlayedCards()
    }
    
    // MARK: - User Actions -
    @IBAction func cardButtonDidPressed(_ sender: UIButton) {
        set.selectCard(card: getPlayedCard(index: cardButtons.index(of: sender)!))
        updateView()
    }
    
    @IBAction func newGameButtonTouched(_ sender: UIButton) {
        set.reset()
        lastButtonsToHide.removeAll()
        updateView()
    }
    
    @IBAction func dealCardButtonTouched(_ sender: UIButton) {
        // tells game to deal three cards
        set.dealCards()
        updateView()
    }
    
    // MARK: - Helper Functions -
    
    private func updateView() {
        
        // First display the currently played cards
        displayPlayedCards()
        // then show borders on the selected cards
        // 1. If there are 3 selected cards:
        // 2. If less than 3 selected cards, show purple border for card selection
        switch set.selectedCards.count {
        case 1, 2:
            showBorder(on: set.selectedCards, color: #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1))
        case 3:
            if set.matched {
                showBorder(on: set.selectedCards, color: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1))
            } else {
                showBorder(on: set.selectedCards, color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
            }
        default:
            break
        }
        // disable deal card button when:
        // 1. If the deck is empty (always)
        // 2. If there are already 24 cards being played (but enable if the 3 selected cards are matching)
        var disableDealcard = false
        if set.playedCards.count == 24 {
            disableDealcard = true
            if set.selectedCards.count == 3 && set.matched == true {
                disableDealcard = false
            }
        }
        if set.deck.isEmpty {
            disableDealcard = true
        }
        dealCard(disable: disableDealcard)
        scoreLabel.text = "Score: \(set.score)"
       
    }
    private func dealCard(disable: Bool) {
        if disable {
            self.dealCardButton.isEnabled = false
            self.dealCardButton.backgroundColor =  UIColor.gray
            self.dealCardButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            self.dealCardButton.isEnabled = true
            self.dealCardButton.backgroundColor =  UIColor.red
            self.dealCardButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    private func getCardButtons(of card: Card) -> UIButton {
        let index = set.playedCards.index(of: card)
        return cardButtons[index!]
    }
    
    private func displayPlayedCards() {
        // start with clean slate
        cardButtons.map { (cardButton) -> UIButton in
            cardButton.isEnabled = false
            cardButton.isHidden = true
            return cardButton
        }
        // only display cards that are being played
        for index in set.playedCards.indices {
            print(index)
            cardButtons[index].isEnabled = true
            cardButtons[index].isHidden = false
            cardButtons[index].layer.borderWidth = CGFloat(0)
            cardButtons[index].setAttributedTitle(displayCard(card: set.playedCards[index]), for: .normal)
        }
        // Check if to add new buttons to hide
        hideLastButtons()
        for button in lastButtonsToHide {
            button.isEnabled = false
            button.isHidden = true
        }
        
    }
    
    private func hideLastButtons() {
        if set.deck.isEmpty && set.selectedCards.count == 1 {
            for card in set.matchedCards {
                if let matchedCardIndex = set.playedCards.index(of: card) {
                    let hideCardButton = cardButtons[matchedCardIndex]
                    self.lastButtonsToHide.append(hideCardButton)
                }
            }
            
        }
    }
    private func showBorder(on selectedCards: [Card], color: UIColor) {
        // then add border to the selected card buttons
        for selectedCard in set.selectedCards {
            let cardButton = getCardButtons(of: selectedCard)
            cardButton.layer.borderColor = color.cgColor
            cardButton.layer.borderWidth = 3.0
        }
    }
    
    private func getAttributes(color: UIColor, shading: ShadingType) -> [NSAttributedStringKey: Any] {
        switch shading {
        case .filled:
            return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25), NSAttributedStringKey.foregroundColor: color]
        case .striped:
            return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25), NSAttributedStringKey.foregroundColor: color.withAlphaComponent(0.15)]
        case .outlined:
            return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25),
                    NSAttributedStringKey.foregroundColor: UIColor.white,
                    NSAttributedStringKey.strokeColor: color,
                    NSAttributedStringKey.strokeWidth: -5.0
            ]
        }
    }
    
    private func displayCard(card: Card) -> NSAttributedString {
        let cardColor = colorDictionary[card.color]!
        let cardSymbolCharacter = symbolDiciontary[card.symbol]!
        let cardSymbolCharacterArray = Array(repeatElement(cardSymbolCharacter, count: card.numberOfSymbols.rawValue))
        let cardsymbolString = String(cardSymbolCharacterArray)
        let stringAttributes: [NSAttributedStringKey: Any] = getAttributes(color: cardColor, shading: shadingDictionary[card.shading]!)
        let attributedString = NSAttributedString(string: cardsymbolString, attributes: stringAttributes)
        return attributedString
    }
    
    private func getPlayedCard(index: Int) -> Card {
        return set.playedCards[index]
    }
    
}

