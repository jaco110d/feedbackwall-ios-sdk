import XCTest
@testable import FeedbackWall

final class FeedbackWallTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset state before each test
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testConfigureSetup() {
        // Given
        let apiKey = "test_api_key"
        let baseURL = URL(string: "https://test.feedbackwall.io")!
        
        // When
        FeedbackWall.configure(apiKey: apiKey, baseURL: baseURL)
        
        // Then
        XCTAssertTrue(FeedbackWall.isConfigured)
    }
    
    func testShowIfAvailableBeforeConfigureDoesNotCrash() {
        // This should not crash, only log a warning
        FeedbackWall.showIfAvailable(trigger: "test_trigger")
        // If we reach here, the test passes
    }
}

