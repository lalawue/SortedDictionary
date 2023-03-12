import XCTest
import Foundation
import SortedDictionary

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
    var map = SortedDictionary<Int,Int,Int>(sorted: { _, value in
        return value
    })
    func set(_ key: Int, _ value: Int?) {
        map[key] = value
    }
    func prefix(count: Int) -> [Int] {
        return map.prefixValues(count: count)
    }
    func count() -> Int {
        return map.count
    }
}

class MyTest {
    
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

// MARK: -

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        let dict = SortedDictionary<String,Decimal,Decimal>(sorted: { _, value in
            return value
        })
        for i in 1...10000 {
            dict["\(i)"] = Decimal(i)
        }
        XCTAssertEqual(dict.count, 10000)
        
        XCTAssertEqual(dict["3"]!, 3)
        XCTAssertEqual(dict["9999"]!, 9999)
        
        XCTAssertEqual(dict.miniOne!.key, "1")
        XCTAssertEqual(dict.miniOne!.priority, 1)
        XCTAssertEqual(dict.miniOne!.value, 1)
        
        XCTAssertEqual(dict.maxOne!.key, "10000")
        XCTAssertEqual(dict.maxOne!.priority, 10000)
        XCTAssertEqual(dict.maxOne!.value, 10000)
        
        let fk = dict.prefixKeys(count: 10)
        XCTAssertEqual(fk.count, 10)
        XCTAssertEqual(fk.first!, "1")
        XCTAssertEqual(fk.last!, "10")
        
        let lk = dict.prefixKeys(reversed: true, count: 10)
        XCTAssertEqual(lk.count, 10)
        XCTAssertEqual(lk.first!, "10000")
        XCTAssertEqual(lk.last!, "9991")
        
        let fv = dict.prefixValues(count: 10)
        XCTAssertEqual(fv.count, 10)
        XCTAssertEqual(fv.first!, 1)
        XCTAssertEqual(fv.last!, 10)
        
        let lv = dict.prefixValues(reversed: true, count: 10)
        XCTAssertEqual(lv.count, 10)
        XCTAssertEqual(lv.first!, 10000)
        XCTAssertEqual(lv.last!, 9991)
        
        let fi = dict.makeIterator()
        var index = Decimal(0)
        
        while let ni = fi.next() {
            index += 1
            XCTAssertEqual(ni.value, index)
        }
        
        let li = dict.makeIterator(reversed: true)
        index = Decimal(10001)
        while let ni = li.next() {
            index -= 1
            XCTAssertEqual(ni.value, index)
        }
        
        dict.removeAll()
        XCTAssertEqual(dict.count, 0)
    }
    
    func testCompare() {
        let amount = Int(256) // impact factor
        let addition = Int(512) // impact factor
        let prefix = Int(16) /// impact factor
        let loop = Int(10)

        print("\n\nwith amount:\(amount) addition:\(addition) prefix:\(prefix) loop:\(loop)")

        print("\nTest Dicionary:")
        if !MyTest.testUnit(container: UnitDict(),
                            amount: amount,
                            addition: addition,
                            prefix: prefix,
                            loop: loop) {
            print("failed to test ud")
        }

        print("\nTest SortedDicionary:")
        if !MyTest.testUnit(container: UnitSD(),
                            amount: amount,
                            addition: addition,
                            prefix: prefix,
                            loop: loop) {
            print("failed to test us")
        }
        
        print("\n")
    }
    
    func testPerformanceExample() {

        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
