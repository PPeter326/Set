//
//  ViewController.swift
//  Set
//
//  Created by Peter Wu on 4/17/18.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let symbol1 = "▲"
        let symbol2 = "◼︎"
        let symbol3 = "✦"

        // filled solid color
        let attributeSolidFilled: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: UIColor.blue
        ]
        // "striped" color
        let attributeStripedFilled: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: UIColor.red.withAlphaComponent(0.15)
        ]
        
        let attributeOutlined: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: UIColor.red,
            NSAttributedStringKey.strokeColor: UIColor.black,
            NSAttributedStringKey.strokeWidth: -3.0
        ]
        let symbolAttributed = NSAttributedString(string: symbol3, attributes: attributeStripedFilled)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

