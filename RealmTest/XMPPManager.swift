//
//  XMPPManager.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/4.
//

import Foundation
import XMPPFramework
import RealmSwift

public protocol XMPPDelegate: AnyObject {
    func receivedMessage(message: XMPPMessage)
}

public enum XMPPManagerError: Error {
    case wrongUserJID
}

public class XMPPManager: NSObject {
    public var xmppStream: XMPPStream
    public let hostName: String
    public let userJID: XMPPJID
    public let hostPort: UInt16
    public let password: String
    public weak var delegate: XMPPDelegate?
    public weak var chatDelegate: ChatViewControllerDelegate?

    public init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String) throws {
        guard let userJID = XMPPJID(string: userJIDString) else {
            throw XMPPManagerError.wrongUserJID
        }
        self.hostName = hostName
        self.userJID = userJID
        self.hostPort = hostPort
        self.password = password

        // Stream Configuration
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        super.init()

        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }

    public func connect() {
        if !self.xmppStream.isDisconnected {
            return
        }
        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
        print(self.xmppStream.isConnected)
    }
    
    public func sendMessage(message: ChatMessage) {
        let message = message
        let senderJID = XMPPJID(string: "user5@localhost")
        let msg = XMPPMessage(type: "chat", to: senderJID)
        msg.addBody(message.messageBody)
        xmppStream.send(msg)
    }
}

extension XMPPManager: XMPPStreamDelegate {
    public func xmppStreamDidConnect(_ stream: XMPPStream) {
        print("Stream: Connected")
        try! stream.authenticate(withPassword: self.password)
    }
    
    public func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
        print(error)
    }
    
    public func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print(message)
        delegate?.receivedMessage(message: message)
        let chatMessage = ChatMessage(messageBody: message.body ?? "", message_Kind: .Text, timeStamp: Date(), senderId: message.fromStr, receiverId: message.toStr)
        chatDelegate?.insertMessage(chatMessage)
    }
    
    public func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        print(presence)
    }
    
    public func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
    }
}
