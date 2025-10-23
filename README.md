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
  + Goal: have a basic demo version of the app that can:
    * Generate 3 different types of routes
    * Routes generated fall within spefications that the user provides (time or distance within ±10%)
    * Calculate the radius around the starting point for random route generation
      - This would be primarliy for the loop route type. 
    * Display the map and routes generated on screen
    * At this state accuracy and randomness will be limited at best will be a focus point for later on.

### Week 7:
  + Goal: Implement calibration for custom user speeds for walking, jogging, and running.
  + Tools: [Core Location Framework](https://developer.apple.com/documentation/corelocation) already has speed, coordinate, and timestamp properties built in.
    * Method to calculate the different speeds would be to have the user walk for a set amount of time (1 min for example) then grab the distance between the starting point and the ending point using coordinates or "[CLLocationDistance](https://developer.apple.com/documentation/corelocation/cllocationdistance)" to get the distance that was travled during the time.
    * The speed property in the Core Location Framework allows for semi-customization for how often the speed value is grabbed.
    * End result is that I will grab the speed value lots of times and then get the average speed and using that average I will calculate the speed with distance/time to create the users average walking/jogging/running speed.
    * Will need the user to calibrate for each speeds for most accurate data.

### Week 8:
  + Goal: Implement routes that tell the user to change speed for a certain amount of the route (Pacing Pattern)
  + Tools: [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections), [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), [MKRoute.steps](https://developer.apple.com/documentation/mapkit/mkroute/step), and data grabbed from speed calibration (look at Week 7 for more details).
    * Use MKRoute.steps to divide generated routes into multiple sections.
    * Once divided into sections for that sections speed assign it a "target speed" value according to the calibration results for the 3 speeds.
    * Using this "target speed" value from the calibration then calculate the estimated time to complete a section. (distance/target speed)
    * For each section they would be labled with the speed (walking/jogging/running not specific values) they are supposed to be going at.
    * The user will be able to set how much of the route they would like to walk/jog/run.
      - This would be done by allowing the user to select a percentage for each category and then dividing the sections up that way.
      - This percentage system would require checking to ensure that the user doesn't have values where the total is above 100% i.e. walk = 60% run = 60%.
      - Example: walk = 100% the route would only contain walking section, walk = 50% and jog = 50% 2 sections half the route is walking other half is jogging.

### Week 9:
  + Goal: Refine "Pacing Pattern" by making sections set to specific lengths depending on the route length, allowing for repeating "patterns", and visual distinciton between sections.
  + Tools:  [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections), [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), and [MKRoute.polyline](https://developer.apple.com/documentation/mapkit/mkroute/polyline)
    * Implementation system for route segements to be fixed on relative distances instead of using navigation steps.
    * Add spot where the user can insert how many times they would like the pattern to repeat.
    * Calculate section boundaries using the total distance measurements along the route's polyline.
      - A polyline is essentially the full path that the steps, and in my case, the multiple smaller routes combined into the one singluar "main" route.
    * Assign each section with the according the speed and repeating pattern logic.
    * Provide a distinction for the different speed sections by changing the routes color or other visual means.
    * Ensure that the section timing and total distance remain consistant with the users orignal route input.

### Week 10:
  + Goal: Implement the ability to save routes for future use
  + Tools: [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) for local storage, [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), and route metadata (distance, time, pattern type)
    * Lets the user save generated routes locally on the device.
    * Include metadata for the route
      - Route name, total distance, duration, and pacing pattern.
    * Add a Save system so the user can quickly reselect saved routes
    * Ensure that routes can be reloaded and displayed on the map again.

### Week 11:
  + Goal: Implement notifications and in-route feedback for speed changes and directions.
  + Tools: [User Notifications](https://developer.apple.com/documentation/usernotifications), [Core Location](https://developer.apple.com/documentation/corelocation), and [AVFoundation](https://developer.apple.com/documentation/avfoundation).
    * Have local notifications (important for later implementations) for pacing transitions.
      - Have dinging or rining sounds to differentiate.
      - When the user sets a route it will display the types of speeds they will be going and then show them what sound means what speed.
    * Have vibration alerts with the same concept as the sounds for people without headphones and/or are hearing impaired.
    * Include turn-by-turn or checkpoint cues for major route steps.
    * Make sure notifications are synced with location updates and not delayed.
   
### Week 12:
  + Goal: Implement a tool that allows the user to place resting points along the generated route.
  + Tools: [MKMapView](https://developer.apple.com/documentation/mapkit/mkmapview), [MKPointAnnotation](https://developer.apple.com/documentation/mapkit/mkpointannotation), and local data storage using [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults).
    * Allow the user to tap a point on the generated route and insert a "pin".
    * Allow multiple break points to be added
    * Each resting point will be stored with its coordinates and an optional label.
    * Resting points will have custom markers or points on the map for clarity.
    * Ensure that the points are saved along with the route data so they can persist across uses.
    * Allow for the removal of break points.
      - In the future this system could be altered for creating POI pins aswell.

### Week 13:
  + Goal: Having the app work in the background and other clean up.
  + Tools: [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate) manages the apps state when doing transitions, [CLLoactionManager](https://developer.apple.com/documentation/corelocation/cllocationmanager), other random tools invovled in improving battery optimization.
  * Allow the app to work if the user locks their phone and/or has another application in the fore-front.
  * Make sure that the notifications and feedback continue to work when in the background.
  * Optimize performance to limit battery drain.
  * Overall "house-keeping" making things look nice and maybe altering little aspects of previous weeks.


### Week 14:
  + Goal: Have the "final" build of the app ready for presentation
  + Tools: N/A
    * Final debugging and performance testing
    * Ensure that all major features are stable:
      - Having a working display for a map.
      - Generating routes based off of user given time or distance.
      - Have the ability to generate 3 different types of routes point-to-point, out-and-back, and loop.
      - Calibration for 3 different speed types from the user.
        + Walk, jog, and run
      - Generated routes will can have different sections that have the user switch inbetween the 3 speeds.
      - The user has the ability to insert and remove resting spots on the route.
      - Working notifications for general directions, changes in speed, and when you reach a resting spot.
        + Visual, audiotorial, and physical (buzzing) notification types.
      - Be able to save "favorited" routes and re-use them later.
        + Will keep resting points in saved version.
       

### Unspecified:
  + Potentially register for the [Apple Developer Program](https://developer.apple.com/programs)
    * Dependent on how much I can accomplish using the "free" version of allowing real hardware testing.
    * You can have apps on your device without paying for it but has limitations:
      - Only allowed to have on device for 7 days
      - Can't use TestFlight (send to other users to test) or distribute
      - Has some limitations for certain background modes like GPS and push notifications
     
     
