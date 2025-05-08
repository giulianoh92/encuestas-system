# Sistema de Gestión de Encuestas

Este proyecto tiene como objetivo desarrollar un sistema para gestionar el ciclo de vida completo de las encuestas, desde su creación hasta el procesamiento de sus resultados. La empresa necesita una solución que sistematice el proceso de diseño, generación, distribución, y análisis de encuestas.

### Descripción General

El sistema permitirá a los clientes (personas o empresas) crear encuestas con preguntas y respuestas ponderadas. Los usuarios podrán responder las encuestas, y el sistema procesará las respuestas y generará resultados ponderados. Además, el sistema permitirá visualizar los resultados completos de cada encuesta respondida.

### Requisitos Funcionales

1. **Solicitante**: Cada encuesta puede ser solicitada por una persona o empresa. Se gestionan datos personales o de contacto de la empresa.
2. **Encuestas**: Cada encuesta tiene un título, fechas de publicación, una cantidad mínima de respuestas y un estado (en carga, abierta, cerrada, procesada).
3. **Preguntas y Respuestas**: Las encuestas contienen preguntas con respuestas posibles, cada una con una ponderación entre 0 y 1.
4. **Encuestados**: Los usuarios pueden responder las encuestas, registrando sus datos y las respuestas seleccionadas.
5. **Procesamiento**: Solo se procesan encuestas cerradas. El sistema calcula ponderaciones generales y por pregunta.
6. **Visualización**: Se permite visualizar los resultados de encuestas respondidas, incluyendo los detalles del encuestado y sus respuestas.

### Diagrama Entidad-Relación (DER)

```mermaid
erDiagram
    PERSONA {
        string dni PK
        string nombre
        string apellido
        string email
    }
    TELEFONO_PERSONA {
        int id PK
        string dni_persona FK
        string numero
    }
    EMPRESA {
        string cuit PK
        string razon_social
        string correo_contacto
    }
    TELEFONO_EMPRESA {
        int id PK
        string cuit_empresa FK
        string numero
    }
    SOLICITANTE {
        int id PK
        string tipo
        string referencia_id
    }
    ESTADO {
        int id PK
        string nombre
    }
    ENCUESTA {
        int id PK
        string denominacion
        date fecha_desde
        date fecha_hasta
        int minimo_respuestas
        int estado_id FK
        int solicitante_id FK
    }
    PREGUNTA {
        int id PK
        int encuesta_id FK
        string texto
        float ponderacion
    }
    OPCION_RESPUESTA {
        int id PK
        int pregunta_id FK
        string texto
        float ponderacion
    }
    ENCUESTADO {
        int id PK
        string nombre
        string apellido
        string genero
        string correo
        date fecha_nacimiento
        string ocupacion
    }
    ENCUESTA_RESPONDIDA {
        int id PK
        int encuesta_id FK
        int encuestado_id FK
        datetime fecha_hora_respuesta
    }
    RESPUESTA_SELECCIONADA {
        int id PK
        int encuesta_respondida_id FK
        int pregunta_id FK
        int opcion_respuesta_id FK
    }

    PERSONA ||--o{ TELEFONO_PERSONA : "tiene"
    EMPRESA ||--o{ TELEFONO_EMPRESA : "tiene"
    
    PERSONA ||--o| SOLICITANTE : "puede ser"
    EMPRESA ||--o| SOLICITANTE : "puede ser"

    SOLICITANTE ||--o{ ENCUESTA : "crea"
    ENCUESTA ||--o{ PREGUNTA : "contiene"
    PREGUNTA ||--o{ OPCION_RESPUESTA : "tiene"
    ENCUESTA ||--o| ESTADO : "tiene"
    
    ENCUESTADO ||--o{ ENCUESTA_RESPONDIDA : "responde"
    ENCUESTA ||--o{ ENCUESTA_RESPONDIDA : "es respondida en"

    ENCUESTA_RESPONDIDA ||--o{ RESPUESTA_SELECCIONADA : "tiene"
    PREGUNTA ||--o{ RESPUESTA_SELECCIONADA : "es respondida con"
    OPCION_RESPUESTA ||--o{ RESPUESTA_SELECCIONADA : "es elegida en"
```