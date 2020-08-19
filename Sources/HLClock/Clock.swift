import Foundation

public final class Clock {
  private let timeProvider: () -> Date
  private let maximumDrift: TimeInterval

  private var time = Timestamp(physical: Date.distantPast, logical: 0)
  private let lock = DispatchSemaphore(value: 1)

  public init(timeProvider: @escaping () -> Date = Date.init, maximumDrift: TimeInterval = 600) {
    self.timeProvider = timeProvider
    self.maximumDrift = maximumDrift
  }

  public func now() throws -> Timestamp {
    self.lock.wait()
    defer { self.lock.signal() }

    var time = self.time
    time.physical = max(self.timeProvider(), time.physical)

    if time.physical == self.time.physical {
      if time.logical == UInt16.max {
        throw ClockError.overflow
      }
      time.logical += 1
    } else {
      time.logical = 0
    }

    self.time = time

    return time
  }

  public func update(from ts: Timestamp) throws {
    self.lock.wait()
    defer { self.lock.signal() }

    let physical = self.timeProvider()

    if ts.physical.timeIntervalSince(physical) > self.maximumDrift {
      throw ClockError.maximumDriftExceeded
    }

    var time = self.time
    time.physical = max(time.physical, ts.physical, physical)

    if time.physical == self.time.physical, time.physical == ts.physical {
      time.logical = max(self.time.logical, ts.logical) + 1
    } else if time.physical == self.time.physical {
      time.logical = self.time.logical + 1
    } else if time.physical == ts.physical {
      time.logical = ts.logical + 1
    } else {
      time.logical = 0
    }

    self.time = time
  }
}
