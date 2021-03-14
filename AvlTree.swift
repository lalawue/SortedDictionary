//
//  Created by lalawue on 2021/3/13.
//
// translate from skywind3000's avlmini.c

final public class AvlNode<K: Comparable, V>: CustomStringConvertible {
    fileprivate var left: AvlNode<K,V>? = nil
    fileprivate var right: AvlNode<K,V>? = nil
    fileprivate weak var parent: AvlNode<K,V>? = nil
    fileprivate var height: Int = 0
    public let key: K
    fileprivate var val: V?
    public var value: V? {
        return val
    }
    fileprivate init(key: K, value: V? = nil) {
        self.key = key
        self.val = value
    }

    public var description: String {
        return "(k:\(key) h:\(height))"
    }
    
    public static func ==(lhs: AvlNode<K,V>, rhs: AvlNode<K,V>) -> Bool {
        return lhs.key == rhs.key
    }
    
    public func replace(value: V?) {
        val = value
    }
    
    public func next() -> AvlNode<K,V>? {
        var node = self
        if node.right != nil {
            node = node.right!
            while node.left != nil {
                node = node.left!
            }
        } else {
            while true {
                let last = node
                if node.parent == nil {
                    return nil
                }
                node = node.parent!
                if node.left != nil && node.left! == last {
                    break
                }
            }
        }
        return node
    }
    
    public func prev() -> AvlNode<K,V>? {
        var node = self
        if node.left != nil {
            node = node.left!
            while node.right != nil {
                node = node.right!
            }
        } else {
            while true {
                let last = node
                if node.parent == nil {
                    return nil
                }
                node = node.parent!
                if node.right != nil && node.right! == last {
                    break
                }
            }
        }
        return node
    }
}

final public class AvlTree<K: Comparable, V> {
    
    private var root: AvlNode<K,V>?

    private var size = Int(0)
    
    public func first() -> AvlNode<K,V>? {
        guard var node = root else {
            return nil
        }
        while node.left != nil {
            node = node.left!
        }
        return node
    }
    
    public func last() -> AvlNode<K,V>? {
        guard var node = root else {
            return nil
        }
        while node.right != nil {
            node = node.right!
        }
        return node
    }
    
    public func find(key: K) -> AvlNode<K,V>? {
        var next = root
        while let node = next {
            if node.key == key {
                return node
            }
            if node.key < key {
                next = node.right
            } else {
                next = node.left
            }
        }
        return nil
    }
    
    /// replace original
    @discardableResult
    public func insert(key: K, value: V?, replace: Bool = false) -> AvlNode<K,V> {
        var link = root
        var parent: AvlNode<K,V>? = nil
        var left = false
        while link != nil {
            parent = link!
            if parent!.key == key {
                if replace {
                    parent!.val = value
                }
                return parent!
            }
            left = parent!.key > key
            if left {
                link = parent!.left
            } else {
                link = parent!.right
            }
        }
        let node = AvlNode(key: key, value: value)
        node.parent = parent
        if parent == nil {
            root = node
        } else {
            if left {
                parent!.left = node
            } else {
                parent!.right = node
            }
        }
        postInsert(node: node)
        size += 1
        return node
    }
    
    @discardableResult
    public func remove(key: K) -> V? {
        if let node = find(key: key) {
            return remove(node: node)
        }
        return nil
    }
    
    @discardableResult
    public func remove(node: AvlNode<K,V>) -> V? {
        let value = node.val
        var child: AvlNode<K,V>? = nil
        var parent: AvlNode<K,V>? = nil
        if node.left != nil && node.right != nil {
            let old = node
            var n = node.right!
            while n.left != nil {
                n = n.left!
            }
            child = n.right
            parent = n.parent
            if child != nil {
                child!.parent = parent
            }
            replaceChild(oldNode: n, newNode: child, parent: parent)
            if n.parent != nil && n.parent! == old {
                parent = n
            }
            n.left = old.left
            n.right = old.right
            n.parent = old.parent
            n.height = old.height
            replaceChild(oldNode: old, newNode: n, parent: old.parent)
            old.left!.parent = n
            if old.right != nil {
                old.right!.parent = n
            }
        } else {
            if node.left == nil {
                child = node.right
            } else {
                child = node.left
            }
            parent = node.parent
            replaceChild(oldNode: node, newNode: child, parent: parent)
            if child != nil {
                child!.parent = parent
            }
        }
        if parent != nil {
            reBalance(node: parent!)
        }
        size -= 1
        return value
    }
    
    public func clear() {
        root = nil
        size = 0
    }
    
    public func count() -> Int {
        return size
    }
}

/// internal
extension AvlTree {
    
    private func leftHeight(node: AvlNode<K,V>) -> Int {
        return node.left != nil ? node.left!.height : 0
    }
    
    private func rightHeight(node: AvlNode<K,V>) -> Int {
        return node.right != nil ? node.right!.height : 0
    }
    
    private func replaceChild(oldNode: AvlNode<K,V>, newNode: AvlNode<K,V>?, parent: AvlNode<K,V>?) {
        guard let `parent` = parent else {
            root = newNode
            return
        }
        if (parent.left != nil && parent.left! == oldNode) {
            parent.left = newNode
        } else {
            parent.right = newNode
        }
    }
    
    private func rotateLeft(node: AvlNode<K,V>) -> AvlNode<K,V> {
        let right = node.right!
        let parent = node.parent
        node.right = right.left
        if right.left != nil {
            right.left!.parent = node
        }
        right.left = node
        right.parent = parent
        replaceChild(oldNode: node, newNode: right, parent: parent)
        node.parent = right
        return right
    }
    
    private func rotateRight(node: AvlNode<K,V>) -> AvlNode<K,V> {
        let left = node.left!
        let parent = node.parent
        node.left = left.right
        if left.right != nil {
            left.right!.parent = node
        }
        left.right = node
        left.parent = parent
        replaceChild(oldNode: node, newNode: left, parent: parent)
        node.parent = left
        return left
    }
    
    private func updateHeight(node: AvlNode<K,V>) {
        let h0 = leftHeight(node: node)
        let h1 = rightHeight(node: node)
        node.height = max(h0, h1) + 1
    }
    
    private func fixLeft(node: AvlNode<K,V>) -> AvlNode<K,V> {
        let right = node.right!
        let rh0 = leftHeight(node: right)
        let rh1 = rightHeight(node: right)
        if rh0 > rh1 {
            let r = rotateRight(node: right)
            updateHeight(node: r.right!)
            updateHeight(node: r)
        }
        let n =  rotateLeft(node: node)
        updateHeight(node: n.left!)
        updateHeight(node: n)
        return n
    }
    
    private func fixRight(node: AvlNode<K,V>) -> AvlNode<K,V> {
        let left = node.left!
        let rh0 = leftHeight(node: left)
        let rh1 = rightHeight(node: left)
        if rh0 < rh1 {
            let l = rotateLeft(node: left)
            updateHeight(node: l.left!)
            updateHeight(node: l)
        }
        let n = rotateRight(node: node)
        updateHeight(node: n.right!)
        updateHeight(node: n)
        return n
    }
    
    private func reBalance(node: AvlNode<K,V>?) {
        var next = node
        while next != nil {
            let h0 = leftHeight(node: next!)
            let h1 = rightHeight(node: next!)
            let diff = h0 - h1
            let height = max(h0, h1) + 1
            if next!.height != height {
                next!.height = height
            } else if diff >= -1, diff <= 1 {
                break
            }
            if diff <= -2 {
                next = fixLeft(node: next!)
            } else if diff >= 2 {
                next = fixRight(node: next!)
            }
            next = next!.parent
        }
    }
    
    private func postInsert(node: AvlNode<K,V>) {
        node.height = 1
        var parent = node.parent
        while var next = parent {
            let h0 = leftHeight(node: next)
            let h1 = rightHeight(node: next)
            let height = max(h0, h1) + 1
            if next.height == height {
                break
            }
            next.height = height
            let diff = h0 - h1
            if diff <= -2 {
                next = fixLeft(node: next)
            } else if  diff >= 2 {
                next = fixRight(node: next)
            }
            parent = next.parent
        }
    }
}
