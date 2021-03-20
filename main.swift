//
// Created by lalawue on 2021/03/19
//
// test re-balance

import Foundation

protocol TestUnit: AnyObject {
    func set(_ key: Int, _ value: Int?)
    func prefix(count: Int) -> [Int]
    func count() -> Int
}

class UnitDict: TestUnit {
    var dict = [Int:Int]()
    func set(_ key: Int, _ value: Int?) {
        dict[key] = value
    }
    func prefix(count: Int) -> [Int] {
        return dict.sorted() { $0.key < $1.key }.prefix(count).map { $0.value }
    }
    func count() -> Int {
        return dict.count
    }
}

class UnitSD: TestUnit {
    var map = SortedDictionary<Int,Int?>()
    func set(_ key: Int, _ value: Int?) {
        map[key] = value
    }
    func prefix(count: Int) -> [Int] {
        var arr = [Int]()
        var index = Int(0)
        map.forEach() { (_, _, value, stop)  in
            if let `value` = value {
                if index >= count {
                    stop = true
                }
                arr.append(value)
                index += 1
            }
        }
        return arr
    }
    func count() -> Int {
        return map.count
    }
}

class Test {
    
    /// amount  : setting data count
    /// addition: delete/replace data count
    /// prefix  : only take prefix after sort
    /// loop    : set/delete/sort round times
    static func testUnit(container: TestUnit,
                         amount: Int,
                         addition: Int,
                         prefix: Int,
                         loop: Int) -> Bool {
        var avg = UInt64(0)
        var round = UInt64(0)
        var last = DispatchTime.now()
        while round < loop {
            round += 1
            
            var left = Int(1)
            var right = amount
            while left < right {
                container.set(left, left)
                container.set(right, right)
                left += 1
                right -= 1
            }
            
            var idx = Int(0)
            var an = Int(0)
            while idx < addition {
                if an % 5 == 0 {
                    container.set(an, nil)
                } else {
                    container.set(an, an)
                }
                an += 1
                idx += 1
                if an >= amount {
                    an = 0
                }
                
                let result = container.prefix(count: prefix)
                var index = Int(0)
                var rn = Int(0)
                while index < prefix {
                    if rn < idx && rn % 5 == 0 {
                        rn += 1
                    }
                    if result[index] != rn {
                        return false
                    }
                    index += 1
                    rn += 1
                }
            }
            
            let now = DispatchTime.now()
            let elapsed = now.uptimeNanoseconds - last.uptimeNanoseconds
            avg += elapsed
            print("round \(round): \(elapsed/1000000)ms, avg: \(avg / round / 1000000)ms")
            last = now
        }
        return true
    }
}

let amount = Int(256) // impact factor
let addition = Int(512) // impact factor
let prefix = Int(16) /// impact factor
let loop = Int(10)

print("with amount:\(amount) addition:\(addition) prefix:\(prefix) loop:\(loop)")

print("\nTest Dicionary:")
if !Test.testUnit(container: UnitDict(),
                  amount: amount,
                  addition: addition,
                  prefix: prefix,
                  loop: loop) {
    print("failed to test ud")
}

print("\nTest SortedDicionary:")
if !Test.testUnit(container: UnitSD(),
                  amount: amount,
                  addition: addition,
                  prefix: prefix,
                  loop: loop) {
    print("failed to test us")
}


