import UIKit

/// The main view controller for displaying a FeedbackWall survey.
/// Supports both popup (centered card with overlay) and fullscreen layouts.
final class FeedbackWallViewController: UIViewController {
    
    // MARK: - Properties
    
    private let survey: Survey
    private let trigger: String
    private let onDismiss: () -> Void
    
    private var answers: [String: String] = [:]
    private var currentQuestionIndex: Int = 0
    private var questionViews: [SurveyQuestionView] = []
    
    // Theme-derived properties
    private var isFullscreen: Bool {
        ThemeLayoutResolver.isFullscreen(from: survey.theme)
    }
    
    private var contentPadding: CGFloat {
        ThemeLayoutResolver.contentPadding(from: survey.theme)
    }
    
    private var textAlignment: NSTextAlignment {
        ThemeLayoutResolver.textAlignment(from: survey.theme)
    }
    
    private var showsCloseButton: Bool {
        ThemeDisplayResolver.showCloseButton(from: survey.theme)
    }
    
    private var entranceAnimation: EntranceAnimation {
        ThemeDisplayResolver.entranceAnimation(from: survey.theme)
    }
    
    private var animationSpeed: AnimationSpeed {
        ThemeDisplayResolver.animationSpeed(from: survey.theme)
    }
    
    // MARK: - UI Components
    
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
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
        view.backgroundColor = ThemeColorResolver.backgroundColor(from: survey.theme)
        view.layer.cornerRadius = ThemeCornerRadiusResolver.cardCornerRadius(from: survey.theme)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Refined shadow for modern depth effect
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 24
        view.layer.shadowOpacity = 0.15
        
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        // Use a subtle gray color instead of theme color for less prominence
        button.tintColor = UIColor.systemGray2
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        return button
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var headerIconLabel: UILabel = {
        let label = UILabel()
        label.text = "💬"
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick question"
        label.font = ThemeFontFactory.headerLabelFont(from: survey.theme)
        label.textColor = ThemeColorResolver.primaryColor(from: survey.theme)
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
        label.font = ThemeFontFactory.bodyFont(from: survey.theme).withSize(13)
        label.textColor = ThemeColorResolver.labelColor(from: survey.theme)
        label.textAlignment = textAlignment
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
        button.titleLabel?.font = ThemeFontFactory.baseFont(from: survey.theme, weight: .medium)
        button.backgroundColor = ThemeColorResolver.optionUnselectedBackground(from: survey.theme)
        button.setTitleColor(ThemeColorResolver.textColor(from: survey.theme), for: .normal)
        button.layer.cornerRadius = ThemeCornerRadiusResolver.buttonCornerRadius(from: survey.theme)
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = ThemeFontFactory.baseFont(from: survey.theme, weight: .semibold)
        button.backgroundColor = primaryColor
        button.setTitleColor(buttonTextColor, for: .normal)
        button.layer.cornerRadius = ThemeCornerRadiusResolver.buttonCornerRadius(from: survey.theme)
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = ThemeFontFactory.baseFont(from: survey.theme, weight: .semibold)
        button.backgroundColor = primaryColor
        button.setTitleColor(buttonTextColor, for: .normal)
        button.layer.cornerRadius = ThemeCornerRadiusResolver.buttonCornerRadius(from: survey.theme)
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var primaryColor: UIColor {
        ThemeColorResolver.primaryColor(from: survey.theme)
    }
    
    private var buttonTextColor: UIColor {
        ThemeColorResolver.buttonTextColor(from: survey.theme)
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
        prepareForEntranceAnimation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        if isFullscreen {
            setupFullscreenLayout()
        } else {
            setupPopupLayout()
        }
        
        // Configure close button visibility
        closeButton.isHidden = !showsCloseButton
        
        // Disable dim view tap gesture if close button is hidden
        if !showsCloseButton {
            dimView.gestureRecognizers?.forEach { dimView.removeGestureRecognizer($0) }
        }
    }
    
    private func setupPopupLayout() {
        // Add dim view
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add tap gesture to dim view for dismissal (only if close button is shown)
        if showsCloseButton {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
            dimView.addGestureRecognizer(tapGesture)
        }
        
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
        
        setupCardContent()
    }
    
    private func setupFullscreenLayout() {
        // Fullscreen layout with vertically centered content
        view.backgroundColor = ThemeColorResolver.backgroundColor(from: survey.theme)
        
        // Card view styling (no shadow, no corner radius)
        cardView.layer.cornerRadius = 0
        cardView.layer.shadowOpacity = 0
        
        // Add scroll view for keyboard handling
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Add card view inside scroll view - centered vertically
        scrollView.addSubview(cardView)
        NSLayoutConstraint.activate([
            // Vertical centering with flexibility
            cardView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor),
            cardView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).withPriority(.defaultLow),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
            // Horizontal: full width
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupCardContent()
    }
    
    private func setupCardContent() {
        // Add header stack (emoji + "Quick question" label)
        headerStackView.addArrangedSubview(headerIconLabel)
        headerStackView.addArrangedSubview(headerLabel)
        cardView.addSubview(headerStackView)
        
        // Add close button on same row as header
        cardView.addSubview(closeButton)
        
        // Add extra top padding for better visual balance
        let headerTopPadding = contentPadding + 8
        NSLayoutConstraint.activate([
            // Header aligned to left
            headerStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: headerTopPadding),
            headerStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: contentPadding),
            headerStackView.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -8),
            
            // Close button aligned to right, vertically centered with header
            closeButton.centerYAnchor.constraint(equalTo: headerStackView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -contentPadding),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Add progress label with spacing after header
        cardView.addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            progressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: contentPadding),
            progressLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -contentPadding)
        ])
        
        // Add question container view
        cardView.addSubview(questionContainerView)
        NSLayoutConstraint.activate([
            questionContainerView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8),
            questionContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: contentPadding),
            questionContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -contentPadding)
        ])
        
        // Add button stack view with refined spacing
        cardView.addSubview(buttonStackView)
        let bottomPadding = contentPadding + 4
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: questionContainerView.bottomAnchor, constant: 28),
            buttonStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: contentPadding),
            buttonStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -contentPadding),
            buttonStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -bottomPadding),
            buttonStackView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupContent() {
        // Create question views
        for question in survey.questions {
            let questionView = SurveyQuestionView(question: question, theme: survey.theme)
            questionView.delegate = self
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
    
    // MARK: - Entrance Animation
    
    private func prepareForEntranceAnimation() {
        guard entranceAnimation != .none else { return }
        
        // Set initial state based on animation type
        switch entranceAnimation {
        case .slideFromBottom:
            cardView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        case .slideFromTop:
            cardView.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
        case .slideFromLeft:
            cardView.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        case .slideFromRight:
            cardView.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        case .fadeIn:
            cardView.alpha = 0
        case .scale:
            cardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            cardView.alpha = 0
        case .none:
            break
        }
    }
    
    /// Performs the entrance animation. Called after the view controller is presented.
    func performEntranceAnimation() {
        guard entranceAnimation != .none else {
            dimView.alpha = 1
            return
        }
        
        UIView.animate(
            withDuration: animationSpeed.duration,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: .curveEaseOut
        ) { [weak self] in
            self?.cardView.transform = .identity
            self?.cardView.alpha = 1
            self?.dimView.alpha = 1
        }
    }
    
    private func performExitAnimation(completion: @escaping () -> Void) {
        // Simple fast fade out for all exit animations
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut
        ) { [weak self] in
            self?.cardView.alpha = 0
            self?.dimView.alpha = 0
        } completion: { _ in
            completion()
        }
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
        guard showsCloseButton else { return }
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
        performExitAnimation { [weak self] in
            self?.dismiss(animated: false) {
                self?.onDismiss()
            }
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
