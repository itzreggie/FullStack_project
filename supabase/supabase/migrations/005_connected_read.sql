-- Let a user see the location of devices they are connected to.
-- Only reading is allowed. Realtime uses the same policy, so the map
-- still gets live updates for connected devices.

CREATE POLICY "Connected users can read device" ON device_locations
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM connected_devices cd
    WHERE cd.connected_device_id = device_locations.id
      AND cd.owner_id = auth.uid()
  ));
