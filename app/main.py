import os
import shutil
from pathlib import Path

from fastapi import FastAPI, UploadFile, File, Request, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from dotenv import load_dotenv
import psycopg

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
templates = Jinja2Templates(directory=str(Path(__file__).parent / "templates"))

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────
def call_stored_procedure(csv_path: str) -> str:
    """Llama a cargar_csv_respuestas y devuelve los mensajes del servidor."""
    notices = []

    def notice_receiver(notice):
        notices.append(str(notice.message_primary))

    try:
        with psycopg.connect(**DB_OPTS) as conn:
            conn.add_notice_handler(notice_receiver)  # <-- Aquí se asigna el handler
            with conn.cursor() as cur:
                cur.execute("CALL cargar_csv_respuestas(%s);", (csv_path,))
        if notices:
            return " | ".join(notices)
        return "Archivo procesado correctamente."
    except psycopg.Error as e:
        raise HTTPException(status_code=400, detail=str(e).splitlines()[-1])

# ──────────────────────────────────────────────────────────────────────────────
# Rutas
# ──────────────────────────────────────────────────────────────────────────────
@app.get("/", response_class=HTMLResponse)
def form(request: Request, msg: str | None = None):
    """Formulario de carga."""
    return templates.TemplateResponse("upload.html",
                                      {"request": request, "message": msg})

@app.post("/upload", response_class=HTMLResponse)
async def upload(request: Request, file: UploadFile = File(...)):
    # 1) Guardar el CSV en /uploads
    target_path = UPLOAD_DIR / file.filename
    with target_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 2) Llamar al procedimiento
    result_msg = call_stored_procedure(str(target_path))

    # 3) Redirigir con mensaje
    url = str(request.url_for("form")) + f"?msg={result_msg}"
    return RedirectResponse(url=url, status_code=303)

@app.get("/status", response_class=HTMLResponse)
def status(request: Request):
    """Chequeo de salud sencillo."""
    try:
        with psycopg.connect(**DB_OPTS) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
        ok = True
    except psycopg.Error as e:
        ok = False
    return templates.TemplateResponse("result.html",
                                      {"request": request,
                                       "message": "✅ DB OK" if ok else "❌ DB DOWN"})
