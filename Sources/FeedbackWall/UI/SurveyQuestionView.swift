import UIKit

/// Protocol for handling question answer events.
protocol SurveyQuestionViewDelegate: AnyObject {
    func questionView(_ view: SurveyQuestionView, didSelectAnswer answer: String, for question: SurveyQuestion)
}

/// View for displaying a single survey question and collecting the answer.
final class SurveyQuestionView: UIView {
    
    // MARK: - Properties
    
    private let question: SurveyQuestion
    weak var delegate: SurveyQuestionViewDelegate?
    
    private var selectedAnswer: String?
    private var theme: SurveyTheme?
    
    // Cached theme-derived values
    private var primaryColor: UIColor = .systemBlue
    private var textColor: UIColor = .label
    private var buttonTextColor: UIColor = .white
    private var buttonCornerRadius: CGFloat = 12.0
    
    // MARK: - UI Components
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFontFactory.questionFont(from: theme)
        label.textColor = textColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = ThemeFontFactory.bodyFont(from: theme)
        tv.textColor = textColor
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isHidden = true
        tv.delegate = self
        return tv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFontFactory.bodyFont(from: theme)
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var optionButtons: [UIButton] = []
    
    // MARK: - Initialization
    
    init(question: SurveyQuestion) {
        self.question = question
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            setupRating()
        case .text:
            setupTextInput()
        }
    }
    
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
            let button = createOptionButton(title: option, tag: index)
            optionButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    private func setupRating() {
        addSubview(optionsStackView)
        optionsStackView.axis = .horizontal
        optionsStackView.distribution = .fillEqually
        optionsStackView.spacing = 8
        
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            optionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            optionsStackView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // Default 1-5 rating if no options provided
        let ratings = question.options ?? ["1", "2", "3", "4", "5"]
        
        for (index, rating) in ratings.enumerated() {
            let button = createRatingButton(title: rating, tag: index)
            optionButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
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
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 13)
        ])
    }
    
    private func createOptionButton(title: String, tag: Int) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseForegroundColor = textColor
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = buttonCornerRadius
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        configuration.titleAlignment = .leading
        
        // Apply themed font
        let buttonFont = ThemeFontFactory.bodyFont(from: theme)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = buttonFont
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        button.tag = tag
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func createRatingButton(title: String, tag: Int) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseForegroundColor = textColor
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // Apply themed font
        let buttonFont = ThemeFontFactory.bodyFont(from: theme)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = buttonFont
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        button.tag = tag
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Actions
    
    @objc private func optionTapped(_ sender: UIButton) {
        // Deselect all buttons
        optionButtons.forEach { button in
            var config = button.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = .secondarySystemBackground
            config.baseForegroundColor = textColor
            button.configuration = config
        }
        
        // Select tapped button
        var selectedConfig = sender.configuration ?? UIButton.Configuration.filled()
        selectedConfig.baseBackgroundColor = primaryColor
        selectedConfig.baseForegroundColor = buttonTextColor
        sender.configuration = selectedConfig
        
        selectedAnswer = sender.configuration?.title
        
        if let answer = selectedAnswer {
            delegate?.questionView(self, didSelectAnswer: answer, for: question)
        }
    }
    
    // MARK: - Public Methods
    
    /// Returns the currently selected answer, if any.
    func getAnswer() -> String? {
        return selectedAnswer
    }
    
    /// Applies theme styling to the question view.
    /// Should be called before adding the view to the hierarchy for best results.
    func applyTheme(_ theme: SurveyTheme?) {
        self.theme = theme
        
        // Resolve theme colors
        primaryColor = ThemeColorResolver.primaryColor(from: theme)
        textColor = ThemeColorResolver.textColor(from: theme)
        buttonTextColor = ThemeColorResolver.buttonTextColor(from: theme)
        buttonCornerRadius = ThemeCornerRadiusResolver.buttonCornerRadius(from: theme)
        
        // Update existing UI elements
        questionLabel.font = ThemeFontFactory.questionFont(from: theme)
        questionLabel.textColor = textColor
        
        textView.font = ThemeFontFactory.bodyFont(from: theme)
        textView.textColor = textColor
        
        placeholderLabel.font = ThemeFontFactory.bodyFont(from: theme)
        
        // Update option buttons with theme
        updateOptionButtonsTheme()
    }
    
    /// Updates all option buttons with current theme styling.
    private func updateOptionButtonsTheme() {
        for button in optionButtons {
            var config = button.configuration ?? UIButton.Configuration.filled()
            
            // Determine if this button is selected (has primary color background)
            let isSelected = config.baseBackgroundColor == primaryColor
            
            if isSelected {
                config.baseBackgroundColor = primaryColor
                config.baseForegroundColor = buttonTextColor
            } else {
                config.baseForegroundColor = textColor
            }
            
            // Apply themed font to button
            let buttonFont = ThemeFontFactory.bodyFont(from: theme)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = buttonFont
                return outgoing
            }
            
            button.configuration = config
        }
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
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.separator.cgColor
    }
}

