//
//  Created by lalawue on 2021/3/14.
//

import Foundation

/// Dictionary base AVL tree, you can sorted by dictionary key or value
/// - K: hashable key for dictionary
/// - P: comparable priority for AVL tree node
/// - V:  value for dictionary
open class SortedDictionary<K:Hashable, P:Comparable, V> {

    /// O(1) get/set
    private var map = [K:AvlNode<K,P,V>]()
    
    /// O(logN) get/set/iterate
    private var tree = AvlTree<K,P,V>()
    
    /// minimal value
    open var miniOne: AvlNode<K,P,V>? {
        return tree.first()
    }

    /// maxima value
    open var maxOne: AvlNode<K,P,V>? {
        return tree.last()
    }
    
    /// count
    open var count: Int {
        return tree.count()
    }
    
    /// user defined from (key, value) -> sorted keys
    let priorityFn: (K,V) -> P
    
    public init(sorted: @escaping (K,V) -> P) {
        self.priorityFn = sorted
    }
    
    /// get/set
    open subscript(_ key: K) -> V? {
        get {
            if let node = map[key] {
                return node.value
            }
            return nil
        }
        set {
            if let `newValue` = newValue {
                if let node = map[key] {
                    node.replace(value: newValue)
                } else {
                    let node = tree.insert(key: key, value: newValue, priority: priorityFn(key, newValue), replace: true)
                    map[key] = node
                }
            } else {
                if let node = map[key] {
                    tree.remove(node: node)
                    map[key] = nil
                }
            }
        }
    }

    /// forEach with index from '0'
    open func forEach(reversed: Bool = false, _ body: (Int, K, V, inout Bool) throws -> Void) rethrows {
        var index = -1
        var next = reversed ? tree.last() : tree.first()
        var stop = false
        while let n = next {
            index += 1
            try body(index, n.key, n.value!, &stop)
            if stop {
                break
            }
            next = reversed ? n.prev() : n.next()
        }
    }

    /// return prefix keys, no more than count
    open func prefixKeys(reversed: Bool = false, count: Int = Int.max) -> [K] {
        let count = min(count, self.count)
        var array = [K]()
        forEach(reversed: reversed, { index, mkey, _, stop in
            array.append(mkey)
            stop = (index + 1) >= count
        })
        return array
    }
    
    /// return prefix values, no more than count
    open func prefixValues(reversed: Bool = false, count: Int = Int.max) -> [V] {
        let count = min(count, self.count)
        var array = [V]()
        forEach(reversed: reversed, { index, _, value, stop in
            array.append(value)
            stop = (index + 1) >= count
        })
        return array
    }
    
    /// create iterator
    open func makeIterator(reversed: Bool = false) -> SortedDictionaryIterator<K,P,V> {
        return SortedDictionaryIterator(tree: self.tree, reversed: reversed)
    }
    
    /// remove all
    open func removeAll() {
        map = [K:AvlNode<K,P,V>]()
        tree = AvlTree<K,P,V>()
    }
}

///
public class SortedDictionaryIterator<K:Hashable, P:Comparable, V>: IteratorProtocol {
    
    public typealias Element = AvlNode<K,P,V>
    var reversed: Bool
    var node: AvlNode<K,P,V>?

    fileprivate init(tree: AvlTree<K,P,V>, reversed: Bool = false) {
        self.reversed = reversed
        self.node = reversed ? tree.last() : tree.first()
    }
    
    public func next() -> Element? {
        let nnode = node
        node = reversed ? nnode?.prev() : nnode?.next()
        return nnode
    }
}
