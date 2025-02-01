//
//  Created by lalawue on 2021/3/13.
//
// translate from skywind3000's avlmini.c

/// AVL tree node
public class AvlNode<K:Hashable, P:Comparable, V> {
    fileprivate var left: AvlNode<K,P,V>? = nil
    fileprivate var right: AvlNode<K,P,V>? = nil
    fileprivate weak var parent: AvlNode<K,P,V>? = nil
    fileprivate var height: Int = 0
    fileprivate var val: V
    
    /// dictionary key
    public let key: K
    
    /// dictionary value
    public var value: V {
        return val
    }
    
    /// sorted key
    public let priority: P
    
    fileprivate init(key: K, value: V, priority: P) {
        self.key = key
        self.priority = priority
        self.val = value
    }
    
    public static func ==(lhs: AvlNode<K,P,V>, rhs: AvlNode<K,P,V>) -> Bool {
        return lhs.priority == rhs.priority
    }
    
    func replace(value: V) {
        val = value
    }
    
    /// next node
    public func next() -> AvlNode<K,P,V>? {
        var node = self
        if let nr = node.right {
            node = nr
            while let nl = node.left {
                node = nl
            }
        } else {
            while true {
                let last = node
                guard let np = node.parent else {
                    return nil
                }
                node = np
                if let nl = node.left, nl == last {
                    break
                }
            }
        }
        return node
    }
    
    /// prev node
    public func prev() -> AvlNode<K,P,V>? {
        var node = self
        if let nl = node.left {
            node = nl
            while let nr = node.right {
                node = nr
            }
        } else {
            while true {
                let last = node
                guard let np = node.parent else {
                    return nil
                }
                node = np
                if let nr = node.right, nr == last {
                    break
                }
            }
        }
        return node
    }
}

/// AVL tree, which first is minimal, and last is maximal
class AvlTree<K:Hashable, P:Comparable, V> {
    
    private var root: AvlNode<K,P,V>?

    private var size = Int(0)
    
    /// minimal
    func first() -> AvlNode<K,P,V>? {
        guard var node = root else {
            return nil
        }
        while let nl = node.left {
            node = nl
        }
        return node
    }
    
    /// maximal
    func last() -> AvlNode<K,P,V>? {
        guard var node = root else {
            return nil
        }
        while let nr = node.right {
            node = nr
        }
        return node
    }
    
    /// replace original
    @discardableResult
    func insert(key: K, value: V, priority: P) -> AvlNode<K,P,V> {
        var link = root
        var parent: AvlNode<K,P,V>? = nil
        var left = false
        while let _link = link {
            parent = _link
            if _link.priority == priority {
                _link.val = value
                return _link
            }
            left = _link.priority > priority
            if left {
                link = _link.left
            } else {
                link = _link.right
            }
        }
        let node = AvlNode(key: key, value: value, priority: priority)
        node.parent = parent
        if let np = parent {
            if left {
                np.left = node
            } else {
                np.right = node
            }
        } else {
            root = node
        }
        postInsert(node: node)
        size += 1
        return node
    }
    
    @discardableResult
    func remove(node: AvlNode<K,P,V>) -> V? {
        let value = node.val
        var child: AvlNode<K,P,V>? = nil
        var parent: AvlNode<K,P,V>? = nil
        if let nl = node.left, let nr = node.right {
            let old = node
            var n = nr
            while let _n = n.left {
                n = _n
            }
            child = n.right
            parent = n.parent
            if let _n = child {
                _n.parent = parent
            }
            replaceChild(oldNode: n, newNode: child, parent: parent)
            if let np = n.parent, np == old {
                parent = n
            }
            n.left = old.left
            n.right = old.right
            n.parent = old.parent
            n.height = old.height
            replaceChild(oldNode: old, newNode: n, parent: old.parent)
            old.left?.parent = n
            if let _n = old.right {
                _n.parent = n
            }
        } else {
            if node.left == nil {
                child = node.right
            } else {
                child = node.left
            }
            parent = node.parent
            replaceChild(oldNode: node, newNode: child, parent: parent)
            if let _n = child {
                _n.parent = parent
            }
        }
        if let np = parent {
            reBalance(node: np)
        }
        size -= 1
        return value
    }

    func match(priority: P, compareFn: (priority: P, node: AvlNode<K,P,V>) -> Int)
        -> AvlNode<K,P,V>?
    {
        guard self.size > 0 else {
            return nil
        }
        var _match: AvlNode<K,P,V>? = root
        while let n = _match {
            let ret = compareFn(priority, n)
            if ret == 0 {
                return n
            } else if ret < 0 {
                _match = n.left
            } else {
                _match = n.right
            }
        }
        return nil
    }
    
    func clear() {
        root = nil
        size = 0
    }
    
    func count() -> Int {
        return size
    }
}

/// internal
extension AvlTree {
    
    private func leftHeight(node: AvlNode<K,P,V>) -> Int {
        return node.left?.height ?? 0
    }
    
    private func rightHeight(node: AvlNode<K,P,V>) -> Int {
        return node.right?.height ?? 0
    }
    
    private func replaceChild(oldNode: AvlNode<K,P,V>, newNode: AvlNode<K,P,V>?, parent: AvlNode<K,P,V>?) {
        guard let `parent` = parent else {
            root = newNode
            return
        }
        if let pl = parent.left, pl == oldNode {
            parent.left = newNode
        } else {
            parent.right = newNode
        }
    }
    
    private func rotateLeft(node: AvlNode<K,P,V>) -> AvlNode<K,P,V> {
        let right = node.right!
        let parent = node.parent
        node.right = right.left
        if let _n = right.left {
            _n.parent = node
        }
        right.left = node
        right.parent = parent
        replaceChild(oldNode: node, newNode: right, parent: parent)
        node.parent = right
        return right
    }
    
    private func rotateRight(node: AvlNode<K,P,V>) -> AvlNode<K,P,V> {
        let left = node.left!
        let parent = node.parent
        node.left = left.right
        if let _n = left.right {
            _n.parent = node
        }
        left.right = node
        left.parent = parent
        replaceChild(oldNode: node, newNode: left, parent: parent)
        node.parent = left
        return left
    }
    
    private func updateHeight(node: AvlNode<K,P,V>) {
        let h0 = leftHeight(node: node)
        let h1 = rightHeight(node: node)
        node.height = max(h0, h1) + 1
    }
    
    private func fixLeft(node: AvlNode<K,P,V>) -> AvlNode<K,P,V> {
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
    
    private func fixRight(node: AvlNode<K,P,V>) -> AvlNode<K,P,V> {
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
    
    private func reBalance(node: AvlNode<K,P,V>?) {
        var next = node
        while let n = next {
            let h0 = leftHeight(node: n)
            let h1 = rightHeight(node: n)
            let diff = h0 - h1
            let height = max(h0, h1) + 1
            if n.height != height {
                n.height = height
            } else if diff >= -1, diff <= 1 {
                break
            }
            if diff <= -2 {
                next = fixLeft(node: n)
            } else if diff >= 2 {
                next = fixRight(node: n)
            }
            next = next?.parent
        }
    }
    
    private func postInsert(node: AvlNode<K,P,V>) {
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
