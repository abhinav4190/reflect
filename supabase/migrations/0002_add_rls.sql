ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE life_entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE reflections ENABLE ROW LEVEL SECURITY;
ALTER TABLE reflection_entity_alignment ENABLE ROW LEVEL SECURITY;
ALTER TABLE photo_assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "own_users_row" ON users FOR ALL USING (auth.uid() = id);
CREATE POLICY "own_entities" ON life_entities FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own_reflections" ON reflections FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own_photos" ON photo_assets FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own_alignment" ON reflection_entity_alignment FOR ALL USING (
    EXISTS (SELECT 1 FROM reflections r WHERE r.id = reflection_id AND r.user_id = auth.uid())
);