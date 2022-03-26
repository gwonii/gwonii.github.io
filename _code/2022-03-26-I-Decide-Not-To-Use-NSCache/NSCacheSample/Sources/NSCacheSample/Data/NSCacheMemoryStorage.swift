import Foundation

public final class NSCacheMemoryStorage: MemoryStorage {
    public typealias Object = UserInfo
    
    // ObjectType must be class
    private(set) var storage: NSCache<NSString, StorageObject<UserInfo>> = .init()
    private(set) public var customStorage: NSCache<CustomKey, StorageObject<UserInfo>> = .init()
    private(set) public var keys: Set<String> = .init()
    
    public init() { }
    
    public func store(value: UserInfo, forKey key: String) {
        storage.setObject(.init(value: value, key: key), forKey: key as NSString)
        keys.insert(key)
    }
    
    public func value(forKey key: String) -> UserInfo? {
        storage.object(forKey: key as NSString)?.value
    }
    
    public func remove(forKey key: String) {
        storage.removeObject(forKey: key as NSString)
        keys.remove(key)
    }
    
    public func removeAll() {
        storage.removeAllObjects()
        keys.removeAll()
    }
    
    public func store(value: UserInfo, key: CustomKey) {
        customStorage.setObject(.init(value: value, key: key.description), forKey: key)
    }
    
    public func value(forKey key: CustomKey) -> UserInfo? {
        customStorage.object(forKey: key)?.value
    }
}

public class StorageObject<T> {
    public let value: T
    public let key: String
    
    public init(value: T, key: String) {
        self.value = value
        self.key = key
    }
}

public class CustomKey: NSObject {
    public let id: UInt
    public let customDescription: String
    
    public init(id: UInt, customDescription: String) {
        self.id = id
        self.customDescription = customDescription
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CustomKey else {
            return false
        }
        return id == other.id && customDescription == other.customDescription
    }
    
    override public var hash: Int {
        return id.hashValue ^ customDescription.hashValue
    }
}
