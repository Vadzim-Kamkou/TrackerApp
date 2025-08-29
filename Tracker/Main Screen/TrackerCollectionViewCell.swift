import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "TrackerCollectionViewCell"
    
    // MARK: - UI Elements
    private let backgroundCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Private Properties
    private var tracker: Tracker?
    private var isCompleted: Bool = false
    private var completionHandler: ((Bool) -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(backgroundCardView)
        backgroundCardView.addSubview(emojiLabel)
        backgroundCardView.addSubview(titleLabel)
        
        contentView.addSubview(counterLabel)
        contentView.addSubview(actionButton)
        
        setupConstraints()
        setupButtonAction()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background card
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundCardView.heightAnchor.constraint(equalToConstant: 90),
            
            // Emoji
            emojiLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -12),
            
            // Counter
            counterLabel.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Action button
            actionButton.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setupButtonAction() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int, currentDate: Date, completion: @escaping (Bool) -> Void) {
        self.tracker = tracker
        self.isCompleted = isCompleted
        self.completionHandler = completion
        
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        backgroundCardView.backgroundColor = tracker.color
        
        updateCounterText(completedDays)
        
        let isFutureDate = Calendar.current.compare(currentDate, to: Date(), toGranularity: .day) == .orderedDescending
        actionButton.isEnabled = !isFutureDate
        actionButton.alpha = isFutureDate ? 0.5 : 1.0
        
        updateButtonAppearance()
    }
    
    private func updateCounterText(_ days: Int) {
        let daysText: String
        let lastDigit = days % 10
        let lastTwoDigits = days % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            daysText = "дней"
        } else {
            switch lastDigit {
            case 1:
                daysText = "день"
            case 2, 3, 4:
                daysText = "дня"
            default:
                daysText = "дней"
            }
        }
        
        let fullText = "\(days) \(daysText)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: "\(days)") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.font,
                                        value: UIFont(name: "YSDisplay-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
                                        range: nsRange)
        }
           
        counterLabel.attributedText = attributedString 
    }
    
    private func updateButtonAppearance() {
        if isCompleted {
            actionButton.setTitle("✓", for: .normal)
            actionButton.backgroundColor = tracker?.color.withAlphaComponent(0.3)
            actionButton.setTitleColor(tracker?.color, for: .normal)
            actionButton.layer.borderWidth = 0
        } else {
            actionButton.setTitle("+", for: .normal)
            actionButton.backgroundColor = tracker?.color
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.layer.borderWidth = 0
        }
        UIView.transition(with: actionButton,
                            duration: 0.2,
                            options: .transitionCrossDissolve,
                            animations: nil,
                            completion: nil)
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        isCompleted.toggle()
        updateButtonAppearance()
        
        let newCompletedDays: Int
        if isCompleted {
            let currentCount = Int(counterLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0
            newCompletedDays = currentCount + 1
        } else {
            let currentCount = Int(counterLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0
            newCompletedDays = max(0, currentCount - 1)
        }
        
        updateCounterText(newCompletedDays)
        completionHandler?(isCompleted)
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        tracker = nil
        isCompleted = false
        completionHandler = nil
 
        emojiLabel.text = nil
        titleLabel.text = nil
        titleLabel.attributedText = nil
        counterLabel.text = nil
        counterLabel.attributedText = nil
        backgroundCardView.backgroundColor = nil
        actionButton.backgroundColor = nil
        actionButton.setTitleColor(nil, for: .normal)
        actionButton.isEnabled = true
        actionButton.alpha = 1.0
    }
}
