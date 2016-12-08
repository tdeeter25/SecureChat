//
//  Message.swift
//  SecureChat
//
//  Created by Tommy Deeter on 12/7/16.
//  Copyright © 2016 Tommy Deeter. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Message {
    
    let senderId: String!
    let text: String!
    let senderName: String!
    
    init(snapshot: FIRDataSnapshot){
        let dict = snapshot.value as? NSDictionary
        senderId = dict?["senderId"] as! String
        senderName = dict?["senderName"] as! String
        text = dict?["text"] as! String
    }
    
}

