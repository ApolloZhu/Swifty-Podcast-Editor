//
//  FlowLayout.swift
//
//  Modified by Apollo Zhu to allow drag & drop reordering.
//  Originally created by Chris Eidhof on 20.08.19.
//  https://gist.github.com/chriseidhof/3c6ea3fb2102052d1898d8ea27fbee07
//

import SwiftUI

/*
 To calculate a flow layout, we need the sizes of the collection's elements.
 The "easiest" way to do this seems to be using preference keys:
 these are values that a child view can set
 and that get propagated up in the view hierarchy.
 
 A preference key consists of two parts:
 a type for the data (this needs to be equatable)
 and a type for the key itself.
 */

struct MyPreferenceKeyData: Equatable {
  var size: CGSize
  var id: AnyHashable
}

struct MyPreferenceKey: PreferenceKey {
  typealias Value = [MyPreferenceKeyData]
  
  static var defaultValue: [MyPreferenceKeyData] = []
  
  static func reduce(value: inout [MyPreferenceKeyData],
                     nextValue: () -> [MyPreferenceKeyData]) {
    value.append(contentsOf: nextValue())
  }
}


let empty = AnyView(Color.clear.frame(height: 0).fixedSize())

// Next up, we create a wrapper view which renders it's content view,
// but also propagates its size up the view hierarchy using the preference key.
struct PropagatesSize<ID: Hashable, V: View>: View {
  var id: ID
  var content: V
  var body: some View {
    content.background(GeometryReader { proxy in
      empty.preference(
        key: MyPreferenceKey.self,
        value: [MyPreferenceKeyData(size: proxy.size, id: AnyHashable(self.id))]
      )
    })
  }
}

// This is a flow layout directly taken from the Swift Talk episode on flow layouts
// (even though it's written for UIKit, we can reuse it without modification).
struct FlowLayout {
  let spacing: UIOffset
  let containerSize: CGSize
  
  init(containerSize: CGSize,
       spacing: UIOffset = UIOffset(horizontal: 10, vertical: 10)) {
    self.spacing = spacing
    self.containerSize = containerSize
  }
  
  var currentX = 0 as CGFloat
  var currentY = 0 as CGFloat
  var lineHeight = 0 as CGFloat
  
  mutating func add(element size: CGSize) -> CGRect {
    if currentX + size.width > containerSize.width {
      currentX = 0
      currentY += lineHeight + spacing.vertical
      lineHeight = 0
    }
    defer {
      lineHeight = max(lineHeight, size.height)
      currentX += size.width + spacing.horizontal
    }
    return CGRect(origin: CGPoint(x: currentX, y: currentY), size: size)
  }
  
  var size: CGSize {
    return CGSize(width: containerSize.width, height: currentY + lineHeight)
  }
}

/*
 Finally, here's the collection view. It works as following:
 
 It contains a collection of `Data`
 and a way to construct `Content` from an element of `Data`.
 
 For each value of `Data`,
 it wraps the element in a `PropagatesSize` container,
 and then collects all those sizes to construct the layout.
 */

typealias CollectionViewElementLocator = (CGPoint) -> Data.Index?


struct CollectionView<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Identifiable, Data.Index == Int {
  
  var data: Data
  @State private var sizes: [MyPreferenceKeyData] = []
  var content: (Data.Element, CGSize, @escaping CollectionViewElementLocator) -> Content
  
  private class ItemFrames {
    fileprivate var data: [CGRect] = []
  }
  private let frames = ItemFrames()
  
  func insertionIndex(for point: CGPoint) -> Data.Index? {
    print(frames.data)
    if frames.data.isEmpty { return nil }
    let (x, y) = (point.x, point.y)
    print(x, y)
    if y < frames.data.first!.minY {
      return nil
    }
    if y > frames.data.last!.maxY {
      return nil
    }
    var i = 0, j = frames.data.count
    
    while i < j {
      print(i, j)
      let mid = (i + j - 1) / 2
      if y < frames.data[mid].minY {
        j = mid - 1
      } else if y > frames.data[mid].maxY {
        i = mid + 1
      } else if x <= frames.data[mid].minX {
        if mid == 0 || x >= frames.data[mid - 1].maxX {
          return mid
        } else {
          j = mid - 1
        }
      } else if x >= frames.data[mid].maxX {
        if mid + 1 == frames.data.count
          || x <= frames.data[mid + 1].minX {
          return mid + 1
        } else {
          i = mid + 1
        }
      } else {
        return mid
      }
    }
    return j
  }
  
  typealias Layout = (items: [AnyHashable: CGSize], size: CGSize)
  
  func layout(size: CGSize) -> Layout {
    var f = FlowLayout(containerSize: size)
    var result: [AnyHashable: CGSize] = [:]
    var itemFrames = [CGRect]()
    for s in sizes {
      let rect = f.add(element: s.size)
      itemFrames.append(rect)
      result[s.id] = CGSize(width: rect.origin.x, height: rect.origin.y)
    }
    frames.data = itemFrames
    return (result, f.size)
  }
  
  func withLayout(_ laidout: Layout) -> some View {
    return ZStack(alignment: .topLeading) {
      ForEach(self.data) { el in
        PropagatesSize(id: el.id, content: self.content(
          el, laidout.items[AnyHashable(el.id)] ?? .zero, self.insertionIndex
        )).offset(laidout.items[AnyHashable(el.id)] ?? .zero)
          .animation(Animation.default)
      }
      Color.clear
        .frame(width: laidout.size.width, height: laidout.size.height)
        .fixedSize()
    }.background(Color.clear)
      .onPreferenceChange(MyPreferenceKey.self, perform: {
        self.sizes = $0
      })
  }
  
  var body: some View {
    return GeometryReader { proxy in
      self.withLayout(self.layout(size: proxy.size))
    }
  }
}

// Just a temporary hack to make things work
extension Int: Identifiable {
  public var id: Int {
    return self
  }
}
