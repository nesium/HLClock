import HLClock
import XCTest

final class HLClockTests: XCTestCase {
  func testIncreasesLogicalTimeIfPhysicalTimeDidNotChange() throws {
    let date = Date()
    let clock = Clock(timeProvider: { date })

    let ts1 = try clock.now()
    XCTAssertEqual(ts1.physical, date)
    XCTAssertEqual(ts1.logical, 0)

    let ts2 = try clock.now()
    XCTAssertEqual(ts2.physical, date)
    XCTAssertEqual(ts2.logical, 1)
  }

  func testResetsLogicalTimeAfterPhysicalTimeDidChange() throws {
    var date = Date()
    let clock = Clock(timeProvider: { date })

    _ = try clock.now()

    let ts1 = try clock.now()
    XCTAssertEqual(ts1.physical, date)
    XCTAssertEqual(ts1.logical, 1)

    date = date.addingTimeInterval(10)

    let ts2 = try clock.now()
    XCTAssertEqual(ts2.physical, date)
    XCTAssertEqual(ts2.logical, 0)
  }

  func testThrowsOnOverflow() throws {
    let date = Date()
    let clock = Clock(timeProvider: { date })

    for _ in 0 ... UInt16.max {
      _ = try clock.now()
    }

    XCTAssertThrowsError(try clock.now())
  }

  func testUpdateAdvancesToPhysicalTimeOnUpdate() throws {
    let date = Date()
    let clock = Clock(timeProvider: { date })

    try clock.update(from: Timestamp(physical: date.addingTimeInterval(-10), logical: 0))

    let now = try clock.now()

    XCTAssertEqual(now.physical, date)
    XCTAssertEqual(now.logical, 1)
  }

  func testUpdateAdvancesToMessageTimeOnUpdate() throws {
    let physicalTime = Date()
    let messageTime = physicalTime.addingTimeInterval(10)
    let clock = Clock(timeProvider: { physicalTime })

    try clock.update(from: Timestamp(physical: messageTime, logical: 0))

    let now = try clock.now()

    XCTAssertEqual(now.physical, messageTime)
    XCTAssertEqual(now.logical, 2)
  }

  func testDoesNotAdvanceOnUpdate() throws {
    let physicalTime = Date()
    let currentTime = Date().addingTimeInterval(10)
    let messageTime = physicalTime.addingTimeInterval(-10)
    let clock = Clock(timeProvider: { physicalTime })

    try clock.update(from: Timestamp(physical: currentTime, logical: 0))
    var now = try clock.now()

    XCTAssertEqual(now.physical, currentTime)
    XCTAssertEqual(now.logical, 2)

    try clock.update(from: Timestamp(physical: messageTime, logical: 0))
    now = try clock.now()

    XCTAssertEqual(now.physical, currentTime)
    XCTAssertEqual(now.logical, 4)
  }

  func testAdvancesLogicalTimeOnUpdate() throws {
    let date = Date()
    let clock = Clock(timeProvider: { date })

    try clock.update(from: Timestamp(physical: date, logical: 33))
    var now = try clock.now()

    XCTAssertEqual(now.physical, date)
    XCTAssertEqual(now.logical, 35)

    try clock.update(from: Timestamp(physical: date, logical: 10))
    now = try clock.now()

    XCTAssertEqual(now.physical, date)
    XCTAssertEqual(now.logical, 37)
  }

  func testThrowsIfMaximumDriftIsExceeded() throws {
    let date = Date()
    let clock = Clock(timeProvider: { date }, maximumDrift: 30)

    XCTAssertThrowsError(
      try clock.update(from: Timestamp(physical: date.addingTimeInterval(40), logical: 0))
    )
  }
}
