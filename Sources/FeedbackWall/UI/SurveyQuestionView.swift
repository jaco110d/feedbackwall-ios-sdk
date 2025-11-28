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
    private var primaryColor: UIColor = .systemBlue
    
    // MARK: - UI Components
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
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
        tv.font = .systemFont(ofSize: 16)
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
        label.font = .systemFont(ofSize: 16)
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
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        configuration.titleAlignment = .leading
        
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
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
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
            config.baseForegroundColor = .label
            button.configuration = config
        }
        
        // Select tapped button
        var selectedConfig = sender.configuration ?? UIButton.Configuration.filled()
        selectedConfig.baseBackgroundColor = primaryColor
        selectedConfig.baseForegroundColor = .white
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
    func applyTheme(_ theme: SurveyTheme?) {
        if let hex = theme?.primaryColorHex, let color = UIColor(hex: hex) {
            primaryColor = color
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

// MARK: - UIColor Extension

private extension UIColor {
    /// Creates a UIColor from a hex string.
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        guard length == 6 || length == 8 else { return nil }
        
        if length == 6 {
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.init(
                red: CGFloat((rgb & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgb & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgb & 0x000000FF) / 255.0
            )
        }
    }
}
