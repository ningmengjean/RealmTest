//
//  ViewController.swift
//  RealmTest
//
//  Created by 朱晓瑾 on 2021/8/13.
//

//
//  ViewController.swift
//  RealmTest
//
//  Created by 朱晓瑾 on 2021/8/13.
//

import UIKit

class OCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    var chatModule: ChatModule?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    var users = ["user4@localhost","user5@localhost","user5@localhost","user5@localhost","user5@localhost","user5@localhost"]
    var receiverEmail = String()
    private func messageRoomID(users: [String]) -> String {
        var id = String()
        var usersName = [String]()
        for user in users {
            usersName.append(user)
        }
        usersName.sort(by: >)
        for userName in usersName {
            id += userName
        }
        return id
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) 
        guard let cellText = cell?.textLabel?.text else { return }
        self.receiverEmail = cellText
        let localUserName = seperateString(str: self.localUserEmail)
        let receiverName = seperateString(str: self.receiverEmail)
        self.chatModule = ChatModule(chatModuleDataSource: self, roomId: messageRoomID(users: [localUserName, receiverName]), receiverEmail: self.receiverEmail)
        chatModule?.listener = self
        self.chatModule?.start()
    }
    
    func seperateString(str: String) -> String {
        return String(str.split(separator: "@")[0])
    }
}

extension OCViewController: ChatModuleDataSource {
    var xmppHostName: String {
        return "localhost"
    }
    
    var xmppUserJIDString: String {
        return "user4@localhost"
    }
    
    var xmppUserPassword: String {
        return "pass"
    }
    
    var localUserEmail: String {
        return "user4@localhost"
    }
}

extension OCViewController: ChatModuleListener{
    func didInitializeSuccess(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

