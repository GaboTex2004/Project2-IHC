import unittest
from fastapi.testclient import TestClient
from main import app
from usuarios.router import obtener_usuario_token

class UsuarioFalso:
    id = 1
    correo = "test@ejemplo.com"

class OtroUsuarioFalso:
    id = 2
    correo = "otro@ejemplo.com"

def mock_obtener_usuario():
    return UsuarioFalso()

def mock_obtener_otro_usuario():
    return OtroUsuarioFalso()

class PruebasHistorial(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        app.dependency_overrides[obtener_usuario_token] = mock_obtener_usuario

    def tearDown(self):
        app.dependency_overrides.clear()

    def crear_cuidado(self, nombre, fecha):
        res = self.client.post("/api/mascotas/crear", json={
            "nombre": nombre, "tipo": "Perro", "cuidado": "Vacuna", "fecha": fecha
        })
        return res.json()["id"]

    def eventos_de(self, mascota_id):
        res = self.client.get("/api/historial/")
        self.assertEqual(res.status_code, 200)
        return [e for e in res.json() if e["mascota_id"] == mascota_id]

    def test_completar_genera_evento(self):
        mascota_id = self.crear_cuidado("Rocky", "2030-05-10")
        self.client.put(f"/api/mascotas/{mascota_id}/completar")

        eventos = self.eventos_de(mascota_id)
        self.assertEqual(len(eventos), 1)
        self.assertEqual(eventos[0]["tipo"], "realizado")
        self.assertEqual(eventos[0]["mascota_nombre"], "Rocky")

    def test_reprogramar_genera_evento(self):
        mascota_id = self.crear_cuidado("Nala", "2030-06-01")
        self.client.put(f"/api/mascotas/editar/{mascota_id}", json={
            "nombre": "Nala", "tipo": "Perro", "cuidado": "Vacuna", "fecha": "2030-06-15"
        })

        eventos = self.eventos_de(mascota_id)
        self.assertEqual(len(eventos), 1)
        self.assertEqual(eventos[0]["tipo"], "reprogramado")
        self.assertEqual(eventos[0]["detalle"], "Del 2030-06-01 al 2030-06-15")

    def test_editar_sin_cambiar_fecha_no_genera_evento(self):
        mascota_id = self.crear_cuidado("Kira", "2030-07-01")
        self.client.put(f"/api/mascotas/editar/{mascota_id}", json={
            "nombre": "Kira", "tipo": "Perro", "cuidado": "Baño", "fecha": "2030-07-01"
        })

        self.assertEqual(self.eventos_de(mascota_id), [])

    def test_reciente_primero(self):
        mascota_id = self.crear_cuidado("Max", "2030-08-01")
        self.client.put(f"/api/mascotas/editar/{mascota_id}", json={
            "nombre": "Max", "tipo": "Perro", "cuidado": "Vacuna", "fecha": "2030-08-10"
        })
        self.client.put(f"/api/mascotas/{mascota_id}/completar")

        eventos = self.eventos_de(mascota_id)
        self.assertEqual(len(eventos), 2)
        # Lo último que se hizo fue completar, así que va primero
        self.assertEqual(eventos[0]["tipo"], "realizado")
        self.assertEqual(eventos[1]["tipo"], "reprogramado")

    def test_otro_usuario_no_ve_el_historial(self):
        mascota_id = self.crear_cuidado("Coco", "2030-09-01")
        self.client.put(f"/api/mascotas/{mascota_id}/completar")

        # Cambiamos al otro usuario y consultamos su historial
        app.dependency_overrides[obtener_usuario_token] = mock_obtener_otro_usuario
        self.assertEqual(self.eventos_de(mascota_id), [])

    def test_filtrar_por_tipo(self):
        mascota_id = self.crear_cuidado("Luna", "2030-10-01")
        self.client.put(f"/api/mascotas/editar/{mascota_id}", json={
            "nombre": "Luna", "tipo": "Perro", "cuidado": "Vacuna", "fecha": "2030-10-05"
        })
        self.client.put(f"/api/mascotas/{mascota_id}/completar")

        res = self.client.get("/api/historial/?tipo=reprogramado")
        eventos = [e for e in res.json() if e["mascota_id"] == mascota_id]
        self.assertEqual(len(eventos), 1)
        self.assertEqual(eventos[0]["tipo"], "reprogramado")

if __name__ == "__main__":
    unittest.main()
