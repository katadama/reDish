Ez a vonal alatt lévő sql-t kell bemásolni a supabase sql editorba
________________________________________________________________

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Profile table
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create indexes on frequently queried columns
CREATE INDEX idx_profiles_user_id ON profiles(user_id);

-- Create Category table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create ListItem table
CREATE TABLE list_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    profile_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    db INTEGER DEFAULT 1,
    price DOUBLE PRECISION DEFAULT 0,
    category_id UUID,
    list_type INTEGER NOT NULL,
    weight INTEGER DEFAULT 0,
    last_moved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    psdays INTEGER DEFAULT 0,  -- predicted spoiling date
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    CONSTRAINT check_list_type CHECK (list_type BETWEEN 1 AND 3)
);

-- Create indexes for better query performance
CREATE INDEX idx_list_items_user_id ON list_items(user_id);
CREATE INDEX idx_list_items_profile_id ON list_items(profile_id);
CREATE INDEX idx_list_items_category_id ON list_items(category_id);
CREATE INDEX idx_list_items_list_type ON list_items(list_type);

-- Function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update the updated_at column
CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_categories_updated_at
BEFORE UPDATE ON categories
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_list_items_updated_at
BEFORE UPDATE ON list_items
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Insert the predefined categories
INSERT INTO categories (name) VALUES
    ('Zöldség'),
    ('Gyümölcs'),
    ('Pékárú'),
    ('Hús'),
    ('Italok'),
    ('Alkohol'),
    ('Háztartás'),
    ('Alapvető élelmiszerek'),
    ('Tejtermékek'),
    ('Szépségápolás');


-- Add a color column (integer) with a default value of 0 to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS color INTEGER DEFAULT 0;


-- Function to update last_moved_at when list_type changes
CREATE OR REPLACE FUNCTION update_last_moved_at()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.list_type IS NULL OR NEW.list_type != OLD.list_type THEN
        NEW.last_moved_at = CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update last_moved_at when list_type changes
CREATE TRIGGER update_list_items_last_moved_at
BEFORE UPDATE ON list_items
FOR EACH ROW EXECUTE FUNCTION update_last_moved_at();

-- Ensure last_moved_at default is CURRENT_DATE
ALTER TABLE list_items 
ALTER COLUMN last_moved_at SET DEFAULT CURRENT_DATE;

-- Update any existing NULL values to current date
UPDATE list_items
SET last_moved_at = CURRENT_DATE
WHERE last_moved_at IS NULL;

-- Function to update last_moved_at when list_type changes
CREATE OR REPLACE FUNCTION update_last_moved_at()
RETURNS TRIGGER AS $$
BEGIN
    -- For new inserts, set last_moved_at to current timestamp
    IF TG_OP = 'INSERT' THEN
        NEW.last_moved_at = CURRENT_TIMESTAMP;
    -- For updates, only change last_moved_at if list_type changed
    ELSIF TG_OP = 'UPDATE' AND NEW.list_type != OLD.list_type THEN
        NEW.last_moved_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_list_items_last_moved_at ON list_items;

-- Create trigger for both INSERT and UPDATE operations
CREATE TRIGGER update_list_items_last_moved_at
BEFORE INSERT OR UPDATE ON list_items
FOR EACH ROW EXECUTE FUNCTION update_last_moved_at();


-- Create Logs table
CREATE TABLE logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    profile_id UUID NOT NULL,
    log_name VARCHAR(255) NOT NULL,
    additional_data JSONB DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_logs_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_logs_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX idx_logs_user_id ON logs(user_id);
CREATE INDEX idx_logs_profile_id ON logs(profile_id);
CREATE INDEX idx_logs_log_name ON logs(log_name);
CREATE INDEX idx_logs_created_at ON logs(created_at);

-- Create trigger to automatically update the updated_at column
CREATE TRIGGER update_logs_updated_at
BEFORE UPDATE ON logs
FOR EACH ROW EXECUTE FUNCTION update_modified_column();