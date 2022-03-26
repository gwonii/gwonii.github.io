import Foundation

public final class DictionaryMemoryStorage: MemoryStorage {
    public typealias Object = UserInfo
    
    private(set) var storage: [String: UserInfo] = [:]
    private(set) public  var keys: Set<String> = .init()
    
    public func store(value: UserInfo, forKey key: String) {
        storage.updateValue(value, forKey: key)
        keys.insert(key)
    }
    
    public func value(forKey key: String) -> UserInfo? {
        storage[key]
    }
    
    public func remove(forKey key: String) {
        storage.removeValue(forKey: key)
        keys.remove(key)
    }
    
    public func removeAll() {
        storage.removeAll()
        keys.removeAll()
    }
}
