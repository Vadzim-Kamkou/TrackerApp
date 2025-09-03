import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    // идентификатор, что чего он нужен?
    static let identifier = "EmojiCollectionViewCell"
    var onTap: (() -> Void)?
    
    // MARK: - UI Elements
    // Смайлик
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Заднее выделение эмоджи
    private let backgroundSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .appLightGray)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initialization
    // Не понимаю зачем это.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // Насколько это необходимо? Исользовать только assertion
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    // настраиваем UI добавляем смайлик и бэк
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
            print("🔥 ЯЧЕЙКА ЭМОДЖИ ТАПНУТА ЧЕРЕЗ GESTURE!")
            onTap?()
        }
    
    // констрейнты бэка и смайла
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background selection view
            backgroundSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Emoji label
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    // непонятно где вызывается
    func configure(with emoji: String, isSelected: Bool, onTap: @escaping () -> Void) {
          emojiLabel.text = emoji
          setSelected(isSelected)
          self.onTap = onTap
      }
    
    // скрываем бэк если смайл не выбран.
    func setSelected(_ selected: Bool) {
        backgroundSelectionView.isHidden = !selected
    }
    
    // MARK: - Reuse
    // подготовка к повторному использованию
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        backgroundSelectionView.isHidden = true
    }
}
