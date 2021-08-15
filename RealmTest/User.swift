//
//  User.swift
//  vmailChat
//
//  Created by 朱晓瑾 on 2021/8/12.
//

import Foundation
import RealmSwift
import MessageKit

enum Presence: String {
    case onLine = "On-Line"
    case offLine = "Off-Line"
    case hidden = "Hidden"
    
    var asString: String {
        self.rawValue
    }
}

class User: Object {
    @Persisted (primaryKey: true) var _id = UUID().uuidString
    @Persisted var userName = ""
    @Persisted var email = ""
    @Persisted var present = "On-Line"
    @Persisted var displayName: String = ""
    @Persisted var avatarImage: String?
    
    convenience init(userName: String, email: String, displayName: String?, avatarImage: String?) {
        self.init()
        self.userName = userName
        self.email = email
        self.present = present
        self.displayName = displayName ?? ""
        self.avatarImage = avatarImage
    }
}


extension User: SenderType {
    var senderId: String {
        return userName
    }
}
