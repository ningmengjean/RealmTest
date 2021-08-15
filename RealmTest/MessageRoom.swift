//
//  MessageRoom.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/12.
//

import Foundation
import RealmSwift

enum Message_Kind: String, PersistableEnum {
    case Text
    case Photo
    case Video
    case File
    case Emoji
}

class MessageRoom: Object {
    @Persisted (primaryKey: true) var id = ""
    @Persisted var displayName = ""
    @Persisted var timeStamp = Date()
    @Persisted var users: List<User>
    @Persisted var messages: List<ChatMessage>
    @Persisted var roomId: String = ""
    
    convenience init(displayName: String, timeStamp: Date, users: [User], messages: [ChatMessage]) {
        self.init()
        self.id = messageRoomID(users: users)
        self.displayName = displayName
        self.timeStamp = timeStamp
        self.users.append(objectsIn: users)
        self.messages.append(objectsIn: messages)
        self.roomId = messageRoomID(users: Array(users))
    }
    
    private func messageRoomID(users: [User]) -> String {
        var id = String()
        var usersEmail = [String]()
        for user in users {
            usersEmail.append(user.email)
        }
        usersEmail.sort(by: >)
        for userEmail in usersEmail {
            id += "."
            id += userEmail
        }
        return id
    }
}


