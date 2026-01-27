# IndependentStudyProject
## Weekly Breakdown
### Documentation for Map Kit API:
[Click here for documentation](https://developer.apple.com/documentation/mapkit)

### Week 1:
  + Goal: Display a live map view, create a new map given a location and size.
  + Tools: Xcode's built in MapKit
    * Specifically the class "MKMapView" should allow for the basics of displaying a live map.
    * This should look similar to the Apple Maps app.
    * Be able to scroll around and look at areas on the map and other basic map features.
      - All the tools to do this are under the "[Map Coordinates](https://developer.apple.com/documentation/mapkit/mkcoordinateregion)" tab in the documentation.
    * Figure out specifics to have my phone be a usable testing tool. (do I need to register for stuff?)
        
### Week 2:
  + Goal: Priority: Basic route generation for point-to-point routes. Allow user to input longitutde and latitude.
  + Tools: MapKit API
    * Select 2 points on the map and generate a route between them.
    * Will use "MKDirections" and other associated direction tools
    * 
      - These tools are under the "[Directions](https://developer.apple.com/documentation/mapkit)" tab in the documentation.
        
### Week 3:
  + Goal: Refine route generation, get very basic alternate route types started. Caching map data.
  + Tools: [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections), [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), and manual coordinate manipulation.
    * Objectives in detail:
      - Can we make the pin control point larger
      - Can we make routes that don't follow roads...
      - Ensure route generation is stable, no failures, consistent output for times and distances.
      - Implement "out-and-back" routes by just reversing the current route. A -> B reverse B -> A.
      - Begin testing logic for loops by generating mid-way points before returning to the starting position.
    * Potential issues:
      - Looped routes might need manual midpoint generation using coordinates rather than built-in route generation.
      - Route lengths might become inaccurate because of generated waypoints.
        
### Week 4:
  + Goal: Finish implementation of alternate route types (loops)
  + Tools: Using [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute) create random points that will
    * Plan for implementation:
      - Use MKDirections to create multiple smaller routes that connect sequentially (EX: A->B, B->C, C->A).
      - Then combine the route segments into the full loop route.
      -  Consider if you want to build the route all at once or segment by segment.  Consider whether/how pins can be used.
        
### Week 5:
  + Goal: Implement Route generation that will use user-inputted distance or time.
  + Tools: [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections) and [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute)
    * Have simple input form that asks for either a specific time or distance from the user.
    * At this stage time-based routes will have placeholder values.
    * Use random points within the calculated radius to make test routes.
    * Compare returned routes using [MKRoute.distance](https://developer.apple.com/documentation/mapkit/mkroute/distance) or [MKRoute.expectedTravelTime](https://developer.apple.com/documentation/mapkit/mkroute/expectedtraveltime)
    * Then display both the calculated route info and the requested to see if it is reasonable.
    * Working on what the requirements for the demo are going to be.

### Week 6:
  + Midterm Checkpoint/Demo build + Fixing any issues
  + Requirements: Have a basic demo version of the app that can:
    * Generate out-and-back route
    * Generate one-way route
    * Generate loop route
    * Routes generated fall within specifications that the user provides (time or distance within ±10%)
    * Calculate the radius around the starting point for random route generation
      - This would be primarily for the loop route type. 
    * Display the map and routes generated on screen
    * At this state accuracy and randomness will be limited at best — will be a focus point for later on.

### Week 7: Midterm DEMO! 
  + Goal: Implement calibration for custom user speeds for walking, jogging, and running. Think about how to do calibration either do my method or do auto-calibration from previous routes.
  + Tools: [Core Location Framework](https://developer.apple.com/documentation/corelocation) already has speed, coordinate, and timestamp properties built in.
    * Method to calculate the different speeds would be to have the user walk for a set amount of time (1 min for example) then grab the distance between the starting point and the ending point using coordinates or [CLLocationDistance](https://developer.apple.com/documentation/corelocation/cllocationdistance) to get the distance traveled during the time.
    * The speed property in the Core Location Framework allows for semi-customization for how often the speed value is grabbed.
    * End result is that I will grab the speed value many times and then get the average speed. Using that average I will calculate the speed with distance/time to create the user’s average walking/jogging/running speed.
    * Will need the user to calibrate for each speed for most accurate data.
    * Will it work with an Apple Watch. If so how? Maybe use compass method or something.
    * Add in manual recalibration
    * Look into how I am going to store info for routes.
    

### Week 8:
  + Goal: Implement the ability to save routes for future use. Have basic settings for turning on and off sound/vibrations. Look at different methods to store map data + any other information that is needed to remake a route.
  + Tools: [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) for local storage, [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), and route metadata (distance, time, pattern type)
    * Lets the user save generated routes locally on the device.
    * Include metadata for the route:
      - Route name, total distance, duration, and pacing pattern.
    * Add a save system so the user can quickly reselect saved routes.
    * Ensure that routes can be reloaded and displayed on the map again.
    * Be able to turn on or off notification/sounds and vibrations

  
### Week 9:
  + Goal: Implement routes that tell the user to change speed for a certain amount of the route (Pacing Pattern)
  + Tools: [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections), [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), [MKRoute.steps](https://developer.apple.com/documentation/mapkit/mkroute/step), and data grabbed from speed calibration (look at Week 7 for more details).
    * Use MKRoute.steps to divide generated routes into multiple sections.
    * Once divided into sections, assign each section a “target speed” value according to the calibration results.
    * Using this “target speed” value from the calibration, calculate the estimated time to complete each section (distance/target speed).
    * Each section will be labeled with the speed (walking/jogging/running, not specific values) they are supposed to go at.
    * The user will be able to set how much of the route they would like to walk/jog/run.
      - This would be done by allowing the user to select a percentage for each category and then dividing the sections up that way.
      - This percentage system would require checking to ensure that the total is not above 100% (e.g., walk = 60%, run = 60%).
      - Example: walk = 100% → the route only contains walking sections; walk = 50% and jog = 50% → two sections, half the route walking and half jogging.
    * Watch sound affects, size of device, make more concrete plans, decide on if pacing should be by distance or by time.
    * Accessing GPS
    * Consider power usage levels: should aim for low


### Week 10:
 + Goal: Refine "Pacing Pattern" by making sections set to specific lengths depending on the route length, allowing for repeating "patterns", and visual distinction between sections.
  + Tools: [MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections), [MKRoute](https://developer.apple.com/documentation/mapkit/mkroute), and [MKRoute.polyline](https://developer.apple.com/documentation/mapkit/mkroute/polyline)
    * Implement a system for route segments to be fixed on relative distances instead of using navigation steps.
    * Add a spot where the user can insert how many times they would like the pattern to repeat.
    * Calculate section boundaries using total distance measurements along the route’s polyline.
      - A polyline is essentially the full path that the steps (and in my case, multiple smaller routes) combine into one single “main” route.
    * Assign each section the corresponding speed and repeating pattern logic.
    * Provide distinction for different speed sections by changing route color or other visual means.
    * Ensure section timing and total distance remain consistent with the user’s original route input.
    * Consider different color combos for color blindness, or another visual element that is non-color related. (dashes, wider, etc.)


### Week 11:
  + Goal: Implement notifications and in-route feedback for speed changes and directions.
  + Tools: [User Notifications](https://developer.apple.com/documentation/usernotifications), [Core Location](https://developer.apple.com/documentation/corelocation), and [AVFoundation](https://developer.apple.com/documentation/avfoundation).
    * Use **local notifications** rather than push notifications. Local notifications can trigger in the background without needing a server.
    * [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) handles scheduling, permissions, and displaying notifications.
    * [Core Location](https://developer.apple.com/documentation/corelocation) will be used to trigger notifications based on real-time location updates.
      - Make sure to enable background location updates in the project settings and with `allowsBackgroundLocationUpdates = true` inside the location manager.
    * Have local notifications for pacing transitions and directional feedback.
      - Include distinct audio tones (using [AVFoundation](https://developer.apple.com/documentation/avfoundation)) for each pacing speed.
      - When the user sets a route, display the speed categories (walk/jog/run) and show which sound corresponds to each.
    * Add vibration alerts to match the sound notifications for users without headphones or who are hearing impaired.
    * Include turn-by-turn or checkpoint notifications triggered by Core Location events.
    * Ensure that notifications still appear while the app is in the background and that they remain synced with location updates for accurate timing.
    * Test background functionality on a physical device (notifications will not appear in the simulator when the app is backgrounded).

### Week 12:
  + Goal: Implement a tool that allows the user to place resting points along the generated route.
  + Tools: [MKMapView](https://developer.apple.com/documentation/mapkit/mkmapview), [MKPointAnnotation](https://developer.apple.com/documentation/mapkit/mkpointannotation), and local data storage using [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults).
    * Allow the user to tap a point on the generated route and insert a "pin".
    * Allow multiple break points to be added.
    * Each resting point will be stored with its coordinates and an optional label.
    * Resting points will have custom markers or points on the map for clarity.
    * Ensure that the points are saved along with the route data so they can persist across uses.
    * Allow for the removal of break points.
      - In the future this system could be altered for creating POI pins as well.

### Week 13:
  + Goal: Having the app work in the background and other clean up.
  + Tools: [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate) manages the app’s state during transitions, [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager), and other tools involved in improving battery optimization.
    * Allow the app to work if the user locks their phone and/or has another application in the foreground.
    * Make sure that notifications and feedback continue to work when in the background.
    * Use `allowsBackgroundLocationUpdates`, `pausesLocationUpdatesAutomatically`, and appropriate background modes in Info.plist.
    * Optimize performance to limit battery drain.
    * Overall “housekeeping” — making things look nice and altering small aspects of previous weeks.

### Week 14:
  + Goal: Have the "final" build of the app ready for presentation.
  + Tools: N/A
    * Final debugging and performance testing.
    * Ensure that all major features are stable:
      - Working display for a map.
      - Generating routes based on user-given time or distance.
      - Ability to generate 3 different types of routes: point-to-point, out-and-back, and loop.
      - Calibration for 3 different speed types from the user.
        + Walk, jog, and run.
      - Generated routes can have different sections where the user switches between the 3 speeds.
      - Ability to insert and remove resting spots on the route.
      - Working notifications for general directions, changes in speed, and when reaching a resting spot.
        + Visual, auditory, and physical (buzzing) notification types.
      - Be able to save "favorited" routes and re-use them later.
        + Will keep resting points in saved versions.


### Week 15:
  + Finals week demo
  + Tuesday April 28th 12-1.
  + Have everything working.



### Features:
  1. Installed on phone [x]
  2. displays map [x]
  3. allows for user to insert points to generate a route [x]
  4. allow user to insert coordinates for a location and go to it [x]
  5. allow for dragging around of point [ ]
  6. have time in corner [ ]
  7. app settings [ ]
  8. start route button [ ]
  9. stop route boutton [ ]
  10. Use current location [ ]
  11. have the user insert a distance for route length [ ]
  12. have user insert a target time for the route [ ]
  13. updating the user speeds for the users walk, jog, run speed [ ]

### Unspecified:
  + Potentially register for the [Apple Developer Program](https://developer.apple.com/programs)
    * Dependent on how much I can accomplish using the "free" version of allowing real hardware testing.
    * You can have apps on your device without paying for it but it has limitations:
      - Only allowed to have on device for 7 days.
      - Can't use TestFlight (send to other users to test) or distribute.
      - Has some limitations for certain background modes like GPS and push notifications.




