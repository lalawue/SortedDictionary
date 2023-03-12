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
    let priorityFn: (K,V) -> P
    
    public init(sorted: @escaping (K,V) -> P) {
        self.priorityFn = sorted
    }
    
    /// get/set
    open subscript(_ key: K) -> V? {
        get {
            return map[key]?.value
        }
        set {
            if let `newValue` = newValue {
                let npri = self.priorityFn(key, newValue)
                if let node = map[key] {
                    if node.priority == npri {
                        node.replace(value: newValue)
                    } else {
                        tree.remove(node: node)
                        map[key] = tree.insert(key: key, value: newValue, priority: npri)
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

    /// forEach with index from '0'
    open func forEach(reversed: Bool = false, _ body: (Int, KeyValue) throws -> Void) rethrows {
        let it = makeIterator(reversed: reversed)
        while let n = it.next() {
            try body(it.index, n)
        }
    }

    /// return prefix KeyValue, no more than count
    open func prefix(_ maxLength: Int = Int.max) -> [KeyValue] {
        var array = [AvlNode<K,P,V>]()
        if maxLength > 0 {
            let it = makeIterator()
            while let n = it.next() {
                array.append(n)
                if it.index + 1 >= maxLength {
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
                if it.index + 1 >= maxLength {
                    break
                }
            }
        }
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

/// sorted dictionary iterator
public class SortedDictionaryIterator<K:Hashable, P:Comparable, V>: IteratorProtocol {
    
    public typealias Element = SortedDictionary<K,P,V>.KeyValue
    
    public var reversed: Bool {
        return _reversed
    }
    
    public var index: Int {
        return _index
    }

    var _node: Element?
    var _reversed: Bool
    var _index: Int

    fileprivate init(tree: AvlTree<K,P,V>, reversed: Bool = false) {
        self._reversed = reversed
        self._index = -1
        self._node = reversed ? tree.last() : tree.first()
    }
    
    public func next() -> Element? {
        let nnode = _node
        _node = _reversed ? nnode?.prev() : nnode?.next()
        _index += 1
        return nnode
    }
}
