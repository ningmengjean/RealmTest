//
//  ChatMessage.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/12.
//

import Foundation
import RealmSwift

class ChatMessage: Object {
    @Persisted (primaryKey: true) var _id = UUID().uuidString
    @Persisted var messageBody = ""
    @Persisted var messageKind = MessageKind.Text
    @Persisted var timeStamp = Date()
    @Persisted var partition: String = "MessageRoom.id"
    @Persisted var senderID: String?
    @Persisted var receiverID: String?
  
    override static func primaryKey() -> String? {
           return "_id"
    }
    
    convenience init(messageBody: String, messageKind: MessageKind, timeStamp: Date, partition: String, senderID: String?, receiverID: String?) {
        self.init()
        self.messageBody = messageBody
        self.messageKind = messageKind
        self.timeStamp = timeStamp
        self.partition = partition
        self.senderID = senderID
        self.receiverID = receiverID
    }
}
