import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "EmojiCollectionViewCell"
    var onTap: (() -> Void)?
    
    // MARK: - UI Elements
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backgroundSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .appLightGray)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) should not be used")
        return nil
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        contentView.addSubview(backgroundSelectionView)
        contentView.addSubview(emojiLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    @objc private func cellTapped() {
        onTap?()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with emoji: String, isSelected: Bool, onTap: @escaping () -> Void) {
        emojiLabel.text = emoji
        setSelected(isSelected)
        self.onTap = onTap
    }
    
    func setSelected(_ selected: Bool) {
        backgroundSelectionView.isHidden = !selected
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        backgroundSelectionView.isHidden = true
    }
}
