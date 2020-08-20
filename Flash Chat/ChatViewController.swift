//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()

    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self

        
        
        //TODO: Set the tapGesture here: 3han lma a tap 3la el table view lazm y5tfi el kebord el bktb bih
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewtap))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here: 3shan a3ml damg for message cell design with table view design
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
    
        configurationTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here: 3sjan aml display ll custom message f el table view  kol index lh row and secation
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        
        
        // display data from firebase in the cell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            
            cell.avatarImageView.backgroundColor = UIColor.flatSkyBlueColorDark()
            cell.messageBackground.backgroundColor = UIColor.flatMint()
            
        }else {
            
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatRed()
            
           
        }
        
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here: kam 3dd el cell and what cell  el h3mlhom display at table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return messageArray.count
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewtap() {
        
        messageTextfield.endEditing(true)
    }
    
    
    
    //TODO: Declare configureTableView here:3shan tzbt el cell eza kan el message kbirh or el message so3'irh
    func configurationTableView () {
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
        
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:lma el user start typing in text field
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        // 3mlt animate 3shan yd mes7a ll keyboard bt3 el phone  yft7 f 5 swany
        UIView.animate(withDuration: 0.5){
            // edtlo el msa7a el hytrf3ha 7gm el keybord 258 + 7gm el textfield w el button
            self.heightConstraint.constant = 50
            // 3shan a3rdha f el view mn 3'r el code da msh hy7sl 7aga
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5){
            
            self.heightConstraint.constant = 308
            
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        // lma bdos send lazm el el keybord ynzl
                   messageTextfield.endEditing(true)
        
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
         // ana 3mlt reference to main datebase w creat gwha database so3'rh esmha " Messages "
        let messageDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        
        messageDB.childByAutoId().setValue(messageDictionary){
            (error, reference) in
            
            if error != nil{
                
                print(error!)
            }else {
                
                print("Message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
            
            
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages(){
        // 3mlt reference lldatebase el 3awz a3mlh save mn el firebase to my message model 3shan a3rdh f el chat
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
          let  snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["MessageBody"]!
            let sender  = snapshotValue["Sender"]!
            
            // we need to save and pass  our data to message model
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            // i pass data from messagebody and message.sender  to  el varible messagerarray fo2
            self.messageArray.append(message)
            
            self.configurationTableView()
            self.messageTableView.reloadData()
            
            
        }
        
        
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
            
          try Auth.auth().signOut()
            // after log out i hv to go to home page
            
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            
            print("error, there was a problem sigin out.")
        }
       
        
    }
    


}
