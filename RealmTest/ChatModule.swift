//
//  ChatModule.swift
//  RealmTest
//
//  Created by 朱晓瑾 on 2021/8/17.
//

import Foundation
import XMPPFramework

public class ChatModule: NSObject {
    var realmDataBase: RealmDataBase?
    var xmppManager: XMPPManager?
    var roomId: String
    var initVC: ChatViewController?
    
    public init(chatModuleDataSource: ChatModuleDataSource, roomId: String) {
        self.realmDataBase = RealmDataBase(senderId: chatModuleDataSource.localUserName, receiverId: chatModuleDataSource.receiverName, roomId: roomId)
        do { self.xmppManager = try XMPPManager(hostName: chatModuleDataSource.xmppHostName, userJIDString: chatModuleDataSource.xmppUserJIDString, password: chatModuleDataSource.xmppUserPassword)}
        catch let error {
            print("XMPPError:",error)
        }
        xmppManager?.delegate = self 
    }
}

extension ChatModule: XMPPDelegate {
    public func receivedMessage(message: XMPPMessage) {
        guard let messageBody = message.body else { return }
        let message = ChatMessage(messageBody: messageBody, messageKind: Message_Kind(rawValue: message.type!) ?? .Text, timeStamp: Date(),senderID: message.fromStr, receiverID: message.toStr)
        self.realmDataBase?.currentMessage.append(message)
    }
}
