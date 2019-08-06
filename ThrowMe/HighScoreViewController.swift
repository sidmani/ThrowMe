//
//  HighScoreViewController.swift
//  ThrowMe
//
//  Created by ouatt on 5/21/16.
//  Copyright © 2016 SidMani. All rights reserved.
//

import Foundation
import UIKit

class HighScoreViewController: UIViewController {
    
    @IBOutlet weak var ScoresLabel: UILabel!
    
    override func viewDidLoad() {
        ScoresLabel.text = ""
        ScoresLabel.lineBreakMode = .ByWordWrapping
        ScoresLabel.numberOfLines = 0
        super.viewDidLoad()
        for i in 0..<min(scores.count,10) {
            print("\(scores[i].score)\n")
            ScoresLabel.text = ScoresLabel.text! +  "\(scores[i].score)\n"
        }
        
    }

}