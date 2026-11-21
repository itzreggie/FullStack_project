-- Link the main tables to the Supabase auth user that owns each row.
-- auth.uid() fills the column on insert, so the app does not have to
-- send it.

ALTER TABLE device_locations
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid();

ALTER TABLE safe_zone
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid();

ALTER TABLE location_list
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid();

ALTER TABLE task_list
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid();

CREATE INDEX IF NOT EXISTS idx_device_locations_user_id ON device_locations(user_id);
CREATE INDEX IF NOT EXISTS idx_safe_zone_user_id ON safe_zone(user_id);
CREATE INDEX IF NOT EXISTS idx_location_list_user_id ON location_list(user_id);
CREATE INDEX IF NOT EXISTS idx_task_list_user_id ON task_list(user_id);
