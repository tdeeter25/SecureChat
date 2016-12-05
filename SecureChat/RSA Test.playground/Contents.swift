//: Playground - noun: a place where people can play

import UIKit
import Foundation

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
extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.characters.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end > 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start > 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.characters.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return self[startIndex ..< endIndex]
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}
extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
    public static func convertFromIntegerLiteral(value: IntegerLiteralType) -> Character {
        return Character(UnicodeScalar(value)!)
    }
}


var p1 = 19
var p2 = 31

var primeProduct = p1 * p2

var totient = (p1-1) * (p2-1)

func isPrime(num: Int) -> Bool {
    var j = Int(sqrt(Double(num)))
    
    for i in 2...j{
        if(num % i == 0){
            return false
        }
    }
    return true
}

print(isPrime(num: 100))

//var testString = "This is some basic shit but it's working real good isn't it"

//var char = testString[testString.startIndex]

/*
var length = testString.characters.count
var stringData = [Int]()

for i in 0...length-1{
    let index = testString.index(testString.startIndex, offsetBy: i)
    var aValue = testString[index].asciiValue
    stringData.append(Int(aValue!))
}

var encryptedString = ""
for number in stringData{
    //encrypt the number using RSA instead of Caesar shit
    var encryptedNumber = number + 5
    var test = Character(UnicodeScalar(encryptedNumber)!)
    encryptedString.append(test)
}
print("Encrypted String")
print(encryptedString)


var enLength = encryptedString.characters.count
var enStringData = [Int]()

for i in 0...length-1{
    let index = encryptedString.index(encryptedString.startIndex, offsetBy: i)
    var aValue = encryptedString[index].asciiValue
    enStringData.append(Int(aValue!))
}

var decryptedString = ""
for number in enStringData{
    //decrypt the number using RSA instead of Caesar shit
    var decryptedNumber = number - 5
    var test = Character(UnicodeScalar(decryptedNumber)!)
    decryptedString.append(test)
}

print("Decrypted String")
print(decryptedString)


var str = "This is a test"
var byteArray = [UInt8](str.utf8)
print(byteArray)
let data = Data(bytes: byteArray)
var testStr = String(bytes: data, encoding: String.Encoding.utf8)
print(testStr)

var numStr = ""
for byte in data{
    print(byte)
    numStr.append(String(byte))
}
print(numStr)
*/


var str = "this is a test"

//Turn into an array of bytes
let byteArray = [UInt8](str.utf8)
let data = Data(bytes: byteArray)

//Make a string representation of these bytes
var numStr = ""
for byte in data{
    var hexByte = String(format: "%2X", Int(byte))
    numStr.append(hexByte)
}
let count = numStr.characters.count
var hexValues = [String]()
var decryptString = ""

for i in stride(from: 0, to: count, by: 2){
    var hexValue = numStr.substring(from: i, to: i+1)
    
    let value = UInt8(hexValue, radix: 16)
    
    var test = Character(UnicodeScalar(value!))
    decryptString.append(test)
}

print(decryptString)

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



//generate random prime number

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


var test = randE(phi: 120)
print(gcd(test, 120))


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

print(inverse(num: 7, phi: 120))













