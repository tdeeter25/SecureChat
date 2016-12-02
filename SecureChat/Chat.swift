//
//  Chat.swift
//  SecureChat
//
//  Created by Tommy Deeter on 12/1/16.
//  Copyright © 2016 Tommy Deeter. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Chat {
    
    let id: String!
    let title: String!
    let cipher: Int!
    
    init(snapshot: FIRDataSnapshot){
        let dict = snapshot.value as? NSDictionary
        id = snapshot.key
        title = dict?["chatTitle"] as! String
        cipher = dict?["cipher"] as! Int
    }
    
    
}
