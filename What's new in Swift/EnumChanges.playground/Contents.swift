import UIKit

enum GameMode: Comparable{
    case easy
    case medium
    case hard
    case veryHard
}

let bossMode = GameMode.hard
let heroMode = GameMode.medium
let chickenMode = GameMode.easy

func check(mode: GameMode){
    if mode <= heroMode{
        print("Hero can do it")
    }else{
        print("It will be to hard for hero")
    }
}

check(mode: bossMode)
check(mode: chickenMode)


protocol Message {
    static var emptyMessage: Self {get}
    static func createImageMessage(_ image: String) -> Self
    var title: String {get}
}

enum PrivateMessage: Message{
    var title: String{
        get{
            switch self {
            case .emptyMessage:
                return ""
            case .createImageMessage(let image):
                return "Title with \(image)"
            }
        }
    }
    
    case emptyMessage
    case createImageMessage(_ image: String)
}

struct PublicMessage: Message {
    var title: String{
        get {
            return ""
        }
    }
    
    static var emptyMessage: PublicMessage {
        get{
            PublicMessage()
        }
    }
    
    static func createImageMessage(_ image: String) -> Self {
        return PublicMessage()
    }
    
    
}
let emptyMessage = PrivateMessage.emptyMessage
let imageMessage = PrivateMessage.createImageMessage("404")

emptyMessage.title
imageMessage.title
