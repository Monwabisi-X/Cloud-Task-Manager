from flask import Blueprint, jsonify, redirect, render_template, request, url_for
from app import db
from app.models import Task

main = Blueprint("main", __name__)

@main.get("/")
def index():
    tasks = Task.query.order_by(Task.id.desc()).all()
    return render_template("index.html", tasks=tasks)

@main.get("/health")
def health():
    return jsonify({"status": "healthy"})

@main.get("/api/tasks")
def list_tasks():
    return jsonify([task.to_dict() for task in Task.query.order_by(Task.id.desc()).all()])

@main.post("/api/tasks")
def create_task():
    data = request.get_json(silent=True) or {}
    title = str(data.get("title", "")).strip()

    if not title:
        return jsonify({"error": "title is required"}), 400

    task = Task(
        title=title,
        description=str(data.get("description", "")).strip(),
        status=str(data.get("status", "pending")).strip() or "pending",
    )
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

@main.put("/api/tasks/<int:task_id>")
def update_task(task_id):
    task = db.get_or_404(Task, task_id)
    data = request.get_json(silent=True) or {}

    if "title" in data:
        title = str(data["title"]).strip()
        if not title:
            return jsonify({"error": "title cannot be empty"}), 400
        task.title = title

    if "description" in data:
        task.description = str(data["description"]).strip()

    if "status" in data:
        task.status = str(data["status"]).strip() or task.status

    db.session.commit()
    return jsonify(task.to_dict())

@main.delete("/api/tasks/<int:task_id>")
def delete_task(task_id):
    task = db.get_or_404(Task, task_id)
    db.session.delete(task)
    db.session.commit()
    return jsonify({"message": "task deleted"})

@main.post("/tasks")
def create_task_from_form():
    title = request.form.get("title", "").strip()
    description = request.form.get("description", "").strip()

    if title:
        db.session.add(Task(title=title, description=description))
        db.session.commit()

    return redirect(url_for("main.index"))
