# IndependentStudyProject
## Weekly Breakdown
### Documentation for Map Kit API:
[Click here for documentation](https://developer.apple.com/documentation/mapkit)
### Week 1:
  + Goal: Display a live map view.
  + Tools: Xcode's built in MapKit
    * Specifically the class "MKMapView" should allow for the basics of displaying a live map.
    * This should look similar to the Apple Maps app.
    * Be able to scroll around and look at areas on the map and other basic map features.
      - All the tools to do this are under the "[Map Coordinates](https://developer.apple.com/documentation/mapkit/mkcoordinateregion)"  tab in the documentation.
### Week 2:
  + Goal: Basic route generation for point-to-point routes
  + Tools: MapKit API
    * Will use "MKDirections" and other associated direction tools
      - These tools are under the "[Directions](https://developer.apple.com/documentation/mapkit)" tab in the documentation.
### Week 3:
  + Goal: Refine route generation, get very basic alternate route types started
  + Tools: [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections), [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), and manual coordinate manipulation.
    * Objectives in detail:
      -  Ensure route genreation is stable, no failures, consistent output for times and distances.
      -  Implment "out-and-back" routes by just reversing the current route. A -> B reverse B -> A.
      -  Begin testing logic for loops by generating mid-way points before returning to starting position.
    * Potentinal issues:
      - Looped routes might need manual midpoint generation using cordinates rather than builitin route generation.
      - Route lenghts might become inaccurate because of generated waypoints.
### Week 4:
  + Goal: Finish implmentation of alternate route types (loops)
  + Tools: Using [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute) create random points that will
    * Plan for implemntation:
      - Use MKDirectisons to create multiple smaller routes that connect sequentially (EX: A->B, B->C, C->A).
      - Then combine the route segments into the full loop route.
### Week 5:
  + Goal: Implement Route generation that will use user-inputted distance or time.
  + Tools: [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections) and [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute)
    * Have simple input form that asks for either a specific time or distance from the user.
    * At this stage time based routes will have placeholder values.
    * Use the random points that are within the calculated radius to make test routes.
    * Compare the returned route's using [MKRoute.distance](https://developer.apple.com/documentation/mapkit/mkroute/distance) or [MKRoute.expectedTravelTime](https://developer.apple.com/documentation/mapkit/mkroute/expectedtraveltime)
    * Then display both the calculated route info and the requested to see if it is reasonable.

### Week 6:
  + Midterm Checkpoint/Demo build
  + Goal: have a basic version of the app that can:
    * Generate 3 different types of routes
    * Routes generated fall within spefications that the user provides (time or distance)
    * Calculate the radius around the starting point for random route generation
      - This would be primarliy for the loop route type. 
    * Display the map and routes generated on screen 
     
     
     
     
     
