CREATE TABLE IF NOT EXISTS organization (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    logo_filename VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS project (
    project_id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organization(organization_id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    schedule DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS project_categories (
    project_id INTEGER NOT NULL REFERENCES project(project_id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, category_id)
);

INSERT INTO organization (name, description, contact_email, logo_filename)
SELECT sample.name, sample.description, sample.contact_email, sample.logo_filename
FROM (VALUES
    ('BrightFuture Builders', 'A nonprofit focused on improving community infrastructure through sustainable construction projects.', 'info@brightfuturebuilders.org', 'green-city.jpg'),
    ('GreenHarvest Growers', 'An urban farming collective promoting food sustainability and education in local neighborhoods.', 'contact@greenharvest.org', 'food-bank.jpg'),
    ('UnityServe Volunteers', 'A volunteer coordination group supporting local charities and service initiatives.', 'hello@unityserve.org', 'youth-center.webp')
) AS sample(name, description, contact_email, logo_filename)
WHERE NOT EXISTS (
    SELECT 1 FROM organization existing WHERE existing.name = sample.name
);

INSERT INTO categories (name) VALUES
    ('Environmental'),
    ('Educational'),
    ('Community Service'),
    ('Health and Wellness')
ON CONFLICT (name) DO NOTHING;

INSERT INTO project (organization_id, name, description, location, schedule)
SELECT organization.organization_id, sample.name, sample.description, sample.location, sample.schedule::date
FROM (VALUES
    ('BrightFuture Builders', 'Community Playground Build', 'Build and paint a safe neighborhood playground.', 'Riverside Community Park', '2026-04-11'),
    ('BrightFuture Builders', 'Neighborhood Housing Repair', 'Complete minor repairs for residents in need.', 'Eastview Homes', '2026-04-18'),
    ('BrightFuture Builders', 'Community Garden Construction', 'Construct raised garden beds and pathways.', 'Union Community Garden', '2026-05-02'),
    ('BrightFuture Builders', 'Accessible Ramp Installation', 'Install wheelchair ramps at local homes.', 'Central Family Center', '2026-05-09'),
    ('BrightFuture Builders', 'School Pavilion Restoration', 'Repair benches and paint a school pavilion.', 'Lincoln Elementary School', '2026-05-16'),
    ('GreenHarvest Growers', 'Community Garden Workday', 'Plant vegetables and maintain community garden beds.', 'GreenHarvest Farm', '2026-04-12'),
    ('GreenHarvest Growers', 'Urban Compost Workshop', 'Teach residents how to start home composting.', 'Westside Library', '2026-04-19'),
    ('GreenHarvest Growers', 'Fresh Produce Distribution', 'Sort and distribute produce to local families.', 'GreenHarvest Market', '2026-05-03'),
    ('GreenHarvest Growers', 'Youth Planting Class', 'Lead students through a seasonal planting activity.', 'Oak Street School Garden', '2026-05-10'),
    ('GreenHarvest Growers', 'Community Orchard Cleanup', 'Prune trees and restore neighborhood orchard beds.', 'Maple Community Orchard', '2026-05-17'),
    ('UnityServe Volunteers', 'Food Bank Volunteer Day', 'Sort donations and prepare grocery boxes.', 'UnityServe Food Bank', '2026-04-13'),
    ('UnityServe Volunteers', 'Neighborhood Tutoring Event', 'Tutor students in reading and mathematics.', 'UnityServe Learning Hall', '2026-04-20'),
    ('UnityServe Volunteers', 'Senior Wellness Check-in', 'Deliver wellness materials to local seniors.', 'Riverside Senior Center', '2026-05-04'),
    ('UnityServe Volunteers', 'Community Cleanup', 'Collect litter and clean public gathering spaces.', 'Memorial Town Square', '2026-05-11'),
    ('UnityServe Volunteers', 'Volunteer Health Fair', 'Help organizers set up a neighborhood health fair.', 'Central Wellness Center', '2026-05-18')
) AS sample(organization_name, name, description, location, schedule)
JOIN organization ON organization.name = sample.organization_name
WHERE NOT EXISTS (
    SELECT 1
    FROM project existing
    WHERE existing.organization_id = organization.organization_id
      AND existing.name = sample.name
);

INSERT INTO project_categories (project_id, category_id)
SELECT project.project_id, categories.category_id
FROM (VALUES
    ('Community Playground Build', 'Community Service'), ('Community Playground Build', 'Educational'),
    ('Neighborhood Housing Repair', 'Community Service'),
    ('Community Garden Construction', 'Environmental'), ('Community Garden Construction', 'Community Service'),
    ('Accessible Ramp Installation', 'Community Service'),
    ('School Pavilion Restoration', 'Community Service'), ('School Pavilion Restoration', 'Environmental'),
    ('Community Garden Workday', 'Environmental'),
    ('Urban Compost Workshop', 'Environmental'), ('Urban Compost Workshop', 'Educational'),
    ('Fresh Produce Distribution', 'Environmental'), ('Fresh Produce Distribution', 'Community Service'),
    ('Youth Planting Class', 'Environmental'), ('Youth Planting Class', 'Educational'),
    ('Community Orchard Cleanup', 'Environmental'),
    ('Food Bank Volunteer Day', 'Community Service'),
    ('Neighborhood Tutoring Event', 'Educational'), ('Neighborhood Tutoring Event', 'Community Service'),
    ('Senior Wellness Check-in', 'Health and Wellness'),
    ('Community Cleanup', 'Environmental'), ('Community Cleanup', 'Community Service'),
    ('Volunteer Health Fair', 'Health and Wellness'), ('Volunteer Health Fair', 'Community Service')
) AS sample(project_name, category_name)
JOIN project ON project.name = sample.project_name
JOIN categories ON categories.name = sample.category_name
WHERE NOT EXISTS (
    SELECT 1
    FROM project_categories existing
    WHERE existing.project_id = project.project_id
      AND existing.category_id = categories.category_id
);

DO $$
BEGIN
    IF (SELECT COUNT(*) FROM project) < 15 THEN
        RAISE EXCEPTION 'At least 15 projects are required';
    END IF;

    IF EXISTS (
        SELECT organization.organization_id
        FROM organization
        LEFT JOIN project ON project.organization_id = organization.organization_id
        GROUP BY organization.organization_id
        HAVING COUNT(project.project_id) < 5
    ) THEN
        RAISE EXCEPTION 'Each organization must have at least 5 projects';
    END IF;

    IF EXISTS (
        SELECT p.project_id
        FROM project p
        LEFT JOIN project_categories pc ON pc.project_id = p.project_id
        WHERE pc.project_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Every project must be assigned to at least one category';
    END IF;
END
$$;
