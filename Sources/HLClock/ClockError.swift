import Foundation

enum ClockError: Error {
  case overflow
  case maximumDriftExceeded
}
