import unittest
from datetime import date

from fastapi import HTTPException
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from core.database import Base
from usuarios.models import UsuarioDB
from mascotas.models import Mascota
from mascotas.router import completar_cuidado, reprogramar_cuidado


class PruebasEstadoMascota(unittest.TestCase):
    def setUp(self):
        # Base de datos SQLite en memoria, se crea nueva en cada prueba
        engine = create_engine("sqlite://")
        Base.metadata.create_all(engine)
        self.db = sessionmaker(bind=engine)()

        self.usuario = UsuarioDB(nombre="Ana", correo="ana@correo.com", password="123")
        self.db.add(self.usuario)
        self.db.commit()

        self.mascota = Mascota(
            nombre="Firulais", tipo="Perro", cuidado="Vacuna",
            fecha=date(2026, 1, 15), usuario_id=self.usuario.id,
        )
        self.db.add(self.mascota)
        self.db.commit()

    def tearDown(self):
        self.db.close()

    def test_estado_inicial_es_pendiente(self):
        self.assertFalse(self.mascota.estado)

    def test_completar_cambia_estado_a_realizado(self):
        completar_cuidado(self.mascota.id, self.db, self.usuario)
        self.db.refresh(self.mascota)
        self.assertTrue(self.mascota.estado)

    def test_completar_dos_veces_se_rechaza(self):
        completar_cuidado(self.mascota.id, self.db, self.usuario)
        with self.assertRaises(HTTPException) as error:
            completar_cuidado(self.mascota.id, self.db, self.usuario)
        self.assertEqual(error.exception.status_code, 400)

    def test_completar_conserva_los_demas_datos(self):
        completar_cuidado(self.mascota.id, self.db, self.usuario)
        self.db.refresh(self.mascota)
        self.assertEqual(self.mascota.nombre, "Firulais")
        self.assertEqual(self.mascota.tipo, "Perro")
        self.assertEqual(self.mascota.cuidado, "Vacuna")
        self.assertEqual(self.mascota.fecha, date(2026, 1, 15))
        self.assertEqual(self.mascota.usuario_id, self.usuario.id)

    def test_reprogramar_cambia_la_fecha_futura(self):
        nueva_fecha = date(2099, 12, 31)

        reprogramar_cuidado(self.mascota.id, nueva_fecha, self.db, self.usuario)
        self.db.refresh(self.mascota)

        self.assertEqual(self.mascota.fecha, nueva_fecha)

    def test_reprogramar_fecha_pasada_se_rechaza(self):
        with self.assertRaises(HTTPException) as error:
            reprogramar_cuidado(
                self.mascota.id,
                date(2020, 1, 1),
                self.db,
                self.usuario,
            )

        self.assertEqual(error.exception.status_code, 400)
        self.assertEqual(error.exception.detail, "La nueva fecha debe ser futura")

    def test_reprogramar_cuidado_completado_se_rechaza(self):
        self.mascota.estado = True
        self.db.commit()

        with self.assertRaises(HTTPException) as error:
            reprogramar_cuidado(
                self.mascota.id,
                date(2099, 12, 31),
                self.db,
                self.usuario,
            )

        self.assertEqual(error.exception.status_code, 400)


if __name__ == "__main__":
    unittest.main()
