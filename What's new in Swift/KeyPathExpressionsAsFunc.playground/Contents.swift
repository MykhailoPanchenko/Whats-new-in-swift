import UIKit

struct Profile {
    var id: Int
    var publisherCount: Int
}

let profileA = Profile(id: 1, publisherCount: 248)
let profileB = Profile(id: 2, publisherCount: 12)
let profileC = Profile(id: 0, publisherCount: 134)
let profiles = [profileA, profileC, profileB]

let getID = \Profile.id

profileA[keyPath: getID]

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

