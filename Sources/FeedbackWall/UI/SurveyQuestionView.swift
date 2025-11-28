import UIKit

/// Protocol for handling question answer events.
protocol SurveyQuestionViewDelegate: AnyObject {
    func questionView(_ view: SurveyQuestionView, didSelectAnswer answer: String, for question: SurveyQuestion)
}

/// View for displaying a single survey question and collecting the answer.
final class SurveyQuestionView: UIView {
    
    // MARK: - Properties
    
    private let question: SurveyQuestion
    private let theme: SurveyTheme?
    weak var delegate: SurveyQuestionViewDelegate?
    
    private var selectedAnswer: String?
    private var selectedRating: Int = 0
    
    // Cached theme-derived values
    private var primaryColor: UIColor = .systemBlue
    private var textColor: UIColor = .label
    private var buttonTextColor: UIColor = .white
    private var buttonCornerRadius: CGFloat = 10.0
    private var optionSelectedBackground: UIColor = .systemBlue
    private var optionSelectedText: UIColor = .white
    private var optionUnselectedBackground: UIColor = .secondarySystemBackground
    private var optionUnselectedBorder: UIColor = .separator
    
    // MARK: - UI Components
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFontFactory.questionFont(from: theme)
        label.textColor = textColor
        label.numberOfLines = 0
        label.textAlignment = ThemeLayoutResolver.textAlignment(from: theme)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10  // Clean spacing between options
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var starsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var poorLabel: UILabel = {
        let label = UILabel()
        label.text = "Poor"
        // Per spec: baseFontSize * 0.85
        let fontSize = CGFloat(theme?.fontSize ?? 14) * 0.85
        label.font = ThemeFontFactory.bodyFont(from: theme).withSize(fontSize)
        label.textColor = textColor.withAlphaComponent(0.80)  // Per spec: 80% opacity
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var excellentLabel: UILabel = {
        let label = UILabel()
        label.text = "Excellent"
        // Per spec: baseFontSize * 0.85
        let fontSize = CGFloat(theme?.fontSize ?? 14) * 0.85
        label.font = ThemeFontFactory.bodyFont(from: theme).withSize(fontSize)
        label.textColor = textColor.withAlphaComponent(0.80)  // Per spec: 80% opacity
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = ThemeFontFactory.bodyFont(from: theme)
        tv.textColor = textColor
        tv.backgroundColor = textColor.withAlphaComponent(0.08)  // Per spec: 8% opacity
        tv.layer.borderColor = textColor.withAlphaComponent(0.20).cgColor  // Per spec: 20% opacity
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = buttonCornerRadius
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isHidden = true
        tv.delegate = self
        return tv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFontFactory.bodyFont(from: theme)
        label.textColor = textColor.withAlphaComponent(0.50)  // Per spec: 50% opacity
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var optionViews: [OptionRowView] = []
    private var starButtons: [UIButton] = []
    
    // MARK: - Initialization
    
    init(question: SurveyQuestion, theme: SurveyTheme? = nil) {
        self.question = question
        self.theme = theme
        super.init(frame: .zero)
        resolveThemeColors()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Theme
    
    private func resolveThemeColors() {
        primaryColor = ThemeColorResolver.primaryColor(from: theme)
        textColor = ThemeColorResolver.textColor(from: theme)
        buttonTextColor = ThemeColorResolver.buttonTextColor(from: theme)
        buttonCornerRadius = ThemeCornerRadiusResolver.buttonCornerRadius(from: theme)
        optionSelectedBackground = ThemeColorResolver.optionSelectedBackground(from: theme)
        optionSelectedText = ThemeColorResolver.optionSelectedText(from: theme)
        optionUnselectedBackground = ThemeColorResolver.optionUnselectedBackground(from: theme)
        optionUnselectedBorder = ThemeColorResolver.optionUnselectedBorder(from: theme)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        questionLabel.text = question.text
        addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        switch question.type {
        case .multipleChoice:
            setupMultipleChoice()
        case .rating:
            setupStarRating()
        case .text:
            setupTextInput()
        }
    }
    
    // MARK: - Multiple Choice
    
    private func setupMultipleChoice() {
        addSubview(optionsStackView)
        
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            optionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        guard let options = question.options else { return }
        
        for (index, option) in options.enumerated() {
            let optionView = OptionRowView(
                title: option,
                theme: theme,
                cornerRadius: buttonCornerRadius
            )
            optionView.tag = index
            optionView.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionViews.append(optionView)
            optionsStackView.addArrangedSubview(optionView)
        }
    }
    
    @objc private func optionTapped(_ sender: OptionRowView) {
        // Deselect all options
        optionViews.forEach { $0.setSelected(false) }
        
        // Select tapped option
        sender.setSelected(true)
        
        guard let options = question.options, sender.tag < options.count else { return }
        
        selectedAnswer = options[sender.tag]
        
        if let answer = selectedAnswer {
            delegate?.questionView(self, didSelectAnswer: answer, for: question)
        }
    }
    
    // MARK: - Star Rating
    
    private func setupStarRating() {
        addSubview(starsContainerView)
        starsContainerView.addSubview(starsStackView)
        starsContainerView.addSubview(poorLabel)
        starsContainerView.addSubview(excellentLabel)
        
        NSLayoutConstraint.activate([
            starsContainerView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            starsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            starsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            starsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            starsStackView.topAnchor.constraint(equalTo: starsContainerView.topAnchor),
            starsStackView.centerXAnchor.constraint(equalTo: starsContainerView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 44),
            
            poorLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 8),
            poorLabel.leadingAnchor.constraint(equalTo: starsStackView.leadingAnchor),
            poorLabel.bottomAnchor.constraint(equalTo: starsContainerView.bottomAnchor),
            
            excellentLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 8),
            excellentLabel.trailingAnchor.constraint(equalTo: starsStackView.trailingAnchor),
            excellentLabel.bottomAnchor.constraint(equalTo: starsContainerView.bottomAnchor)
        ])
        
        // Create 5 star buttons
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.tag = i
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            starButton.setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
            starButton.tintColor = textColor.withAlphaComponent(0.30)
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButton.translatesAutoresizingMaskIntoConstraints = false
            starButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            starButtons.append(starButton)
            starsStackView.addArrangedSubview(starButton)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        selectedRating = rating
        
        // Update star appearance
        for (index, button) in starButtons.enumerated() {
            let starIndex = index + 1
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            
            if starIndex <= rating {
                button.setImage(UIImage(systemName: "star.fill", withConfiguration: config), for: .normal)
                button.tintColor = primaryColor
            } else {
                button.setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
                button.tintColor = textColor.withAlphaComponent(0.30)
            }
        }
        
        selectedAnswer = String(rating)
        delegate?.questionView(self, didSelectAnswer: String(rating), for: question)
    }
    
    // MARK: - Text Input
    
    private func setupTextInput() {
        placeholderLabel.text = question.placeholder ?? "Enter your response..."
        textView.isHidden = false
        placeholderLabel.isHidden = false
        
        addSubview(textView)
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 13)
        ])
    }
    
    // MARK: - Public Methods
    
    /// Returns the currently selected answer, if any.
    func getAnswer() -> String? {
        return selectedAnswer
    }
    
    /// Applies theme styling to the question view (legacy method, kept for compatibility).
    func applyTheme(_ theme: SurveyTheme?) {
        // Theme is now applied in init, this method exists for backward compatibility
    }
}

// MARK: - UITextViewDelegate

extension SurveyQuestionView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        selectedAnswer = textView.text
        
        if let answer = selectedAnswer, !answer.isEmpty {
            delegate?.questionView(self, didSelectAnswer: answer, for: question)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = primaryColor.cgColor
        textView.layer.borderWidth = 2
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = textColor.withAlphaComponent(0.20).cgColor  // Per spec: 20% opacity
        textView.layer.borderWidth = 1
    }
}

// MARK: - OptionRowView

/// A tappable option row with radio-style selection indicator.
/// Matches the FeedbackWall web preview pixel-perfectly.
final class OptionRowView: UIControl {
    
    // MARK: - Properties
    
    private let theme: SurveyTheme?
    private var isSelectedState: Bool = false
    
    // Theme colors
    private var primaryColor: UIColor
    private var selectedBackground: UIColor
    private var unselectedBackground: UIColor
    private var unselectedBorder: UIColor
    private var textColor: UIColor
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = unselectedBackground
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 0
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Radio button outer circle (16x16 per spec)
    private lazy var radioIndicator: UIView = {
        let outer = UIView()
        outer.layer.cornerRadius = 8  // 16/2 = 8
        outer.layer.borderWidth = 2
        outer.layer.borderColor = unselectedBorder.cgColor
        outer.backgroundColor = .clear
        outer.isUserInteractionEnabled = false
        outer.translatesAutoresizingMaskIntoConstraints = false
        return outer
    }()
    
    /// White inner ring that creates the "dot" effect when selected
    private lazy var radioInnerRing: UIView = {
        let ring = UIView()
        ring.layer.cornerRadius = 5  // 10/2 = 5 (3pt inset from 16x16)
        ring.backgroundColor = .white
        ring.isHidden = true
        ring.isUserInteractionEnabled = false
        ring.translatesAutoresizingMaskIntoConstraints = false
        return ring
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFontFactory.baseFont(from: theme)
        label.textColor = textColor
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cornerRadius: CGFloat
    
    // MARK: - Initialization
    
    init(title: String, theme: SurveyTheme?, cornerRadius: CGFloat) {
        self.theme = theme
        self.cornerRadius = cornerRadius
        
        // Resolve colors
        self.primaryColor = ThemeColorResolver.primaryColor(from: theme)
        self.selectedBackground = ThemeColorResolver.optionSelectedBackground(from: theme)
        self.unselectedBackground = ThemeColorResolver.optionUnselectedBackground(from: theme)
        self.unselectedBorder = ThemeColorResolver.optionUnselectedBorder(from: theme)
        self.textColor = ThemeColorResolver.textColor(from: theme)
        
        super.init(frame: .zero)
        
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(radioIndicator)
        radioIndicator.addSubview(radioInnerRing)
        containerView.addSubview(titleLabel)
        
        // Layout for clean, modern appearance - match button height (48pt)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Radio button: 16pt from left edge, 16x16 size
            radioIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            radioIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            radioIndicator.widthAnchor.constraint(equalToConstant: 16),
            radioIndicator.heightAnchor.constraint(equalToConstant: 16),
            
            // Inner ring: centered with 10x10 size
            radioInnerRing.centerXAnchor.constraint(equalTo: radioIndicator.centerXAnchor),
            radioInnerRing.centerYAnchor.constraint(equalTo: radioIndicator.centerYAnchor),
            radioInnerRing.widthAnchor.constraint(equalToConstant: 10),
            radioInnerRing.heightAnchor.constraint(equalToConstant: 10),
            
            // Title centered vertically with horizontal padding
            titleLabel.leadingAnchor.constraint(equalTo: radioIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    // MARK: - Selection
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            if selected {
                // SELECTED STATE:
                // - Background: primaryColor @ 20% opacity
                // - Text: stays textColor (NOT white)
                // - Radio: primaryColor fill with white inner ring
                self.containerView.backgroundColor = self.selectedBackground
                self.titleLabel.textColor = self.textColor  // Text stays same color
                self.radioIndicator.layer.borderColor = self.primaryColor.cgColor
                self.radioIndicator.backgroundColor = self.primaryColor
                self.radioInnerRing.isHidden = false
            } else {
                // UNSELECTED STATE:
                // - Background: textColor @ 8% opacity
                // - Text: textColor
                // - Radio: transparent with border
                self.containerView.backgroundColor = self.unselectedBackground
                self.titleLabel.textColor = self.textColor
                self.radioIndicator.layer.borderColor = self.unselectedBorder.cgColor
                self.radioIndicator.backgroundColor = .clear
                self.radioInnerRing.isHidden = true
            }
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        containerView.alpha = 0.7
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        containerView.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        containerView.alpha = 1.0
    }
}
