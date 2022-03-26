import UIKit
import NSCacheSample

//var greeting = "Hello, playground"

//let memoryStorage: NSCacheM = NSCachM
let memoryStorage: NSCacheMemoryStorage = .init()

let userInfo1: UserInfo = .init(id: 01, userName: "userInfo1", commuteStatus: .on)
let userInfo2: UserInfo = .init(id: 02, userName: "userInfo2", commuteStatus: .on)
let userInfo3: UserInfo = .init(id: 03, userName: "userInfo3", commuteStatus: .on)
let userInfo4: UserInfo = .init(id: 04, userName: "userInfo4", commuteStatus: .on)


memoryStorage.store(value: userInfo1, key: .init(id: userInfo1.id, customDescription: ""))
memoryStorage.store(value: userInfo2, key: .init(id: userInfo1.id, customDescription: ""))
memoryStorage.store(value: userInfo1, key: .init(id: userInfo1.id, customDescription: "1"))
memoryStorage.store(value: userInfo2, key: .init(id: userInfo2.id, customDescription: ""))

print(memoryStorage.customStorage)
// --> ?

print(memoryStorage.value(forKey: .init(id: userInfo1.id, customDescription: "")))
// --> userInfo2

print(memoryStorage.value(forKey: .init(id: userInfo1.id, customDescription: "1")))
// --> userInfo1

print(memoryStorage.value(forKey: .init(id: userInfo2.id, customDescription: "")))
// --> userInfo2
