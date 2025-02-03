//
//  Created by lalawue on 2021/3/14.
//

import Foundation

/// Dictionary base AVL tree, you can sorted by dictionary key or value
/// - K: hashable key for dictionary
/// - P: comparable priority for AVL tree node
/// - V: value for dictionary
open class SortedDictionary<K:Hashable, P:Comparable, V> {
    
    public typealias KeyValue = AvlNode<K,P,V>

    /// O(1) get/set
    private var map = [K:KeyValue]()
    
    /// O(logN) get/set/iterate
    private var tree = AvlTree<K,P,V>()
    
    /// minimal
    open var first: KeyValue? {
        return tree.first()
    }

    /// maxima
    open var last: KeyValue? {
        return tree.last()
    }
    
    /// count
    open var count: Int {
        return tree.count()
    }
    
    /// user defined from (key, value) -> sorted keys
    private let sortedFn: (K, V) -> P
    
    public init(sorted: @escaping (K, V) -> P) {
        self.sortedFn = sorted
    }
    
    /// get / set value with Key
    open subscript(_ key: K) -> V? {
        get {
            return map[key]?.value
        }
        set {
            if let `newValue` = newValue {
                let npri = self.sortedFn(key, newValue)
                if let node = map[key] {
                    if node.priority == npri {
                        node.replace(value: newValue)
                    } else {
                        tree.remove(node: node)
                        tree.insert(key: key, value: newValue, priority: npri, freeNode: node)
                    }
                } else {
                    map[key] = tree.insert(key: key, value: newValue, priority: npri)
                }
            } else {
                if let node = map[key] {
                    tree.remove(node: node)
                    map[key] = nil
                }
            }
        }
    }
    
    /// get KeyValue base on priority, custom compareFn for matching
    /// - compareFn: return -1, 0, 1 for priority less then, equal to or greater than KeyValue
    open func match(priority: P, compareFn: (P, KeyValue) -> Int) -> KeyValue? {
        return tree.match(priority: priority, compareFn: compareFn)
    }

    /// forEach with index range 0 -> count -1
    /// - reversed: true from last, and index range count -1 -> 0
    /// - body() return true to stop looping, and index range [0, count -1] from 0 when reversed false
    open func forEach(reversed: Bool = false, _ body: (Int, KeyValue) throws -> Bool) rethrows {
        let it = makeIterator(reversed: reversed)
        let step = reversed ? -1 : 1
        var index = reversed ? tree.count() : -1
        while let n = it.next() {
            index += step
            if try body(index, n) {
                break
            }
        }
    }

    /// return prefix KeyValue, no more than count
    open func prefix(_ maxLength: Int = Int.max) -> [KeyValue] {
        var array = [AvlNode<K,P,V>]()
        if maxLength > 0 {
            let it = makeIterator()
            while let n = it.next() {
                array.append(n)
                if array.count >= maxLength {
                    break
                }
            }
        }
        return array
    }
    
    /// return prefix KeyValue, no more than count
    open func suffix(_ maxLength: Int = Int.max) -> [KeyValue] {
        var array = [AvlNode<K,P,V>]()
        if maxLength > 0 {
            let it = makeIterator(reversed: true)
            while let n = it.next() {
                array.append(n)
                if array.count >= maxLength {
                    break
                }
            }
        }
        return array
    }

    /// create iterator
    /// - reversed: true from last
    open func makeIterator(reversed: Bool = false) -> SortedDictionaryIterator<K,P,V> {
        return SortedDictionaryIterator(tree: self.tree, reversed: reversed)
    }
    
    /// remove all
    open func removeAll() {
        map = [K:AvlNode<K,P,V>]()
        tree.clear()
    }
}

/// sorted dictionary iterator
public class SortedDictionaryIterator<K:Hashable, P:Comparable, V>: IteratorProtocol {
    
    public typealias Element = SortedDictionary<K,P,V>.KeyValue
    
    private let _nextFn: () -> Element?

    fileprivate init(tree: AvlTree<K,P,V>, reversed: Bool = false) {
        if reversed {
            var node = tree.last()
            self._nextFn = {
                if let n = node {
                    node = n.prev()
                    return n
                }
                return nil
            }
        } else {
            var node = tree.first()        
            self._nextFn = {
                if let n = node {
                    node = n.next()
                    return n
                }
                return nil
            }
        }
    }

    @inline(__always)    
    public func next() -> Element? {
        return _nextFn()
    }
}
