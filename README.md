# Whats new in swift
## 1. Multiple Trailing Closures [SE-0279](https://github.com/apple/swift-evolution/blob/main/proposals/0279-multiple-trailing-closures.md)

For example, we have initialization of class Alert like that:
```swift 
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
```

We used to use this init:
```swift
let oldAlert = Alert(with: "Old", resume: {
    print("resumeOld")
}, detail: {
    print("resumeOld")
}) {
    print("cancelOld")
}
```

So in this example we use trailing closure
```swift
{
    print("cancelOld")
}
```
and you really don't now what exactly closure it is
In swift 5.3 you can do it this way:
```swift
let alert = Alert(with: "Hey") {
    print("resume")
} detail: {
    print("detail")
} cancel: {
    print("cancel")
}
```
Also Apple provides new "API design: trailing closure syntax" that's meaning you need to 
name your function that use multiple trailing closure as first trailing closure like:
```swift
UIView.animate(withDuration: 0.3) {
  self.view.alpha = 0
} completion: { _ in
  self.view.removeFromSuperview()
}
```
The current type-checking rule for trailing closures performs a limited backwards scan through the parameters looking for a parameter that is compatible with a trailing closure. 
The proposed type-checking rule builds on this while seeking to degenerate to the old behavior when there are no labeled trailing closures.
This is done by performing a backwards scan through the parameters to bind all the labeled trailing closures to parameters using label-matching, 
then doing the current limited scan for the unlabeled trailing closure starting from the last labeled parameter that was matched.

For example, given this function:
```swift
func when<T>(
    _ condition: @autoclosure () -> Bool,
    then: () -> T,
    `else`: (() -> T)? = nil
) -> T? {
    return condition() ? then() : `else`?()
}
```
The following call using the new syntax:
```swift
when(12<5) {
    print("true")
} else: {
    print("false")
}

when(true) {
    print("true")
}
```
## 2. Enum Changes [SE-0266](https://github.com/apple/swift-evolution/blob/main/proposals/0266-synthesized-comparable-for-enumerations.md) and [SE-0280](https://github.com/apple/swift-evolution/blob/main/proposals/0280-enum-cases-as-protocol-witnesses.md)
### - Synthesized Comparable conformance for enum types [SE-0266](https://github.com/apple/swift-evolution/blob/main/proposals/0266-synthesized-comparable-for-enumerations.md)
For example, we have a game mode for rpg:
```swift 
enum GameMode {
    case easy
    case medium
    case hard
    case veryHard
}
```
And now if game mode for a special character is medium that is meaning he beats easy and medium
to do it without 
extra lines of code you can implement Comparable protocol:
```swift
enum GameMode: Comparable {
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

check(mode: bossMode) //It will be to hard for hero
check(mode: chickenMode) //Hero can do it
```
### - Enum cases as protocol witnesses [SE-0280](https://github.com/apple/swift-evolution/blob/main/proposals/0280-enum-cases-as-protocol-witnesses.md)
Enum now can implement static functions and proparties as cases:
```swift
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
```
For example, if we use struct:
```swift
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
```
## 3. Key Path Expressions as Functions [SE-0249](https://github.com/apple/swift-evolution/blob/main/proposals/0249-key-path-literal-function-expressions.md)

One-off closures that traverse from a root type to a value are common in Swift. Consider the following Profile struct:
```swift
struct Profile {
    var id: Int
    var publisherCount: Int
}
```
Applying map allows the following code to gather an array of id's from a source user array:
```swift
users.map { $0.id }
```
These ad hoc closures are short and sweet but Swift already has a shorter and sweeter syntax that can describe this: key paths. The Swift forum has [previously proposed](https://forums.swift.org/t/pitch-support-for-map-and-flatmap-with-smart-key-paths/6073) adding `map`, `flatMap`, and `compactMap` overloads that accept key paths as input. Popular libraries [define overloads](https://github.com/ReactiveCocoa/ReactiveSwift/search?utf8=✓&q=KeyPath&type=) of their own. Adding an overload per function, though, is a losing battle.
Swift should allow `\Root.value` key path expressions wherever it allows `(Root) -> Value` functions:

```swift
users.map(\.id)
```
As implemented in [apple/swift#19448](https://github.com/apple/swift/pull/19448), occurrences of `\Root.value` are implicitly converted to key path applications of `{ $0[keyPath: \Root.value] }` wherever `(Root) -> Value` functions are expected. For example:

``` swift
profiles.map(\.id)
```

Is equivalent to:

``` swift
profiles.map { $0[keyPath: \Profile.id] }
```

The implementation is limited to key path literal expressions (for now), which means the following is not allowed:

``` swift
let getID = \Profile.id // KeyPath<Profile, Int>
profiles.map(getID)
```

> 🛑 Cannot convert value of type 'WritableKeyPath<Profile, Int>' to expected argument type '(Profile) throws -> Int'

But the following is:

``` swift
let f1: (Profile) -> Int = \Profile.id
users.map(f1)

let f2: (Profile) -> String = \.id
users.map(f2)

let f3 = \Profile.id as (Profile) -> String
users.map(f3)

let f4 = \.id as (Profile) -> String
users.map(f4)
```
The `^` prefix operator offers a common third party solution for many users:

```Swift
prefix operator ^

prefix func ^ <Root, Value>(keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
  return { root in root[keyPath: keyPath] }
}

profiles.map(^\.id)
```
