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

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
   
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
        FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
                
                let alertController = UIAlertController(
                    title: "Invalid Credentials",
                    message: error.localizedDescription,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let confirmAction = UIAlertAction(
                title: "OK", style: UIAlertActionStyle.default) { (action) in
                    // ...
                }
                
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
                
            } else {
                print("Sign in worked for: ", user?.displayName)
                self.performSegue(withIdentifier: "goToChatList", sender: nil)
            }

        }
    }
   
    func setDisplayName(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.performSegue(withIdentifier: "goToChatList", sender: nil)
            }
        }
    }
    
    @IBAction func signUpTouched(_ sender: AnyObject) {
        
        FIRAuth.auth()?.createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                
                let alertController = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let confirmAction = UIAlertAction(
                title: "OK", style: UIAlertActionStyle.default) { (action) in
                    // ...
                }
                
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.setDisplayName(user!)
        }
        
    }

    
}



