//
//  ChatListsVC.swift
//  SecureChat
//
//  Created by Tommy Deeter on 11/20/16.
//  Copyright © 2016 Tommy Deeter. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatListsVC: UITableViewController {

    var chats = ["Chat 1", "Chat 2", "Chat 3", "Chat 4"]
    var chatList = [Chat]()
    
    var ref: FIRDatabaseReference!
    var chatsRef: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        chatsRef = ref.child("chats")
        
        
        observeChats()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func observeChats(){
        refHandle = chatsRef.observe(FIRDataEventType.value, with: { (snapshot) in
            self.chatList.removeAll()
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for item in snapshot.children {
                
                let chat = Chat(snapshot: item as! FIRDataSnapshot)
                self.chatList.append(chat)
            }
            self.tableView.reloadData()
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let chat = chatList[indexPath.row]
        
        cell.textLabel?.text = chat.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(chatList[indexPath.row].title)
        self.performSegue(withIdentifier: "selectedChat", sender: chatList[indexPath.row])
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "selectedChat" {
            let dvc = segue.destination as! ChatViewController
            dvc.currentChat = sender as? Chat
        }
        
    }


}
