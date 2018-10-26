//
//  Message.swift
//  Real-Time-Chat-App
//
//  Created by Zijia Zhai on 10/26/18.
//  Copyright © 2018 cognitiveAI. All rights reserved.
//

import UIKit

@objcMembers
class Message: NSObject {
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
}
