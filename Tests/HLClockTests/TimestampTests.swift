import HLClock
import XCTest

final class TimestampTests: XCTestCase {
  func testRawRepresentation() throws {
    let date = try XCTUnwrap(
      Calendar.current.date(from: .init(
        year: 2500,
        month: 8,
        day: 19,
        hour: 17,
        minute: 15,
        second: 32,
        nanosecond: Int(Double(123) * 1e+6)
      ))
    )

    let original = Timestamp(physical: date, logical: 65535)
    let decoded = try XCTUnwrap(Timestamp(rawValue: original.rawValue))

    XCTAssertEqual(
      original.physical.timeIntervalSince1970,
      decoded.physical.timeIntervalSince1970,
      accuracy: 5e-5 // Tolerance of 500µs
    )
    XCTAssertEqual(decoded.logical, 65535)
    XCTAssertEqual(original, decoded)
  }

  func testComparison() {
    let date1 = Date(timeIntervalSinceReferenceDate: 100)
    let date2 = Date(timeIntervalSinceReferenceDate: 200)

    XCTAssertTrue(
      Timestamp(physical: date1, logical: 0) < Timestamp(physical: date2, logical: 0)
    )
    XCTAssertTrue(
      Timestamp(physical: date1, logical: 0) < Timestamp(physical: date2, logical: 65535)
    )
    XCTAssertFalse(
      Timestamp(physical: date1, logical: 0) < Timestamp(physical: date1, logical: 0)
    )
    XCTAssertTrue(
      Timestamp(physical: date1, logical: 0) < Timestamp(physical: date1, logical: 1)
    )
  }
}
