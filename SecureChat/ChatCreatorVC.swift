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
            <<< IntRow("Integer") { $0.title = "Pick a Number" }

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
        let cipher = chatInfo["Integer"] as! Int
        
        chatsRef = ref.child("chats").childByAutoId()
        
        let dict: [String: AnyObject] = ["chatTitle": chatTitle as AnyObject,
                                         "cipher": cipher as AnyObject]
        chatsRef.setValue(dict)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
