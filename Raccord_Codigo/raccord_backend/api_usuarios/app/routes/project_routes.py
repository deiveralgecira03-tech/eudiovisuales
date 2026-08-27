from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.project_controller import (
    get_projects,
    get_project,
    create_project,
    update_project_full,
    update_project,
    delete_project,
    get_projects_by_client,
    create_project_and_link
)
from app.schemas.project_schema import ProjectSchema, ProjectUpdateSchema, ProjectCreateSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/projects")
def projects(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_projects(db)

# CREATE PROJECT AND LINK USER
# Solo Administrador (1001) crea proyectos. Director (1002) tiene el
# mismo nivel de acceso que Administrador excepto crear proyectos:
# solo puede elegir entre los ya existentes.

@router.post("/projects/create")
def store_and_link(data: ProjectCreateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_project"))):
    project = ProjectSchema(
        project_name=data.project_name,
        formato_de_produccion=data.formato_de_produccion,
        genero=data.genero,
        sinopsis=data.sinopsis,
        director=data.director,
        id_client=data.id_client
    )
    return create_project_and_link(project, data.id_user, db)

# GET PROJECTS BY CLIENT

@router.get("/projects/client/{id_client}")
def projects_by_client(id_client: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_projects_by_client(id_client, db)

@router.get("/projects/{id}")
def project(id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_project(id, db)

@router.post("/projects")
def store_project(project: ProjectSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_project"))):
    return create_project(project, db)

@router.put("/projects/{id}")
def edit_project(id: str, project: ProjectSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("manage_projects"))):
    return update_project_full(id, project, db)

@router.patch("/projects/{id}")
def patch_project(id: str, project: ProjectUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("manage_projects"))):
    return update_project(id, project, db)

@router.delete("/projects/{id}")
def destroy_project(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("manage_projects"))):
    return delete_project(id, db)
