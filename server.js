import "dotenv/config";
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { getAllOrganizations } from "./src/models/organizations.js";
import { getAllProjects } from "./src/models/projects.js";
import { getAllCategories } from "./src/models/categories.js";

const app = express();
const port = process.env.PORT || 3000;
const currentDir = path.dirname(fileURLToPath(import.meta.url));

app.set("view engine", "ejs");
app.set("views", path.join(currentDir, "src", "views"));
app.use(express.static(path.join(currentDir, "public")));

const renderPage = (viewName, pageTitle) => async (request, response) => {
  response.render(viewName, { title: pageTitle });
};

const fallbackOrganizations = [
  {
    name: "Community Food Pantry",
    description: "Fights food insecurity by collecting, sorting, and distributing groceries to local families.",
    imagePath: "/images/food-bank.jpg",
    category: "Community Service"
  },
  {
    name: "Green City Alliance",
    description: "Improves neighborhoods through cleanups, conservation projects, and community education.",
    imagePath: "/images/green-city.jpg",
    category: "Environmental"
  },
  {
    name: "Bright Futures Youth Center",
    description: "Supports students with tutoring, mentoring, and after-school enrichment activities.",
    imagePath: "/images/youth-center.webp",
    category: "Educational"
  }
];

const fallbackProjects = [
  { name: "Riverside Cleanup", description: "Help remove litter and restore a shared community trail.", schedule: "Saturday, 9:00 AM", organizationName: "Green City Alliance" },
  { name: "Homework Buddies", description: "Volunteer as a tutor and encourage young learners.", schedule: "Wednesday, 4:00 PM", organizationName: "Bright Futures Youth Center" },
  { name: "Community Meal", description: "Prepare and serve a welcoming meal for local neighbors.", schedule: "Sunday, 10:00 AM", organizationName: "Community Food Pantry" }
];

const fallbackCategories = [
  { name: "Environmental" },
  { name: "Educational" },
  { name: "Community Service" },
  { name: "Health and Wellness" }
];

app.get("/", renderPage("home", "Home"));
app.get("/organizations", async (request, response, next) => {
  try {
    const organizations = await getAllOrganizations();
    response.render("organizations", { title: "Organizations", organizations });
  } catch (error) {
    console.error("Unable to load organizations from the database:", error.message);
    response.render("organizations", { title: "Organizations", organizations: fallbackOrganizations });
  }
});
app.get("/projects", async (request, response, next) => {
  try {
    const projects = await getAllProjects();
    response.render("projects", { title: "Service Projects", projects });
  } catch (error) {
    console.error("Unable to load projects from the database:", error.message);
    response.render("projects", { title: "Service Projects", projects: fallbackProjects });
  }
});
app.get("/categories", async (request, response, next) => {
  try {
    const categories = await getAllCategories();
    response.render("categories", { title: "Service Project Categories", categories });
  } catch (error) {
    console.error("Unable to load categories from the database:", error.message);
    response.render("categories", { title: "Service Project Categories", categories: fallbackCategories });
  }
});

app.listen(port);
