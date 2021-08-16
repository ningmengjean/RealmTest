//
//  RealmDataBase.swift
//  RealmTest
//
//  Created by 朱晓瑾 on 2021/8/16.
//

import Foundation
import RealmSwift

class RealmDataBase: NSObject {
    let realmService = RealmService.shared
    var currentRoom: MessageRoom?
    let maxCacheMessagesCount = 10
    
    var currentMessage = [ChatMessage]() {
        didSet {
            handleCurrentMessageChange()
        }
    }
    
    private func handleCurrentMessageChange() {
        if currentMessage.count < maxCacheMessagesCount {
            return
        }
        flushMessages()
    }
    private func flushMessages() {
        guard let currentRoom = currentRoom else { return }
        currentRoom.messages.append(objectsIn: currentMessage)
        realmService.saveObject(currentRoom)
        currentMessage.removeAll()
    }
    
    public func getAllMessagesForSpeficMessageRoom(roomID: String) -> [ChatMessage] {
        let room = realmService.object(MessageRoom.self)?.filter("roomId == 'roomID'")
        let messages = room?.toArray(ofType: ChatMessage.self)
        return messages ?? []
    }
    
    public func creatNewMessageRoom(receiverId: String) -> String? {
        guard let senderId = UserDefaults.standard.value(forKey: "userName") as? String else {
            return nil
        }
        let user1 = User(userName: senderId, email: senderId, displayName: senderId, avatarImage: nil)
        let user2 = User(userName: receiverId, email: receiverId, displayName: receiverId, avatarImage: nil)
        let room = MessageRoom(displayName: receiverId, timeStamp: Date(), users: [user1, user2], messages: [])
        realmService.saveObject(room)
        return room.id
    }
}
