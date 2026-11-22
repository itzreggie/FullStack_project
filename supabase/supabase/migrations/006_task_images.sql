-- The old "Public Access" policy let anyone upload, replace or delete
-- any task image. Keep the bucket public for reading, but only allow
-- changes inside a folder named after the user's id.

DROP POLICY IF EXISTS "Public Access" ON storage.objects;

CREATE POLICY "Anyone can view task images" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'task-images');

CREATE POLICY "Users can upload own task images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'task-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can update own task images" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'task-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can delete own task images" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'task-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
