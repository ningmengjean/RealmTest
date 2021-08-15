//
//  XMPPManager.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/4.
//

import Foundation
import XMPPFramework

public enum XMPPManagerError: Error {
    case wrongUserJID
}

public class XMPPManager: NSObject {
    public var xmppStream: XMPPStream
    public let hostName: String
    public let userJID: XMPPJID
    public let hostPort: UInt16
    public let password: String

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
    
    public func sendMessage() {
        let message = "Yo!"
        let senderJID = XMPPJID(string: "user5@localhost")
        let msg = XMPPMessage(type: "chat", to: senderJID)
        
        msg.addBody(message)
        xmppStream.send(msg)
    }
    
    let dbService = DBService()
    var currentRoom: Room?
    var currentMessage = [ChatMessage]() {
        didSet {
            handleCurrentMessageChange()
        }
    }
    
    let maxCacheMessagesCount = 10
    
    private func handleCurrentMessageChange() {
        if currentMessage.count < maxCacheMessagesCount {
            return
        }
        flushMessages()
    }
    private func flushMessages() {
        currentRoom.messages.append(currentMessage)
        db.save(currentRoom)
        currentMessage.removeAll()
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
        cachedMessage.append(message)
    }
    
    public func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        print(presence)
    }
    
    public func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
        sendMessage()
    }
}
