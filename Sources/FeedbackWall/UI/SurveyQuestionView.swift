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
        stack.spacing = 12
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
        label.font = ThemeFontFactory.bodyFont(from: theme).withSize(12)
        label.textColor = ThemeColorResolver.labelColor(from: theme)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var excellentLabel: UILabel = {
        let label = UILabel()
        label.text = "Excellent"
        label.font = ThemeFontFactory.bodyFont(from: theme).withSize(12)
        label.textColor = ThemeColorResolver.labelColor(from: theme)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = ThemeFontFactory.bodyFont(from: theme)
        tv.textColor = textColor
        tv.backgroundColor = optionUnselectedBackground
        tv.layer.borderColor = optionUnselectedBorder.cgColor
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
        label.textColor = ThemeColorResolver.labelColor(from: theme)
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
        textView.layer.borderColor = optionUnselectedBorder.cgColor
        textView.layer.borderWidth = 1
    }
}

// MARK: - OptionRowView

/// A tappable option row with radio-style selection indicator.
final class OptionRowView: UIControl {
    
    // MARK: - Properties
    
    private let theme: SurveyTheme?
    private var isSelectedState: Bool = false
    
    // Theme colors
    private var selectedBackground: UIColor
    private var selectedTextColor: UIColor
    private var unselectedBackground: UIColor
    private var unselectedBorder: UIColor
    private var textColor: UIColor
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = unselectedBackground
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = unselectedBorder.cgColor
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var radioIndicator: UIView = {
        let outer = UIView()
        outer.layer.cornerRadius = 10
        outer.layer.borderWidth = 2
        outer.layer.borderColor = unselectedBorder.cgColor
        outer.backgroundColor = .clear
        outer.isUserInteractionEnabled = false
        outer.translatesAutoresizingMaskIntoConstraints = false
        return outer
    }()
    
    private lazy var radioInnerDot: UIView = {
        let dot = UIView()
        dot.layer.cornerRadius = 5
        dot.backgroundColor = selectedTextColor
        dot.isHidden = true
        dot.isUserInteractionEnabled = false
        dot.translatesAutoresizingMaskIntoConstraints = false
        return dot
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFontFactory.baseFont(from: theme)
        label.textColor = textColor
        label.numberOfLines = 0
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
        self.selectedBackground = ThemeColorResolver.optionSelectedBackground(from: theme)
        self.selectedTextColor = ThemeColorResolver.optionSelectedText(from: theme)
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
        radioIndicator.addSubview(radioInnerDot)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            radioIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            radioIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            radioIndicator.widthAnchor.constraint(equalToConstant: 20),
            radioIndicator.heightAnchor.constraint(equalToConstant: 20),
            
            radioInnerDot.centerXAnchor.constraint(equalTo: radioIndicator.centerXAnchor),
            radioInnerDot.centerYAnchor.constraint(equalTo: radioIndicator.centerYAnchor),
            radioInnerDot.widthAnchor.constraint(equalToConstant: 10),
            radioInnerDot.heightAnchor.constraint(equalToConstant: 10),
            
            titleLabel.leadingAnchor.constraint(equalTo: radioIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }
    
    // MARK: - Selection
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            if selected {
                self.containerView.backgroundColor = self.selectedBackground
                self.containerView.layer.borderColor = UIColor.clear.cgColor
                self.titleLabel.textColor = self.selectedTextColor
                self.radioIndicator.layer.borderColor = self.selectedTextColor.cgColor
                self.radioInnerDot.isHidden = false
            } else {
                self.containerView.backgroundColor = self.unselectedBackground
                self.containerView.layer.borderColor = self.unselectedBorder.cgColor
                self.titleLabel.textColor = self.textColor
                self.radioIndicator.layer.borderColor = self.unselectedBorder.cgColor
                self.radioInnerDot.isHidden = true
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
