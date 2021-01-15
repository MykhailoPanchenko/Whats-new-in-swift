import UIKit

class Alert{
    var resumeAction: ()->()
    var detailAction: ()->()
    var cancelAction: ()->()
    var name: String
    
    init(with name: String, resume: @escaping ()->(), detail: @escaping ()->(), cancel: @escaping ()->()) {
        resumeAction = resume
        detailAction = detail
        cancelAction = cancel
        self.name = name
    }
}

let oldAlert = Alert(with: "Old", resume: {
    print("resumeOld")
}, detail: {
    print("resumeOld")
}) {
    print("cancelOld")
}

let alert = Alert(with: "Hey") {
    print("resume")
} detail: {
    print("detail")
} cancel: {
    print("cancel")
}

alert.resumeAction()

func when<T>(
    _ condition: @autoclosure () -> Bool,
    then: () -> T,
    `else`: (() -> T)? = nil
) -> T? {
    return condition() ? then() : `else`?()
}

when(12<5) {
    print("true")
} else: {
    print("false")
}

when(true) {
    print("true")
}

