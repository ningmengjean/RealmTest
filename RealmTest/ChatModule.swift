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
    
    public init(chatModuleDataSource: ChatModuleDataSource, roomId: String, receiverEmail: String) {
        self.roomId = roomId
        self.realmDataBase = RealmDataBase(senderEmail: chatModuleDataSource.localUserEmail, receiverEmail: receiverEmail, roomId: roomId)
        do { self.xmppManager = try XMPPManager(hostName: chatModuleDataSource.xmppHostName, userJIDString: chatModuleDataSource.xmppUserJIDString, password: chatModuleDataSource.xmppUserPassword)}
        catch let error {
            print("XMPPError:",error)
        }
        self.initVC?.xmppManager = self.xmppManager
        super.init()
    }
}


