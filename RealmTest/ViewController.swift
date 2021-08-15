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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    var xmppManager: XMPPManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    var users = ["user4@localhost","user5@localhost"]
    
    private func messageRoomID(users: [String]) -> String {
        var id = String()
        var usersEmail = [String]()
        for user in users {
            usersEmail.append(user)
        }
        usersEmail.sort(by: >)
        for userEmail in usersEmail {
            id += userEmail
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
        let JIDText = cell?.textLabel?.text
        xmppManager = try! XMPPManager(hostName: "localhost", userJIDString: JIDText!, password: "pass")
        xmppManager.connect()
        xmppManager.sendMessage()
        let vc = ChatViewController(with: "user5@localhost", id: messageRoomID(users: users))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

