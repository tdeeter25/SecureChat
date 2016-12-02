//
//  ChatViewController.swift
//  SecureChat
//
//  Created by Tommy Deeter on 11/17/16.
//  Copyright © 2016 Tommy Deeter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import JSQMessagesViewController
import FirebaseAuth


class ChatViewController: JSQMessagesViewController {

    var ref:FIRDatabaseReference!
    var messageRef: FIRDatabaseReference!
    
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var isEncrypted = false
    var isDecrypted = false
    
    
    var guessedCipher:Int?

    @IBOutlet weak var segControl: UISegmentedControl!
    
    
    var currentChat: Chat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentChat.title)
        print(currentChat.cipher)
        
        self.edgesForExtendedLayout = UIRectEdge()
        ref = FIRDatabase.database().reference()
        
        messageRef = ref.child("messages").child(self.currentChat.id)
        /*
        if let user = FIRAuth.auth()?.currentUser {
            senderId = user.uid
            senderDisplayName = user.displayName
        }
        else{
            senderId = "1234567"
            senderDisplayName = "John Cena"
        }*/
        senderId = "1234567"
        senderDisplayName = "John Cena"
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        setupBubbles()
        observeMessages()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func changeMessageType(_ sender: AnyObject) {
        if(segControl.selectedSegmentIndex == 0){
            print("encrypted")
            isEncrypted = true
            isDecrypted = false
            
            
            self.messages.removeAll()
            self.observeMessages()
            self.collectionView!.reloadData()
        }
        else{
            isEncrypted = false
            isDecrypted = true
            
            let alert = UIAlertController(title: "Select Number",
                                          message: "Choose a number to decrypt the message", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Done", style: .destructive, handler: { action in
                let text = ((alert.textFields?.first)! as UITextField).text
                self.guessedCipher = Int(text!)
                
                self.messages.removeAll()
                self.observeMessages()
                self.collectionView!.reloadData()
            })
            alert.addAction(yesAction)
            
            //Add text field
            alert.addTextField { (textField) -> Void in
                textField.textColor = UIColor.black
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    
    func encryptMessage(str: String) -> String {
        
        var tempString = str

        var length = tempString.characters.count
        var stringData = [Int]()
        
        for i in 0...length-1{
            let index = tempString.index((tempString.startIndex), offsetBy: i)
            var aValue = tempString[index].asciiValue
            stringData.append(Int(aValue!))
        }
        
        var encryptedString = ""
        for number in stringData{
            //encrypt the number using RSA instead of Caesar shit
            var encryptedNumber = number - currentChat.cipher
            var test = Character(UnicodeScalar(encryptedNumber)!)
            encryptedString.append(test)
        }
        return encryptedString
    
    }
    
    func decryptMessage(str: String, cipher: Int) -> String {
        
        
        var encryptedString = str
        
        var enLength = encryptedString.characters.count
        var enStringData = [Int]()
        
        for i in 0...enLength-1{
            let index = encryptedString.index(encryptedString.startIndex, offsetBy: i)
            var aValue = encryptedString[index].asciiValue
            enStringData.append(Int(aValue!))
        }
        
        var decryptedString = ""
        for number in enStringData{
            //decrypt the number using RSA instead of Caesar shit
            let decryptedNumber = number + cipher
            var test = Character(UnicodeScalar(decryptedNumber)!)
            decryptedString.append(test)
        }
        
        return decryptedString
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        //things are going to need to go here in order to work
        //encrypt message here and we're good
        
        let itemRef = messageRef.childByAutoId()
        
        let encryptedString = encryptMessage(str: text)
        
        let messageItem:[String:Any] = [
            "text": encryptedString,
            "senderId": senderId
        ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        print(text)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func addMessage(_ id: String, text: String){
        let message = JSQMessage(senderId: id, displayName: senderDisplayName, text: text)
        messages.append(message!)
    }
    
    // FIX THIS MAYBE
    fileprivate func observeMessages(){
        
        let messagesQuery = messageRef.queryLimited(toLast: 50)
        
        messagesQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
            
            let dict = snapshot.value as? NSDictionary
            
            let id = dict?["senderId"] as! String
            let text = dict?["text"] as! String
            
            if self.isDecrypted {
                
                let decryptedString = self.decryptMessage(str: text, cipher: self.guessedCipher!)
                self.addMessage(id, text: decryptedString)
                
            }
            else {
                self.addMessage(id, text: text)
            }
            
            self.finishReceivingMessage()
            
        }
        
    }
    
    
    fileprivate func setupBubbles(){
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }
    
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        /*let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }*/
        return nil
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
    
}
extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
    public static func convertFromIntegerLiteral(value: IntegerLiteralType) -> Character {
        return Character(UnicodeScalar(value)!)
    }
}



