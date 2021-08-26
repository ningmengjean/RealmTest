//
//  ChatModule.swift
//  RealmTest
//
//  Created by 朱晓瑾 on 2021/8/17.
//

import Foundation
import XMPPFramework

public protocol ChatModuleListener: AnyObject {
    func didInitializeSuccess(vc: UIViewController)
}

public class ChatModule: NSObject {
    var realmDataBase: RealmDataBase?
    var xmppManager: XMPPManager?
    var roomId: String
    var initVC: ChatViewController?
    var senderEmail: String
    var receiverEmail: String
    public weak var listener: ChatModuleListener?
    
    public init(chatModuleDataSource: ChatModuleDataSource, roomId: String, receiverEmail: String) {
        self.roomId = roomId
        self.realmDataBase = RealmDataBase(senderEmail: chatModuleDataSource.localUserEmail, receiverEmail: receiverEmail, roomId: roomId)
        do { self.xmppManager = try XMPPManager(hostName: chatModuleDataSource.xmppHostName, userJIDString: chatModuleDataSource.xmppUserJIDString, password: chatModuleDataSource.xmppUserPassword)}
        catch let error {
            print("XMPPError:",error)
        }
        self.senderEmail = chatModuleDataSource.localUserEmail
        self.receiverEmail = receiverEmail
        super.init()
    }
    
    func start() {
        self.xmppManager?.connect()
        let vc = ChatViewController(senderEmail:self.senderEmail, roomId: self.roomId, receiverEmail: self.receiverEmail)
        vc.xmppManager = xmppManager
        listener?.didInitializeSuccess(vc: vc)
    }
}


