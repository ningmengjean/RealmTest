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

enum Message_Kind: String, PersistableEnum {
    case Text
    case Photo
    case Video
    case File
    case Emoji
}

public class ChatMessage: Object {
    @Persisted (primaryKey: true) var _id = UUID().uuidString
    @Persisted var messageBody = ""
    @Persisted var messageKind = Message_Kind.Text
    @Persisted var timeStamp = Date()
    @Persisted var partition: String = "MessageRoom.id"
    @Persisted var senderID: String?
    @Persisted var receiverID: String?
  
    public override static func primaryKey() -> String? {
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
    public var sender: SenderType {
        return senderID ?? ""
    }
    
    public var messageId: String {
        return _id
    }
    
    public var sentDate: Date {
        return timeStamp
    }
    
    public var kind: MessageKind {
        switch messageKind {
        case .Text:
            return .text(messageBody)
        case .File:
            return .linkPreview(messageBody as! LinkItem)
        case .Photo:
            return .photo(messageBody)
        case .Video:
            return .video(messageBody)
        case .Emoji:
            return .emoji(messageBody)
        }
    }
}


extension String: MediaItem {
    
    func toMediaItem(completion: @escaping (Result<MediaItem, Error>)->Void) {
        
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

extension String: SenderType {
    public var senderId: String {
        return self
    }
    
    public var displayName: String {
        return self
    }
}
