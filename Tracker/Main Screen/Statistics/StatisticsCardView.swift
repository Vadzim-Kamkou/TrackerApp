import UIKit

final class StatisticsCardView: UIView {
    
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let gradientColors: [UIColor] = [.appStatisticsRed, .appStatisticsGreen, .appStatisticsBlue]

    
    init(value: String, title: String, gradientColors: [UIColor] = [.appStatisticsBlue, .appStatisticsGreen, .appStatisticsRed]) {
        super.init(frame: .zero)
        
        setupCard(value: value, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCard(value: String, title: String) {
        backgroundColor = .clear
        layer.cornerRadius = 16
        
        valueLabel.text = value
        valueLabel.font = Fonts.ysDisplayBold34 ?? UIFont.boldSystemFont(ofSize: 34)
        valueLabel.textAlignment = .left
        
        titleLabel.text = title
        titleLabel.font = Fonts.ysDisplayMedium12 ?? UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .left
        
        [valueLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if layer.sublayers?.first(where: { $0.name == "gradientBorder" }) == nil {
            addGradientBorder(colors: gradientColors, width: 1.0, cornerRadius: 16)
        }
    }
}

extension UIView {
    func addGradientBorder(colors: [UIColor], width: CGFloat = 2.0, cornerRadius: CGFloat = 0) {
        layer.sublayers?.removeAll { $0.name == "gradientBorder" }

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientBorder"
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: width, dy: width), cornerRadius: max(0, cornerRadius - width))

        path.append(innerPath)
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd

        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }
}
