//
//  ChatsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 06/06/1443 AH.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView


struct Sender : SenderType{
    var senderId: String

    var displayName: String
}

struct Message:MessageType{

    var messageId = ""

    var sender : SenderType

    var sentDate : Date

    var kind : MessageKind

   var text = ""
    init(dict:[String:Any],sender:Sender,kind: MessageKind,sentDate: Date) {
        if let messageId = dict["messageId"] as? String,
           let text = dict["text"] as? String{
            self.messageId = messageId
            self.text = text
        }
        self.sentDate = sentDate
        self.kind = .text(text)
        self.sender = sender
    }
}

class ChatsViewController: MessagesViewController {
    var messages: [Message] = []
    let currentUser = Auth.auth().currentUser
 //   let database = Firestore.firestore()
    var sender :Sender?
    var chat :Message?
    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        getData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

    func getData(){
        let db = Firestore.firestore()
        if let currentUser = currentUser {
            db.collection("users").document(currentUser.uid).getDocument { documentSnapshot, error in
                if let error = error{
                    print("err",error)
                }
                if let documentSnapshot = documentSnapshot,
                   let senderData = documentSnapshot.data(){
                    if let id = senderData["id"] as? String,let name = senderData["name"] as? String{
                        let sender = Sender(senderId: id, displayName: name)
                        
                        db.collection("chat").addSnapshotListener { querySnapshot, error in
                            if let error = error{
                                print("chat error",error)
                            }

                            if let querySnapshot = querySnapshot{
                                querySnapshot.documentChanges.forEach { documentChange in
                                    let message = documentChange.document.data()
                                    if let text = message["text"] as? String{
                                        let date = Date()
                                    switch documentChange.type{
                                    case .added:
                                        let messageChat = Message(dict: message, sender: sender, kind: .text(text), sentDate: date)
                                        self.chat = messageChat
                                        self.messages.append(messageChat)
                                        self.messagesCollectionView.reloadData()
                                        
                                        print(self.messages)
                                    case .modified:
                                        break
                                    case .removed:
                                        let userId = documentChange.document.documentID
                                        if let deleteIndex = self.messages.firstIndex(where: {$0.messageId == userId}){
                                            self.messages.remove(at: deleteIndex)
                                            self.messagesCollectionView.deleteItems(at: [IndexPath(row: deleteIndex, section: 0)])
                                            self.messagesCollectionView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
extension ChatsViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func currentSender() -> SenderType {
       
        return Sender(senderId: "me", displayName: "me")
        
    }

    func messageForItem(at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func messageTopLabelAttributedText(for message: MessageType,at indexPath: IndexPath) -> NSAttributedString? {

        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ])
    }
}

extension ChatsViewController: MessagesLayoutDelegate {
 
    func footerViewSize(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }


    func messageTopLabelHeight(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}
extension ChatsViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .systemYellow : .systemTeal
    }


    func shouldDisplayHeader(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }


    func configureAvatarView(_ avatarView: AvatarView,for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }

    func messageStyle(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}
extension ChatsViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        let messageId = "\(Firebase.UUID())"
        if let currentUser = currentUser?.uid{
           let date = Date()
            let chat:[String:Any] = [
                "messageId": messageId,
                "text": text,
                "sentDate":date,
                "sender":currentUser
            ]

            let database = Firestore.firestore()
            database.collection("chat").document(messageId).setData(chat){error in
                if let error = error{
                    print("chat error",error)
                }
            }
            // messages.append(Message(sender: currentSender(), messageId: currentUser, sentDate: Date(timeIntervalSinceReferenceDate: -123456789.0) , kind: .text(text)))
                        print(chat)
            //            messagesCollectionView.reloadData()

        }
        inputBar.inputTextView.text = ""
    }
}

//
//struct Member {
//  let name: String
//  let color: UIColor
//}
//
//struct Message {
//  let member: Member
//  let text: String
//  let messageId: String
//}
//extension Message: MessageType {
//  var sender: SenderType {
//
//    return Sender(senderId: member.name, displayName: member.name)
//  }
//
//  var sentDate: Date {
//    return Date()
//  }
//
//  var kind: MessageKind {
//    return .text(text)
//  }
//}
//class ChatsViewController: MessagesViewController {
//    var messages: [Message] = []
//    var member: Member!
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            member = Member(name: "bluemoon", color: .blue)
//            messageInputBar.delegate = self
//            messagesCollectionView.messagesDataSource = self
//            messagesCollectionView.messagesLayoutDelegate = self
//            messagesCollectionView.messagesDisplayDelegate = self
//
//        }
//}
//
//extension ChatsViewController: MessagesDataSource {
//
//
//  func numberOfSections(
//    in messagesCollectionView: MessagesCollectionView) -> Int {
//    return messages.count
//  }
//
//  func currentSender() -> SenderType {
//    return Sender(senderId: member.name, displayName: member.name)
//  }
//
//  func messageForItem(
//    at indexPath: IndexPath,
//    in messagesCollectionView: MessagesCollectionView) -> MessageType {
//
//    return messages[indexPath.section]
//  }
//
//  func messageTopLabelHeight(
//    for message: MessageType,
//    at indexPath: IndexPath,
//    in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//    return 12
//  }
//
//  func messageTopLabelAttributedText(
//    for message: MessageType,
//    at indexPath: IndexPath) -> NSAttributedString? {
//
//    return NSAttributedString(
//      string: message.sender.displayName,
//      attributes: [.font: UIFont.systemFont(ofSize: 12)])
//  }
//}
//extension ChatsViewController: MessagesLayoutDelegate {
//  func heightForLocation(message: MessageType,
//    at indexPath: IndexPath,
//    with maxWidth: CGFloat,
//    in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//    return 0
//  }
//}
//extension ChatsViewController: MessagesDisplayDelegate {
//  func configureAvatarView(
//    _ avatarView: AvatarView,
//    for message: MessageType,
//    at indexPath: IndexPath,
//    in messagesCollectionView: MessagesCollectionView) {
//
//    let message = messages[indexPath.section]
//    let color = message.member.color
//    avatarView.backgroundColor = color
//  }
//}
//extension ChatsViewController: InputBarAccessoryViewDelegate {
//  func messageInputBar(
//    _ inputBar: InputBarAccessoryView,
//    didPressSendButtonWith text: String) {
//
//    let newMessage = Message(
//      member: member,
//      text: text,
//      messageId: UUID().uuidString)
//
//    messages.append(newMessage)
//    inputBar.inputTextView.text = ""
//    messagesCollectionView.reloadData()
//    messagesCollectionView.scrollToBottom(animated: true)
//  }
//}
//
//struct Chat {
//var users: [String]
//var dictionary: [String: Any] {
//return ["users": users]
//   }
//}
//extension Chat {
//init?(dictionary: [String:Any]) {
//guard let chatUsers = dictionary["users"] as? [String] else {return nil}
//self.init(users: chatUsers)
//}
//}
//struct ChatUser: SenderType, Equatable {
//var senderId: String
//var displayName: String
//}
//struct Message {
//var id: String
//var content: String
//var created: Timestamp
//var senderID: String
//var senderName: String
//var dictionary: [String: Any] {
//return [
//"id": id,
//"content": content,
//"created": created,
//"senderID": senderID,
//"senderName":senderName]
//    }
//}
//extension Message {
//init?(dictionary: [String: Any]) {
//guard let id = dictionary["id"] as? String,
//let content = dictionary["content"] as? String,
//let created = dictionary["created"] as? Timestamp,
//let senderID = dictionary["senderID"] as? String,
//let senderName = dictionary["senderName"] as? String
//else {return nil}
//self.init(id: id, content: content, created: created, senderID: senderID, senderName:senderName)
//    }
//}
//extension Message: MessageType {
//var sender: SenderType {
//return ChatUser(senderId: senderID, displayName: senderName)
//}
//var messageId: String {
//return id
//}
//var sentDate: Date {
//return created.dateValue()
//}
//var kind: MessageKind {
//return .text(content)
//}
//}
//class ChatsViewController: MessagesViewController ,InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
//    var currentUser = Auth.auth().currentUser
//    private var docReference: DocumentReference?
//    var messages: [Message] = []
//    //I'll send the profile of user 2 from previous class from which //I'm navigating to chat view. So make sure you have the following //three variables information when you are on this class.
//    var user2Name: String?
//    var user2ImgUrl: String?
//    var user2UID: String?
//    func loadChat() {
//    //Fetch all the chats which has current user in it
//    let db = Firestore.firestore().collection("Chats").whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
//    db.getDocuments { (chatQuerySnap, error) in
//    if let error = error {
//    print("Error: \(error)")
//    return
//    } else {
//    //Count the no. of documents returned
//    guard let queryCount = chatQuerySnap?.documents.count else {
//    return
//    }
//    if queryCount == 0 {
//    //If documents count is zero that means there is no chat available and we need to create a new instance
//    self.createNewChat()
//    }
//    else if queryCount >= 1 {
//    //Chat(s) found for currentUser
//    for doc in chatQuerySnap!.documents {
//    let chat = Chat(dictionary: doc.data())
//    //Get the chat which has user2 id
//    if (chat?.users.contains(self.user2UID ?? "ID Not Found")) == true {
//    self.docReference = doc.reference
//    //fetch it's thread collection
//    doc.reference.collection("thread")
//    .order(by: "created", descending: false)
//    .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
//    if let error = error {
//    print("Error: \(error)")
//    return
//    } else {
//    self.messages.removeAll()
//    for message in threadQuery!.documents {
//    let msg = Message(dictionary: message.data())
//    self.messages.append(msg!)
//    print("Data: \(msg?.content ?? "No message found")")
//    }
//    //We'll edit viewDidload below which will solve the error
//    self.messagesCollectionView.reloadData()
//    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
//    }
//    })
//    return
//    } //end of if
//    } //end of for
//    self.createNewChat()
//    } else {
//    print("Let's hope this error never prints!")
//    }}}}
//
//    func createNewChat() {
//        let users = [self.currentUser?.uid, self.user2UID]
//    let data: [String: Any] = [
//    "users":users
//    ]
//    let db = Firestore.firestore().collection("Chats")
//    db.addDocument(data: data) { (error) in
//    if let error = error {
//    print("Unable to create chat! \(error)")
//    return
//    } else {
//    self.loadChat()
//    }
//    }
//    }
//
//    private func insertNewMessage(_ message: Message) {
//    //add the message to the messages array and reload it
//    messages.append(message)
//    messagesCollectionView.reloadData()
//    DispatchQueue.main.async {
//    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
//    }
//    }
//    private func save(_ message: Message) {
//    //Preparing the data as per our firestore collection
//    let data: [String: Any] = [
//    "content": message.content,
//    "created": message.created,
//    "id": message.id,
//    "senderID": message.senderID,
//    "senderName": message.senderName
//    ]
//    //Writing it to the thread using the saved document reference we saved in load chat function
//    docReference?.collection("thread").addDocument(data: data, completion: { (error) in
//    if let error = error {
//    print("Error Sending message: \(error)")
//    return
//    }
//    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
//    })
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//    //When use press send button this method is called.
//        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser!.uid, senderName: currentUser?.displayName ?? "hi")
//    //calling function to insert and save message
//    insertNewMessage(message)
//    save(message)
//    //clearing input field
//    inputBar.inputTextView.text = ""
//    messagesCollectionView.reloadData()
//    messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
//    // messagesCollectionView.scrollToBottom(animated: true)
//    }
//
//    func currentSender() -> SenderType {
//    return ChatUser(senderId: Auth.auth().currentUser!.uid, displayName: (Auth.auth().currentUser?.displayName)!)
//    // return Sender(id: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser?.displayName ?? "Name not found")
//    }
//    //This return the MessageType which we have defined to be text in Messages.swift
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//    return messages[indexPath.section]
//    }
//    //Return the total number of messages
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//    if messages.count == 0 {
//    print("There are no messages")
//    return 0
//    } else {
//    return messages.count
//    }
//    }
//
//    // We want the default avatar size. This method handles the size of the avatar of user that'll be displayed with message
//    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//    return .zero
//    }
//    //Explore this delegate to see more functions that you can implement but for the purpose of this tutorial I've just implemented one function.
//
//    //Background colors of the bubbles
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//    return isFromCurrentSender(message: message) ? .blue: .lightGray
//    }
//    //THis function shows the avatar
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//    //If it's current user show current user photo.
////    if message.sender.senderId == currentUser.uid {
////    SDWebImageManager.shared.loadImage(with: currentUser.photoURL, options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
////    avatarView.image = image
////    }
////    } else {
////    SDWebImageManager.shared.loadImage(with: URL(string: user2ImgUrl!), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
////    avatarView.image = image
////    }
////    }
//    }
//    //Styling the bubble to have a tail
//    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
//    return .bubbleTail(corner, .curved)
//    }
//    override func viewDidLoad() {
//
//    self.title = user2Name ?? "Chat"
//    navigationItem.largeTitleDisplayMode = .never
//    maintainPositionOnKeyboardFrameChanged = true
//    scrollsToLastItemOnKeyboardBeginsEditing = true
//    messageInputBar.inputTextView.tintColor = .systemBlue
//    messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
//    messageInputBar.delegate = self
//    messagesCollectionView.messagesDataSource = self
//    messagesCollectionView.messagesLayoutDelegate = self
//    messagesCollectionView.messagesDisplayDelegate = self
//    loadChat()
//    }
//
//}
