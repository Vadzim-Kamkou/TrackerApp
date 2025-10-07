import XCTest
import SnapshotTesting
import CoreData
@testable import Tracker

// MARK: - Mock CoreDataManager
class MockCoreDataManager: CoreDataManagerProtocol {
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Data")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Mock Core Data setup failed: \(error)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    lazy var trackerStore: TrackerStore = {
        do {
            return try TrackerStore(context: viewContext)
        } catch {
            fatalError("Failed to create mock TrackerStore: \(error)")
        }
    }()
    
    lazy var trackerRecordStore: TrackerRecordStore = {
        do {
            return try TrackerRecordStore(context: viewContext)
        } catch {
            fatalError("Failed to create mock TrackerRecordStore: \(error)")
        }
    }()
    
    lazy var trackerCategoryStore: TrackerCategoryStore = {
        do {
            return try TrackerCategoryStore(context: viewContext)
        } catch {
            fatalError("Failed to create mock TrackerCategoryStore: \(error)")
        }
    }()
    
    func saveContext() {}
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {return []}
    func delete(_ object: NSManagedObject) {}
}

final class TrackerSnapshotTests: XCTestCase {
    
    // MARK: - Properties
    private var trackerViewController: TrackerViewController!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        
        let mockCoreDataManager = MockCoreDataManager()
        
        trackerViewController = TrackerViewController(coreDataManager: mockCoreDataManager)
        trackerViewController.loadViewIfNeeded()
        
        trackerViewController.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        trackerViewController.view.layoutIfNeeded()
    }
    
    override func tearDown() {
        trackerViewController = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testMainScreenEmptyStateLightMode() {
        trackerViewController.overrideUserInterfaceStyle = .light
        trackerViewController.view.layoutIfNeeded()
        
        assertSnapshot(
            of: trackerViewController,
            as: .image,
            named: "MainScreen_EmptyState_Light"
        )
    }
    
    func testMainScreenEmptyStateDarkMode() {
        trackerViewController.overrideUserInterfaceStyle = .dark
        trackerViewController.view.layoutIfNeeded()
        
        assertSnapshot(
            of: trackerViewController,
            as: .image,
            named: "MainScreen_EmptyState_Dark"
        )
    }
}
