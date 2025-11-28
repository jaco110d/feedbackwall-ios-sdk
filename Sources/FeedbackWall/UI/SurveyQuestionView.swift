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
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isHidden = true
        return field
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
        
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            optionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            optionsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Default 1-5 rating if no options provided
        let ratings = question.options ?? ["1", "2", "3", "4", "5"]
        
        for (index, rating) in ratings.enumerated() {
            let button = createOptionButton(title: rating, tag: index)
            button.layer.cornerRadius = 22
            optionButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    private func setupTextInput() {
        textField.placeholder = question.placeholder ?? "Enter your response..."
        textField.isHidden = false
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func createOptionButton(title: String, tag: Int) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
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
        selectedConfig.baseBackgroundColor = .systemBlue
        selectedConfig.baseForegroundColor = .white
        sender.configuration = selectedConfig
        
        selectedAnswer = sender.configuration?.title
        
        if let answer = selectedAnswer {
            delegate?.questionView(self, didSelectAnswer: answer, for: question)
        }
    }
    
    @objc private func textFieldDidChange() {
        selectedAnswer = textField.text
        if let answer = selectedAnswer, !answer.isEmpty {
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
        // Theme application will be implemented when needed
        // For now, using system defaults
    }
}

