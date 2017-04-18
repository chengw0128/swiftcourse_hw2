//
//  ViewController.swift
//  calculator
//
//  Created by mac on 2017/4/18.
//  Copyright © 2017年 mac. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }}
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }}
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set { 
            layer.borderColor = newValue?.cgColor 
        }}}

extension Double {
    
    /// This computed property would provide a formatted string representation of this double value.
    /// For an integer value, like `2.0`, this property would be `"2"`.
    /// And for other values like `2.4`, this would be `"2.4"`.
    fileprivate var displayString: String {
        // 1. We have to check whether this double value is an integer or not.
        //    Here I subtract the value with its floor. If the result is zero, it's an integer.
        //    (Note: `floor` means removing its fraction part, 無條件捨去.
        //           `ceiling` also removes the fraction part, but it's by adding. 無條件進位.)
        let floor = self.rounded(.towardZero)  // You should check document for the `rounded` method of double
        let isInteger = self.distance(to: floor).isZero
        
        let string = String(self)
        if isInteger {
            // Okay this value is an integer, so we have to remove the `.` and tail zeros.
            // 1. Find the index of `.` first
            if let indexOfDot = string.characters.index(of: ".") {
                // 2. Return the substring from 0 to the index of dot
                //    For example: "2.0" --> "2"
                return string.substring(to: indexOfDot)
            }
        }
        // Return original string representation
        return String(self)
    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var core = Core<Double>()
    
    @IBOutlet weak var displayLabel: UILabel!
    
    // MARK: - View Controller Setup
    
    // Check the documentation. This value of this computed property decides the style of the system status bar.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Input
    
    @IBAction func numericButtonClicked(_ sender: UIButton) {
        // Get the digit from the button.
        // There are 2 ways to get the digit set on the button.
        
        // 1. By the label of the button. Like this way:
        //    (But this only works when the button title is also the digit.
        /*
         let digitText = sender.title(for: .normal)!
         */
        
        // 2. Use the tag to identify which button it is.
        //    First, I set the tag of each digit button from 1000 to 1009 in Storyboard.
        //    (The unset/default tag of a view is `0`.
        //     So it's better not to use `0` to check button identity. I add 1000 for this)
        let numericButtonDigit = sender.tag - 1000
        let digitText = "\(numericButtonDigit)"
        
        // Show the digit
        let currentText = self.displayLabel.text ?? "0"
        if currentText == "0" {
            // When the current display text is "0", replace it directly.
            self.displayLabel.text = digitText
        } else {
            // Else, append it
            self.displayLabel.text = currentText + digitText
        }
    }
    
    @IBAction func constantButtonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 1201:
            self.displayLabel.text = String(format: "%g", M_E)
        case 1202:
            self.displayLabel.text = String(format: "%g", M_PI)
                default:
            fatalError("Unknown operator button: \(sender)")
        }
    }
    
    @IBAction func negativeButtonClicked(_ sender: UIButton) {
        let currentText = self.displayLabel.text ?? "0"
        if !currentText.contains("-") {
            guard currentText != "0" else {
                return
            }
            self.displayLabel.text = "-" + currentText
        }else {
            let positive = currentText.replacingOccurrences(of: "-", with: "")
            self.displayLabel.text = positive
        }
    }
    
    @IBAction func persentButtonClicked(_ sender: UIButton) {
        let currentText = self.displayLabel.text ?? "0"
        let percent = Double(currentText)! / 100
        self.displayLabel.text = String(format: "%g", percent)
    }
    
    @IBAction func logButtonClicked(_ sender: UIButton) {
        let currentText = self.displayLabel.text ?? "0"
        let log = log10(Double(currentText)!)
        self.displayLabel.text = String(format: "%g", log)
    }

    
    @IBAction func dotButtonClicked(_ sender: UIButton) {
        let currentText = self.displayLabel.text ?? "0"
        // Append the `.` to the display string only when there's no `.` in the string
        guard !currentText.contains(".") else {
            return
        }
        // Append and re-assign the string
        self.displayLabel.text = currentText + "."
    }
    
    @IBAction func clearButtonClicked(_ sender: UIButton) {
        // Clear (Reset)
        // 1. Clean the display label
        self.displayLabel.text = "0"
        // 2. Reset the core
        self.core = Core<Double>()
    }
    
    // MARK: - Actions
    
    @IBAction func operatorButtonClicked(_ sender: UIButton) {
        // Add current number into the core as a step
        let currentNumber = Double(self.displayLabel.text ?? "0")!
        try! self.core.addStep(currentNumber)
        // Clean the display to accept user's new input
        self.displayLabel.text = "0"
        
        // Here, I use tag to check whether the button it is.
        switch sender.tag {
        case 1101: // Add
            try! self.core.addStep(+)
        case 1102: // Sub
            try! self.core.addStep(-)
        case 1103: //
            try! self.core.addStep(*)
        case 1104: //
            try! self.core.addStep(/)
        //case 1105:
            //try! self.core.addStep(pow(,))
        //case 1106: //
            //try! self.core.addStep(sqrt())
        default:
            fatalError("Unknown operator button: \(sender)")
        }
    }
    
    @IBAction func calculateButtonClicked(_ sender: UIButton) {
        // Add current number into the core as a step
        let currentNumber = Double(self.displayLabel.text ?? "0")!
        try! self.core.addStep(currentNumber)
        // Get and show the result
        let result = self.core.calculate()!
        self.displayLabel.text = result.displayString
        // Reset the core
        self.core = Core<Double>()
    }



}

