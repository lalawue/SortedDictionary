//
//  Created by lalawue on 2021/3/14.
//

import Foundation

/** AVL tree sorted Key/Value Dictionary
 */
final public class SortedDictionary<K: Hashable & Comparable, V> {

    /// O(1) get/set
    private var map = [K:AvlNode<K,V>]()
    
    /// O(logN) get/set/iterate
    private var tree = AvlTree<K,V>()
    
    /// get/set
    subscript(key: K) -> V? {
        get {
            if let node = map[key] {
                return node.value
            }
            return nil
        }
        set {
            if newValue == nil {
                if let node = map[key] {
                    tree.remove(node: node)
                    map[key] = nil
                }
            } else {
                if let node = map[key] {
                    node.replace(value: newValue)
                } else {
                    let node = tree.insert(key: key, value: newValue, replace: true)
                    map[key] = node
                }
            }
        }
    }

    /// forEach with index
    public func forEach(reversed: Bool = false, _ body: (Int, K, V, inout Bool) throws -> Void) rethrows {
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
    
    /// remove all
    public func removeAll() {
        map = [K:AvlNode<K,V>]()
        tree = AvlTree<K,V>()
    }
}
