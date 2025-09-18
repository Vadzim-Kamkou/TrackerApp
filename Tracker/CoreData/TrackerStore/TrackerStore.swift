import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    // MARK: - Init
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        try setupFetchedResultsController()
    }
    
    // MARK: - Public Functions
    func fetchTracker() throws -> [Tracker] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return try objects.map { try TrackerStore.tracker(from: $0) }
    }
    
    static func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        
        let color = trackerCoreData.uiColor
        let schedule = trackerCoreData.scheduleArray.isEmpty ? nil : trackerCoreData.scheduleArray
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    // MARK: - Private Functions
    private func setupFetchedResultsController() throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
}

// MARK: - Extension
extension TrackerCoreData {
    var uiColor: UIColor {
        get {
            guard let colorString = color as? String else {
                return UIColor.systemBlue
            }
            return UIColor.fromHex(colorString) ?? UIColor.systemBlue
        }
        set {
            color = newValue.toHex() as NSObject
        }
    }
    
    var scheduleArray: [Int] {
        get {
            guard let scheduleString = schedule as? String else {
                return []
            }
            
            let components = scheduleString.split(separator: ",")
            return components.compactMap { Int($0) }
        }
        set {
            if newValue.isEmpty {
                schedule = nil
            } else {
                let scheduleString = newValue.map { String($0) }.joined(separator: ",")
                schedule = scheduleString as NSObject
            }
        }
    }
    
    func toTracker() -> Tracker {
        return Tracker(
            id: id ?? UUID(),
            name: name ?? "",
            color: uiColor,
            emoji: emoji ?? "",
            schedule: scheduleArray.isEmpty ? nil : scheduleArray
        )
    }
}

// MARK: - Extension
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { return }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { return }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            movedIndexes?.insert(.init(
                oldIndex: oldIndexPath.item,
                newIndex: newIndexPath.item
            ))
        @unknown default:
            break
        }
    }
}

// MARK: - Extension
extension UIColor {
    func toHex() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
        return String(format: "#%06x", rgb)
    }
    
    static func fromHex(_ hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
