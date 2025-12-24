import XCTest
@testable import FeedbackWall

final class FeedbackWallTests: XCTestCase {
    
    // MARK: - Test Constants
    
    // NOTE: Use mock/placeholder values for tests. Never commit real API keys.
    private let testBaseURL = URL(string: "https://api.example.feedbackwall.io")!
    private let testAPIKey = "test_api_key_placeholder"
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Configuration Tests
    
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
    
    // MARK: - JSON Parsing Tests - Survey
    
    func testSurveyDecodingMinimal() throws {
        let json = """
        {
            "id": "test-id",
            "title": "Test Survey",
            "questions": []
        }
        """
        
        let survey = try JSONDecoder().decode(Survey.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(survey.id, "test-id")
        XCTAssertEqual(survey.title, "Test Survey")
        XCTAssertNil(survey.description)
        XCTAssertNil(survey.theme)
        XCTAssertNil(survey.version)
        XCTAssertTrue(survey.questions.isEmpty)
    }
    
    func testSurveyDecodingWithAllFields() throws {
        let json = """
        {
            "id": "survey-123",
            "title": "Customer Feedback",
            "description": "Please share your experience",
            "questions": [
                {
                    "id": "q1",
                    "type": "multiple_choice",
                    "text": "How was your experience?",
                    "options": ["Great", "Good", "Average", "Poor"]
                }
            ],
            "theme": {
                "layout": "popup",
                "primaryColorHex": "#ff8800"
            },
            "version": 3
        }
        """
        
        let survey = try JSONDecoder().decode(Survey.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(survey.id, "survey-123")
        XCTAssertEqual(survey.title, "Customer Feedback")
        XCTAssertEqual(survey.description, "Please share your experience")
        XCTAssertEqual(survey.questions.count, 1)
        XCTAssertEqual(survey.theme?.layout, "popup")
        XCTAssertEqual(survey.theme?.primaryColorHex, "#ff8800")
        XCTAssertEqual(survey.version, 3)
    }
    
    // MARK: - JSON Parsing Tests - Theme
    
    func testThemeDecodingAllFields() throws {
        let json = """
        {
            "layout": "fullscreen",
            "primaryColorHex": "#C2662D",
            "backgroundColorHex": "#FFFBF7",
            "textColorHex": "#1A1A1A",
            "buttonTextColorHex": "#FFFFFF",
            "optionSelectedBackgroundHex": "#FF5500",
            "optionSelectedTextHex": "#FFFFFF",
            "cornerRadius": 16,
            "buttonCornerRadius": 10,
            "fontFamily": "rounded",
            "fontSize": 14,
            "textAlign": "center",
            "titleFontSize": 20,
            "bodyFontSize": 14,
            "buttonFontSize": 16,
            "contentPadding": 24,
            "delaySeconds": 5,
            "showCloseButton": false,
            "entranceAnimation": "fadeIn",
            "animationSpeed": "slow"
        }
        """
        
        let theme = try JSONDecoder().decode(SurveyTheme.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(theme.layout, "fullscreen")
        XCTAssertEqual(theme.primaryColorHex, "#C2662D")
        XCTAssertEqual(theme.backgroundColorHex, "#FFFBF7")
        XCTAssertEqual(theme.textColorHex, "#1A1A1A")
        XCTAssertEqual(theme.buttonTextColorHex, "#FFFFFF")
        XCTAssertEqual(theme.optionSelectedBackgroundHex, "#FF5500")
        XCTAssertEqual(theme.optionSelectedTextHex, "#FFFFFF")
        XCTAssertEqual(theme.cornerRadius, 16)
        XCTAssertEqual(theme.buttonCornerRadius, 10)
        XCTAssertEqual(theme.fontFamily, "rounded")
        XCTAssertEqual(theme.fontSize, 14)
        XCTAssertEqual(theme.textAlign, "center")
        XCTAssertEqual(theme.titleFontSize, 20)
        XCTAssertEqual(theme.bodyFontSize, 14)
        XCTAssertEqual(theme.buttonFontSize, 16)
        XCTAssertEqual(theme.contentPadding, 24)
        XCTAssertEqual(theme.delaySeconds, 5)
        XCTAssertEqual(theme.showCloseButton, false)
        XCTAssertEqual(theme.entranceAnimation, "fadeIn")
        XCTAssertEqual(theme.animationSpeed, "slow")
    }
    
    func testThemeDecodingPartial() throws {
        let json = """
        {
            "layout": "popup",
            "primaryColorHex": "#3366FF"
        }
        """
        
        let theme = try JSONDecoder().decode(SurveyTheme.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(theme.layout, "popup")
        XCTAssertEqual(theme.primaryColorHex, "#3366FF")
        XCTAssertNil(theme.backgroundColorHex)
        XCTAssertNil(theme.textColorHex)
        XCTAssertNil(theme.fontFamily)
        XCTAssertNil(theme.fontSize)
        XCTAssertNil(theme.cornerRadius)
        XCTAssertNil(theme.delaySeconds)
        XCTAssertNil(theme.showCloseButton)
        XCTAssertNil(theme.entranceAnimation)
    }
    
    func testEmptyThemeDecoding() throws {
        let json = "{}"
        
        let theme = try JSONDecoder().decode(SurveyTheme.self, from: json.data(using: .utf8)!)
        
        XCTAssertNil(theme.layout)
        XCTAssertNil(theme.primaryColorHex)
        XCTAssertNil(theme.fontFamily)
    }
    
    // MARK: - JSON Parsing Tests - Questions
    
    func testMultipleChoiceQuestionDecoding() throws {
        let json = """
        {
            "id": "q1",
            "type": "multiple_choice",
            "text": "How was your experience?",
            "options": ["Excellent", "Good", "Fair", "Poor"]
        }
        """
        
        let question = try JSONDecoder().decode(SurveyQuestion.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(question.id, "q1")
        XCTAssertEqual(question.type, .multipleChoice)
        XCTAssertEqual(question.text, "How was your experience?")
        XCTAssertEqual(question.options, ["Excellent", "Good", "Fair", "Poor"])
        XCTAssertNil(question.placeholder)
    }
    
    func testRatingQuestionDecoding() throws {
        let json = """
        {
            "id": "q2",
            "type": "rating",
            "text": "Rate our service"
        }
        """
        
        let question = try JSONDecoder().decode(SurveyQuestion.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(question.id, "q2")
        XCTAssertEqual(question.type, .rating)
        XCTAssertEqual(question.text, "Rate our service")
        XCTAssertNil(question.options)
    }
    
    func testTextQuestionDecoding() throws {
        let json = """
        {
            "id": "q3",
            "type": "text",
            "text": "Any additional feedback?",
            "placeholder": "Enter your thoughts here..."
        }
        """
        
        let question = try JSONDecoder().decode(SurveyQuestion.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(question.id, "q3")
        XCTAssertEqual(question.type, .text)
        XCTAssertEqual(question.text, "Any additional feedback?")
        XCTAssertEqual(question.placeholder, "Enter your thoughts here...")
    }
    
    // MARK: - JSON Parsing Tests - TriggerCheckResponse
    
    func testTriggerCheckResponseWithSurvey() throws {
        let json = """
        {
            "show": true,
            "survey": {
                "id": "survey-123",
                "title": "Quick Feedback",
                "questions": [
                    {
                        "id": "q1",
                        "type": "rating",
                        "text": "How satisfied are you?"
                    }
                ],
                "theme": {
                    "primaryColorHex": "#FF3366",
                    "layout": "popup"
                },
                "version": 1
            }
        }
        """
        
        let response = try JSONDecoder().decode(TriggerCheckResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(response.show)
        XCTAssertNotNil(response.survey)
        XCTAssertEqual(response.survey?.id, "survey-123")
        XCTAssertEqual(response.survey?.title, "Quick Feedback")
        XCTAssertEqual(response.survey?.questions.count, 1)
        XCTAssertEqual(response.survey?.theme?.primaryColorHex, "#FF3366")
        XCTAssertEqual(response.survey?.theme?.layout, "popup")
    }
    
    func testTriggerCheckResponseNoSurvey() throws {
        let json = """
        {
            "show": false
        }
        """
        
        let response = try JSONDecoder().decode(TriggerCheckResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertFalse(response.show)
        XCTAssertNil(response.survey)
    }
    
    // MARK: - Hex Color Conversion Tests
    
    func testHexColorConversionValid6Digit() {
        let color = UIColor(hex: "#FF3366")
        
        XCTAssertNotNil(color)
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0, accuracy: 0.01)
        XCTAssertEqual(green, 0.2, accuracy: 0.01)
        XCTAssertEqual(blue, 0.4, accuracy: 0.01)
        XCTAssertEqual(alpha, 1.0, accuracy: 0.01)
    }
    
    func testHexColorConversionWithoutHash() {
        let color = UIColor(hex: "00FF00")
        
        XCTAssertNotNil(color)
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 0.0, accuracy: 0.01)
        XCTAssertEqual(green, 1.0, accuracy: 0.01)
        XCTAssertEqual(blue, 0.0, accuracy: 0.01)
    }
    
    func testHexColorConversionBlack() {
        let color = UIColor(hex: "#000000")
        
        XCTAssertNotNil(color)
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 0.0, accuracy: 0.01)
        XCTAssertEqual(green, 0.0, accuracy: 0.01)
        XCTAssertEqual(blue, 0.0, accuracy: 0.01)
    }
    
    func testHexColorConversionWhite() {
        let color = UIColor(hex: "#FFFFFF")
        
        XCTAssertNotNil(color)
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0, accuracy: 0.01)
        XCTAssertEqual(green, 1.0, accuracy: 0.01)
        XCTAssertEqual(blue, 1.0, accuracy: 0.01)
    }
    
    func testHexColorConversion8DigitWithAlpha() {
        let color = UIColor(hex: "#FF336680") // 50% alpha
        
        XCTAssertNotNil(color)
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0, accuracy: 0.01)
        XCTAssertEqual(green, 0.2, accuracy: 0.01)
        XCTAssertEqual(blue, 0.4, accuracy: 0.01)
        XCTAssertEqual(alpha, 0.5, accuracy: 0.01)
    }
    
    func testHexColorConversionInvalidHex() {
        let color = UIColor(hex: "#GGGGGG")
        XCTAssertNil(color)
    }
    
    func testHexColorConversionInvalidLength() {
        let color = UIColor(hex: "#FFF") // 3 digits not supported
        XCTAssertNil(color)
    }
    
    func testHexColorConversionEmpty() {
        let color = UIColor(hex: "")
        XCTAssertNil(color)
    }
    
    // MARK: - Theme Color Resolver Tests
    
    func testPrimaryColorResolverWithValidHex() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"primaryColorHex": "#FF5500"}
        """.data(using: .utf8)!)
        
        let color = ThemeColorResolver.primaryColor(from: theme)
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0, accuracy: 0.01)
        XCTAssertEqual(green, 0.33, accuracy: 0.01)
        XCTAssertEqual(blue, 0.0, accuracy: 0.01)
    }
    
    func testPrimaryColorResolverWithNilTheme() {
        let color = ThemeColorResolver.primaryColor(from: nil)
        XCTAssertNotNil(color)
        // Should return default color #C2662D
    }
    
    func testPrimaryColorResolverWithInvalidHex() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"primaryColorHex": "invalid"}
        """.data(using: .utf8)!)
        
        let color = ThemeColorResolver.primaryColor(from: theme)
        XCTAssertNotNil(color) // Should return default
    }
    
    func testBackgroundColorResolverDefault() {
        let color = ThemeColorResolver.backgroundColor(from: nil)
        XCTAssertNotNil(color)
        // Should return default color #FFFBF7
    }
    
    // MARK: - Font Family Mapping Tests
    
    func testFontFamilySystem() {
        let font = ThemeFontFactory.bodyFont(from: nil)
        XCTAssertNotNil(font)
        // System font should be used by default
    }
    
    func testFontFamilyRounded() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"fontFamily": "rounded"}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.bodyFont(from: theme)
        XCTAssertNotNil(font)
        
        // Verify it's a rounded design
        let descriptor = font.fontDescriptor
        XCTAssertNotNil(descriptor.object(forKey: .traits))
    }
    
    func testFontFamilySerif() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"fontFamily": "serif"}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.bodyFont(from: theme)
        XCTAssertNotNil(font)
    }
    
    func testFontFamilyMono() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"fontFamily": "mono"}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.bodyFont(from: theme)
        XCTAssertNotNil(font)
        
        // Monospaced fonts have fixed-width attributes
        XCTAssertTrue(font.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
    }
    
    func testFontFamilyCasual() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"fontFamily": "casual"}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.bodyFont(from: theme)
        XCTAssertNotNil(font)
    }
    
    func testFontFamilyUnknownFallsBackToSystem() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"fontFamily": "comic_sans"}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.bodyFont(from: theme)
        XCTAssertNotNil(font)
        // Should fallback to system font without crashing
    }
    
    func testTitleFontSize() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"titleFontSize": 24}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.titleFont(from: theme)
        XCTAssertEqual(font.pointSize, 24)
    }
    
    func testButtonFontSize() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"buttonFontSize": 18}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.buttonFont(from: theme)
        XCTAssertEqual(font.pointSize, 18)
    }
    
    // MARK: - Layout Resolver Tests
    
    func testLayoutResolverPopup() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"layout": "popup"}
        """.data(using: .utf8)!)
        
        XCTAssertFalse(ThemeLayoutResolver.isFullscreen(from: theme))
    }
    
    func testLayoutResolverFullscreen() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"layout": "fullscreen"}
        """.data(using: .utf8)!)
        
        XCTAssertTrue(ThemeLayoutResolver.isFullscreen(from: theme))
    }
    
    func testLayoutResolverDefault() {
        XCTAssertFalse(ThemeLayoutResolver.isFullscreen(from: nil))
    }
    
    func testContentPaddingDefault() {
        let padding = ThemeLayoutResolver.contentPadding(from: nil)
        XCTAssertEqual(padding, 20) // Default from SurveyThemeDefaults
    }
    
    func testContentPaddingCustom() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"contentPadding": 32}
        """.data(using: .utf8)!)
        
        let padding = ThemeLayoutResolver.contentPadding(from: theme)
        XCTAssertEqual(padding, 32)
    }
    
    func testTextAlignmentLeft() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"textAlign": "left"}
        """.data(using: .utf8)!)
        
        XCTAssertEqual(ThemeLayoutResolver.textAlignment(from: theme), .natural)
    }
    
    func testTextAlignmentCenter() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"textAlign": "center"}
        """.data(using: .utf8)!)
        
        XCTAssertEqual(ThemeLayoutResolver.textAlignment(from: theme), .center)
    }
    
    // MARK: - Corner Radius Resolver Tests
    
    func testCardCornerRadiusDefault() {
        let radius = ThemeCornerRadiusResolver.cardCornerRadius(from: nil)
        XCTAssertEqual(radius, 16) // Default
    }
    
    func testCardCornerRadiusCustom() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"cornerRadius": 24}
        """.data(using: .utf8)!)
        
        let radius = ThemeCornerRadiusResolver.cardCornerRadius(from: theme)
        XCTAssertEqual(radius, 24)
    }
    
    func testCardCornerRadiusZeroForFullscreen() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"layout": "fullscreen", "cornerRadius": 24}
        """.data(using: .utf8)!)
        
        let radius = ThemeCornerRadiusResolver.cardCornerRadius(from: theme)
        XCTAssertEqual(radius, 0) // Fullscreen ignores corner radius
    }
    
    func testButtonCornerRadiusDefault() {
        let radius = ThemeCornerRadiusResolver.buttonCornerRadius(from: nil)
        XCTAssertEqual(radius, 10) // Default
    }
    
    func testButtonCornerRadiusCustom() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"buttonCornerRadius": 20}
        """.data(using: .utf8)!)
        
        let radius = ThemeCornerRadiusResolver.buttonCornerRadius(from: theme)
        XCTAssertEqual(radius, 20)
    }
    
    // MARK: - Display Settings Resolver Tests
    
    func testDelaySecondsDefault() {
        let delay = ThemeDisplayResolver.delaySeconds(from: nil)
        XCTAssertEqual(delay, 0)
    }
    
    func testDelaySecondsCustom() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"delaySeconds": 5}
        """.data(using: .utf8)!)
        
        let delay = ThemeDisplayResolver.delaySeconds(from: theme)
        XCTAssertEqual(delay, 5)
    }
    
    func testDelaySecondsClamped() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"delaySeconds": 60}
        """.data(using: .utf8)!)
        
        let delay = ThemeDisplayResolver.delaySeconds(from: theme)
        XCTAssertEqual(delay, 30) // Clamped to max 30
    }
    
    func testShowCloseButtonDefault() {
        XCTAssertTrue(ThemeDisplayResolver.showCloseButton(from: nil))
    }
    
    func testShowCloseButtonFalse() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"showCloseButton": false}
        """.data(using: .utf8)!)
        
        XCTAssertFalse(ThemeDisplayResolver.showCloseButton(from: theme))
    }
    
    func testEntranceAnimationDefault() {
        let animation = ThemeDisplayResolver.entranceAnimation(from: nil)
        XCTAssertEqual(animation, .slideFromBottom)
    }
    
    func testEntranceAnimationFadeIn() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"entranceAnimation": "fadeIn"}
        """.data(using: .utf8)!)
        
        let animation = ThemeDisplayResolver.entranceAnimation(from: theme)
        XCTAssertEqual(animation, .fadeIn)
    }
    
    func testEntranceAnimationScale() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"entranceAnimation": "scale"}
        """.data(using: .utf8)!)
        
        let animation = ThemeDisplayResolver.entranceAnimation(from: theme)
        XCTAssertEqual(animation, .scale)
    }
    
    func testEntranceAnimationNone() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"entranceAnimation": "none"}
        """.data(using: .utf8)!)
        
        let animation = ThemeDisplayResolver.entranceAnimation(from: theme)
        XCTAssertEqual(animation, .none)
    }
    
    func testAnimationSpeedDefault() {
        let speed = ThemeDisplayResolver.animationSpeed(from: nil)
        XCTAssertEqual(speed, .normal)
        XCTAssertEqual(speed.duration, 0.75)
    }
    
    func testAnimationSpeedFast() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"animationSpeed": "fast"}
        """.data(using: .utf8)!)
        
        let speed = ThemeDisplayResolver.animationSpeed(from: theme)
        XCTAssertEqual(speed, .fast)
        XCTAssertEqual(speed.duration, 0.5)
    }
    
    func testAnimationSpeedSlow() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"animationSpeed": "slow"}
        """.data(using: .utf8)!)
        
        let speed = ThemeDisplayResolver.animationSpeed(from: theme)
        XCTAssertEqual(speed, .slow)
        XCTAssertEqual(speed.duration, 1.0)
    }
    
    // MARK: - Edge Case Tests
    
    func testSurveyWithNullTheme() throws {
        let json = """
        {
            "id": "test-id",
            "title": "Test Survey",
            "questions": [],
            "theme": null
        }
        """
        
        let survey = try JSONDecoder().decode(Survey.self, from: json.data(using: .utf8)!)
        
        XCTAssertNil(survey.theme)
        // Verify defaults are used when theme is nil
        XCTAssertFalse(ThemeLayoutResolver.isFullscreen(from: survey.theme))
        XCTAssertNotNil(ThemeColorResolver.primaryColor(from: survey.theme))
    }
    
    func testSurveyWithEmptyQuestions() throws {
        let json = """
        {
            "id": "test-id",
            "title": "Test Survey",
            "questions": []
        }
        """
        
        let survey = try JSONDecoder().decode(Survey.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(survey.questions.isEmpty)
    }
    
    func testMultipleQuestionsDecoding() throws {
        let json = """
        {
            "id": "multi-q-survey",
            "title": "Multi-Question Survey",
            "questions": [
                {"id": "q1", "type": "rating", "text": "Rate us"},
                {"id": "q2", "type": "multiple_choice", "text": "Pick one", "options": ["A", "B"]},
                {"id": "q3", "type": "text", "text": "Tell us more", "placeholder": "Type here"}
            ]
        }
        """
        
        let survey = try JSONDecoder().decode(Survey.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(survey.questions.count, 3)
        XCTAssertEqual(survey.questions[0].type, .rating)
        XCTAssertEqual(survey.questions[1].type, .multipleChoice)
        XCTAssertEqual(survey.questions[2].type, .text)
    }
    
    func testLargeCornerRadiusClamped() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"cornerRadius": 100}
        """.data(using: .utf8)!)
        
        let radius = ThemeCornerRadiusResolver.cardCornerRadius(from: theme)
        XCTAssertEqual(radius, 50) // Clamped to max 50
    }
    
    func testNegativeCornerRadiusUsesDefault() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"cornerRadius": -10}
        """.data(using: .utf8)!)
        
        let radius = ThemeCornerRadiusResolver.cardCornerRadius(from: theme)
        XCTAssertEqual(radius, 16) // Falls back to default
    }
    
    func testNegativeFontSizeUsesDefault() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"titleFontSize": -5}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.titleFont(from: theme)
        XCTAssertEqual(font.pointSize, 18) // Default title font size
    }
    
    func testZeroFontSizeUsesDefault() {
        let theme = try! JSONDecoder().decode(SurveyTheme.self, from: """
        {"fontSize": 0}
        """.data(using: .utf8)!)
        
        let font = ThemeFontFactory.baseFont(from: theme)
        XCTAssertEqual(font.pointSize, 14) // Default base font size
    }
    
    // MARK: - UIColor isDark Tests
    
    func testIsDarkBlack() {
        let color = UIColor(hex: "#000000")!
        XCTAssertTrue(color.isDark)
    }
    
    func testIsDarkWhite() {
        let color = UIColor(hex: "#FFFFFF")!
        XCTAssertFalse(color.isDark)
    }
    
    func testIsDarkBrightRed() {
        let color = UIColor(hex: "#FF0000")!
        XCTAssertFalse(color.isDark) // Red has high luminance
    }
    
    func testIsDarkDarkBlue() {
        let color = UIColor(hex: "#000066")!
        XCTAssertTrue(color.isDark)
    }
    
    // MARK: - Entrance Animation Tests
    
    func testEntranceAnimationFromValidString() {
        XCTAssertEqual(EntranceAnimation(from: "slideFromBottom"), .slideFromBottom)
        XCTAssertEqual(EntranceAnimation(from: "slideFromTop"), .slideFromTop)
        XCTAssertEqual(EntranceAnimation(from: "slideFromLeft"), .slideFromLeft)
        XCTAssertEqual(EntranceAnimation(from: "slideFromRight"), .slideFromRight)
        XCTAssertEqual(EntranceAnimation(from: "fadeIn"), .fadeIn)
        XCTAssertEqual(EntranceAnimation(from: "scale"), .scale)
        XCTAssertEqual(EntranceAnimation(from: "none"), .none)
    }
    
    func testEntranceAnimationFromInvalidString() {
        XCTAssertEqual(EntranceAnimation(from: "bounce"), .slideFromBottom) // Falls back to default
    }
    
    func testEntranceAnimationFromNil() {
        XCTAssertEqual(EntranceAnimation(from: nil), .slideFromBottom)
    }
    
    // MARK: - Animation Speed Tests
    
    func testAnimationSpeedFromValidString() {
        XCTAssertEqual(AnimationSpeed(from: "fast"), .fast)
        XCTAssertEqual(AnimationSpeed(from: "normal"), .normal)
        XCTAssertEqual(AnimationSpeed(from: "slow"), .slow)
    }
    
    func testAnimationSpeedFromInvalidString() {
        XCTAssertEqual(AnimationSpeed(from: "veryfast"), .normal) // Falls back to default
    }
    
    func testAnimationSpeedDurations() {
        XCTAssertEqual(AnimationSpeed.fast.duration, 0.5)
        XCTAssertEqual(AnimationSpeed.normal.duration, 0.75)
        XCTAssertEqual(AnimationSpeed.slow.duration, 1.0)
    }
}

// MARK: - Integration Tests

final class FeedbackWallIntegrationTests: XCTestCase {
    
    // NOTE: Integration tests use mock values. For real integration testing,
    // set up a local test server or use environment variables.
    private let testBaseURL = URL(string: "https://api.example.feedbackwall.io")!
    private let testAPIKey = "test_api_key_placeholder"
    
    override func setUp() {
        super.setUp()
        FeedbackWall.configure(apiKey: testAPIKey, baseURL: testBaseURL)
    }
    
    // MARK: - Ping Endpoint Test
    
    func testPingEndpoint() async throws {
        // The ping is sent automatically on configure, but we can verify SDK is configured
        XCTAssertTrue(FeedbackWall.isConfigured)
    }
    
    // MARK: - Trigger Check Tests
    
    func testTriggerCheckWithValidTrigger() async throws {
        let survey = await FeedbackWall.checkTrigger("onboarding_completed")
        
        // Note: This depends on backend having a survey configured for this trigger
        // The test passes whether a survey is returned or not - it just verifies no crash
        if let survey = survey {
            XCTAssertFalse(survey.id.isEmpty)
            XCTAssertFalse(survey.title.isEmpty)
        }
    }
    
    func testTriggerCheckWithUnknownTrigger() async throws {
        let survey = await FeedbackWall.checkTrigger("unknown_trigger_12345")
        
        // Should return nil without crashing
        // (depends on backend configuration)
        _ = survey // Just verify it doesn't crash
    }
    
    func testTriggerCheckWithSpecialCharacters() async throws {
        let survey = await FeedbackWall.checkTrigger("test-trigger_with.special:chars")
        
        // Should handle gracefully without crashing
        _ = survey
    }
    
    func testTriggerCheckWithEmptyTrigger() async throws {
        let survey = await FeedbackWall.checkTrigger("")
        
        // Should handle gracefully
        XCTAssertNil(survey)
    }
    
    // MARK: - User Identification Tests
    
    func testIdentifyUser() {
        // This should not crash
        FeedbackWall.identify(userId: "test_user_123")
        
        XCTAssertEqual(UserSession.shared.userId, "test_user_123")
    }
    
    func testIdentifyUserWithTraits() {
        FeedbackWall.identify(
            userId: "test_user_456",
            traits: [
                "plan": "premium",
                "signupDate": "2024-01-15",
                "age": 25
            ]
        )
        
        XCTAssertEqual(UserSession.shared.userId, "test_user_456")
        XCTAssertNotNil(UserSession.shared.traits)
    }
    
    func testResetUser() {
        FeedbackWall.identify(userId: "user_to_reset")
        XCTAssertEqual(UserSession.shared.userId, "user_to_reset")
        
        FeedbackWall.reset()
        XCTAssertNil(UserSession.shared.userId)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkTimeoutDoesNotCrash() async throws {
        // Configure with invalid URL that will timeout
        let invalidURL = URL(string: "https://invalid.domain.that.does.not.exist.12345.com")!
        FeedbackWall.configure(apiKey: "test_key", baseURL: invalidURL)
        
        // This should timeout gracefully and return nil
        let survey = await FeedbackWall.checkTrigger("test")
        XCTAssertNil(survey)
        
        // Reset to valid URL for other tests
        FeedbackWall.configure(apiKey: testAPIKey, baseURL: testBaseURL)
    }
}

// MARK: - Complete Survey JSON Parsing Test

final class CompleteSurveyParsingTests: XCTestCase {
    
    func testCompleteServerResponseParsing() throws {
        // This mimics a complete response from the server
        let json = """
        {
            "show": true,
            "survey": {
                "id": "cm4a7xyzq0001abc123def456",
                "title": "How's your experience?",
                "description": "Help us improve by answering a few quick questions.",
                "questions": [
                    {
                        "id": "q1_rating",
                        "type": "rating",
                        "text": "How would you rate our app?"
                    },
                    {
                        "id": "q2_choice",
                        "type": "multiple_choice",
                        "text": "What feature do you use most?",
                        "options": ["Dashboard", "Reports", "Settings", "Notifications"]
                    },
                    {
                        "id": "q3_feedback",
                        "type": "text",
                        "text": "Any suggestions for improvement?",
                        "placeholder": "Share your thoughts..."
                    }
                ],
                "theme": {
                    "layout": "popup",
                    "primaryColorHex": "#6366F1",
                    "backgroundColorHex": "#FFFFFF",
                    "textColorHex": "#1F2937",
                    "buttonTextColorHex": "#FFFFFF",
                    "optionSelectedBackgroundHex": "#6366F1",
                    "optionSelectedTextHex": "#FFFFFF",
                    "cornerRadius": 16,
                    "buttonCornerRadius": 8,
                    "fontFamily": "system",
                    "fontSize": 14,
                    "titleFontSize": 18,
                    "bodyFontSize": 14,
                    "buttonFontSize": 16,
                    "textAlign": "left",
                    "contentPadding": 24,
                    "delaySeconds": 2,
                    "showCloseButton": true,
                    "entranceAnimation": "slideFromBottom",
                    "animationSpeed": "normal"
                },
                "version": 3
            }
        }
        """
        
        let response = try JSONDecoder().decode(TriggerCheckResponse.self, from: json.data(using: .utf8)!)
        
        // Verify response
        XCTAssertTrue(response.show)
        XCTAssertNotNil(response.survey)
        
        guard let survey = response.survey else {
            XCTFail("Survey should not be nil")
            return
        }
        
        // Verify survey
        XCTAssertEqual(survey.id, "cm4a7xyzq0001abc123def456")
        XCTAssertEqual(survey.title, "How's your experience?")
        XCTAssertEqual(survey.description, "Help us improve by answering a few quick questions.")
        XCTAssertEqual(survey.version, 3)
        
        // Verify questions
        XCTAssertEqual(survey.questions.count, 3)
        XCTAssertEqual(survey.questions[0].type, .rating)
        XCTAssertEqual(survey.questions[1].type, .multipleChoice)
        XCTAssertEqual(survey.questions[1].options?.count, 4)
        XCTAssertEqual(survey.questions[2].type, .text)
        XCTAssertEqual(survey.questions[2].placeholder, "Share your thoughts...")
        
        // Verify theme
        guard let theme = survey.theme else {
            XCTFail("Theme should not be nil")
            return
        }
        
        XCTAssertEqual(theme.layout, "popup")
        XCTAssertEqual(theme.primaryColorHex, "#6366F1")
        XCTAssertEqual(theme.backgroundColorHex, "#FFFFFF")
        XCTAssertEqual(theme.textColorHex, "#1F2937")
        XCTAssertEqual(theme.cornerRadius, 16)
        XCTAssertEqual(theme.fontFamily, "system")
        XCTAssertEqual(theme.delaySeconds, 2)
        XCTAssertEqual(theme.showCloseButton, true)
        XCTAssertEqual(theme.entranceAnimation, "slideFromBottom")
        XCTAssertEqual(theme.animationSpeed, "normal")
        
        // Verify theme resolvers work correctly
        XCTAssertFalse(ThemeLayoutResolver.isFullscreen(from: theme))
        XCTAssertEqual(ThemeLayoutResolver.contentPadding(from: theme), 24)
        XCTAssertEqual(ThemeDisplayResolver.delaySeconds(from: theme), 2)
        XCTAssertTrue(ThemeDisplayResolver.showCloseButton(from: theme))
        XCTAssertEqual(ThemeDisplayResolver.entranceAnimation(from: theme), .slideFromBottom)
        XCTAssertEqual(ThemeDisplayResolver.animationSpeed(from: theme), .normal)
        
        // Verify color resolution
        let primaryColor = ThemeColorResolver.primaryColor(from: theme)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        primaryColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.388, accuracy: 0.01) // #63 = 99/255 ≈ 0.388
        XCTAssertEqual(g, 0.400, accuracy: 0.01) // #66 = 102/255 ≈ 0.400
        XCTAssertEqual(b, 0.945, accuracy: 0.01) // #F1 = 241/255 ≈ 0.945
    }
}
