//
//  FavoriteVenueRepository.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation
import CoreData

protocol FavoriteVenueRepositoryDelegate: AnyObject {
    func favoriteVenueRepositoryDidChange(_ favoriteVenueRepository: FavoriteVenueRepository)
}

class FavoriteVenueRepository {
    private let persistentContainer: NSPersistentContainer
    
    // Let it be for now
    private var mainContext: NSManagedObjectContext {
        assert(Thread.isMainThread)
        return persistentContainer.viewContext
    }
        
    weak var delegate: FavoriteVenueRepositoryDelegate? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            if delegate != nil {
                addCoreDataObserver()
            }
        }
    }
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func delete(item: FavoriteVenue) {
        let request: NSFetchRequest<FavoriteVenueEntity> = FavoriteVenueEntity.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(FavoriteVenueEntity.id)) == %@", item.id)
        
        let result = fetch(withRequest: request)
        guard !result.isEmpty else {
            NSLog("Could not delete favorite venue with id: \(item.id): it doesn't exist.")
            return
        }
        
        mainContext.delete(result[0])
        save()
    }
    
    func insert(item: FavoriteVenue) {
        let entity = FavoriteVenueEntity(context: mainContext)
        entity.id = item.id
        
        mainContext.insert(entity)
        save()
    }
    
    func findAll() -> [FavoriteVenue] {
        let request: NSFetchRequest<FavoriteVenueEntity> = FavoriteVenueEntity.fetchRequest()
        return fetch(withRequest: request).compactMap { FavoriteVenue(managedObject: $0) }
    }
    
    private func save() {
        do {
            guard mainContext.hasChanges else { return }
            try mainContext.save()
        } catch let error as NSError {
            NSLog("Could not save context. Error: \(error.localizedDescription), \(error.userInfo)")
        }
    }
    
    private func fetch(withRequest request: NSFetchRequest<FavoriteVenueEntity>) -> [FavoriteVenueEntity] {
        do {
            return try mainContext.fetch(request)
        } catch let error as NSError {
            NSLog("Could not fetch favorite venues by predicate: \(request.predicate?.description ?? "no predicate"). \(error.localizedDescription), \(error.userInfo)")
        }
        
        return []
    }
    
    private func addCoreDataObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: mainContext)
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        func any(for key: String) -> Bool {
            if let objects = userInfo[key] as? Set<FavoriteVenueEntity>, objects.count > 0 {
                return true
            }
            return false
        }
        
        guard any(for: NSInsertedObjectsKey) || any(for: NSDeletedObjectsKey) || any(for: NSUpdatedObjectsKey) else { return }
        
        delegate?.favoriteVenueRepositoryDidChange(self)
    }
}
