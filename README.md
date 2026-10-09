# Ahtet

Ahtet is a mobile app that helps children and young people with cognitive
disabilities, including autism, travel and handle daily routines with more
independence. Parents or trusted caregivers can follow the child's location
on a map and get notified when the child enters or leaves a safe zone.

## Current state

The project is at the starting point. It contains the Flutter project setup
for Android, iOS, web, Windows, macOS and Linux, the default starter app, and
a small Node.js backend with a health check endpoint. Features will be added
step by step.

## Tech stack

- Flutter and Dart for the mobile app
- Node.js and Express for the backend server
- Supabase (PostgreSQL) for the database

## Project structure

- The Flutter app sits at the root of the repository.
- `supabase/` holds the backend: the Express server and the Supabase client.

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

## Author

Rejoice Ekong
