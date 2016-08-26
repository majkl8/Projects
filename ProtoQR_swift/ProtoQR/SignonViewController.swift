//
//  SignonViewController.swift
//  ProtoQR
//
//  Created by Majkl on 05/03/16.
//  Copyright © 2016 Majkl. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit


class SignonViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    var loginView : FBSDKLoginButton = FBSDKLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sign In"
        
//        loginView.center = self.view.center
        
        loginView.frame = CGRectMake(20, 300, view.frame.width-40, 40)        
        self.view.addSubview(loginView)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
        
        
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        // TODO: Change where the log in button is positioned in your view
        //logInButton.center = self.view.center
        
        logInButton.frame = CGRectMake(20, 342, view.frame.width-40, 40)
        self.view.addSubview(logInButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            print(error.localizedDescription)
        } else {
            returnUserData()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func returnUserData() {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: //["fields":"id,interested_in,gender,birthday,email,age_range,name,picture.width(480).height(480)"])
            ["fields":"id,email,name,picture.width(480).height(480)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                print(error.localizedDescription)
            }
            else {
                print("fetched user: \(result)")
                let id : NSString = result.valueForKey("id") as! String
                print("User ID is: \(id)")
                //etc...
            }
        })
    }
}
