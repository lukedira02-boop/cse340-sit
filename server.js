import "dotenv/config";
import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const port = process.env.PORT || 3000;
const currentDir = path.dirname(fileURLToPath(import.meta.url));

app.set("view engine", "ejs");
app.set("views", path.join(currentDir, "views"));
app.use(express.static(path.join(currentDir, "public")));

const renderPage = (viewName, pageTitle) => async (request, response) => {
  response.render(viewName, { title: pageTitle });
};

app.get("/", renderPage("home", "Home"));
app.get("/organizations", renderPage("organizations", "Organizations"));
app.get("/projects", renderPage("projects", "Service Projects"));
app.get("/categories", renderPage("categories", "Service Project Categories"));

app.listen(port);
