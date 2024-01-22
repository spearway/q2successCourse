import XCTest
@testable import q2successCourse

final class q2successCourseTests: XCTestCase {

    func testNames() {
        let names = ElementBlueprint.registry.names

        XCTAssertEqual(names.count, 10, "the list of names is missing elements")
        XCTAssertTrue(names.contains(.cardLabel), "the list of names should contains a card label name")
    }

    func testGroups() {
        let groups = ElementBlueprint.registry.groups

        XCTAssertEqual(groups.count, 2, "the list of groups is missing elements")
        XCTAssertTrue(groups.contains(.card), "the list of groups should contains a card group")
        XCTAssertTrue(groups.contains(.question), "the list of groups should contains a question group")
    }

    func testCourse() {
        let aCourse = course

        do {
            let json = try aCourse.data()

            print("json: \(String(describing: String(data: json, encoding: .utf8)))")

            let aNewCourse = try Course.read(from: json)

            XCTAssertEqual(aCourse, aNewCourse, "Seriaization / Deserialization of course failed.")
        } catch {
            XCTFail("exception thrown \(error.localizedDescription)")
        }

   }

    static var allTests = [
        ("Test Names", testNames),
        ("Test Groups", testGroups),
        ("Test Formula", testCourse),
    ]
    
    
    var course: Course {
        let aCourse = Course()
        return aCourse
    }
}
