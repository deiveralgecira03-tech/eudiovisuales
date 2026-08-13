import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.routes.login_routes import router as login_router
from app.routes.register_routes import router as register_router
from app.routes.password_routes import router as password_router
from app.routes.user_routes import router as user_router
from app.routes.client_routes import router as client_router
from app.routes.project_routes import router as project_router
from app.routes.role_routes import router as role_router
from app.routes.department_routes import router as department_router
from app.routes.script_routes import router as script_router
from app.routes.scene_routes import router as scene_router
from app.routes.breakdown_routes import router as breakdown_router
from app.routes.shooting_day_routes import router as shooting_day_router
from app.routes.breakdown_sheet_routes import router as breakdown_sheet_router
from app.routes.contact_routes import router as contact_router

from app.config.database import Base, engine
from app.models.user_project_model import UserProject
from app.models.department_model import Department
from app.models.script_model import Script
from app.models.scene_model import Scene
from app.models.breakdown_model import DesgloseItem, DesgloseItemDetalle
from app.models.shooting_day_model import ShootingDay
from app.models.breakdown_sheet_model import BreakdownSheet
from app.utils.response import api_response

logger = logging.getLogger("raccord")

# CREATE TABLES
Base.metadata.create_all(bind=engine)

# FASTAPI

app = FastAPI(
    title="API´S RACCORD",
    version="1.0"
)


# CORS -  esto habilita a que react pueda hacer peticiones a traves de las apis dispuesta en el backend

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ROUTES

# Auth (login, register, recuperación de contraseña) - entrada pública
app.include_router(login_router)
app.include_router(register_router)
app.include_router(password_router)

# Recursos protegidos por JWT
app.include_router(user_router)
app.include_router(client_router)
app.include_router(project_router)
app.include_router(role_router)
app.include_router(department_router)
app.include_router(script_router)
app.include_router(scene_router)
app.include_router(breakdown_router)
app.include_router(shooting_day_router)
app.include_router(breakdown_sheet_router)

# Landing / contacto - público
app.include_router(contact_router)


# ==========================================
# MANEJO GLOBAL DE ERRORES NO CONTROLADOS
# ==========================================
# Sin esto, cualquier excepción no capturada (ej. un dato corrupto en la
# BD, un error de hashing, etc.) devuelve un 500 vacío/sin CORS bien
# formado, y el frontend lo interpreta como "no se pudo conectar con el
# servidor" en vez de mostrar un mensaje claro. Aquí siempre respondemos
# JSON con el mismo formato api_response que usa el resto de la API.
@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    logger.exception("Error no controlado en %s %s", request.method, request.url.path)

    return JSONResponse(
        status_code=500,
        content=api_response(
            False,
            "Ocurrió un error inesperado en el servidor",
            error="INTERNAL_SERVER_ERROR"
        )
    )


# HOME

@app.get("/")
def home():
    return {
        "success": True,
        "message": "API funcionando correctamente"
    }
