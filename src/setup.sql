DROP TABLE IF EXISTS project_categories;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS organization;

CREATE TABLE organization (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    logo_filename VARCHAR(255) NOT NULL
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE project (
    project_id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL
        REFERENCES organization(organization_id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    schedule DATE NOT NULL
);

CREATE TABLE project_categories (
    project_id INTEGER NOT NULL
        REFERENCES project(project_id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL
        REFERENCES categories(category_id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, category_id)
);

INSERT INTO organization (name, description, contact_email, logo_filename) VALUES
    ('BrightFuture Builders', 'A nonprofit focused on improving community infrastructure through sustainable construction projects.', 'info@brightfuturebuilders.org', 'green-city.jpg'),
    ('GreenHarvest Growers', 'An urban farming collective promoting food sustainability and education in local neighborhoods.', 'contact@greenharvest.org', 'food-bank.jpg'),
    ('UnityServe Volunteers', 'A volunteer coordination group supporting local charities and service initiatives.', 'hello@unityserve.org', 'youth-center.webp');

INSERT INTO categories (name) VALUES
    ('Environmental'),
    ('Educational'),
    ('Community Service'),
    ('Health and Wellness');

INSERT INTO project (organization_id, name, description, location, schedule) VALUES
    (1, 'Community Playground Build', 'Build and paint a safe neighborhood playground.', 'Riverside Community Park', '2026-04-11'),
    (1, 'Neighborhood Housing Repair', 'Complete minor repairs for residents in need.', 'Eastview Homes', '2026-04-18'),
    (1, 'Community Garden Construction', 'Construct raised garden beds and pathways.', 'Union Community Garden', '2026-05-02'),
    (1, 'Accessible Ramp Installation', 'Install wheelchair ramps at local homes.', 'Central Family Center', '2026-05-09'),
    (1, 'School Pavilion Restoration', 'Repair benches and paint a school pavilion.', 'Lincoln Elementary School', '2026-05-16'),
    (2, 'Community Garden Workday', 'Plant vegetables and maintain community garden beds.', 'GreenHarvest Farm', '2026-04-12'),
    (2, 'Urban Compost Workshop', 'Teach residents how to start home composting.', 'Westside Library', '2026-04-19'),
    (2, 'Fresh Produce Distribution', 'Sort and distribute produce to local families.', 'GreenHarvest Market', '2026-05-03'),
    (2, 'Youth Planting Class', 'Lead students through a seasonal planting activity.', 'Oak Street School Garden', '2026-05-10'),
    (2, 'Community Orchard Cleanup', 'Prune trees and restore neighborhood orchard beds.', 'Maple Community Orchard', '2026-05-17'),
    (3, 'Food Bank Volunteer Day', 'Sort donations and prepare grocery boxes.', 'UnityServe Food Bank', '2026-04-13'),
    (3, 'Neighborhood Tutoring Event', 'Tutor students in reading and mathematics.', 'UnityServe Learning Hall', '2026-04-20'),
    (3, 'Senior Wellness Check-in', 'Deliver wellness materials to local seniors.', 'Riverside Senior Center', '2026-05-04'),
    (3, 'Community Cleanup', 'Collect litter and clean public gathering spaces.', 'Memorial Town Square', '2026-05-11'),
    (3, 'Volunteer Health Fair', 'Help organizers set up a neighborhood health fair.', 'Central Wellness Center', '2026-05-18');

INSERT INTO project_categories (project_id, category_id) VALUES
    (1, 3), (1, 2),
    (2, 3),
    (3, 1), (3, 3),
    (4, 3),
    (5, 3), (5, 1),
    (6, 1),
    (7, 1), (7, 2),
    (8, 1), (8, 3),
    (9, 1), (9, 2),
    (10, 1),
    (11, 3),
    (12, 2), (12, 3),
    (13, 4),
    (14, 1), (14, 3),
    (15, 4), (15, 3);
