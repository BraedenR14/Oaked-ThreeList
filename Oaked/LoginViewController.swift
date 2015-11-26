//
//  LoginViewController.swift
//  Oaked
//
//  Created by Adam Owoc on 2015-11-23.
//  Copyright © 2015 Braeden Robak. All rights reserved.
//

import UIKit

// Taken straight from http://stackoverflow.com/questions/30845495/how-to-use-nsregularexpression-in-swift-2-0
extension String {
    func isEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$",
            options: [.CaseInsensitive])
        
        return regex.firstMatchInString(self, options:[],
            range: NSMakeRange(0, utf16.count)) != nil
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        /* // Uncomment this before release
        signinButton.enabled = false
        */
        
        // Set tint/cursor color
        emailTextField.tintColor = titleTextColour
        passwordTextField.tintColor = titleTextColour
        
        // Set label color
        emailLabel.textColor = titleTextColour
        passwordLabel.textColor = titleTextColour
        
        // Set button color
        signinButton.backgroundColor = titleTextColour
        signinButton.tintColor = UIColor.whiteColor()
        
        // Handle the email text field's user input through delegate callbacks.
        emailTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text?.isEmail() != false) {
            signinButton.enabled = true
        } else {
            signinButton.enabled = false
        }
    }
    
}
