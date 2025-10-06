import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: TrackerRecordStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    // MARK: - Init
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        try setupFetchedResultsController()
    }
    
    // MARK: - Public Functions
    func addTrackerRecord(_ trackerRecord: TrackerRecord) {
        do {
            let trackerRecordCoreData = TrackerRecordCoreData(context: context)
            trackerRecordCoreData.id = trackerRecord.id
            trackerRecordCoreData.date = trackerRecord.date
            
            try context.save()
        } catch {
            assertionFailure("Failed to add TrackerRecord: \(error.localizedDescription)")
            print("Failed to save TrackerRecord: \(error)")
        }
    }
    
    func deleteTrackerRecord(with trackerId: UUID, on date: Date) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        fetchRequest.fetchLimit = 1
        
        let records = try context.fetch(fetchRequest)
        if let recordToDelete = records.first {
            context.delete(recordToDelete)
            try context.save()
        }
    }
    
    func fetchTrackerRecord() throws -> [TrackerRecord] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return try objects.map { try self.trackerRecord(from: $0) }
    }
    
    func trackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id else {
            throw TrackerRecordStoreError.decodingErrorInvalidId
        }
        guard let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidDate
        }
        
        return TrackerRecord(
            id: id,
            date: date
        )
    }

    // MARK: - Private Functions
    private func setupFetchedResultsController() throws {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
            NSSortDescriptor(key: "id", ascending: true)
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
    
    func getRecordsForDate(_ date: Date) -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            let recordsCoreData = try context.fetch(fetchRequest)
            return recordsCoreData.compactMap { recordCoreData in
                guard let id = recordCoreData.id,
                      let date = recordCoreData.date else { return nil }
                return TrackerRecord(id: id, date: date)
            }
        } catch {
            print("Failed to fetch records for date: \(error)")
            return []
        }
    }
    
    func getAllRecords() -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let recordsCoreData = try context.fetch(fetchRequest)
            let records: [TrackerRecord] = recordsCoreData.compactMap { recordCoreData -> TrackerRecord? in
                guard let id = recordCoreData.id,
                      let date = recordCoreData.date else { return nil }
                return TrackerRecord(id: id, date: date)
            }
            return records
        } catch {
            print("Failed to fetch all records: \(error)")
            return []
        }
    }
    
    func getAllUniqueDates() -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let recordsCoreData = try context.fetch(fetchRequest)
            let dates = recordsCoreData.compactMap { $0.date }
            
            let calendar = Calendar.current
            let uniqueDates = Set(dates.map { calendar.startOfDay(for: $0) })
            
            return Array(uniqueDates).sorted()
        } catch {
            print("Failed to fetch unique dates: \(error)")
            return []
        }
    }
    
    func deleteAllRecords(for trackerId: UUID) throws {
          let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
          fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
          
          let records = try context.fetch(fetchRequest)
        
          for record in records {
              context.delete(record)
          }
          
          try context.save()
      }
}

// MARK: - Extension
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerRecordStoreUpdate(
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
