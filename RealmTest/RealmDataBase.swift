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
    var roomId: String
    var senderEmail: String
    var senderId: String
    var receiverEmail: String
    var receiverId: String
    
    init(senderEmail: String, receiverEmail: String, roomId: String) {
        self.senderEmail = senderEmail
        self.senderId = String(senderEmail.split(separator: "@")[0])
        self.receiverEmail = receiverEmail
        self.roomId = roomId
        self.receiverId = String(receiverEmail.split(separator: "@")[0])
    }
    
    let maxCacheMessagesCount = 10
    var currentMessage = [ChatMessage]() {
        didSet {
            handleCurrentMessageChange()
        }
    }
    var currentRoom: MessageRoom {
        let rooms = realmService.object(MessageRoom.self)
        let targetRoom = rooms?.filter("roomId = %@", self.roomId).first
        if targetRoom == nil {
            return self.creatNewMessageRoom(senderEmail: self.senderEmail, receiverEmail: self.receiverEmail)
        } else {
            return targetRoom!
        }
    }
    
    private func handleCurrentMessageChange() {
        if currentMessage.count < maxCacheMessagesCount {
            return
        }
        flushMessages()
    }
    
    public func flushMessages() {
        realmService.update {
            for message in self.currentMessage {
                self.currentRoom.messages.append(message)
            }
            return self.currentRoom
        }
        currentMessage.removeAll()
    }
    
    public func getAllMessagesForSpeficMessageRoom(roomId: String) -> [ChatMessage] {
        let room = realmService.object(MessageRoom.self)?.filter("roomId = %@", self.roomId).first
        if let room = room {
            let messages = Array(room.messages)
            return messages
        }
        return []
    }
    
    public func creatNewMessageRoom(senderEmail: String, receiverEmail: String) -> MessageRoom {
        let user1 = User(userName: seperateString(str: senderEmail), email: senderEmail, displayName: seperateString(str: senderEmail), avatarImage: nil)
        let user2 = User(userName: seperateString(str: receiverEmail), email: receiverEmail, displayName: seperateString(str: receiverEmail), avatarImage: nil)
        let room = MessageRoom(displayName: seperateString(str: receiverEmail), timeStamp: Date(), users: [user1, user2], messages: [])
        realmService.saveObject(room)
        return room
    }
    
    func seperateString(str: String) -> String {
        return String(str.split(separator: "@")[0])
    }
}

extension RealmDataBase: XMPPDelegate {
    public func receivedMessage(message: XMPPMessage) {
        guard let messageBody = message.body else { return }
        let message = ChatMessage(messageBody: messageBody, message_Kind: .Text, timeStamp: Date(),senderId: message.fromStr, receiverId: message.toStr)
        self.currentMessage.append(message)
    }
}


