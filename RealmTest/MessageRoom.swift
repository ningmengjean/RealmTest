//
//  MessageRoom.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/12.
//

import Foundation
import RealmSwift

class MessageRoom: Object {
    @Persisted (primaryKey: true) var id = UUID().uuidString
    @Persisted var displayName = ""
    @Persisted var timeStamp = Date()
    @Persisted var roomId: String = ""
    @Persisted var users: List<User>
    @Persisted var messages: List<ChatMessage>
    
    convenience init(displayName: String, timeStamp: Date, users: [User], messages: [ChatMessage]) {
        self.init()
        self.displayName = displayName
        self.timeStamp = timeStamp
        self.users.append(objectsIn: users)
        self.messages.append(objectsIn: messages)
        self.roomId = messageRoomID(users: Array(users))
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private func messageRoomID(users: [User]) -> String {
        var id = String()
        var usersName = [String]()
        for user in users {
            usersName.append(user.userName)
        }
        usersName.sort(by: >)
        for userName in usersName {
            id += userName
        }
        return id
    }
}


