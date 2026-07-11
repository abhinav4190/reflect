CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    timezone VARCHAR(100) DEFAULT 'UTC',
    is_premium_member BOOLEAN DEFAULT FALSE,
    waking_hours_start TIME NOT NULL DEFAULT '07:00:00',
    waking_hours_end TIME NOT NULL DEFAULT '23:00:00',
    reflection_frequency VARCHAR(50) NOT NULL DEFAULT 'hourly',
    custom_frequency_minutes INT DEFAULT 60,
    gdrive_connected BOOLEAN DEFAULT FALSE,
    gdrive_root_folder_id VARCHAR(255) DEFAULT NULL,
    storage_mode VARCHAR(50) NOT NULL DEFAULT 'local'
);

CREATE TABLE life_entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) on DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    target_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    archived BOOLEAN DEFAULT FALSE,
    recurrence_rule VARCHAR(100) DEFAULT NULL,
    current_value NUMERIC DEFAULT 0,
    target_value NUMERIC DEFAULT NULL,
    metric_label VARCHAR(100) DEFAULT NULL
);

CREATE TABLE reflections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    raw_text TEXT NOT NULL,
    mood VARCHAR(100) DEFAULT NULL,
    consciousness_score INT NOT NULL,
    time_allocation JSONB DEFAULT '[]'::jsonb,
    spending JSONB DEFAULT '[]'::jsonb,
    food_consumption JSONB DEFAULT '[]'::jsonb,
    water_ml INT DEFAULT 0,
    sleep_duration_minutes INT DEFAULT NULL,
    sleep_quality INT DEFAULT NULL,
    ai_summary TEXT NOT NULL
);

CREATE TABLE reflection_entity_alignment (
    reflection_id UUID NOT NULL REFERENCES reflections(id) ON DELETE CASCADE,
    entity_id UUID NOT NULL REFERENCES life_entities(id) ON DELETE CASCADE,
    progress_delta NUMERIC DEFAULT 0,
    qualitative_impact TEXT DEFAULT NULL,
    PRIMARY KEY (reflection_id, entity_id)
);

CREATE TABLE photo_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    associated_entity_id UUID DEFAULT NULL REFERENCES life_entities(id) ON DELETE SET NULL,
    photo_type VARCHAR(50) NOT NULL,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    storage_provider VARCHAR(50) NOT NULL,
    file_refrence_path TEXT NOT NULL,
    image_metadata JSONB DEFAULT '{}'::jsonb
);