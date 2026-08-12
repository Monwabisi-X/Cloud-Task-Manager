# Cloud Task Manager — Week 1

A small CRUD web application built with Flask and PostgreSQL and packaged with Docker.

This is the application/containerization stage of the four-week cloud engineering project. The application is intentionally simple so that the cloud architecture in Weeks 2–4 remains the focus.

## Technology stack

- Python 3.12
- Flask
- Flask-SQLAlchemy
- PostgreSQL 16
- Docker
- Docker Compose
- Gunicorn
- pytest

## Application features

- Create tasks
- Read/list tasks
- Update tasks through the REST API
- Delete tasks through the REST API
- Basic browser UI
- `/health` health-check endpoint
- Automated tests

## Project structure

```text
cloud-task-manager/
├── app/
│   ├── __init__.py
│   ├── models.py
│   └── routes.py
├── static/
│   └── style.css
├── templates/
│   └── index.html
├── tests/
│   ├── conftest.py
│   └── test_app.py
├── .dockerignore
├── .env.example
├── .gitignore
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── run.py
```

## Prerequisites

Install:

1. Git
2. Python 3.12+
3. Docker Desktop
4. A Docker Hub account
5. A GitHub account

Docker Desktop is the easiest option on Windows because it provides Docker Engine and Docker Compose.

## Option A — Run locally with Docker (recommended)

From the project directory:

```bash
docker compose up --build
```

Open:

```text
http://localhost:5000
```

The first build downloads the Python and PostgreSQL images, so it can take a few minutes.

Stop the application with:

```bash
docker compose down
```

To stop it and delete the PostgreSQL data volume:

```bash
docker compose down -v
```

Use `-v` only when you intentionally want to reset the database.

## Option B — Run the Flask app directly

This is useful for understanding the application before containerization.

Create a virtual environment:

Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

Linux/macOS:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

You still need a PostgreSQL database and a `DATABASE_URL` environment variable.

Example:

```text
postgresql+psycopg://postgres:postgres@localhost:5432/cloudapp
```

Then:

```bash
python run.py
```

## Run tests

The tests use an in-memory SQLite database so that testing does not require PostgreSQL.

```bash
pytest
```

All five tests should pass.

## API examples

List tasks:

```bash
curl http://localhost:5000/api/tasks
```

Create a task:

```bash
curl -X POST http://localhost:5000/api/tasks ^
  -H "Content-Type: application/json" ^
  -d "{"title":"Learn AWS","description":"Study VPCs and EC2"}"
```

On Linux/macOS:

```bash
curl -X POST http://localhost:5000/api/tasks   -H "Content-Type: application/json"   -d '{"title":"Learn AWS","description":"Study VPCs and EC2"}'
```

Update:

```bash
curl -X PUT http://localhost:5000/api/tasks/1   -H "Content-Type: application/json"   -d '{"status":"done"}'
```

Delete:

```bash
curl -X DELETE http://localhost:5000/api/tasks/1
```

Health check:

```bash
curl http://localhost:5000/health
```

## Docker image

Build the image manually:

```bash
docker build -t cloud-task-manager:1.0 .
```

Run it manually:

```bash
docker run --rm -p 5000:5000 cloud-task-manager:1.0
```

The manual `docker run` command expects a PostgreSQL database to be reachable at the configured `DATABASE_URL`. For the complete local environment, prefer Docker Compose.

## Push to Docker Hub

This cannot be automated from this starter because it requires your Docker Hub credentials.

1. Create a repository on Docker Hub, for example:
   `YOUR_DOCKERHUB_USERNAME/cloud-task-manager`
2. Log in:

```bash
docker login
```

3. Build the image:

```bash
docker build -t YOUR_DOCKERHUB_USERNAME/cloud-task-manager:1.0 .
```

4. Also tag it as `latest`:

```bash
docker tag YOUR_DOCKERHUB_USERNAME/cloud-task-manager:1.0 YOUR_DOCKERHUB_USERNAME/cloud-task-manager:latest
```

5. Push both tags:

```bash
docker push YOUR_DOCKERHUB_USERNAME/cloud-task-manager:1.0
docker push YOUR_DOCKERHUB_USERNAME/cloud-task-manager:latest
```

6. Verify the images appear in Docker Hub.

For Week 3, GitHub Actions will perform this build and push automatically.

## Push to GitHub

Create a new empty GitHub repository.

Then from this project directory:

```bash
git init
git add .
git commit -m "Complete Week 1 Flask CRUD application"
git branch -M main
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

Do not commit passwords, API keys, AWS credentials, or `.env` files. The `.gitignore` is already configured to exclude `.env`.

## What is intentionally not completed automatically

The following require accounts, credentials, or your personal cloud repositories and therefore must be completed by you:

- Creating your GitHub repository
- Pushing the project to GitHub
- Creating your Docker Hub repository
- Authenticating with Docker Hub
- Pushing the image to Docker Hub
- Capturing screenshots of your own running application
- Writing your personal Week 1 reflection/challenges

These steps are documented above so you can complete them safely.

## Why this design?

The application uses Flask because it is lightweight and easy to understand for a cloud-focused project.

PostgreSQL is used because it is the database engine required by the overall project and will later map naturally to Amazon RDS PostgreSQL.

Docker packages the application and its Python dependencies into a repeatable deployment unit. The same image can later be pulled by EC2 instances.

Docker Compose is used locally to run two services:

- `web`: Flask/Gunicorn application
- `db`: PostgreSQL

Gunicorn is used instead of Flask's development server because the application will eventually run as a production-style container behind an AWS Application Load Balancer.

The `/health` endpoint is deliberately included because the Application Load Balancer will eventually need a reliable endpoint for health checks.

The application is stateless: task data lives in PostgreSQL rather than inside the container. This is important because Week 4 will introduce Auto Scaling, where multiple EC2 instances may run the same application simultaneously.

## Week 1 completion checklist

- [ ] Project files downloaded/extracted
- [ ] Docker Desktop installed
- [ ] `docker compose up --build` works
- [ ] Browser application loads
- [ ] Create task works
- [ ] API endpoints work
- [ ] `pytest` passes
- [ ] Docker image builds
- [ ] Docker Hub repository created
- [ ] Image pushed to Docker Hub
- [ ] GitHub repository created
- [ ] Code pushed to GitHub
- [ ] README reviewed
- [ ] Screenshots captured for evidence

## Important Week 2 note

Do not redesign the application when starting Terraform.

The intended Week 2 flow is:

```text
Internet
   |
   v
Application Load Balancer
   |
   v
EC2 instances running this Docker image
   |
   v
Amazon RDS PostgreSQL
```

The two public and two private subnets, routing, security groups, NAT gateway, ALB, launch template and Auto Scaling Group will be created in Terraform in Week 2.
