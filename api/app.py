from fastapi import FastAPI, UploadFile, File, Request, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import asyncpg
import os
import asyncio
import csv
from io import TextIOWrapper
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

UPLOADS_DIR = "/docker-entrypoint-initdb.d/uploads"

app = FastAPI()
templates = Jinja2Templates(directory="templates")

DB_USER = os.getenv("POSTGRES_USER", "usuario")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "contraseña")
DB_NAME = os.getenv("POSTGRES_DB", "encuesta_db")
DB_HOST = os.getenv("POSTGRES_HOST", "db")
DB_PORT = int(os.getenv("POSTGRES_PORT", "5432"))

def wait_for_db(max_attempts=20, delay=2):
    import psycopg2
    for attempt in range(max_attempts):
        try:
            logger.info(f"Intentando conectar a la base de datos (intento {attempt + 1}/{max_attempts})...")
            conn = psycopg2.connect(
                dbname=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD,
                host=DB_HOST,
                port=DB_PORT,
            )
            conn.close()
            logger.info("Conexión exitosa a la base de datos.")
            return
        except Exception as e:
            logger.warning(f"No se pudo conectar a la base de datos: {e}")
            time.sleep(delay)
    logger.error("No se pudo conectar a la base de datos después de varios intentos.")
    raise Exception("No se pudo conectar a la base de datos después de varios intentos.")

@app.on_event("startup")
async def startup():
    logger.info("Iniciando aplicación y esperando base de datos...")
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, wait_for_db)
    logger.info("Creando pool de conexiones a la base de datos...")
    app.state.db_pool = await asyncpg.create_pool(
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        host=DB_HOST,
        port=DB_PORT,
        min_size=1,
        max_size=5
    )
    logger.info("Pool de conexiones creado.")

@app.on_event("shutdown")
async def shutdown():
    logger.info("Cerrando pool de conexiones a la base de datos...")
    await app.state.db_pool.close()
    logger.info("Pool cerrado.")

@app.get("/", response_class=HTMLResponse)
async def form(request: Request):
    logger.info("Renderizando formulario de carga de CSV.")
    return templates.TemplateResponse("upload.html", {"request": request})

@app.post("/cargar_csv/")
async def cargar_csv(file: UploadFile = File(...)):
    logger.info(f"Recibiendo archivo: {file.filename}")
    if not file.filename.endswith(".csv"):
        logger.warning("El archivo recibido no es un CSV.")
        raise HTTPException(status_code=400, detail="El archivo debe ser un CSV")

    # Guardar el archivo en el volumen compartido
    os.makedirs(UPLOADS_DIR, exist_ok=True)
    dest_path = os.path.join(UPLOADS_DIR, file.filename)
    logger.info(f"Guardando archivo en: {dest_path}")
    with open(dest_path, "wb") as f:
        content = await file.read()
        f.write(content)

    try:
        async with app.state.db_pool.acquire() as conn:
            async with conn.transaction():
                logger.info("Truncando tabla csv_encuestas_temp...")
                await conn.execute("TRUNCATE TABLE csv_encuestas_temp")
                try:
                    logger.info("Cargando CSV en tabla csv_encuestas_temp usando COPY...")
                    copy_sql = f"""
                        COPY csv_encuestas_temp (id_encuesta, id_pregunta, id_respuesta, fecha_respuesta, id_encuestado, id_respondida)
                        FROM '{dest_path}'
                        DELIMITER ','
                        CSV
                    """
                    await conn.execute(copy_sql)
                    logger.info("Archivo CSV cargado en tabla csv_encuestas_temp.")
                except Exception as e:
                    logger.error(f"Error al cargar CSV: {e}")
                    raise HTTPException(status_code=400, detail=f"Error al cargar CSV: {str(e)}")

                try:
                    logger.info("Ejecutando procedimiento almacenado procesar_csv_encuestas()...")
                    await conn.execute("CALL procesar_csv_encuestas()")
                    logger.info("Procedimiento ejecutado correctamente.")
                except Exception as e:
                    logger.error(f"Error al ejecutar procedimiento: {e}")
                    raise HTTPException(status_code=500, detail=f"Error al ejecutar procedimiento: {str(e)}")
    except Exception as e:
        logger.error(f"Error general en cargar_csv: {e}")
        raise

    logger.info("CSV cargado y procesado correctamente.")
    return {"mensaje": "CSV cargado y procesado correctamente"}