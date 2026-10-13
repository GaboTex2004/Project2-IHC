import unittest
from fastapi.testclient import TestClient
from main import app
from usuarios.router import obtener_usuario_token

class UsuarioFalso:
    id = 1
    correo = "test@ejemplo.com"

def mock_obtener_usuario():
    return UsuarioFalso()

class PruebasApiMascotas(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        # Bypasseamos la autenticación para la prueba
        app.dependency_overrides[obtener_usuario_token] = mock_obtener_usuario

    def tearDown(self):
        app.dependency_overrides.clear()

    def test_api_restriccion_doble_completado(self):
        # 1. Creamos la mascota mediante la API
        respuesta_crear = self.client.post("/api/mascotas/crear", json={
            "nombre": "Boby",
            "tipo": "Gato",
            "cuidado": "Desparasitación",
            "fecha": "2026-11-20"
        })
        id_mascota = respuesta_crear.json()["id"]

        # 2. La marcamos como completada (Debe funcionar)
        res_completar_1 = self.client.put(f"/api/mascotas/{id_mascota}/completar")
        self.assertEqual(res_completar_1.status_code, 200)

        # 3. Intentamos completarla de nuevo (Debe lanzar la restricción de tu tarea)
        res_completar_2 = self.client.put(f"/api/mascotas/{id_mascota}/completar")
        self.assertEqual(res_completar_2.status_code, 400)
        self.assertEqual(res_completar_2.json()["detail"], "El cuidado ya estaba completado")

    # --- NUEVOS TESTS INTEGRADOS CORRECTAMENTE ---

    def test_editar_reprogramar_permitido(self):
        # 1. Crear una mascota/cuidado pendiente (estado=False por defecto)
        mascota_data = {
            "nombre": "Firulais",
            "tipo": "Perro",
            "cuidado": "Vacuna",
            "fecha": "2026-10-15"
        }
        res_crear = self.client.post("/api/mascotas/crear", json=mascota_data)
        mascota_id = res_crear.json()["id"]

        # 2. Intentar editar/reprogramar (Caso Permitido)
        mascota_actualizada = {
            "nombre": "Firulais",
            "tipo": "Perro",
            "cuidado": "Vacuna",
            "fecha": "2026-10-20"  # Nueva fecha
        }
        res_editar = self.client.put(f"/api/mascotas/editar/{mascota_id}", json=mascota_actualizada)
        
        self.assertEqual(res_editar.status_code, 200)
        self.assertEqual(res_editar.json()["fecha"], "2026-10-20")


    def test_editar_reprogramar_rechazado(self):
        # 1. Crear cuidado
        mascota_data = {
            "nombre": "Michi",
            "tipo": "Gato",
            "cuidado": "Baño",
            "fecha": "2026-10-10"
        }
        res_crear = self.client.post("/api/mascotas/crear", json=mascota_data)
        mascota_id = res_crear.json()["id"]

        # 2. Marcarlo como completado
        self.client.put(f"/api/mascotas/{mascota_id}/completar")

        # 3. Intentar editar/reprogramar (Caso Rechazado)
        mascota_actualizada = {
            "nombre": "Michi",
            "tipo": "Gato",
            "cuidado": "Baño",
            "fecha": "2026-10-12" # Intento de cambio de fecha
        }
        res_editar = self.client.put(f"/api/mascotas/editar/{mascota_id}", json=mascota_actualizada)
        
        self.assertEqual(res_editar.status_code, 400)
        self.assertEqual(res_editar.json()["detail"], "No puedes editar un cuidado que ya fue realizado.")

if __name__ == "__main__":
    unittest.main()

