import Foundation

public protocol MemoryStorage {
    associatedtype Object
    var keys: Set<String> { get }
    func store(value: Object, forKey key: String)
    func value(forKey key: String) -> Object?
    func remove(forKey key: String)
    func removeAll()
}
