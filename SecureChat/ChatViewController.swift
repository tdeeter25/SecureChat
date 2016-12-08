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
    var messageKeys = [String]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var isEncrypted = false
    var isDecrypted = false
    
    
    var guessedCipher:BInt?

    @IBOutlet weak var segControl: UISegmentedControl!
   
    var currentChat: Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentChat.title)
        
        self.edgesForExtendedLayout = UIRectEdge()
        ref = FIRDatabase.database().reference()
        
        messageRef = ref.child("messages").child(self.currentChat.id)
        
        if let user = FIRAuth.auth()?.currentUser {
            senderId = user.uid
            senderDisplayName = user.displayName
        }
        else{
            senderId = "1234567"
            senderDisplayName = "John Cena"
        }
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
            self.messageKeys.removeAll()
            self.observeMessages()
            
        }
            
        else{
            isEncrypted = false
            isDecrypted = true
            
            let alert = UIAlertController(title: "Select Number",
                                          message: "Enter the Private Key to decrypt the message", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Done", style: .destructive, handler: { action in
                let text = ((alert.textFields?.first)! as UITextField).text
                self.guessedCipher = BInt(text!)
                
                self.messages.removeAll()
                self.messageKeys.removeAll()
                self.observeMessages()
            })
            alert.addAction(yesAction)
            
            //Add text field
            alert.addTextField { (textField) -> Void in
                textField.textColor = UIColor.black
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        self.collectionView.reloadData()
    }
    
    
    
    func encryptMessage(str: String) -> String {
        
        let byteArray = [UInt8](str.utf8)
        var encryptedString = ""
        for number in byteArray {
            let numAsInt = Int(number)
            let base = BInt(numAsInt)
            //Encrypt the number m by doing m ^ Public Key mod n
            let encrypt = mod_exp(base, self.currentChat.publicKey, self.currentChat.modulus)
            encryptedString.append(encrypt.dec)
            encryptedString.append(" ")
        }
        return encryptedString
    }
    
    func decryptMessage(str: String, cipher: BInt) -> String {
        
        let encryptData = str.components(separatedBy: " ")
        var decryptedString = ""
        
        for byte in encryptData {
            let num = BInt(byte)
            //decrypt the encrypted number e by doing e ^ Private Key mod n
            let decrypt = mod_exp(num, self.guessedCipher!, self.currentChat.modulus)
            let intByte = Int(decrypt.dec)
            let test = Character(UnicodeScalar(intByte!)!)
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
            "senderId": senderId,
            "senderName": self.senderDisplayName
        ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func addMessage(_ id: String, text: String, senderName: String){
        let message = JSQMessage(senderId: id, displayName: senderDisplayName, text: text)
        messages.append(message!)
    }
    
    // FIX THIS MAYBE
    fileprivate func observeMessages(){
        self.messageKeys.removeAll()
        let messagesQuery = messageRef.queryLimited(toLast: 50)

        messagesQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
                let dict = snapshot.value as? NSDictionary
            
                let id = dict?["senderId"] as! String
                let text = dict?["text"] as! String
                let senderName = dict?["senderName"] as! String
                
                if self.isDecrypted {
                    print("this called")
                    let decryptedString = self.decryptMessage(str: text, cipher: self.guessedCipher!)
                    if self.doesMessageExistYet(messageId: snapshot.key) == false{
                        print("adding message")
                        self.addMessage(id, text: decryptedString, senderName: senderName)
                    }
                }
                else {
                    print("Else getting called")
                    var tempStr = "" //a dummy message that will be displayed.
                    let textData = text.components(separatedBy: " ")
                    for value in textData {
                        var aValue = BInt(value)
                        aValue = (aValue % 92) + 32 //a padding on the value to make it a printable ascii character
                        let aValueInt = Int(aValue.dec)
                        let char = Character(UnicodeScalar(aValueInt!)!)
                        tempStr.append(char)
                    }
                    if self.doesMessageExistYet(messageId: snapshot.key) == false{
                        print("adding message")
                        self.addMessage(id, text: tempStr, senderName: senderName)
                    }
                }
            
            if !self.messageKeys.contains(snapshot.key){
                self.messageKeys.append(snapshot.key)
            }
            self.finishReceivingMessage()
        }
    }
    
    func doesMessageExistYet(messageId: String) -> Bool{
        print(messageId)
        print("blah")
        print(self.messageKeys)
        for messageKey in self.messageKeys{
            if messageKey == messageId{
                return true
            }
        }
        return false
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
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
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



