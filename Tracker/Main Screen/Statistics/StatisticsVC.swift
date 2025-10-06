import UIKit

final class StatisticsViewController: UIViewController {
    
    private let coreDataManager: CoreDataManagerProtocol
    
    private var statisticsView: UIView?
    private var statisticsLabel: UILabel?
    private var statisticsTitleLabel: UILabel?
    
    private var statisticsStackView: UIStackView?
    private var scrollView: UIScrollView?
    
    private let statisticsService: StatisticsServiceProtocol
    private var currentStatistics: StatisticsData?
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
        self.statisticsService = StatisticsService(coreDataManager: coreDataManager)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackgroundDay
        setupUI()
        updateStatisticsViewVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    private func setupUI() {
        let statisticsTitleLabel = UILabel()
        statisticsTitleLabel.text = NSLocalizedString("statistics", comment: "Main statistics title")
        statisticsTitleLabel.font = Fonts.ysDisplayBold34 ?? UIFont.systemFont(ofSize: 34)
        statisticsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statisticsTitleLabel)
        self.statisticsTitleLabel = statisticsTitleLabel

        NSLayoutConstraint.activate([
            statisticsTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticsTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 42),
        ])
        
        setupEmptyStatisticsView()
        setupStatisticsCardsStack()
    }
    
    private func setupEmptyStatisticsView() {
        let noStatisticsImages = UIImage(resource: .noStatistics)
        let noStatisticsImageView = UIImageView(image: noStatisticsImages)
        
        noStatisticsImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noStatisticsImageView)
        
        let statisticsLabel = UILabel()
        statisticsLabel.text = NSLocalizedString("statistics_to_track", comment: "Empty statistics state message")
        statisticsLabel.font = Fonts.ysDisplayMedium12 ?? UIFont.systemFont(ofSize: 12)
        statisticsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statisticsLabel)
        
        NSLayoutConstraint.activate([
            noStatisticsImageView.widthAnchor.constraint(equalToConstant: 80),
            noStatisticsImageView.heightAnchor.constraint(equalToConstant: 80),
            noStatisticsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noStatisticsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statisticsLabel.centerXAnchor.constraint(equalTo: noStatisticsImageView.centerXAnchor),
            statisticsLabel.topAnchor.constraint(equalTo: noStatisticsImageView.bottomAnchor, constant: 8)
        ])
        
        self.statisticsView = noStatisticsImageView
        self.statisticsLabel = statisticsLabel
    }
    
    private func setupStatisticsCardsStack() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        self.scrollView = scrollView
        
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        self.statisticsStackView = stackView
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: statisticsTitleLabel!.bottomAnchor, constant: 77),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func loadStatistics() {
        let completionToday = statisticsService.getCompletionPercentageToday()
        let averageLast7Days = statisticsService.getAverageCompletionLast7Days()
        let perfectDays = statisticsService.getPerfectDaysCount()
        let totalCompleted = statisticsService.getTotalCompletedTrackersCount()
        
        let statistics = StatisticsData(
            completionPercentageToday: completionToday,
            averageCompletionLast7Days: averageLast7Days,
            perfectDaysCount: perfectDays,
            totalCompletedTrackersCount: totalCompleted
        )
        
        self.currentStatistics = statistics
        
        updateStatisticsViewVisibility()
        if statistics.hasAnyData {
            updateStatisticsCards(with: statistics)
        }
    }
    
    private func updateStatisticsCards(with data: StatisticsData) {
        guard let stackView = statisticsStackView else { return }
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        
        let cards = [
            (formatPercentage(data.completionPercentageToday), NSLocalizedString("statistics_completed_today_percentage", comment: "")),
            (formatPercentage(data.averageCompletionLast7Days), NSLocalizedString("statistics_completed_7days_percentage", comment: "")),
            (formatCount(data.perfectDaysCount), (formatCountWithLocalization(data.perfectDaysCount, key: "statistics_ideal_days_count"))),
            
            
            (formatCount(data.totalCompletedTrackersCount), NSLocalizedString("statistics_trackers_completed_count", comment: ""))
        ]
    
        for (value, title) in cards {
            let card = StatisticsCardView(value: value, title: title)
            card.heightAnchor.constraint(equalToConstant: 90).isActive = true
            stackView.addArrangedSubview(card)
        }
    }
    
    private func updateStatisticsViewVisibility() {
        let hasStatistics = currentStatistics?.hasAnyData ?? false
        
        statisticsView?.isHidden = hasStatistics
        statisticsLabel?.isHidden = hasStatistics
        
        scrollView?.isHidden = !hasStatistics
    }
    
    private func formatPercentage(_ value: Double) -> String {
        if value == 0.0 {
            return "0%"
        } else {
            return String(format: "%.0f%%", value * 100)
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        return "\(count)"
    }
    
    private func formatCountWithLocalization(_ count: Int, key: String) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString(key, comment: ""),
            count
        )
    }
}
