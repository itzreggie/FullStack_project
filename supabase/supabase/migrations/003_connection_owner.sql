-- Store who created each device connection. The connection row is
-- written from the tracking device, so this is the user who added
-- the other device to their list.

ALTER TABLE connected_devices
  ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid();

CREATE INDEX IF NOT EXISTS idx_connected_devices_owner_id ON connected_devices(owner_id);

-- Fill the owner for older rows from the device that made the connection.
UPDATE connected_devices cd
SET owner_id = dl.user_id
FROM device_locations dl
WHERE cd.device_location_id = dl.id
  AND cd.owner_id IS NULL
  AND dl.user_id IS NOT NULL;
