import 'dotenv/config';
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import { getAllOrganizations } from './src/models/organizations.js';
import { getAllProjects } from './src/models/projects.js';
import { getAllCategories } from './src/models/categories.js';

// ESM does not provide __dirname, so build it from import.meta.url
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const port = process.env.PORT || 3000;
const app = express();

// Serve everything in /public (css, images) as static files
app.use(express.static(path.join(__dirname, 'public')));

// Configure EJS as the template engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'src', 'views'));

// Routes
app.get('/', async (req, res) => {
    const title = 'Home';
    res.render('home', { title });
});

app.get('/organizations', async (req, res, next) => {
    const title = 'Partner Organizations';
    try {
        const organizations = await getAllOrganizations();
        res.render('organizations', { title, organizations });
    } catch (error) {
        next(error);
    }
});

app.get('/projects', async (req, res, next) => {
    const title = 'Service Projects';
    try {
        const projects = await getAllProjects();
        res.render('projects', { title, projects });
    } catch (error) {
        next(error);
    }
});

app.get('/categories', async (req, res, next) => {
    const title = 'Service Project Categories';
    try {
        const categories = await getAllCategories();
        res.render('categories', { title, categories });
    } catch (error) {
        next(error);
    }
});

app.use((error, req, res, next) => {
    console.error('Database request failed:', error);
    res.status(500).send('Database error: unable to load the requested data.');
});

app.listen(port, () => {
    console.log(`Server is running on http://127.0.0.1:${port}`);
});
