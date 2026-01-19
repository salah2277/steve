import XCTest
@testable import steve

final class OutputTests: XCTestCase {
    func testOkPayloadWithoutData() {
        let payload = Output.okPayload()
        XCTAssertEqual(payload["ok"] as? Bool, true)
        XCTAssertNil(payload["data"])
    }

    func testErrorPayload() {
        let payload = Output.errorPayload("nope")
        XCTAssertEqual(payload["ok"] as? Bool, false)
        XCTAssertEqual(payload["error"] as? String, "nope")
    }

    func testEncodeRoundTrip() throws {
        let payload = Output.okPayload(["a": 1])
        guard let data = Output.encode(payload) else {
            XCTFail("Failed to encode JSON")
            return
        }
        let obj = try JSONSerialization.jsonObject(with: data)
        let dict = obj as? [String: Any]
        XCTAssertEqual(dict?["ok"] as? Bool, true)
        let dataDict = dict?["data"] as? [String: Any]
        XCTAssertEqual(dataDict?["a"] as? Int, 1)
    }
}
