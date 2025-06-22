import os
import shutil
from pathlib import Path
from datetime import date

from fastapi import FastAPI, UploadFile, File, Request, HTTPException, Form, Depends, status
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from dotenv import load_dotenv
import psycopg
from typing import Dict, List, Optional
from starlette.middleware.sessions import SessionMiddleware

# ──────────────────────────────────────────────────────────────────────────────
# Configuración
# ──────────────────────────────────────────────────────────────────────────────
load_dotenv()

DB_OPTS = {
    "dbname":   os.getenv("POSTGRES_DB"),
    "user":     os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "host":     os.getenv("POSTGRES_HOST", "db"),
    "port":     os.getenv("POSTGRES_PORT", "5432"),
}

print(f"Conectando a la base de datos {DB_OPTS['dbname']} en {DB_OPTS['host']}:{DB_OPTS['port']}...")

UPLOAD_DIR = Path("/uploads")        # volumen compartido
UPLOAD_DIR.mkdir(exist_ok=True)

app = FastAPI(title="CSV Survey Uploader")
app.add_middleware(SessionMiddleware, secret_key="your-secret-key")
templates = Jinja2Templates(directory=str(Path(__file__).parent / "templates"))
app.mount("/static", StaticFiles(directory=str(Path(__file__).parent / "static")), name="static")


# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────
def call_stored_procedure(csv_path: str) -> str:
    """Llama a cargar_csv_respuestas y devuelve los mensajes del servidor."""
    notices = []

    def notice_receiver(notice):
        notices.append(str(notice.message_primary))

    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        conn.add_notice_handler(notice_receiver)
        with conn.cursor() as cur:
            cur.execute("CALL cargar_csv_respuestas(%s);", (csv_path,))
        conn.commit()
        if notices:
            return " | ".join(notices)
        return "Archivo procesado correctamente."
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=400, detail=str(e).splitlines()[-1])
    finally:
        if conn:
            conn.close()

def get_encuestado_by_id(id: int, nombre: str):
    """Busca un encuestado por ID y nombre."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                """
                SELECT e.*, g.nombre as genero_nombre 
                FROM Encuestado e
                JOIN Genero g ON e.genero_id = g.id
                WHERE e.id = %s AND e.nombre = %s
                """, 
                (id, nombre)
            )
            result = cur.fetchone()
        conn.commit()
        return result
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()

def get_open_surveys():
    """Obtiene las encuestas abiertas (estado_id = 2)."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                "SELECT * FROM Encuesta WHERE estado_id = 2"
            )
            result = cur.fetchall()
        conn.commit()
        return result
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()

def get_survey_with_questions(survey_id: int):
    """Obtiene una encuesta con sus preguntas y opciones de respuesta."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            # Obtener la encuesta
            cur.execute("SELECT * FROM Encuesta WHERE id = %s", (survey_id,))
            survey = cur.fetchone()
            if not survey:
                raise HTTPException(status_code=404, detail="Encuesta no encontrada")
            
            # Obtener las preguntas
            cur.execute("SELECT * FROM Pregunta WHERE encuesta_id = %s", (survey_id,))
            preguntas = cur.fetchall()
            
            # Obtener opciones de respuesta para cada pregunta
            opciones = {}
            for pregunta in preguntas:
                cur.execute("SELECT * FROM OpcionRespuesta WHERE pregunta_id = %s", (pregunta['id'],))
                opciones[pregunta['id']] = cur.fetchall()
        
        conn.commit()
        return survey, preguntas, opciones
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()

def submit_survey_responses(encuestado_id: int, encuesta_id: int, responses: Dict[int, int]):
    """
    Guarda las respuestas de una encuesta en la base de datos.
    
    Args:
        encuestado_id: ID del encuestado
        encuesta_id: ID de la encuesta
        responses: Diccionario con key=pregunta_id, value=opcion_id
    """
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor() as cur:
            # Verificar si el usuario ya respondió esta encuesta
            cur.execute(
                "SELECT id FROM EncuestaRespondida WHERE encuesta_id = %s AND encuestado_id = %s",
                (encuesta_id, encuestado_id)
            )
            if cur.fetchone():
                raise HTTPException(status_code=400, detail="Ya has respondido esta encuesta anteriormente")
            
            # Insertar EncuestaRespondida
            cur.execute(
                "INSERT INTO EncuestaRespondida (encuesta_id, encuestado_id) VALUES (%s, %s) RETURNING id",
                (encuesta_id, encuestado_id)
            )
            encuesta_respondida_id = cur.fetchone()[0]
            
            # Insertar cada respuesta seleccionada
            for pregunta_id, opcion_id in responses.items():
                cur.execute(
                    "INSERT INTO RespuestaSeleccionada (encuesta_respondida_id, pregunta_id, opcion_respuesta_id) VALUES (%s, %s, %s)",
                    (encuesta_respondida_id, pregunta_id, opcion_id)
                )
        
        conn.commit()
        return "Encuesta enviada correctamente"
    except HTTPException as e:
        if conn:
            conn.rollback()
        raise e
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=400, detail=f"Error al guardar respuestas: {str(e)}")
    finally:
        if conn:
            conn.close()

def create_encuestado(nombre: str, apellido: str, genero_id: int, correo: str, fecha_nacimiento: date, ocupacion: str):
    """Crea un nuevo encuestado en la base de datos."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO Encuestado (nombre, apellido, genero_id, correo, fecha_nacimiento, ocupacion) 
                VALUES (%s, %s, %s, %s, %s, %s) RETURNING id
                """,
                (nombre, apellido, genero_id, correo, fecha_nacimiento, ocupacion)
            )
            new_id = cur.fetchone()[0]
        
        conn.commit()
        return new_id
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        if "correo" in str(e) and "already exists" in str(e):
            raise HTTPException(status_code=400, detail="El correo electrónico ya está registrado")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()
            
def has_responded_to_survey(encuestado_id: int, encuesta_id: int) -> bool:
    """Verifica si un encuestado ya respondió una encuesta específica."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id FROM EncuestaRespondida WHERE encuesta_id = %s AND encuestado_id = %s",
                (encuesta_id, encuestado_id)
            )
            result = cur.fetchone()
        conn.commit()
        return result is not None
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()
            
def get_all_genders():
    """Obtiene todos los géneros disponibles."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute("SELECT * FROM Genero")
            result = cur.fetchall()
        conn.commit()
        return result
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()
            
def process_csv_responses():
    """Procesa las respuestas CSV cargadas llamando al procedimiento almacenado."""
    notices = []

    def notice_receiver(notice):
        notices.append(str(notice.message_primary))

    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        conn.add_notice_handler(notice_receiver)
        with conn.cursor() as cur:
            cur.execute("CALL procesar_csv_respuestas();")
        conn.commit()
        if notices:
            return " | ".join(notices)
        return "CSV procesado correctamente."
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=400, detail=str(e).splitlines()[-1])
    finally:
        if conn:
            conn.close()

def process_survey(survey_id: int):
    """Procesa una encuesta específica."""
    notices = []

    def notice_receiver(notice):
        notices.append(str(notice.message_primary))

    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        conn.add_notice_handler(notice_receiver)
        with conn.cursor() as cur:
            cur.execute("CALL procesar_encuesta(%s);", (survey_id,))
        conn.commit()
        if notices:
            return " | ".join(notices)
        return f"Encuesta {survey_id} procesada correctamente."
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=400, detail=str(e).splitlines()[-1])
    finally:
        if conn:
            conn.close()

def get_all_surveys():
    """Obtiene todas las encuestas para selección."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                "SELECT id, denominacion, estado_id FROM Encuesta"
            )
            result = cur.fetchall()
        conn.commit()
        return result
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            conn.close()
            


# ──────────────────────────────────────────────────────────────────────────────
# Middleware para verificar sesión
# ──────────────────────────────────────────────────────────────────────────────
def get_current_user(request: Request):
    user = request.session.get("user")
    if not user:
        raise HTTPException(
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            detail="No autenticado",
            headers={"Location": "/login"}
        )
    return user

# ──────────────────────────────────────────────────────────────────────────────
# Rutas
# ──────────────────────────────────────────────────────────────────────────────
@app.get("/", response_class=HTMLResponse)
def root():
    """Redirecciona a la página de login."""
    return RedirectResponse(url="/login", status_code=303)

@app.get("/upload-form", response_class=HTMLResponse)
def upload_form(request: Request, msg: str = None, process_result: str = None):
    """Formulario para subir un archivo CSV."""
    surveys = get_all_surveys()  # Obtener encuestas para el selector
    return templates.TemplateResponse("upload.html", {
        "request": request,
        "message": msg,
        "process_result": process_result,
        "surveys": surveys
    })

@app.post("/process-csv", response_class=HTMLResponse)
async def process_csv(request: Request):
    """Procesa el CSV cargado previamente."""
    try:
        result_msg = process_csv_responses()
        return RedirectResponse(url=f"/upload-form?process_result={result_msg}", status_code=303)
    except HTTPException as e:
        return RedirectResponse(url=f"/upload-form?process_result=Error: {e.detail}", status_code=303)

@app.post("/process-survey", response_class=HTMLResponse)
async def process_survey_endpoint(request: Request, survey_id: int = Form(...)):
    """Endpoint para procesar una encuesta específica."""
    try:
        result_msg = process_survey(survey_id)
        return RedirectResponse(url=f"/surveys?message={result_msg}", status_code=303)
    except HTTPException as e:
        return RedirectResponse(url=f"/surveys?message=Error: {e.detail}", status_code=303)

@app.get("/surveys", response_class=HTMLResponse)
def surveys_list(request: Request, user: dict = Depends(get_current_user), message: str = None):
    """Lista las encuestas disponibles."""
    surveys = get_open_surveys()
    all_surveys = get_all_surveys()  # Para el selector de procesamiento
    
    # Verificar cuáles encuestas ya fueron respondidas por el usuario
    for survey in surveys:
        survey["ya_respondida"] = has_responded_to_survey(user["id"], survey["id"])
    
    return templates.TemplateResponse(
        "surveys.html", 
        {
            "request": request, 
            "surveys": surveys, 
            "all_surveys": all_surveys,
            "encuestado": user,
            "message": message
        }
    )

@app.post("/upload", response_class=HTMLResponse)
async def upload(request: Request, file: UploadFile = File(...)):
    # 1) Guardar el CSV en /uploads
    target_path = UPLOAD_DIR / file.filename
    with target_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 2) Llamar al procedimiento
    result_msg = call_stored_procedure(str(target_path))

    # 3) Redirigir con mensaje
    return RedirectResponse(url=f"/upload-form?msg={result_msg}", status_code=303)

@app.get("/status", response_class=HTMLResponse)
def status(request: Request):
    """Chequeo de salud sencillo."""
    conn = None
    try:
        conn = psycopg.connect(**DB_OPTS)
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
        conn.commit()
        ok = True
    except psycopg.Error as e:
        if conn:
            conn.rollback()
        ok = False
    finally:
        if conn:
            conn.close()
    
    return templates.TemplateResponse("result.html",
                                     {"request": request,
                                     "message": "✅ DB OK" if ok else "❌ DB DOWN"})

# ──────────────────────────────────────────────────────────────────────────────
# Nuevas rutas para encuestados
# ──────────────────────────────────────────────────────────────────────────────
@app.get("/login", response_class=HTMLResponse)
def login_form(request: Request, message: str = None):
    """Formulario de inicio de sesión."""
    return templates.TemplateResponse("login.html", {"request": request, "message": message})

@app.post("/login")
async def login(request: Request, id: int = Form(...), nombre: str = Form(...)):
    """Procesa el inicio de sesión."""
    encuestado = get_encuestado_by_id(id, nombre)
    if not encuestado:
        return templates.TemplateResponse(
            "login.html", 
            {"request": request, "message": "ID o nombre incorrectos"}
        )
    
    # Convertir fechas a string para la sesión
    for k, v in encuestado.items():
        if isinstance(v, date):
            encuestado[k] = v.isoformat()
    
    # Guardar información de usuario en sesión
    request.session["user"] = encuestado
    
    # Redirigir a la lista de encuestas
    return RedirectResponse(url="/surveys", status_code=303)

@app.get("/register", response_class=HTMLResponse)
def register_form(request: Request, message: str = None):
    """Formulario de registro."""
    generos = get_all_genders()
    return templates.TemplateResponse("register.html", {
        "request": request, 
        "message": message, 
        "generos": generos
    })

@app.post("/register")
async def register(
    request: Request,
    nombre: str = Form(...),
    apellido: str = Form(...),
    genero_id: int = Form(...),
    correo: str = Form(...),
    fecha_nacimiento: date = Form(...),
    ocupacion: str = Form(...)
):
    """Procesa el registro de un nuevo encuestado."""
    try:
        # Crear nuevo encuestado
        encuestado_id = create_encuestado(nombre, apellido, genero_id, correo, fecha_nacimiento, ocupacion)
        
        # Obtener el encuestado completo
        encuestado = get_encuestado_by_id(encuestado_id, nombre)
        
        # Convertir fechas a string para la sesión
        for k, v in encuestado.items():
            if isinstance(v, date):
                encuestado[k] = v.isoformat()
        
        # Guardar en sesión
        request.session["user"] = encuestado
        
        # Redirigir a la lista de encuestas
        return RedirectResponse(url="/surveys", status_code=303)
    except HTTPException as e:
        generos = get_all_genders()
        return templates.TemplateResponse(
            "register.html", 
            {"request": request, "message": e.detail, "generos": generos}
        )

@app.post("/logout")
async def logout(request: Request):
    """Cierra la sesión del usuario."""
    request.session.pop("user", None)
    return RedirectResponse(url="/login", status_code=303)

@app.get("/surveys", response_class=HTMLResponse)
def surveys_list(request: Request, user: dict = Depends(get_current_user)):
    """Lista las encuestas disponibles."""
    surveys = get_open_surveys()
    
    # Verificar cuáles encuestas ya fueron respondidas por el usuario
    for survey in surveys:
        survey["ya_respondida"] = has_responded_to_survey(user["id"], survey["id"])
    
    return templates.TemplateResponse(
        "surveys.html", 
        {"request": request, "surveys": surveys, "encuestado": user}
    )

@app.get("/survey/{survey_id}", response_class=HTMLResponse)
def take_survey(survey_id: int, request: Request, user: dict = Depends(get_current_user)):
    """Muestra una encuesta para ser respondida."""
    # Verificar si ya respondió esta encuesta
    if has_responded_to_survey(user["id"], survey_id):
        return templates.TemplateResponse(
            "result.html",
            {"request": request, "message": "Ya has respondido esta encuesta anteriormente"}
        )
    
    survey, preguntas, opciones = get_survey_with_questions(survey_id)
    
    return templates.TemplateResponse(
        "take_survey.html", 
        {
            "request": request,
            "survey": survey,
            "preguntas": preguntas,
            "opciones": opciones,
            "encuestado": user
        }
    )

@app.post("/submit-survey")
async def submit_survey(request: Request, user: dict = Depends(get_current_user)):
    """Procesa el envío de respuestas a una encuesta."""
    form_data = await request.form()
    
    encuesta_id = int(form_data["encuesta_id"])
    
    # Procesar respuestas (formato: pregunta_X donde X es el ID de pregunta)
    responses = {}
    for key, value in form_data.items():
        if key.startswith("pregunta_"):
            pregunta_id = int(key.split("_")[1])
            respuesta_id = int(value)
            responses[pregunta_id] = respuesta_id
    
    try:
        message = submit_survey_responses(user["id"], encuesta_id, responses)
        return templates.TemplateResponse(
            "result.html",
            {"request": request, "message": message}
        )
    except HTTPException as e:
        survey, preguntas, opciones = get_survey_with_questions(encuesta_id)
        return templates.TemplateResponse(
            "take_survey.html",
            {
                "request": request,
                "survey": survey,
                "preguntas": preguntas,
                "opciones": opciones,
                "encuestado": user,
                "message": e.detail
            }
        )