//
//  MockMessages.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/12.
//

import Foundation
import RealmSwift

class MockMessages: NSObject {
    let user4 = User(userName: "user4", email: "user4@localhost", displayName: "user4", avatarImage: nil)
    let user5 = User(userName: "user5", email: "user5@localhost", displayName: "user5", avatarImage: nil)
    lazy var messageRoom1: MessageRoom = {
       return MessageRoom(displayName: "user5",
                          timeStamp: Date(),
                          users: [user4,user5],
                          messages: [chatMessage1,chatMessage2])
    }()
    let chatMessage1 = ChatMessage(messageBody: "hello", messageKind: .Text, timeStamp: Date(), partition: "user5@localhost.user4@localhost", senderID: User(userName: "user4", email: "user4@localhost", displayName: "user4", avatarImage: nil).userName, receiverID: nil)
    let chatMessage2 = ChatMessage(messageBody: "hellohello", messageKind: .Text, timeStamp: Date(), partition: "user5@localhost.user4@localhost", senderID: nil, receiverID: User(userName: "user5", email: "user5@localhost", displayName: "user5", avatarImage: nil).userName)
    func saveData() {
        RealmService.shared.saveObject(user4)
        RealmService.shared.saveObject(user5)
        RealmService.shared.saveObject(messageRoom1)
        RealmService.shared.saveObject(chatMessage1)
        RealmService.shared.saveObject(chatMessage1)
    }
    
//    private func generateRandomMessage(roomId: String) -> ChatMessage {
//        let ids = roomId.split(separator: ".")
//        let user1 = ids.first ?? ""
//        let user2 = ids.last ?? ""
//
//    }
    
    private func messageRoomID(users: [User]) -> String {
        var id = String()
        var usersEmail = [String]()
        for user in users {
            usersEmail.append(user.email)
        }
        usersEmail.sort(by: >)
        for userEmail in usersEmail {
            id += userEmail
        }
        return id
    }
}

