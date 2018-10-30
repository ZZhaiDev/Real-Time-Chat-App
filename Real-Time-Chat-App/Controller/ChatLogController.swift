//
//  ChatLogController.swift
//  Real-Time-Chat-App
//
//  Created by Zijia Zhai on 10/17/18.
//  Copyright © 2018 cognitiveAI. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var messages = [Message]()
    
    var user: User?{
        didSet{
            navigationItem.title =  user?.name
            observeMessages()
        }
    }
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("Message").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else{
                    return
                }
                let message = Message()
                //potential of crashing if keys don't match
                message.setValuesForKeys(dictionary)
                if message.chatPartnerId() == self.user?.id{
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
                print(message.text)
            })
        }
    }
    
    lazy var inputTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Enter Message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()

    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        //collectionView 上边留间隙
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setUpInputComponents()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        //modify the bubbleView's width
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32
        return cell
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCatchWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get estimated height somehow????
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }
    
    func setUpInputComponents(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = UIColor.red
        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.translatesAutoresizingMaskIntoConstraints =  false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        let seperatorLinView = UIView()
        seperatorLinView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLinView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLinView)
        seperatorLinView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLinView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLinView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        seperatorLinView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleSend(){
        let ref = Database.database().reference().child("Message")
        let childRef = ref.childByAutoId()
        let toID = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["text": inputTextField.text!, "toId": toID, "fromId": fromId, "timeStamp": timestamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            self.inputTextField.text = nil
            
            guard let messageId = childRef.key else { return }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(messageId)
            userMessagesRef.setValue(1)
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID).child(messageId)
            recipientUserMessagesRef.setValue(1)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }


}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
