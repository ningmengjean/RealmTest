//
//  ChatDataSourceModule.swift
//  RealmTest
//
//  Created by 朱晓瑾 on 2021/8/17.
//

import Foundation

public protocol ChatModuleDataSource {
    var xmppHostName: String { get }
    var xmppUserJIDString: String { get }
    var xmppUserPassword: String { get }
    var localUserName: String { get }
    var receiverName: String { get }
}
