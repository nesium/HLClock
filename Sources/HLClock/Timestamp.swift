import Foundation

public struct Timestamp {
  public var physical: Date
  public var logical: UInt16

  public init(physical: Date, logical: UInt16) {
    self.physical = physical
    self.logical = logical
  }
}

extension Timestamp: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

extension Timestamp: RawRepresentable, Equatable {
  public init?(rawValue: UInt64) {
    self.logical = UInt16(rawValue & 0xFFFF)
    self.physical = Date(timeIntervalSince1970: TimeInterval(rawValue & ~0xFFFF) / 1e+9)
  }

  public var rawValue: UInt64 {
    let nanos = UInt64(self.physical.timeIntervalSince1970 * 1e+9)
    return (nanos & ~0xFFFF) | UInt64(self.logical)
  }
}
