//
//  ChatInfoVC.swift
//  SecureChat
//
//  Created by Tommy Deeter on 12/8/16.
//  Copyright © 2016 Tommy Deeter. All rights reserved.
//

import UIKit

class ChatInfoVC: UIViewController {

    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var publicKeyValueLabel: UILabel!
    
    var currentChat: Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatNameLabel.text = currentChat.title
        self.publicKeyValueLabel.text = "(" + self.currentChat.publicKey.dec + ", " + self.currentChat.modulus.dec + ")"
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
