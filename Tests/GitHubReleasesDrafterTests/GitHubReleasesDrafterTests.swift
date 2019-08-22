import XCTest
import class Foundation.Bundle

final class GitHubReleasesDrafterTests: XCTestCase {
    
    private func executeDrafter(parameter: String = "") throws -> String? {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return nil
        }
        
        let fooBinary = productsDirectory.appendingPathComponent("GitHubReleasesDrafter")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    func testNoRequiredParameters() throws {
        let output = try executeDrafter()
        XCTAssertEqual(output, "")
        //XCTAssertEqual(output, "Cannot find required parameter⁉️\n")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
            for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
              return bundle.bundleURL.deletingLastPathComponent()
            }
            fatalError("couldn't find the products directory")
        #else
            return Bundle.main.bundleURL
        #endif
    }

    static var allTests = [
        ("testNoRequiredParameters", testNoRequiredParameters),
    ]
}
