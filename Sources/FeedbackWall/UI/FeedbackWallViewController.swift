import UIKit

/// The main view controller for displaying a FeedbackWall survey.
/// Presented modally with a dark dim background and a centered card.
final class FeedbackWallViewController: UIViewController {
    
    // MARK: - Properties
    
    private let survey: Survey
    private let trigger: String
    private let onDismiss: () -> Void
    
    private var answers: [String: String] = [:]
    private var currentQuestionIndex: Int = 0
    private var questionViews: [SurveyQuestionView] = []
    
    // MARK: - UI Components
    
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceVertical = false
        return scroll
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = survey.theme?.cornerRadius ?? 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var questionContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var primaryColor: UIColor {
        if let hex = survey.theme?.primaryColorHex {
            return UIColor(hex: hex) ?? .systemBlue
        }
        return .systemBlue
    }
    
    private var cardViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    init(survey: Survey, trigger: String, onDismiss: @escaping () -> Void) {
        self.survey = survey
        self.trigger = trigger
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
        setupKeyboardObservers()
        updateNavigationButtons()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Add dim view
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add tap gesture to dim view for dismissal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
        dimView.addGestureRecognizer(tapGesture)
        
        // Add scroll view
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        // Add card view inside scroll view
        scrollView.addSubview(cardView)
        let bottomConstraint = cardView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor)
        cardViewBottomConstraint = bottomConstraint
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor),
            cardView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).withPriority(.defaultLow),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomConstraint
        ])
        
        // Add close button
        cardView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Add title label
        cardView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])
        
        // Add description label
        cardView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])
        
        // Add progress label
        cardView.addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            progressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            progressLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])
        
        // Add question container view
        cardView.addSubview(questionContainerView)
        NSLayoutConstraint.activate([
            questionContainerView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            questionContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            questionContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])
        
        // Add button stack view
        cardView.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: questionContainerView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            buttonStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            buttonStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupContent() {
        titleLabel.text = survey.title
        descriptionLabel.text = survey.description
        descriptionLabel.isHidden = survey.description == nil
        
        // Create question views
        for question in survey.questions {
            let questionView = SurveyQuestionView(question: question)
            questionView.delegate = self
            questionView.applyTheme(survey.theme)
            questionView.translatesAutoresizingMaskIntoConstraints = false
            questionViews.append(questionView)
        }
        
        // Show first question
        showQuestion(at: 0)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Question Navigation
    
    private func showQuestion(at index: Int) {
        guard index >= 0 && index < questionViews.count else { return }
        
        // Remove current question view
        questionContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add new question view
        let questionView = questionViews[index]
        questionContainerView.addSubview(questionView)
        NSLayoutConstraint.activate([
            questionView.topAnchor.constraint(equalTo: questionContainerView.topAnchor),
            questionView.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor),
            questionView.bottomAnchor.constraint(equalTo: questionContainerView.bottomAnchor)
        ])
        
        currentQuestionIndex = index
        updateProgressLabel()
        updateNavigationButtons()
    }
    
    private func updateProgressLabel() {
        let total = survey.questions.count
        if total > 1 {
            progressLabel.text = "Question \(currentQuestionIndex + 1) of \(total)"
            progressLabel.isHidden = false
        } else {
            progressLabel.isHidden = true
        }
    }
    
    private func updateNavigationButtons() {
        buttonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let isFirstQuestion = currentQuestionIndex == 0
        let isLastQuestion = currentQuestionIndex == survey.questions.count - 1
        
        if survey.questions.count == 1 {
            // Single question - just show submit
            buttonStackView.addArrangedSubview(submitButton)
        } else if isFirstQuestion {
            // First question - just show next
            buttonStackView.addArrangedSubview(nextButton)
        } else if isLastQuestion {
            // Last question - show back and submit
            buttonStackView.addArrangedSubview(backButton)
            buttonStackView.addArrangedSubview(submitButton)
        } else {
            // Middle question - show back and next
            buttonStackView.addArrangedSubview(backButton)
            buttonStackView.addArrangedSubview(nextButton)
        }
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        view.endEditing(true)
        dismissSurvey()
    }
    
    @objc private func dimViewTapped() {
        view.endEditing(true)
        dismissSurvey()
    }
    
    @objc private func backTapped() {
        view.endEditing(true)
        if currentQuestionIndex > 0 {
            showQuestion(at: currentQuestionIndex - 1)
        }
    }
    
    @objc private func nextTapped() {
        view.endEditing(true)
        if currentQuestionIndex < survey.questions.count - 1 {
            showQuestion(at: currentQuestionIndex + 1)
        }
    }
    
    @objc private func submitTapped() {
        view.endEditing(true)
        
        // Collect all answers
        let surveyAnswers = answers.map { questionId, value in
            SurveyAnswer(questionId: questionId, value: value)
        }
        
        // Submit in background
        Task {
            await SurveyManager.shared.submitResponse(
                for: survey,
                trigger: trigger,
                answers: surveyAnswers
            )
        }
        
        // Dismiss immediately regardless of submission result
        dismissSurvey()
    }
    
    private func dismissSurvey() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss()
        }
    }
}

// MARK: - SurveyQuestionViewDelegate

extension FeedbackWallViewController: SurveyQuestionViewDelegate {
    func questionView(_ view: SurveyQuestionView, didSelectAnswer answer: String, for question: SurveyQuestion) {
        answers[question.id] = answer
    }
}

// MARK: - NSLayoutConstraint Extension

private extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
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
