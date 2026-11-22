-- Replace the open policies with policies that only let a user work
-- with their own rows.

DROP POLICY IF EXISTS "Enable all operations for device_locations" ON device_locations;
DROP POLICY IF EXISTS "Enable all operations for safe zone" ON safe_zone;
DROP POLICY IF EXISTS "Enable all operations for users" ON location_list;
DROP POLICY IF EXISTS "Enable all operations for task list" ON task_list;
DROP POLICY IF EXISTS "Enable all operations for bounding box" ON bounding_box;
DROP POLICY IF EXISTS "Enable all operations for task completions" ON task_completions;
DROP POLICY IF EXISTS "Enable all operations for connected_devices" ON connected_devices;
DROP POLICY IF EXISTS "Enable all operations for notifications" ON notifications;

-- Tables with their own user_id
CREATE POLICY "Owner can manage device" ON device_locations
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Owner can manage safe zone" ON safe_zone
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Owner can manage route" ON location_list
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Owner can manage task" ON task_list
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Owner can manage connection" ON connected_devices
  FOR ALL TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- Tables that belong to a parent row
CREATE POLICY "Owner can manage bounding box" ON bounding_box
  FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM safe_zone sz
    WHERE sz.id = bounding_box.safe_zone_id AND sz.user_id = auth.uid()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM safe_zone sz
    WHERE sz.id = bounding_box.safe_zone_id AND sz.user_id = auth.uid()
  ));

CREATE POLICY "Owner can manage task completion" ON task_completions
  FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM task_list t
    WHERE t.id = task_completions.original_task_id AND t.user_id = auth.uid()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM task_list t
    WHERE t.id = task_completions.original_task_id AND t.user_id = auth.uid()
  ));

-- Notifications point at the watched device, which belongs to another
-- user, so they get their own owner column.
ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid();

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);

CREATE POLICY "Owner can manage notification" ON notifications
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
