import Foundation

public struct UserInfo {
    public let id: UInt
    public let userName: String
    public let commuteStatus: CommuteStatus
    
    public init(id: UInt, userName: String, commuteStatus: CommuteStatus) {
        self.id = id
        self.userName = userName
        self.commuteStatus = commuteStatus
    }
}

public enum CommuteStatus {
    case on
    case off
}

