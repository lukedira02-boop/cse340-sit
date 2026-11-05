DROP TABLE IF EXISTS project_categories;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS organizations;

CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    email VARCHAR(255) NOT NULL,
    logo VARCHAR(255)
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    schedule DATE NOT NULL
);

CREATE TABLE project_categories (
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, category_id)
);

INSERT INTO organizations (name, description, email, logo) VALUES
    ('Green Valley Alliance', 'Restores local parks, plants trees, and organizes river cleanups.', 'hello@greenvalley.example', '/images/green-valley-alliance.svg'),
    ('Bright Futures Tutoring', 'Offers free after-school tutoring and reading help for local students.', 'learn@brightfutures.example', '/images/bright-futures-tutoring.svg'),
    ('Helping Hands Health', 'Runs wellness fairs, food drives, and neighborhood health check-ins.', 'care@helpinghands.example', '/images/helping-hands-health.svg');

INSERT INTO categories (name) VALUES
    ('Environmental'),
    ('Educational'),
    ('Community Service'),
    ('Health and Wellness');

INSERT INTO projects (organization_id, name, description, location, schedule) VALUES
    (1, 'Riverbank Cleanup', 'Remove litter and plant native shrubs along the river trail.', 'River Trail North Entrance', '2026-04-11'),
    (1, 'Community Tree Planting', 'Plant native trees in neighborhood parks.', 'Green Valley Park', '2026-04-18'),
    (1, 'Trail Restoration Day', 'Repair trail erosion and improve park paths.', 'Canyon Loop Trailhead', '2026-05-02'),
    (1, 'Park Invasive Plant Removal', 'Remove invasive plants and restore garden beds.', 'Central Community Park', '2026-05-09'),
    (1, 'Neighborhood Recycling Drive', 'Collect and sort recyclables from residents.', 'Green Valley Community Center', '2026-05-16'),
    (2, 'Saturday Reading Club', 'Read with elementary students and help build confidence.', 'Bright Futures Learning Center', '2026-04-12'),
    (2, 'Math Homework Lab', 'Support middle-school students with math assignments.', 'Westside Public Library', '2026-04-19'),
    (2, 'Back-to-School Supply Fair', 'Prepare and distribute school supplies for students.', 'Bright Futures Gymnasium', '2026-05-03'),
    (2, 'Reading Buddy Training', 'Train volunteers to mentor beginning readers.', 'Oak Street Library', '2026-05-10'),
    (2, 'Student Career Workshop', 'Help high-school students practice interview skills.', 'Bright Futures Career Room', '2026-05-17'),
    (3, 'Neighborhood Food Drive', 'Sort and deliver donated groceries to families in need.', 'Helping Hands Food Pantry', '2026-04-13'),
    (3, 'Community Wellness Fair', 'Assist with screenings and healthy-living booths.', 'Helping Hands Wellness Hall', '2026-04-20'),
    (3, 'Senior Wellness Check-in', 'Deliver check-in materials and wellness resources.', 'Riverside Senior Center', '2026-05-04'),
    (3, 'Blood Pressure Clinic', 'Register visitors and support volunteer health professionals.', 'Central Clinic Campus', '2026-05-11'),
    (3, 'Healthy Meals Packing Day', 'Pack nutritious meals for local households.', 'Helping Hands Kitchen', '2026-05-18');

INSERT INTO project_categories (project_id, category_id) VALUES
    (1, 1), (1, 3),
    (2, 1),
    (3, 1), (3, 3),
    (4, 1),
    (5, 1), (5, 3),
    (6, 2),
    (7, 2),
    (8, 2), (8, 3),
    (9, 2),
    (10, 2), (10, 3),
    (11, 3),
    (12, 4), (12, 3),
    (13, 4),
    (14, 4),
    (15, 3), (15, 4);
