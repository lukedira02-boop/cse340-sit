CREATE TABLE IF NOT EXISTS organizations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  image_path VARCHAR(255)
);

ALTER TABLE organizations DROP COLUMN IF EXISTS category;

CREATE TABLE IF NOT EXISTS projects (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  schedule DATE,
  location VARCHAR(255),
  image_path VARCHAR(255)
);

ALTER TABLE projects ADD COLUMN IF NOT EXISTS location VARCHAR(255);

ALTER TABLE projects
  ALTER COLUMN schedule TYPE DATE
  USING CASE
    WHEN schedule IS NULL THEN NULL
    WHEN schedule::TEXT ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN schedule::TEXT::DATE
    ELSE NULL
  END;

CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS project_categories (
  project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (project_id, category_id)
);

INSERT INTO organizations (name, description, image_path) VALUES
  ('Community Food Pantry', 'Fights food insecurity by collecting, sorting, and distributing groceries to local families.', '/images/food-bank.jpg'),
  ('Green City Alliance', 'Improves neighborhoods through cleanups, conservation projects, and community education.', '/images/green-city.jpg'),
  ('Bright Futures Youth Center', 'Supports students with tutoring, mentoring, and after-school enrichment activities.', '/images/youth-center.webp')
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  image_path = EXCLUDED.image_path;

INSERT INTO categories (name) VALUES
  ('Environmental'),
  ('Educational'),
  ('Community Service'),
  ('Health and Wellness')
ON CONFLICT (name) DO NOTHING;

INSERT INTO projects (organization_id, name, description, schedule, location, image_path) VALUES
  ((SELECT id FROM organizations WHERE name = 'Community Food Pantry'), 'Community Meal', 'Prepare and serve a welcoming meal for local neighbors.', '2026-11-08', 'Community Food Pantry Kitchen', '/images/food-bank.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Community Food Pantry'), 'Food Sorting Shift', 'Sort donated groceries and prepare food boxes for families.', '2026-11-10', 'Main Distribution Center', '/images/food-bank.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Community Food Pantry'), 'Weekend Grocery Drive', 'Collect donations and distribute groceries in the community.', '2026-11-14', 'Westside Market', '/images/food-bank.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Community Food Pantry'), 'Senior Lunch Delivery', 'Deliver prepared meals to senior neighbors.', '2026-11-17', 'Central Neighborhood Route', '/images/food-bank.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Community Food Pantry'), 'Pantry Inventory Day', 'Organize pantry shelves and update supply records.', '2026-11-21', 'Community Food Pantry Storage', '/images/food-bank.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Green City Alliance'), 'Riverside Cleanup', 'Help remove litter and restore a shared community trail.', '2026-11-09', 'Riverside Walking Trail', '/images/green-city.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Green City Alliance'), 'Tree Planting Day', 'Plant native trees in neighborhood green spaces.', '2026-11-12', 'Oak View Park', '/images/green-city.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Green City Alliance'), 'Community Garden Build', 'Build garden beds and prepare planting areas.', '2026-11-16', 'Northside Community Garden', '/images/green-city.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Green City Alliance'), 'Park Trail Repair', 'Repair walkways and remove invasive plants from park trails.', '2026-11-19', 'Greenwood Park', '/images/green-city.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Green City Alliance'), 'Neighborhood Recycling Drive', 'Collect recyclable materials and teach residents sorting basics.', '2026-11-23', 'Green City Alliance Center', '/images/green-city.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Bright Futures Youth Center'), 'Homework Buddies', 'Volunteer as a tutor and encourage young learners.', '2026-11-11', 'Bright Futures Learning Room', '/images/youth-center.webp'),
  ((SELECT id FROM organizations WHERE name = 'Bright Futures Youth Center'), 'Youth Mentoring Night', 'Meet with students and support their personal goals.', '2026-11-13', 'Bright Futures Main Hall', '/images/youth-center.webp'),
  ((SELECT id FROM organizations WHERE name = 'Bright Futures Youth Center'), 'Reading Circle', 'Read stories and lead literacy activities with young children.', '2026-11-18', 'Bright Futures Library', '/images/youth-center.webp'),
  ((SELECT id FROM organizations WHERE name = 'Bright Futures Youth Center'), 'Science Activity Lab', 'Help students complete hands-on science experiments.', '2026-11-20', 'Bright Futures Technology Lab', '/images/youth-center.webp'),
  ((SELECT id FROM organizations WHERE name = 'Bright Futures Youth Center'), 'After-School Sports Clinic', 'Coach games and teach teamwork to middle-school students.', '2026-11-22', 'Bright Futures Gymnasium', '/images/youth-center.webp')
ON CONFLICT (name) DO UPDATE SET
  organization_id = EXCLUDED.organization_id,
  description = EXCLUDED.description,
  schedule = EXCLUDED.schedule,
  location = EXCLUDED.location,
  image_path = EXCLUDED.image_path;

INSERT INTO project_categories (project_id, category_id)
SELECT p.id, c.id FROM projects p
JOIN categories c ON
  (p.name IN ('Community Meal', 'Food Sorting Shift', 'Weekend Grocery Drive', 'Senior Lunch Delivery', 'Pantry Inventory Day') AND c.name IN ('Community Service', 'Health and Wellness'))
  OR (p.name IN ('Riverside Cleanup', 'Tree Planting Day', 'Community Garden Build', 'Park Trail Repair', 'Neighborhood Recycling Drive') AND c.name = 'Environmental')
  OR (p.name IN ('Homework Buddies', 'Youth Mentoring Night', 'Reading Circle', 'Science Activity Lab', 'After-School Sports Clinic') AND c.name IN ('Educational', 'Community Service'))
ON CONFLICT DO NOTHING;
