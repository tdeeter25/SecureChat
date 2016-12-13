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
            <<< TextRow("Prime1") { $0.title = "Pick a Prime Number" }
            <<< TextRow("Prime2") { $0.title = "Pick a Second Prime Number" }


            +++ Section()
            
            <<< ButtonRow("Button") {
                $0.title = "Submit"
                $0.onCellSelection { cell, row in
                    print("yes")
                    self.pushDataToFirebase()
                }
                
        }
    }

    func pushDataToFirebase() {
        let chatInfo = self.form.values(includeHidden: false)
        let chatTitle = chatInfo["Name"] as! String
        //let cipher = chatInfo["Integer"] as! Int
        let p1 = BInt(chatInfo["Prime1"] as! String)
        let p2 = BInt(chatInfo["Prime2"] as! String)
        //let p1 = randPrimeBInt()
        //let p2 = randPrimeBInt()
        print("primes generated")
        print(p1)
        print(p2)
        
        //cast to BigInts to be used for calculations
        
        if !(isValidNumber(num: p1) && isValidNumber(num: p2)){
            showMessage("Error", message: "Either one of your numbers is invalid.")
            return
        }
    
        var totient = (p1-1) * (p2-1)
        print("totient")
        print(totient)
        
        let publicKey = generatePublicKey(p1: p1, p2: p2)
        print("pulbic Key")
        let privateKey = generatePrivateKey(pubKey: publicKey, totient: totient)
        print("Private Key")
        let modulus = genereateModulus(p1: p1, p2: p2).dec
        print("modulus")

        showMessage("Private Key is " + privateKey.dec, message: "Be sure to remember this value!")
        
        chatsRef = ref.child("chats").childByAutoId()
        
        let dict: [String: AnyObject] = ["chatTitle": chatTitle as AnyObject,
                                         "publicKey": publicKey.dec as AnyObject,
                                         "privateKey": privateKey.dec as AnyObject,
                                         "modulus": modulus as AnyObject,
                                         ]
        chatsRef.setValue(dict)
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    //returns true if number is prime
    func isPrime(num: BInt) -> Bool {
        var j = BInt(sqrt(Double(num)))
        
        for i in stride(from: 2, to: j, by: 1){
            if(num % i == 0){
                return false
            }
        }
        return true
    }
    */
    
    func isPrime(_ n: BInt) -> Bool
    {
        if n <= 3 { return n > 1 }
        
        if ((n % 2) == 0) || ((n % 3) == 0) { return false }
        
        var i = 5
        while (i * i) <= n
        {
            if ((n % i) == 0) || ((n % (i + 2)) == 0)
            {
                return false
            }
            i += 6
        }
        return true
    }
    
    func isValidNumber(num: BInt) -> Bool {
        return isPrime(num) && num > 100
    }
    
    //generates the public key, which is a random exponent in the range 1 < e < totient
    func generatePublicKey(p1: BInt, p2: BInt) -> BInt {
        let totient = (p1-1) * (p2-1)
        let pubKey = randE(phi: totient)
        
        return pubKey
    }
    
    //returns the Euler's totient of two numbers
    func generateTotient(p1: BInt, p2: BInt) -> BInt {
        return (p1 - 1) * (p2 - 1)
    }
    
    
    
    func generatePrivateKey(pubKey: BInt, totient: BInt) -> BInt {
        return inverse(num: pubKey, phi: totient)
    }
    
    //returns the product of two prime numbers
    func genereateModulus(p1: BInt, p2: BInt) -> BInt {
        return p1 * p2
    }

    
    
    //generate random prime number in the range 1 to num
    func randPrime(num: Int) -> BInt{
        var prime = UInt64.random(lower: 1, upper: UInt64(num))
        var n = UInt64(num)
        n += n % 2
        
        prime += 1 - prime % 2
        while true {
            if isPrime(BInt(prime)) {
                return BInt(prime)
            }
            prime = (prime + 2) % n
        }
    }
 
    //finds a random prime number no greater than the totient that is coprime with it
    
    func randE(phi: BInt) -> BInt {
        var e: BInt
        
        if Int(phi.dec) != nil{
            e = randPrime(num: Int(phi.dec)!)
        }
        else {
            e = BInt(Int(INT_MAX)) // the number was too big, just use INT_MAX as upper bound
        }
        while true {
            if gcd(phi, e) == 1 { //test if gcd is 1
                return e
            }
            e = (e+1 % phi) // to make sure e never exceeds phi
            if e <= 2 {
                e = 3
            }
        }
    }
    
    
    
    /*
    func randPrimeBInt(numBits: Int) -> BInt{
        var n = randomBInt(bits: numBits)
        while isPrime(n) == false {
            n = n - 1
        }
        return n
    }*/
    
    /*
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
    */
    
    
    //generate the inverse using Euclid's Extended algorithm
    func inverse(num: BInt, phi: BInt) -> BInt{
        var a = num, b = phi
        var x=BInt(0), y=BInt(1), x0 = BInt(1), y0 = BInt(0)
        var q: BInt
        var temp: BInt
        
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
