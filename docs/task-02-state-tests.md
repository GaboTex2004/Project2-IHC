# Tarea 02 - Pruebas de transición de estado (Mascotas)

## Acción nueva
"Marcar como realizado" en un cuidado de mascota.
- Interfaz: botón en `HomeScreen`; al presionarlo llama a `PUT /api/mascotas/{id}/completar` y la tarjeta pasa a "✓ Realizado".
- Backend: `completar_cuidado` en `backend/mascotas/router.py`.

## Estados
`estado = False` (pendiente) → `estado = True` (realizado).
Completar un cuidado que ya está realizado se rechaza con error 400.

## Pruebas (`backend/tests/test_mascotas.py`)
| Prueba | Qué verifica |
|---|---|
| `test_estado_inicial_es_pendiente` | Una mascota nueva empieza con `estado = False` |
| `test_completar_cambia_estado_a_realizado` | La acción cambia el estado a `True` |
| `test_completar_dos_veces_se_rechaza` | Segunda vez lanza `HTTPException` 400 |
| `test_completar_conserva_los_demas_datos` | nombre, tipo, cuidado, fecha y usuario no cambian |

## Cómo ejecutarlas
Desde `backend/`:

```bash
python -m unittest discover -v
```

Resultado: `Ran 4 tests ... OK`.
