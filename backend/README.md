# Backend - Mascota al Día

## Pruebas unitarias

Desde la carpeta `backend/` (con las dependencias instaladas):

```bash
pip install -r requirements.txt
python -m unittest discover -v
```

Las pruebas están en `tests/test_mascotas.py` y usan una base SQLite en memoria, no necesitan Postgres ni Docker.
