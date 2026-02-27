//
//  SavedRoute+CoreDataProperties.swift
//  MapApp
//
//  Created by Wolf,Luke D on 2/27/26.
//

import Foundation
import CoreData

extension SavedRoute {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedRoute> {
        return NSFetchRequest<SavedRoute>(entityName: "SavedRoute")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var createdDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var routeType: Int16
    @NSManaged public var isScenicMode: Bool
    @NSManaged public var targetDistance: Double
    @NSManaged public var direction: String?
    @NSManaged public var waypointsData: Data?
    @NSManaged public var fullRouteData: Data?
    @NSManaged public var wasCompleted: Bool
    @NSManaged public var actualDistance: Double
    @NSManaged public var actualDuration: Double
    @NSManaged public var avgSpeed: Double
    @NSManaged public var completedDate: Date?
    @NSManaged public var isFavorite: Bool
}

extension SavedRoute : Identifiable {
    
}
