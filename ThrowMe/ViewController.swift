//
//  ViewController.swift
//  ThrowMe
//
//  Created by ouatt on 5/21/16.
//  Copyright © 2016 SidMani. All rights reserved.
//

import UIKit
import CoreMotion
struct highScore {
    var score:Double
    var time:NSDate
}
var scores:[highScore] = []

class ViewController: UIViewController {
    enum states {
        case inHand, inAir
    }
    
    var currState = states.inHand
    
    @IBOutlet weak var IconView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var BreakdownLabel: UILabel!
    @IBOutlet weak var OrientationLabel: UILabel!
    
    var motionManager: CMMotionManager!
    var timeInAir:Double = 0
    var timer:NSTimer?
    let modelPrice = UIDevice.currentDevice().modelPrice
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(handleThrow), userInfo: nil, repeats: true)
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates()
        BreakdownLabel.lineBreakMode = .ByWordWrapping;
        BreakdownLabel.numberOfLines = 0
        self.view.backgroundColor = UIColor.greenColor()
        NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {(_) in self.flips += 1})
    }
    var currScore:Double = 0
    var flips:Double = 0
    var distance:Double = 0
    var velocity:Double = 0
    func handleThrow() {
        
        var inAir:Bool = true
        for _ in 0..<5 {
            inAir = inAir && isInAir()
        }
        if (inAir) {
            if (currState == .inHand) {
                currState = .inAir
                timeInAir = 0
                if (currScore != 0) {
                    scores.append(highScore(score: currScore, time: NSDate()))
                    scores.sortInPlace{
                        return $1.score < $0.score
                    }
                }
                currScore = 0
                flips = 0
                distance = 0
                velocity = 0
            }
            stateLabel.text = "In Air"
            self.view.backgroundColor = UIColor.redColor()
            timeInAir += 0.1
            velocity += 0.1 * getTotalAcc() * 9.8
            distance += 0.1 * velocity
        }
        else {
            if (currState == .inAir) {
                currState = .inHand
                stateLabel.text = "In Hand"
                timeLabel.text = "\(timeInAir) sec in the air"
                var facedownMultiplier:Double = 0
                print(motionManager.accelerometerData?.acceleration.z)
                if((motionManager.accelerometerData?.acceleration.z)! > 0.8) {
                    facedownMultiplier = 10
                }
                let flipPts:Double = flips*5
                let pricePts = timeInAir*(modelPrice/5)
                BreakdownLabel.text = "Price of phone - \(pricePts) pts.\nAir time - \(timeInAir*5) pts.\nLanded on screen - \(facedownMultiplier) pts.\nFlips - \(flipPts)\nVertical Distance - \(10*distance/10*5)"
                currScore = pricePts + (timeInAir*5) + facedownMultiplier + flipPts + 10*distance/10 * 5
                scoreLabel.text = "\(currScore) points"
                self.view.backgroundColor = UIColor.greenColor()
            }
            
        }
        
    }
    
    func getTotalAcc() -> Double {
        if let accelerometerData = motionManager.accelerometerData {
            return sqrt(accelerometerData.acceleration.x * accelerometerData.acceleration.x + accelerometerData.acceleration.y * accelerometerData.acceleration.y + (accelerometerData.acceleration.z) * (accelerometerData.acceleration.z))
        }
        return 0
    }
    func getPhonePrice() {
        
    }
    func isInAir() -> Bool {
        let totalAcc = getTotalAcc()
        return totalAcc < 0.1
    }
    
    @IBAction func goBack(segue:UIStoryboardSegue) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


public extension UIDevice {
    
    var modelPrice: Double {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return 249
        case "iPod7,1":                                 return 299
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return 99
        case "iPhone4,1":                               return 149
        case "iPhone5,1", "iPhone5,2":                  return 199
        case "iPhone5,3", "iPhone5,4":                  return 199
        case "iPhone6,1", "iPhone6,2":                  return 249
        case "iPhone7,2":                               return 349
        case "iPhone7,1":                               return 349
        case "iPhone8,1":                               return 399
        case "iPhone8,2":                               return 399
        case "iPhone8,4":                               return 349
        default:                                        return 0
        }
    }
    
}

