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

app.get("/", renderPage("home", "Home"));
app.get("/organizations", async (request, response, next) => {
  try {
    const organizations = await getAllOrganizations();
    response.render("organizations", { title: "Organizations", organizations });
  } catch (error) {
    console.error("Unable to load organizations from the database:", error.message);
    next(error);
  }
});
app.get("/projects", async (request, response, next) => {
  try {
    const projects = await getAllProjects();
    response.render("projects", { title: "Service Projects", projects });
  } catch (error) {
    console.error("Unable to load projects from the database:", error.message);
    next(error);
  }
});
app.get("/categories", async (request, response, next) => {
  try {
    const categories = await getAllCategories();
    response.render("categories", { title: "Service Project Categories", categories });
  } catch (error) {
    console.error("Unable to load categories from the database:", error.message);
    next(error);
  }
});

app.use((request, response) => {
  response.status(404).render("404", { title: "Page Not Found" });
});

app.use((error, request, response, next) => {
  console.error("Unexpected server error:", error);
  response.status(500).send("An unexpected server error occurred.");
});

app.listen(port, () => {
  console.log(`Community Connections is running at http://localhost:${port}`);
});
