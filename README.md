
# About

Swift SortedDictionary base on AVL tree, insert O(logN)/ delete O(1) / find O(1) / sort O(logN), test under Swift 5.

## Install

To integrate `SortedDictionary` into your Xcode project using CocoaPods, specify it in your Podfile:

```
    pod 'SortedDictionary'
```

## Test & Performance

run Test in Example demo

test and performance under

- Apple Swift version 4.0.3 (swiftlang-900.0.74.1 clang-900.0.39.2)
- Target: x86_64-apple-macosx10.9

for example, with amount data, every time add some data into it, take its minimal preifx count, the amount, additional data count, preifx number are keys for sorting efficiency.

```
with amount:256 addition:512 prefix:16 loop:10

Test Dicionary:
round 1: 111ms, avg: 111ms
round 2: 109ms, avg: 110ms
round 3: 109ms, avg: 110ms
round 4: 109ms, avg: 109ms
round 5: 109ms, avg: 109ms
round 6: 109ms, avg: 109ms
round 7: 109ms, avg: 109ms
round 8: 108ms, avg: 109ms
round 9: 109ms, avg: 109ms
round 10: 112ms, avg: 109ms

Test SortedDicionary:
round 1: 21ms, avg: 21ms
round 2: 18ms, avg: 19ms
round 3: 18ms, avg: 19ms
round 4: 19ms, avg: 19ms
round 5: 19ms, avg: 19ms
round 6: 19ms, avg: 19ms
round 7: 19ms, avg: 19ms
round 8: 19ms, avg: 19ms
round 9: 19ms, avg: 19ms
round 10: 19ms, avg: 19ms
```
