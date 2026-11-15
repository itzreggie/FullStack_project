# Ahtet

Ahtet is a mobile app that helps children and young people with cognitive
disabilities, including autism, travel and handle daily routines with more
independence. Parents or trusted caregivers can follow the child's location
on a map and get notified when the child enters or leaves a safe zone.

<img src="flutter_01.png" alt="Ahtet map screen" width="250">

## Features

- **Live map.** A Mapbox map whose style follows the time of day. The user
  and every connected device show up as round photo markers with a pulse.
- **Location tracking.** The phone's position is sent to Supabase, also in
  the background, and can be turned on or off in the settings.
- **Connected devices.** Each phone gets a short code such as `12A-B34`. A
  parent types in a child's code to follow that phone on the map and can
  give it a custom name.
- **Safe zones.** Search for a place, save it as a safe zone and draw its
  border on the map by dragging four corners.
- **Notifications.** A notification is shown when a connected device enters
  or leaves a safe zone. Every event is saved and can be reviewed in the
  notification history.
- **Routes.** Plan a route between two places by walking, driving or
  cycling, choose a time range and save it. Saved routes can be shown on
  the map again.
- **Tasks.** Create daily, weekly or one time tasks with an optional photo
  and tick them off on the home screen.

## Tech stack

- Flutter and Dart for the mobile app
- Mapbox Maps Flutter for the map, and Mapbox geocoding with Google Places
  for place search
- Google Directions API for routes
- Geolocator and Flutter Background Service for location tracking
- Flutter Local Notifications for safe zone alerts
- Supabase (PostgreSQL, Realtime and Storage) for data, live location
  updates and task images
- Node.js and Express for the backend server

## Project structure

- `lib/main.dart` starts the services and opens the map.
- `lib/screens/` holds the screens: map, home, directions, safe zones,
  task input, settings, notification history and the info pages.
- `lib/services/` holds the logic for Supabase, tracking, notifications,
  place search, routes and map markers.
- `lib/widgets/` holds the reusable parts such as the map buttons, the
  sidebar, the bounding box editor and the lists.
- `lib/assets/` holds the images and app icons.
- `supabase/` holds the backend: the Express server, the Supabase client,
  the SQL migration and the `npm run migrate` script that creates the
  tables.

## Running the app

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   (Dart 3.8 or newer).
2. Clone the repository:

   ```
   git clone https://github.com/itzreggie/FullStack_project.git
   cd FullStack_project
   ```

3. Copy `.env.example` to `.env` in the project root and fill in the keys:

   - `MAPBOX_ACCESS_TOKEN` from your Mapbox account
   - `GOOGLE_PLACES_API_KEY` from Google Cloud
   - `SUPABASE_URL` and `SUPABASE_ANON_KEY` from your Supabase project settings

   The app bundles `.env` as an asset, so the file has to exist before you
   build. It is listed in `.gitignore` to keep the keys out of the repository.

4. Get the packages and start the app on a connected device or emulator:

   ```
   flutter pub get
   flutter run
   ```

## Running the backend

1. Install [Node.js](https://nodejs.org/).
2. Copy `supabase/.env.example` to `supabase/.env` and fill in the keys from
   your Supabase project settings.
3. Install the packages and start the server:

   ```
   cd supabase
   npm install
   npm start
   ```

4. Open http://localhost:3000/health to check that the server is running.
5. Create the tables and the `task-images` storage bucket with:

   ```
   npm run migrate
   ```

   The script calls an `execute_sql` function, which has to exist in your
   Supabase project.

## Author

Rejoice Ekong
