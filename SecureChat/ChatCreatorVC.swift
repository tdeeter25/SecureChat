//
//  ChatCreatorVC.swift
//  SecureChat
//
//  Created by Tommy Deeter on 11/20/16.
//  Copyright © 2016 Tommy Deeter. All rights reserved.
//

import UIKit
import Eureka
import FirebaseDatabase

class ChatCreatorVC: FormViewController {

    var ref: FIRDatabaseReference!
    var chatsRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

        form =
            
            Section("Chat Creation Form")
            
            <<< TextRow("Name") { $0.title = "Chat Name" }
            <<< IntRow("Prime1") { $0.title = "Pick a Prime Number" }
            <<< IntRow("Prime2") { $0.title = "Pick a Second Prime Number" }


            +++ Section()
            
            <<< ButtonRow("Button") {
                $0.title = "Submit"
                $0.onCellSelection { cell, row in
                    print("yes")
                    self.pushDataToFirebase()
                    self.navigationController?.popViewController(animated: true)
                }
                
        }
    }

    func pushDataToFirebase() {
        let chatInfo = self.form.values(includeHidden: false)
        let chatTitle = chatInfo["Name"] as! String
        //let cipher = chatInfo["Integer"] as! Int
        var p1 = chatInfo["Prime1"] as! Int
        var p2 = chatInfo["Prime2"] as! Int
        
        
        //cast to BigInts to be used for calculations
        
        if !(isValidNumber(num: p1) && isValidNumber(num: p2)){
            showMessage("Error", message: "Either one of your numbers is invalid.")
            return
        }
    
        var totient = (p1-1) * (p2-1)
        let publicKey = generatePublicKey(p1: p1, p2: p2)
        let privateKey = generatePrivateKey(pubKey: Int(publicKey.dec)!, totient: totient)
        let modulus = genereateModulus(p1: p1, p2: p2).dec

        
        chatsRef = ref.child("chats").childByAutoId()
        
        let dict: [String: AnyObject] = ["chatTitle": chatTitle as AnyObject,
                                         "publicKey": publicKey.dec as AnyObject,
                                         "privateKey": privateKey.dec as AnyObject,
                                         "modulus": modulus as AnyObject,
                                         ]
        chatsRef.setValue(dict)
        
    }
    
    //returns true if number is prime
    func isPrime(num: Int) -> Bool {
        var j = Int(sqrt(Double(num)))
        
        for i in stride(from: 2, to: j, by: 1){
            if(num % i == 0){
                return false
            }
        }
        return true
    }
    
    func isValidNumber(num: Int) -> Bool {
        return isPrime(num: num) && num < 10000000000
    }
    
    
    func generatePublicKey(p1: Int, p2: Int) -> BInt {
        let totient = (p1-1) * (p2-1)
        let pubKey = randE(phi: totient)
        
        return BInt(pubKey)
    }
    
    
    func generatePrivateKey(pubKey: Int, totient: Int) -> BInt {
        return BInt(inverse(num: pubKey, phi: totient))
    }
    
    func genereateModulus(p1: Int, p2: Int) -> BInt {
        let prime1 = BInt(p1)
        let prime2 = BInt(p2)
        
        return prime1 * prime2
    }

    
    
    //generate random prime number in the range 1 to num
    func randPrime(num: Int) -> Int{
        var prime = UInt64.random(lower: 1, upper: UInt64(num))
        var n = UInt64(num)
        n += n % 2
        
        prime += 1 - prime % 2
        while true {
            if isPrime(num: Int(prime)) {
                return Int(prime)
            }
            prime = (prime + 2) % n
        }
    }
    
    //finds a random prime number no greater than the totient that is coprime with it
    func randE(phi: Int) -> Int {
        var e = randPrime(num: phi)
        
        while true {
            if gcd(phi, Int(e)) == 1 {
                return Int(e)
            }
            e = (e+1 % phi)
            if e <= 2 {
                e = 3
            }
        }
    }
    
    //returns the gcd of two numbers
    func gcd(_ a: Int, _ b: Int) -> Int {
        if b == 0 {
            return a
        } else {
            if a > b {
                return gcd(a-b, b)
            } else {
                return gcd(a, b-a)
            }
        }
    }
    
    //generate the inverse using Euclid's Extended algorithm
    //used for generation of private key
    func inverse(num: Int, phi: Int) -> Int{
        var a = num, b = phi
        var x=0, y=1, x0 = 1, y0 = 0
        var q: Int
        var temp: Int
        
        while b != 0 {
            q = a / b
            temp = a % b
            a = b
            b = temp
            temp = x; x = x0 - q * x; x0 = temp
            temp = y; y = y0 - q * y0; y0 = temp
        }
        if (x0 < 0) {
            x0 += phi
        }
        return x0
    }

    
    
    func showMessage(_ title:String, message:String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
public func arc4random<T: ExpressibleByIntegerLiteral>(_ type: T.Type) -> T {
    var r: T = 0
    arc4random_buf(&r, MemoryLayout<T>.size)
    return r
}
public extension UInt64 {
    public static func random(lower: UInt64 = min, upper: UInt64 = max) -> UInt64 {
        var m: UInt64
        let u = upper - lower
        var r = arc4random(UInt64.self)
        
        if u > UInt64(Int64.max) {
            m = 1 + ~u
        } else {
            m = ((max - (u * 2)) + 1) % u
        }
        
        while r < m {
            r = arc4random(UInt64.self)
        }
        
        return (r % u) + lower
    }
}
public extension Int64 {
    public static func random(lower: Int64 = min, upper: Int64 = max) -> Int64 {
        let (s, overflow) = Int64.subtractWithOverflow(upper, lower)
        let u = overflow ? UInt64.max - UInt64(~s) : UInt64(s)
        let r = UInt64.random(upper: u)
        
        if r > UInt64(Int64.max)  {
            return Int64(r - (UInt64(~lower) + 1))
        } else {
            return Int64(r) + lower
        }
    }
}
