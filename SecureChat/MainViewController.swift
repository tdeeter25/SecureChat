//
//  ViewController.swift
//  SecureChat
//
//  Created by Tommy Deeter on 11/17/16.
//  Copyright © 2016 Tommy Deeter. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
class MainViewController: UIViewController, FBSDKLoginButtonDelegate {

   
    @IBOutlet weak var loginButton: FBSDKLoginButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("OMG")
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print("user id = " + (user?.uid)!)
        }
        self.performSegue(withIdentifier: "goToChat", sender: nil)
        print("yes")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("ok")
    }
    
    

    func loginFacebook(_ segueId: String) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["user_friends", "public_profile", "email"], from: self, handler: {
            (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. UH OH \(facebookError)")
            } else if (facebookResult?.isCancelled)! {
                print("Facebook login was cancelled. YIKES")
            } else {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    if let error = error {
                        print("Sign in failed:", error.localizedDescription)
                    } else {
                        print("Sign in worked for", user?.displayName)
                       /*
                        self.getFriends()
                        self.getId()
                       
                         //stores info in AppState of the user's basic information.
                        AppState.sharedInstance.profilePicture = user?.photoURL
                        AppState.sharedInstance.userId = user?.uid
                        AppState.sharedInstance.displayName = user?.displayName
                        */
                        self.performSegue(withIdentifier: segueId, sender: nil)
                    }
                }
            }
        })
    }

    @IBAction func loginTouched(_ sender: AnyObject) {
        login("goToChatList")
    }
    
    func login(_ segueId: String){
        print("getting called")
        FIRAuth.auth()?.signIn(withEmail: "tommydeeter25@sbcglobal.net", password: "123456") { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
            } else {
                print("Sign in worked for", user?.displayName)
                
                self.performSegue(withIdentifier: segueId, sender: nil)
            }

        }
        
        
       // self.performSegue(withIdentifier: segueId, sender: nil)
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject) {
            }

    
    
    
    
    
}

