//
//  MessageThreadDetailViewController.swift
//  Message Board
//
//  Created by Kenneth Jones on 10/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class MessageThreadDetailViewController: MessagesViewController {
    
    var messageThread: MessageThread?
    var messageThreadController: MessageThreadController?
    
    private lazy var formatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .medium
        result.timeStyle = .medium
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

extension MessageThreadDetailViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        if let currentUser = messageThreadController?.currentUser {
            return currentUser
        } else {
            return Sender(senderId: "foo", displayName: "bar")
        }
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageThread?.messages.count ?? 0
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let message = messageThread?.messages[indexPath.item] else {
            fatalError("No message found in thread.")
        }
        return message
    }
    
    // -------------------------------
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
        return NSAttributedString(string: name, attributes: attrs)
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]
        return NSAttributedString(string: dateString, attributes: attrs)
    }
}

extension MessageThreadDetailViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension MessageThreadDetailViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemTeal : .lightGray
    }
    
    // Adds tails onto the messages
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // Sets the senders first initial to the avatar circle view
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let initials = String(message.sender.displayName.first ?? Character(""))
        let avatar = Avatar(image: nil, initials: initials)
        avatarView.set(avatar: avatar)
    }
}

extension MessageThreadDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let messageThread = messageThread,
              let currentSender = currentSender() as? Sender else { return }
        
        messageThreadController?.createMessage(in: messageThread, withText: text, sender: currentSender, completion: {
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
            }
        })
    }
}
