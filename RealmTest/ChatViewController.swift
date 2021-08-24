  //
//  ChatViewController.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 6/10/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVFoundation
import AVKit
import Kingfisher
import CoreLocation

final class ChatViewController: MessagesViewController {

    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?

    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()

    public var receiverId: String
    public var roomId: String
    public var senderId: String
    public let realmService = RealmService.shared
    public var realDataBase: RealmDataBase?
    public var xmppManager: XMPPManager?

    public var messages = [MessageType]() {
        didSet {
            listenForMessages(roomId: self.roomId, shouldScrollToBottom: true)
        }
    }

    private var selfSender: Sender? {
        return Sender(photoURL: "",
                      senderId: self.senderId,
                      displayName: "Me")
    }

    init(with senderId: String, roomId: String, receiverId: String) {
        self.roomId = roomId
        self.receiverId = receiverId
        self.senderId = senderId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
    }

    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        } else {
            // Fallback on earlier versions
            button.setImage(UIImage(named: "paperclip"), for: .normal)
        }
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }

    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
            self?.presentVideoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {  _ in

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }

    private func presentPhotoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }

    private func presentVideoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "Where would you like to attach a video from?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }

    private func listenForMessages(roomId: String, shouldScrollToBottom: Bool) {
        let realmDataBase = RealmDataBase(senderId: self.senderId, receiverId: self.receiverId, roomId: self.roomId)
        let messages = Array(realmDataBase.currentRoom.messages)
        self.messages = messages
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadDataAndKeepOffset()
            if shouldScrollToBottom {
                self.messagesCollectionView.scrollToLastItem()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        listenForMessages(roomId: roomId, shouldScrollToBottom: true)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        guard let messageId = createMessageId(),
//            let name = self.title,
//            let selfSender = selfSender else {
//                return
//        }
//
//        if let image = info[.editedImage] as? UIImage, let imageData =  image.pngData() {
//            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
//
//            // Upload image
//
//            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
//                guard let strongSelf = self else {
//                    return
//                }
//
//                switch result {
//                case .success(let urlString):
//                    // Ready to send message
//                    print("Uploaded Message Photo: \(urlString)")
//
//                    guard let url = URL(string: urlString),
//                        let placeholder = UIImage(systemName: "plus") else {
//                            return
//                    }
//
//                    let media = Media(url: url,
//                                      image: nil,
//                                      placeholderImage: placeholder,
//                                      size: .zero)
//
//                    let message = Message(sender: selfSender,
//                                          messageId: messageId,
//                                          sentDate: Date(),
//                                          kind: .photo(media))
//
//                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
//
//                        if success {
//                            print("sent photo message")
//                        }
//                        else {
//                            print("failed to send photo message")
//                        }
//
//                    })
//
//                case .failure(let error):
//                    print("message photo upload error: \(error)")
//                }
//            })
//        }
//        else if let videoUrl = info[.mediaURL] as? URL {
//            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
//
//            // Upload Video
//
//            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
//                guard let strongSelf = self else {
//                    return
//                }
//
//                switch result {
//                case .success(let urlString):
//                    // Ready to send message
//                    print("Uploaded Message Video: \(urlString)")
//
//                    guard let url = URL(string: urlString),
//                        let placeholder = UIImage(systemName: "plus") else {
//                            return
//                    }
//
//                    let media = Media(url: url,
//                                      image: nil,
//                                      placeholderImage: placeholder,
//                                      size: .zero)
//
//                    let message = Message(sender: selfSender,
//                                          messageId: messageId,
//                                          sentDate: Date(),
//                                          kind: .video(media))
//
//                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
//
//                        if success {
//                            print("sent photo message")
//                        }
//                        else {
//                            print("failed to send photo message")
//                        }
//
//                    })
//
//                case .failure(let error):
//                    print("message photo upload error: \(error)")
//                }
//            })
//        }
//    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        // Send Message
        let newMessage = ChatMessage(messageBody: text, messageKind: .Text, timeStamp: Date(), senderID: self.senderId, receiverID: self.receiverId)
        xmppManager?.sendMessage(message: newMessage)
        self.realDataBase?.currentMessage.append(newMessage)
        self.listenForMessages(roomId: self.roomId, shouldScrollToBottom: true)
        self.messageInputBar.inputTextView.text = nil
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }

        fatalError("Self Sender is nil, email should be cached")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }

        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.kf.setImage(with: imageUrl)
        default:
            break
        }
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // our message that we've sent
            if #available(iOS 13.0, *) {
                return .link
            } else {
                // Fallback on earlier versions
                return UIColor.init(red: 0.0, green: 122.0, blue: 255.0, alpha: 1.0)
            }
        }

        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        } else {
            // Fallback on earlier versions
            return UIColor.init(red: 242.0, green: 242.0, blue: 247.0, alpha: 1.0)
        }
    }

//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//
//        let sender = message.sender
//
//        if sender.senderId == selfSender?.senderId {
//            // show our image
//            if let currentUserImageURL = self.senderPhotoURL {
//                avatarView.kf.setImage(with: currentUserImageURL)
//            }
//            else {
//                // images/safeemail_profile_picture.png
//
//                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
//                    return
//                }
//
//                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//                let path = "images/\(safeEmail)_profile_picture.png"
//
//                // fetch url
//                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
//                    switch result {
//                    case .success(let url):
//                        self?.senderPhotoURL = url
//                        DispatchQueue.main.async {
//                            avatarView.sd_setImage(with: url, completed: nil)
//                        }
//                    case .failure(let error):
//                        print("\(error)")
//                    }
//                })
//            }
//        }
//        else {
//            // other user image
//            if let otherUsrePHotoURL = self.otherUserPhotoURL {
//                avatarView.kf.setImage(with: otherUsrePHotoURL)
//            }
//            else {
//                // fetch url
//                let email = self.receiverId
//
//                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//                let path = "images/\(safeEmail)_profile_picture.png"
//
//                // fetch url
//                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
//                    switch result {
//                    case .success(let url):
//                        self?.otherUserPhotoURL = url
//                        DispatchQueue.main.async {
//                            avatarView.sd_setImage(with: url, completed: nil)
//                        }
//                    case .failure(let error):
//                        print("\(error)")
//                    }
//                })
//            }
//        }
//
//    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        
        default:
            break
        }
    }

    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }

            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}
