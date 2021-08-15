//
//  ChatMessage.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/12.
//

import Foundation
import RealmSwift
import MessageKit
import Kingfisher

extension String: SenderType {
    public var senderId: String {
        return self
    }
    
    public var displayName: String {
        return self

    }
}

class ChatMessage: Object {
    @Persisted (primaryKey: true) var _id = UUID().uuidString
    @Persisted var messageBody = ""
    @Persisted var messageKind = Message_Kind.Text
    @Persisted var timeStamp = Date()
    @Persisted var partition: String = "MessageRoom.id"
    @Persisted var senderID: String?
    @Persisted var receiverID: String?
  
    override static func primaryKey() -> String? {
           return "_id"
    }
    
    convenience init(messageBody: String, messageKind: Message_Kind, timeStamp: Date, partition: String, senderID: String?, receiverID: String?) {
        self.init()
        self.messageBody = messageBody
        self.messageKind = messageKind
        self.timeStamp = timeStamp
        self.partition = partition
        self.senderID = senderID
        self.receiverID = receiverID
    }
}

extension ChatMessage: MessageType {
    var sender: SenderType {
        return senderID ?? ""
    }
    
    var messageId: String {
        return _id
    }
    
    var sentDate: Date {
        return timeStamp
    }
    
    var kind: MessageKind {
        switch messageKind {
        case .Text:
            return .text(messageBody)
        case .File:
            return .linkPreview(messageBody)
        case .Photo:
            return .photo(messageBody)
        
        }
        return .text(messageBody)
    }
}


extension String: MediaItem {
    
    func toMediaItem(completion: @escaping (Result<MediaItem, Error>->Void) {
        
        return nil
    }
    public var url: URL? {
        return URL(string: self)
    }
    
    public var image: UIImage? {
        return nil
    }
    
    public var placeholderImage: UIImage {
        return UIImage()
    }
    
    public var size: CGSize {
        return .zero
    }
}
