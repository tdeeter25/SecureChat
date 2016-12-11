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

class MainViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func randPrimeBInt() -> BInt{
        var n = randomBInt(bits: 512)
        print("attempt")
        if isPrime(n){
            return n
        }
        else{
            return randPrimeBInt()
        }
    }
    func pad(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<toSize - string.characters.count {
            padded = "0" + padded
        }
        return padded
    }
    
    func stringToBinary(testString: String) -> String {
        var length = testString.characters.count
        var binaryString = ""
        
        for i in 0...length-1{
            let index = testString.index(testString.startIndex, offsetBy: i)
            var aValue = testString[index].asciiValue
            var result = String(aValue!, radix: 2)
            var bitString = pad(string: result, toSize: 8)
            
            binaryString.append(bitString)
        }
        return binaryString
    }
    
    func stringToBigIntDecimal(binaryString: String) -> BInt {
        var stringAsDecimal = BInt(0)
        var len = binaryString.characters.count
        var currentPower = binaryString.characters.count-1
        for i in 0...len-1 {
            let index = binaryString.index(binaryString.startIndex, offsetBy: i)
            if binaryString[index] == "1" {
                var temp = BInt(2) ^ currentPower
                stringAsDecimal += temp
            }
            currentPower = currentPower - 1
        }
        return stringAsDecimal
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



