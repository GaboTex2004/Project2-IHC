# Mascota al Día 🐾

Aplicación móvil y web diseñada para la gestión y control del cuidado de mascotas, desarrollada con un backend en **FastAPI (Python)** y un frontend moderno en **Flutter**.

---

## 📋 Tabla de Contenidos

1. [Prerrequisitos](#-prerrequisitos)
2. [Configuración del Backend (FastAPI)](#2-configuración-del-backend-fastapi)
3. [Configuración del Frontend (Flutter)](#3-configuración-del-frontend-flutter)
4. [Ejecución del Sistema Completo](#4-ejecución-del-sistema-completo)

---

## 1. Prerrequisitos

Antes de clonar el repositorio, asegúrate de tener instalado en tu computadora:

- [Docker y Docker Compose](https://www.docker.com/) (Recomendado para levantar la base de datos y el backend de forma automática).
- [Flutter SDK](https://flutter.dev/) (Versión 3.x o superior).
- [Git](https://git-scm.com/).

---

## 2. Configuración del Backend (FastAPI)

1. **Clona el repositorio en tu máquina local:**

   ```bash
   git clone <URL_DE_TU_REPOSITORIO>
   cd nombre-del-repositorio

   ```

2. **Configura las variables de entorno del Backend:**
   Crea un archivo .env en la raíz de tu backend basándote en la siguiente estructura de ejemplo (.env.example):

3. **Levanta el Backend usando Docker Compose:**
   docker compose up --build
   Verificación: Abre tu navegador e ingresa a http://localhost:8000/docs

## 3. Configuración del Frontend (Flutter)

    flutter pub get

## 4. Ejecucion de la Aplicacion

    flutter run
