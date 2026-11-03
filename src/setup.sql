CREATE TABLE IF NOT EXISTS organizations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  image_path VARCHAR(255),
  category VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS projects (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  schedule VARCHAR(100),
  image_path VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS project_categories (
  project_id INTEGER NOT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  category_id INTEGER NOT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (project_id, category_id)
);

INSERT INTO organizations (name, description, image_path, category) VALUES
  ('Community Food Pantry', 'Fights food insecurity by collecting, sorting, and distributing groceries to local families.', '/images/food-bank.jpg', 'Community Service'),
  ('Green City Alliance', 'Improves neighborhoods through cleanups, conservation projects, and community education.', '/images/green-city.jpg', 'Environmental'),
  ('Bright Futures Youth Center', 'Supports students with tutoring, mentoring, and after-school enrichment activities.', '/images/youth-center.webp', 'Educational')
ON CONFLICT (name) DO NOTHING;

INSERT INTO projects (organization_id, name, description, schedule, image_path) VALUES
  ((SELECT id FROM organizations WHERE name = 'Green City Alliance'), 'Riverside Cleanup', 'Help remove litter and restore a shared community trail.', 'Saturday, 9:00 AM', '/images/green-city.jpg'),
  ((SELECT id FROM organizations WHERE name = 'Bright Futures Youth Center'), 'Homework Buddies', 'Volunteer as a tutor and encourage young learners.', 'Wednesday, 4:00 PM', '/images/youth-center.webp'),
  ((SELECT id FROM organizations WHERE name = 'Community Food Pantry'), 'Community Meal', 'Prepare and serve a welcoming meal for local neighbors.', 'Sunday, 10:00 AM', '/images/food-bank.jpg')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name) VALUES
  ('Environmental'),
  ('Educational'),
  ('Community Service'),
  ('Health and Wellness')
ON CONFLICT (name) DO NOTHING;

INSERT INTO project_categories (project_id, category_id) VALUES
  ((SELECT id FROM projects WHERE name = 'Riverside Cleanup'), (SELECT id FROM categories WHERE name = 'Environmental')),
  ((SELECT id FROM projects WHERE name = 'Homework Buddies'), (SELECT id FROM categories WHERE name = 'Educational')),
  ((SELECT id FROM projects WHERE name = 'Homework Buddies'), (SELECT id FROM categories WHERE name = 'Community Service')),
  ((SELECT id FROM projects WHERE name = 'Community Meal'), (SELECT id FROM categories WHERE name = 'Community Service')),
  ((SELECT id FROM projects WHERE name = 'Community Meal'), (SELECT id FROM categories WHERE name = 'Health and Wellness'))
ON CONFLICT DO NOTHING;
