import UIKit

struct Profile {
    var name: String
    var id: Int
    var publisherCount: Int
}

let getID: KeyPath<Profile, Int> = \.id

let profileA = Profile(name: "A", id: 1, publisherCount: 248)
let profileB = Profile(name: "B", id: 2, publisherCount: 12)
let profileC = Profile(name: "C", id: 0, publisherCount: 134)
profileA[keyPath: getID]


let profiles = [profileA, profileC, profileB]

profiles.map { $0[keyPath: \Profile.id] }
profiles.map(\.id)

//profiles.map(getID)

let getPublishersCount: (Profile) -> Int = \.publisherCount
profiles.map(getPublishersCount)

prefix operator ^

prefix func ^ <Root, Value>(keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
  return { root in root[keyPath: keyPath] }
}

profiles.map(^getID)

