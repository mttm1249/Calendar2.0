//
//  CoreDataManager.swift
//  EventList
//
//  Created by Денис on 17.01.2023.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "EventRecordModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var managedContext: NSManagedObjectContext {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

extension CoreDataManager {
    
    static func saveEventRecord(name: String?,
                                 eventText: String?,
                                 isCompleted: Bool?,
                                 eventDate: Date?,
                                 priorityID: Int?,
                                 eventNotificationDate: Date?,
                                 eventNotificationID: UUID!,
                                 eventWithNotification: Bool?) {
        let event = Event(context: managedContext)

        event.name = name
        event.eventText = eventText
        event.isCompleted = isCompleted ?? false
        event.eventDate = eventDate
        event.priorityID = Int16(priorityID ?? 0)
        event.eventNotificationDate = eventNotificationDate
        event.eventNotificationID = eventNotificationID!
        event.eventWithNotification = eventWithNotification ?? false
        
        CoreDataManager.shared.saveContext()
    }
}
