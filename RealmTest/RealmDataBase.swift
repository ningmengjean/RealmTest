//
//  RealmDataBase.swift
//  RealmTest
//
//  Created by 朱晓瑾 on 2021/8/16.
//

import Foundation
import RealmSwift
import XMPPFramework

class RealmDataBase: NSObject {
    let realmService = RealmService.shared
    var currentRoom: MessageRoom?
    var senderId: String
    var receiverId: String
    init(senderId: String, receiverId: String, roomId: String) {
        self.senderId = senderId
        self.receiverId = receiverId
        let room = realmService.object(MessageRoom.self)?.filter("roomId = %@", roomId).first
        self.currentRoom = room
    }
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
        let room = realmService.object(MessageRoom.self)?.filter("roomId = @%", roomID)[0]
        if let room = room {
            let messages = Array(room.messages)
            return messages
        }
        return []
    }
    
    public func creatNewMessageRoom(senderId: String, receiverId: String) {
        let user1 = User(userName: senderId, email: senderId, displayName: senderId, avatarImage: nil)
        let user2 = User(userName: receiverId, email: receiverId, displayName: receiverId, avatarImage: nil)
        let room = MessageRoom(displayName: receiverId, timeStamp: Date(), users: [user1, user2], messages: [])
        if realmService.object(MessageRoom.self)?.filter("roomId = %@", room.roomId)[0] == nil {
            realmService.saveObject(room)
        }
    }
}

extension RealmDataBase: XMPPDelegate {
    public func receivedMessage(message: XMPPMessage) {
        guard let messageBody = message.body else { return }
        let message = ChatMessage(messageBody: messageBody, messageKind: Message_Kind(rawValue: message.type!) ?? .Text, timeStamp: Date(),senderID: message.fromStr, receiverID: message.toStr)
        self.currentMessage.append(message)
    }
}


