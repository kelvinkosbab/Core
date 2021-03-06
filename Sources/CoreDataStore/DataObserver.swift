//
//  CoreDataObserver.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import CoreData
import Core

// MARK: - DataObserver

public protocol DataObserverDelegate : AnyObject where ObjectType == ObjectType.ManagedObject.StructType {
    
    associatedtype ObjectType : ManagedObjectAssociated
    
    func didAdd(object: ObjectType) -> Void
    func didUpdate(object: ObjectType) -> Void
    func didRemove(object: ObjectType) -> Void
}

public class DataObserver<Delegate: DataObserverDelegate> : NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias ManagedObject = Delegate.ObjectType.ManagedObject
    public typealias ObjectType = Delegate.ObjectType
    
    public weak var delegate: Delegate?
    private let fetchedResultsController: NSFetchedResultsController<ManagedObject>
    private let logger: Logger
    
    public private(set) var objects: Set<ObjectType> = Set()
    
    public convenience init(context: NSManagedObjectContext) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    public convenience init(id: String, context: NSManagedObjectContext) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(id: id, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    public convenience init(ids: [String], context: NSManagedObjectContext) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(ids: ids, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    public init(fetchedResultsController: NSFetchedResultsController<ManagedObject>) {
        
        self.fetchedResultsController = fetchedResultsController
        self.logger = Logger(subsystem: "CoreDataStore", category: "DatabaseObserver.\(String(describing: ManagedObject.self))")
        
        super.init()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            self.logger.error("Failed to performFetch: \(error.localizedDescription)")
        }
        
        self.fetchedResultsController.delegate = self
        
        for cdObject in self.fetchedResultsController.fetchedObjects ?? [] {
            if let object = cdObject.structValue {
                self.objects.insert(object)
            }
        }
    }
    
    // MARK: - NSFetchedResultsController
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        
        guard let cdObject = anObject as? ManagedObject else {
            self.logger.error("Updated object is not of type NSManagedObject.")
            return
        }
        
        guard let object = cdObject.structValue else {
            return
        }
        
        switch type {
        case .insert:
            
            guard !self.objects.contains(object) else {
                return
            }
            
            self.objects.insert(object)
            self.delegate?.didAdd(object: object)
            
        case .update:
            if self.objects.contains(object) {
                self.objects.update(with: object)
                self.delegate?.didUpdate(object: object)
            } else {
                self.objects.insert(object)
                self.delegate?.didAdd(object: object)
            }
            
        case .delete:
            if self.objects.contains(object) {
                self.objects.remove(object)
                self.delegate?.didRemove(object: object)
            }
            
        case .move:
            self.logger.debug("Unsupported operation 'move'.")
        @unknown default:
            fatalError("Unsupported operation 'unknown' for")
        }
    }
}

// MARK: - ManagedObjectParentIdentifiable

public extension DataObserver where Delegate.ObjectType.ManagedObject : ManagedObjectParentIdentifiable {
    
    convenience init(id: String, parentId: String, context: NSManagedObjectContext) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(id: id, parentId: parentId, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    convenience init(parentId: String, context: NSManagedObjectContext) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(parentId: parentId, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
}
