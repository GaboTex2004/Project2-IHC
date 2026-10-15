# Evaluación Heurística de Nielsen — Mascota al Día

- **Aplicación:** Mascota al Día
- **Acción concreta evaluada:** Encontrar un cuidado y reprogramarlo (recorrido desde la lista o búsqueda hasta el resultado final, incluyendo casos equivocados o bloqueados).
- **Archivos principales del flujo:**
  - `frontend/lib/features/mascotas/screens/home_screen.dart`
  - `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart`
  - `backend/mascotas/router.py`

---

## 1. Trabajo en clase: Registro de los tres hallazgos

### Tabla resumen de hallazgos (antes de elegir uno)

| # | Pantalla y evidencia | Problema y consecuencia | Heurística | Severidad |
| :-: | :--- | :--- | :--- | :--- |
| **1** | En `editar_mascota_screen.dart`, al abrir la pantalla para reprogramar un cuidado desde `home_screen.dart` y seleccionar una nueva fecha en el calendario. | Al cambiar la fecha o intentar salir, no se muestra la fecha original para comparar ni existe un botón explícito de cancelar/confirmar descarte de cambios. La persona debe recordar de memoria la fecha previa o puede guardar/perder una fecha accidental. | **H6 · Reconocer antes que recordar** y **H3 · Control y libertad** (faltan datos visibles al decidir y una salida clara sin guardar por error). | **3 · Mayor** (Afecta directamente la seguridad y precisión al reprogramar). |
| **2** | En `home_screen.dart`, después de buscar o filtrar un cuidado (por nombre, estado o fecha), entrar a reprogramarlo en `editar_mascota_screen.dart` y guardar. | Al regresar a la lista tras reprogramar, el cuidado modificado no destaca visualmente el cambio recién aplicado o deja de verse si ya no coincide con el filtro de fecha activo. La persona puede dudar de si la acción funcionó o repetir la búsqueda. | **H1 · Visibilidad del estado del sistema** y **H7 · Flexibilidad y eficiencia** (falta confirmación visual contextualizada al volver al listado filtrado). | **2 · Menor** (Dificulta la verificación inmediata, pero permite continuar). |
| **3** | En `editar_mascota_screen.dart`, al intentar reprogramar eligiendo una fecha equivocada (por ejemplo, una fecha pasada o idéntica a la actual). | El selector de fecha y el formulario no previenen ni explican de antemano qué fechas son válidas para reprogramar un cuidado pendiente. La persona descubre el problema recién al intentar guardar o registra una fecha incoherente sin guía previa. | **H5 · Prevención de errores** y **H9 · Reconocer y recuperarse de errores** (no previene el error antes de que ocurra ni guía con una salida clara). | **3 · Mayor** (Es importante corregirlo para evitar registros con fechas erróneas). |

---

### Desglose detallado de cada hallazgo (Formato verificable)

#### Hallazgo 1 (Elegido para mejora inmediata)
- **Dónde:** En la pantalla de edición/reprogramación (`editar_mascota_screen.dart`), después de tocar el selector de fecha para cambiar el día de un cuidado pendiente.
- **Qué ocurre:** El campo actualiza el valor temporalmente, pero desaparece la referencia de la fecha original programada y no hay una acción secundaria clara (`Cancelar`) junto al botón de guardado para descartar un cambio accidental con seguridad.
- **Consecuencia:** La persona tiene que recordar cuál era la fecha anterior antes de entrar a la pantalla y corre el riesgo de guardar una fecha equivocada o salir sin certeza de si el cambio se aplicó.
- **Heurística:** **H3 · Control y libertad** y **H6 · Reconocer antes que recordar**.
- **Severidad:** **3 · Mayor**.

#### Hallazgo 2
- **Dónde:** En la pantalla principal de listado y búsqueda (`home_screen.dart`), inmediatamente después de guardar la reprogramación de un cuidado desde `editar_mascota_screen.dart`.
- **Qué ocurre:** El estado de la lista se recarga, pero no se resalta el registro recién reprogramado ni se informa qué nueva fecha quedó asignada en el mensaje de confirmación.
- **Consecuencia:** La persona puede pensar que el cambio no se guardó o verse obligada a buscar nuevamente la mascota en la lista para comprobar la nueva fecha.
- **Heurística:** **H1 · Visibilidad del estado del sistema** y **H7 · Flexibilidad y eficiencia**.
- **Severidad:** **2 · Menor**.

#### Hallazgo 3
- **Dónde:** En el formulario de reprogramación (`editar_mascota_screen.dart`), al abrir el selector de calendario (`showDatePicker`) o intentar guardar la misma fecha sin cambios.
- **Qué ocurre:** No se indica mediante un texto de ayuda qué rango de fechas es válido ni se bloquea el botón de guardado cuando la fecha seleccionada es exactamente igual a la que ya tenía el cuidado.
- **Consecuencia:** La persona realiza envíos innecesarios al servidor o selecciona fechas pasadas por accidente sin recibir prevención oportuna en la interfaz.
- **Heurística:** **H5 · Prevención de errores**, **H9 · Reconocer y recuperarse de errores** y **H10 · Ayuda y documentación**.
- **Severidad:** **3 · Mayor**.

---

## 2. Trabajo en clase: Del problema observado a una mejora comprobable

| Observación | Heurística | Severidad | Mejora | Comprobación |
| :--- | :--- | :--- | :--- | :--- |
| Al reprogramar un cuidado en `editar_mascota_screen.dart`, se pierde de vista la fecha original y no existe un botón explícito de "Cancelar" junto a la acción principal que permita salir descartando una fecha seleccionada por error. | **H3 · Control y libertad** / **H6 · Reconocer antes que recordar** | **3 · Mayor** | 1. Mostrar un resumen visible con la `"Fecha actual programada"` arriba del selector de nueva fecha (`H6`).<br>2. Agregar el botón `"Cancelar"` (y diálogo de descarte si hay cambios sin guardar) para cerrar sin guardar una fecha accidental (`H3`).<br>3. Incluir en el `SnackBar` de éxito el detalle de la nueva fecha asignada (`H1`). | Otra persona entra a reprogramar un cuidado, selecciona una fecha distinta por accidente, toca `"Cancelar"` y comprueba sin recibir ayuda que el cuidado conserva su fecha original en la lista. |

---

## 3. Tarea 3: Evaluación Heurística Completa (H1–H10)

> **Nota para la entrega:** Guardar las capturas correspondientes en la carpeta `docs/evidencias/` con los nombres indicados abajo.

| Heurística | Estado final | Pantalla o flujo | Explicación y evidencia | Referencia al código | Captura (Antes / Después) |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **H1 · Visibilidad del estado del sistema** | Corregida / Cumple | Listado de cuidados (`home_screen.dart`) y guardado en `editar_mascota_screen.dart`. | La interfaz muestra etiquetas claras de estado (`Pendiente` / `Realizado`), indicadores de carga y un `SnackBar` que confirma explícitamente cuando el cuidado fue reprogramado con su nueva fecha. | `frontend/lib/features/mascotas/screens/home_screen.dart` y `editar_mascota_screen.dart` | `docs/evidencias/h1-visibilidad.png` |
| **H2 · Relación con el mundo real** | Cumple | Tarjetas de cuidado y formulario de reprogramación. | Se utilizan palabras comprensibles para dueños de mascotas (`Vacuna`, `Desparasitación`, `Baño`, `Pendiente`, `Realizado`, `Reprogramar`) y formato de fecha claro en lugar de términos técnicos de base de datos. | `frontend/lib/features/mascotas/screens/home_screen.dart` | `docs/evidencias/h2-mundo-real.png` |
| **H3 · Control y libertad** | Corregida | Formulario de reprogramación (`editar_mascota_screen.dart`). | Permite cerrar la pantalla de reprogramación mediante el botón `"Cancelar"` o la navegación hacia atrás sin guardar una fecha seleccionada por accidente. | `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart` | Antes: `docs/evidencias/h3-antes.png`<br>Después: `docs/evidencias/h3-despues.png` |
| **H4 · Consistencia y estándares** | Cumple | Flujo completo (`home_screen.dart`, `agregar_mascota_screen.dart`, `editar_mascota_screen.dart`). | Las mismas palabras, colores de estado (`Pendiente` vs. `Realizado`), iconos y botones mantienen el mismo significado y ubicación en todas las pantallas. | `frontend/lib/features/mascotas/screens/home_screen.dart` y `editar_mascota_screen.dart` | `docs/evidencias/h4-consistencia.png` |
| **H5 · Prevención de errores** | Corregida / Cumple | Intento de reprogramar un cuidado ya `"Realizado"` o elegir fecha inválida. | El sistema bloquea la edición/reprogramación de cuidados que ya tienen estado `"Realizado"` tanto en la interfaz como en la API, y evita guardar si no se ha modificado la fecha o si es inválida. | `frontend/lib/features/mascotas/screens/home_screen.dart`, `editar_mascota_screen.dart` y `backend/mascotas/router.py` | Antes: `docs/evidencias/h5-antes.png`<br>Después: `docs/evidencias/h5-despues.png` |
| **H6 · Reconocer antes que recordar** | Corregida | Pantalla de reprogramación (`editar_mascota_screen.dart`). | Al reprogramar, la pantalla mantiene visibles el nombre de la mascota, el tipo de cuidado y la **fecha original programada** junto al selector de la nueva fecha, sin obligar a regresar al listado. | `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart` | Antes: `docs/evidencias/h6-antes.png`<br>Después: `docs/evidencias/h6-despues.png` |
| **H7 · Flexibilidad y eficiencia** | Cumple | Búsqueda y filtros en `home_screen.dart`. | La pantalla principal permite filtrar rápidamente por nombre de mascota/cuidado, por estado (`Todos`, `Pendiente`, `Realizado`) y por fecha, conservando los filtros activos al regresar de reprogramar. | `frontend/lib/features/mascotas/screens/home_screen.dart` | `docs/evidencias/h7-eficiencia.png` |
| **H8 · Diseño estético y minimalista** | Cumple | Tarjetas de listado y vista de reprogramación. | Cada tarjeta muestra únicamente la información relevante para decidir (mascota, tipo de cuidado, fecha y estado), destacando la acción principal sin saturar la pantalla de ruido visual. | `frontend/lib/features/mascotas/screens/home_screen.dart` | `docs/evidencias/h8-minimalismo.png` |
| **H9 · Reconocer y recuperarse de errores** | Corregida | Mensajes de validación y bloqueo en `editar_mascota_screen.dart` y `home_screen.dart`. | Cuando una acción no está permitida (ej. reprogramar un cuidado ya realizado o fallo de validación), el mensaje explica la causa en lenguaje claro e indica cómo continuar. | `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart` y `backend/mascotas/router.py` | Antes: `docs/evidencias/h9-antes.png`<br>Después: `docs/evidencias/h9-despues.png` |
| **H10 · Ayuda y documentación** | Corregida | Campo de selección de fecha en `editar_mascota_screen.dart`. | Se incluye un texto breve de ayuda (`helperText`) justo donde se configura la nueva fecha, explicando que solo los cuidados pendientes pueden reprogramarse a una nueva fecha. | `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart` | Antes: `docs/evidencias/h10-antes.png`<br>Después: `docs/evidencias/h10-despues.png` |

---

## 4. Plantilla para el Issue Principal en GitHub

> Copia y pega este bloque al crear el issue llamado **`Evaluación heurística H1–H10`** en GitHub:

```markdown
## Evaluación heurística H1–H10 — Mascota al Día
**Flujo evaluado:** Encontrar un cuidado y reprogramarlo.

### Lista de verificación de heurísticas
- [x] **H1 · Visibilidad del estado del sistema** — Cumple / Mejorada en `home_screen.dart` y `editar_mascota_screen.dart`.
- [x] **H2 · Relación con el mundo real** — Cumple en `home_screen.dart` y `editar_mascota_screen.dart`.
- [ ] **H3 · Control y libertad** — Corregir en sub-issue: permitir cancelar reprogramación sin guardar fecha accidental (`editar_mascota_screen.dart`).
- [x] **H4 · Consistencia y estándares** — Cumple en el flujo de cuidados (`home_screen.dart`, `editar_mascota_screen.dart`).
- [x] **H5 · Prevención de errores** — Cumple / Mejorada en bloqueo de cuidados realizados y validación de fecha (`home_screen.dart`, `router.py`).
- [ ] **H6 · Reconocer antes que recordar** — Corregir en sub-issue: mostrar fecha original y resumen del cuidado al reprogramar (`editar_mascota_screen.dart`).
- [x] **H7 · Flexibilidad y eficiencia** — Cumple con conservación de búsqueda y filtros en `home_screen.dart`.
- [x] **H8 · Diseño estético y minimalista** — Cumple en tarjetas de cuidado y formulario de reprogramación.
- [ ] **H9 · Reconocer y recuperarse de errores** — Corregir en sub-issue: mensajes claros con salida concreta ante errores de validación (`editar_mascota_screen.dart`).
- [ ] **H10 · Ayuda y documentación** — Corregir en sub-issue: agregar texto corto de ayuda contextual en el selector de reprogramación (`editar_mascota_screen.dart`).

### Evidencia y documentación
El detalle completo con capturas antes/después y referencias al código se encuentra en `docs/evaluacion-heuristica.md` y `docs/evidencias/`.
```