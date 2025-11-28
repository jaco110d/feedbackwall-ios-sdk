import UIKit

/// The main view controller for displaying a FeedbackWall survey.
/// Presented modally with a dark dim background and a centered card.
final class FeedbackWallViewController: UIViewController {
    
    // MARK: - Properties
    
    private let survey: Survey
    private let trigger: String
    private let onDismiss: () -> Void
    
    private var answers: [String: String] = [:]
    private var questionViews: [SurveyQuestionView] = []
    
    // MARK: - UI Components
    
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = survey.theme?.cornerRadius ?? 24
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
    
    private lazy var questionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
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
        
        // Add card view
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
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
        
        // Add questions stack view
        cardView.addSubview(questionsStackView)
        NSLayoutConstraint.activate([
            questionsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            questionsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            questionsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])
        
        // Add submit button
        cardView.addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: questionsStackView.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            submitButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupContent() {
        titleLabel.text = survey.title
        descriptionLabel.text = survey.description
        descriptionLabel.isHidden = survey.description == nil
        
        // Add question views
        for question in survey.questions {
            let questionView = SurveyQuestionView(question: question)
            questionView.delegate = self
            questionView.applyTheme(survey.theme)
            questionViews.append(questionView)
            questionsStackView.addArrangedSubview(questionView)
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismissSurvey()
    }
    
    @objc private func dimViewTapped() {
        dismissSurvey()
    }
    
    @objc private func submitTapped() {
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

