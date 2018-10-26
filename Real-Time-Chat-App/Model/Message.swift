//
//  Message.swift
//  Real-Time-Chat-App
//
//  Created by Zijia Zhai on 10/26/18.
//  Copyright © 2018 cognitiveAI. All rights reserved.
//

import UIKit
import Firebase

@objcMembers
class Message: NSObject {
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String?{
        
        if fromId == Auth.auth().currentUser?.uid{
            return toId
        }
        return fromId
    }
}
