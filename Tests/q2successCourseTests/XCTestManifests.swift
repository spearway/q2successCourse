import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(q2successCourseTests.allTests),
    ]
}
#endif
