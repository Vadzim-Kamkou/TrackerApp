import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    var viewContext: NSManagedObjectContext { get }
    
    func saveContext()
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T]
    func delete(_ object: NSManagedObject)
}

final class CoreDataManager: CoreDataManagerProtocol {
    
    // MARK: - Properties
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    func saveContext() {
        let context = viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("CoreDataManager save error: \(nsError), \(nsError.userInfo)")
        }
    }
    
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try viewContext.fetch(request)
        } catch {
            print("CoreDataManager fetch error: \(error)")
            return []
        }
    }
    
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
    }
}
