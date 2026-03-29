//
//  CoreDataManager.swift
//  MapApp
//
//  Created by Wolf,Luke D on 2/27/26.
//

import CoreData
import MapKit

class CoreDataManager {
    private struct StoredPaceSegment: Codable {
        let type: String
        let percentage: Double
    }

    // Singleton - one instance for whole app
    static let shared = CoreDataManager()
    
    // The container that holds your database
    lazy var persistentContainer: NSPersistentContainer = {
        // Name MUST match your .xcdatamodeld filename
        let container = NSPersistentContainer(name: "RouteModel")
        
        // for auto migration
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        // Load the database from disk (or create if first launch)
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        return container
    }()
    
    func resetRouteCounter() {
        UserDefaults.standard.set(0, forKey: "routeCounter")
        print("🔄 Route counter reset to 0")
    }
    
    // Your workspace for making changes
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Save changes to disk
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Route Counter (for stable route numbers)
    
    // Auto-incrementing counter for route numbers
    private var routeCounter: Int {
        get {
            return UserDefaults.standard.integer(forKey: "routeCounter")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "routeCounter")
        }
    }
    
    // Get next route number and increment counter
    private func getNextRouteNumber() -> Int {
        let number = routeCounter
        routeCounter = number + 1
        return number + 1  // Start at 1, not 0
    }
    
    // MARK: - Coordinate Encoding/Decoding
    
    // Convert [CLLocationCoordinate2D] → Data (for storage)
    func encodeCoordinates(_ coords: [CLLocationCoordinate2D]) -> Data? {
        // Flatten: [(lat, lon), (lat, lon)] → [lat, lon, lat, lon]
        let array = coords.flatMap { [$0.latitude, $0.longitude] }
        return try? JSONEncoder().encode(array)
    }
    
    // Convert Data → [CLLocationCoordinate2D] (for loading)
    func decodeCoordinates(_ data: Data) -> [CLLocationCoordinate2D]? {
        guard let array = try? JSONDecoder().decode([Double].self, from: data) else { return nil }
        var coords: [CLLocationCoordinate2D] = []
        // Unflatten: [lat, lon, lat, lon] → [(lat, lon), (lat, lon)]
        for i in stride(from: 0, to: array.count, by: 2) {
            coords.append(CLLocationCoordinate2D(latitude: array[i], longitude: array[i+1]))
        }
        return coords
    }
    
    // MARK: - Save Route
    
    func saveRoute(
        routeType: Int,
        isScenicMode: Bool,
        targetDistance: Double,
        direction: String?,
        waypoints: [CLLocationCoordinate2D],
        fullRoute: [CLLocationCoordinate2D]?,
        name: String? = nil,
        paceConfig: [PaceSegmentConfig]? = nil
    ) {
        // Create new database row
        let route = SavedRoute(context: context)
        
        // Fill in the columns
        route.id = UUID()
        route.createdDate = Date()
        route.name = name
        route.routeType = Int16(routeType)
        route.isScenicMode = isScenicMode
        route.targetDistance = targetDistance
        route.direction = direction
        route.waypointsData = encodeCoordinates(waypoints)
        if let fullRoute = fullRoute {
            route.fullRouteData = encodeCoordinates(fullRoute)
        }
        route.wasCompleted = false
        route.isFavorite = false
        
        // Assign permanent route number
        route.routeNumber = Int32(getNextRouteNumber())

        if let paceConfig = paceConfig {
            route.paceOrderData = encodePaceConfig(paceConfig)
        }
        
        // Write to disk
        saveContext()
        print("✅ Saved route #\(route.routeNumber): \(targetDistance) miles")
    }

    func encodePaceConfig(_ config: [PaceSegmentConfig]) -> Data? {
        let simplified = config.map {
            StoredPaceSegment(type: $0.paceType.rawValue, percentage: $0.percentage)
        }
        return try? JSONEncoder().encode(simplified)
    }

    func decodePaceConfig(_ data: Data) -> [PaceSegmentConfig]? {
        guard let array = try? JSONDecoder().decode([StoredPaceSegment].self, from: data) else {
            return nil
        }

        return array.compactMap { item in
            guard let paceType = PaceType(rawValue: item.type) else { return nil }
            return PaceSegmentConfig(paceType: paceType, percentage: item.percentage, distance: 0)
        }
    }
    
    // MARK: - Fetch Routes
    
    func fetchAllRoutes() -> [SavedRoute] {
        let request: NSFetchRequest<SavedRoute> = SavedRoute.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchFavorites() -> [SavedRoute] {
        let request: NSFetchRequest<SavedRoute> = SavedRoute.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Delete Route
    
    func deleteRoute(_ route: SavedRoute) {
        context.delete(route)
        saveContext()
    }
    
    // MARK: - Migration Helper
    
    // Assign route numbers to existing routes (runs once on app launch)
    func migrateExistingRoutes() {
        let routes = fetchAllRoutes()
        
        // Find routes without a number
        let unnumberedRoutes = routes.filter { $0.routeNumber == 0 }
        
        if unnumberedRoutes.isEmpty {
            print("✅ All routes already have numbers")
            return
        }
        
        print("🔄 Migrating \(unnumberedRoutes.count) routes...")
        
        // Sort by creation date (oldest first)
        let sortedRoutes = unnumberedRoutes.sorted {
            ($0.createdDate ?? Date.distantPast) < ($1.createdDate ?? Date.distantPast)
        }
        
        // Assign numbers
        for route in sortedRoutes {
            route.routeNumber = Int32(getNextRouteNumber())
            print("  - Assigned #\(route.routeNumber) to route from \(route.createdDate ?? Date())")
        }
        
        saveContext()
        print("✅ Migration complete!")
    }
}
