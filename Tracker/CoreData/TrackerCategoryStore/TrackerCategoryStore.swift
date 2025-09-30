import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    // MARK: - Init
    convenience override init() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate
        else {
            assertionFailure("❌ Unable to cast AppDelegate")
            do {
                try self.init(context: TrackerCategoryStore.dummyContext())
            } catch {
                fatalError("❌ Critical: Cannot initialize even with dummy context: \(error)")
            }
            return
        }

        let context = delegate.persistentContainer.viewContext

        do {
            try self.init(context: context)
        } catch {
            assertionFailure("❌ Failed to initialize TrackerCategoryStore: \(error)")
            do {
                try self.init(context: TrackerCategoryStore.dummyContext())
            } catch {
                fatalError("❌ Critical: Cannot initialize even with dummy context: \(error)")
            }
        }
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        try setupFetchedResultsController()
    }
    
    // MARK: - Public Functions
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = trackerCategory.title
        
        for tracker in trackerCategory.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.uiColor = tracker.color
            trackerCoreData.scheduleArray = tracker.schedule ?? []
            trackerCoreData.category = trackerCategoryCoreData
        }
        
        try context.save()
    }
    
    func addTrackerToCategory(_ tracker: Tracker, categoryTitle: String) throws {
        
        if let existingCategoryCoreData = try fetchCategoryCoreData(with: categoryTitle) {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.uiColor = tracker.color
            trackerCoreData.scheduleArray = tracker.schedule ?? []
            trackerCoreData.category = existingCategoryCoreData
            
            try context.save()
            print("Added tracker '\(tracker.name)' to existing category '\(categoryTitle)'")
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            try addTrackerCategory(newCategory)
            print("Created new category '\(categoryTitle)' with tracker '\(tracker.name)'")
        }
    }
    
    func fetchTrackerCategory() throws -> [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return try objects.map { try self.trackerCategory(from: $0) }
    }
    
    func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        let trackers: [Tracker]
        if let trackersSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> {
            trackers = try trackersSet.compactMap { trackerCoreData in
                return try TrackerStore.tracker(from: trackerCoreData)
            }
        } else {
            trackers = []
        }
        
        return TrackerCategory(
            title: title,
            trackers: trackers
        )
    }
    
    func fetchCategoryCoreData(with title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        let categories = try context.fetch(fetchRequest)
        return categories.first
    }
    
    
    
    // MARK: - Private Functions
    private func setupFetchedResultsController() throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    private static func dummyContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "Data")
        
        // Используем in-memory store (данные не сохраняются)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("⚠️ Dummy context failed to load: \(error)")
            }
        }
        
        return container.viewContext
    }
}

// MARK: - Extension NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
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
