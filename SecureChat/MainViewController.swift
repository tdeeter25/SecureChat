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
        
        //Input a string
        var str = "thi"
        
        //Turn into an array of bytes
        let byteArray = [UInt8](str.utf8)
        let data = Data(bytes: byteArray)
        /*
        //Make a string representation of these bytes
        var numStr = ""
        for byte in data{
            //var hexByte = String(format: "%2X", Int(byte))
            numStr.append(hexByte)
        }
   */
        
        
        var encryptedString = [String]()
        var decryptedString = ""
        
        //Make your public and Private Key info into BigInts as well
        let mod = BInt("145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053")
        let privateKey = BInt("89489425009274444368228545921773093919669586065884257445497854456487674839629818390934941973262879616797970608917283679875499331574161113854088813275488110588247193077582527278437906504015680623423550067240042466665654232383502922215493623289472138866445818789127946123407807725702626644091036502372545139713")
        let publicKey = BInt("65537")
        
        for number in byteArray {
            var numAsInt = Int(number)
            let base = BInt(numAsInt)
            //Encrypt the number m by doing m ^ Public Key mod n
            let encrypt = mod_exp(base, publicKey, mod)
            encryptedString.append(encrypt.dec)
        }
        
        print("Encrypted String")
        print(encryptedString)
    
        
        for byte in encryptedString {
            var num = BInt(byte)
            //decrypt the encrypted number e by doing e ^ Private Key mod n
            let decrypt = mod_exp(num, privateKey,mod)
        
            let intByte = Int(decrypt.dec)
            
            var test = Character(UnicodeScalar(intByte!)!)
            decryptedString.append(test)
        }
        
        print("Decrypted String")
        print(decryptedString)
        
        /*
        let count = decryptValue.characters.count
        var hexValues = [String]()
        var decryptString = ""
        for i in stride(from: 0, to: count, by: 2){
            var hexValue = numStr.substring(from: i, to: i+1)
            
            let value = UInt8(hexValue, radix: 16)
            
            var test = Character(UnicodeScalar(value!))
            decryptString.append(test)
        }
        
        print(decryptString)
        */
        
        
        
        
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



