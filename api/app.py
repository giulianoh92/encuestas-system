from fastapi import FastAPI
import asyncpg
import os

app = FastAPI()

DB_USER = os.getenv("POSTGRES_USER", "usuario")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "contraseña")
DB_NAME = os.getenv("POSTGRES_DB", "encuesta_db")
DB_HOST = os.getenv("POSTGRES_HOST", "db")
DB_PORT = int(os.getenv("POSTGRES_PORT", "5432"))

@app.on_event("startup")
async def startup():
    app.state.db_pool = await asyncpg.create_pool(
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        host=DB_HOST,
        port=DB_PORT,
        min_size=1,
        max_size=5
    )

@app.on_event("shutdown")
async def shutdown():
    await app.state.db_pool.close()

@app.get("/ping")
async def ping():
    try:
        async with app.state.db_pool.acquire() as conn:
            await conn.execute("SELECT 1")
        db_status = "ok"
    except Exception as e:
        db_status = f"error: {str(e)}"
    return {"message": "Hola Mundo", "db_status": db_status}