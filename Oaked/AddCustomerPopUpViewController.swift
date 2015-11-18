//
//  PopUpViewControllerSwift.swift
//  NMPopUpView
//
//  Created by Nikos Maounis on 13/9/14.
//  Copyright (c) 2014 Nikos Maounis. All rights reserved.
//

import UIKit
import QuartzCore

@objc protocol CustomerAddDelegate {
    func customerToAdd(controller:AddCustomerPopUpViewControllerSwift, addCustomer: User)
}

@objc public class AddCustomerPopUpViewControllerSwift : UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var addButton: UIButton!

    var delegate: CustomerAddDelegate! = nil
    
    var user: User?

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }
    
    public func showInView(aView: UIView!, withMessage message: String!, animated: Bool)
    {
        aView.addSubview(self.view)
        messageLabel!.text = message
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    //MARK: Navigation
    
    @IBAction public func closePopup(sender: AnyObject) {
        if addButton === sender {
            let firstName = firstNameLabel.text ?? ""
            let lastName = lastNameLabel.text ?? ""
            let phoneNumber = phoneNumberLabel.text ?? ""
            
            //TODO: Need to make it find this information from the database based on phone number/first name
            let id = "2"
            
            // Set the user to be passed to OKDViewController after the unwind segue.
            user = User(id: id, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
            delegate.customerToAdd(self, addCustomer: user!)
        }
        self.removeAnimate()
    }
}
