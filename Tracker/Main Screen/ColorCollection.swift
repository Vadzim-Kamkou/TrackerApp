import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "ColorCollectionViewCell"
    var onTap: (() -> Void)?
    
    // MARK: - UI Elements
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorRect: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .appLightGray)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 11
        view.layer.borderWidth = 3
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
        
        contentView.addSubview(borderView)
        contentView.addSubview(colorRect)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    @objc private func cellTapped() {
        onTap?()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            borderView.widthAnchor.constraint(equalToConstant: 52),
            borderView.heightAnchor.constraint(equalToConstant: 52),
            
            colorRect.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorRect.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorRect.widthAnchor.constraint(equalToConstant: 40),
            colorRect.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Configuration
    func configure(with color: UIColor, isSelected: Bool, onTap: @escaping () -> Void) {
        colorRect.backgroundColor = color
        setSelected(isSelected, with: color)
        self.onTap = onTap
    }
    
    func setSelected(_ selected: Bool, with color: UIColor) {
        if selected {
            borderView.isHidden = false
            borderView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            borderView.isHidden = true
            borderView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        colorRect.backgroundColor = nil
        borderView.isHidden = true
        borderView.layer.borderColor = UIColor.clear.cgColor
    }
}
