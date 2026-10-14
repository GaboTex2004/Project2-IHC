# Evaluación heurística H1–H10 — Mascota al Día

- **Issue principal:** #12 "Evaluación heurística H1–H10"
- **Sub-issues de lo que no cumplía:** #13 (H3), #14 (H6), #15 (H10), #16 (H9), #17 (H5)
- **Acción evaluada:** encontrar un cuidado y reprogramarlo.
- **Fecha de la evaluación:** 14 de octubre de 2026
- **Datos de prueba:** un usuario de prueba con tres cuidados: Firulais (Vacuna, pendiente), Michi (Desparasitación, pendiente) y Rocky (Baño, ya realizado).

## Recorrido evaluado

1. En el panel (`HomeScreen`) la persona busca por nombre o filtra por estado, tipo y fecha.
2. En la tarjeta del cuidado toca **Editar**.
3. En la pantalla de edición elige la nueva fecha en el calendario.
4. Toca **Guardar Cambios** (o **Cancelar**) y vuelve a la lista.

**Caso permitido:** reprogramar a Firulais (pendiente) del 20 al 23 de octubre. La lista muestra la nueva fecha y aparece el mensaje "Cuidado editado y reprogramado correctamente." ([caso-permitido.png](evidencias/caso-permitido.png))

**Caso bloqueado:** tocar **Editar** en Rocky, que ya fue realizado. La app no abre la edición y muestra "No puedes editar un cuidado que ya fue realizado." ([caso-bloqueado.png](evidencias/caso-bloqueado.png)) La API también lo rechaza con error 400 (`backend/mascotas/router.py:118-119`).

## Resumen

| Heurística | Estado final | Sub-issue | Commit |
| :--- | :---: | :---: | :---: |
| H1 · Visibilidad del estado del sistema | Cumple | — | — |
| H2 · Relación con el mundo real | Cumple | — | — |
| H3 · Control y libertad | Corregida | #13 | `f65d50b` |
| H4 · Consistencia y estándares | Cumple | — | — |
| H5 · Prevención de errores | Corregida | #17 | `a8aab70` |
| H6 · Reconocer antes que recordar | Corregida | #14 | `69c2f16` |
| H7 · Flexibilidad y eficiencia | Cumple | — | — |
| H8 · Diseño estético y minimalista | Cumple | — | — |
| H9 · Reconocer y recuperarse de errores | Corregida | #16 | `3da753d` |
| H10 · Ayuda y documentación | Corregida | #15 | `87591d0` |

---

## H1 · Visibilidad del estado del sistema — Cumple

- **Pantalla o flujo:** panel de cuidados y guardado de la reprogramación.
- **Explicación:** cada tarjeta muestra si el cuidado está realizado ("✓ Realizado") o si todavía se puede marcar ("Marcar como realizado"). Mientras carga la lista aparece un indicador de carga, y mientras se guarda el botón cambia a "Actualizando...". Al guardar aparece un mensaje verde de confirmación y la lista se recarga con la nueva fecha.
- **Cómo se comprobó:** se reprogramó a Firulais del 20 al 23 de octubre. Al volver a la lista se vio la fecha nueva y el mensaje de confirmación.
- **Captura:** [caso-permitido.png](evidencias/caso-permitido.png)
- **Código:**
  - `frontend/lib/features/mascotas/screens/home_screen.dart:402` (indicador de carga)
  - `home_screen.dart:448-471` (estado de cada tarjeta)
  - `home_screen.dart:510-511` (recarga al volver)
  - `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart:57-63` (mensaje de éxito)
  - `editar_mascota_screen.dart:208` ("Actualizando...")

## H2 · Relación con el mundo real — Cumple

- **Pantalla o flujo:** tarjetas del panel y pantalla de edición.
- **Explicación:** se usan palabras que entiende cualquier dueño de mascota: Vacuna, Desparasitación, Baño, Control, "Marcar como realizado", "Realizado", "Pendientes". No aparecen términos técnicos como "estado = true" ni identificadores.
- **Cómo se comprobó:** se revisaron los textos visibles del panel y de la edición durante el recorrido.
- **Captura:** [flujo-lista.png](evidencias/flujo-lista.png)
- **Código:**
  - `home_screen.dart:280-311` (opciones de los filtros)
  - `home_screen.dart:443-465` (textos de la tarjeta)

## H3 · Control y libertad — Corregida (#13)

- **Problema:** en la pantalla de edición solo existía "Guardar Cambios". Si la persona elegía una fecha por error, no había un botón visible para salir sin guardar; dependía de encontrar la flecha de atrás.
- **Severidad:** 3 (mayor). Se puede terminar guardando una fecha equivocada.
- **Corrección:** se agregó un botón **Cancelar** debajo de "Guardar Cambios". Cierra la pantalla sin guardar con `Navigator.pop(context, false)`.
- **Cómo se comprobó:** se eligió el 23 de octubre para Firulais y se tocó Cancelar. En la lista el cuidado siguió con su fecha original, el 20 de octubre.
- **Antes:** [h3-antes.png](evidencias/h3-antes.png)
- **Después:**
  - [edicion-despues.png](evidencias/edicion-despues.png)
  - [h3-despues-lista.png](evidencias/h3-despues-lista.png)
- **Archivos modificados:** `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart:211-226`
- **Commit:** `f65d50b` "H3: agrega boton Cancelar en la pantalla de reprogramacion (#13)"

## H4 · Consistencia y estándares — Cumple

- **Pantalla o flujo:** todo el recorrido.
- **Explicación:**
  - El botón "Editar" de la tarjeta abre la pantalla "Editar Mascota".
  - La palabra "Cancelar" significa lo mismo en el diálogo de eliminar y en la edición.
  - El mensaje del caso bloqueado es el mismo en la app y en la API ("No puedes editar un cuidado que ya fue realizado.").
  - Los campos usan el mismo estilo de borde en todas las pantallas.
- **Cómo se comprobó:** se compararon los textos y estilos de las dos pantallas y del diálogo de eliminar.
- **Capturas:**
  - [flujo-lista.png](evidencias/flujo-lista.png)
  - [edicion-despues.png](evidencias/edicion-despues.png)
  - [caso-bloqueado.png](evidencias/caso-bloqueado.png)
- **Código:**
  - `home_screen.dart:198` y `editar_mascota_screen.dart:224` ("Cancelar")
  - `home_screen.dart:495` y `backend/mascotas/router.py:119` (mismo mensaje)

## H5 · Prevención de errores — Corregida (#17)

- **Problema:** el calendario permitía elegir cualquier fecha desde 2020. Se podía "reprogramar" un cuidado a una fecha que ya pasó, y el backend lo guardaba porque `/editar` no validaba la fecha.
- **Severidad:** 3 (mayor). Queda un cuidado pendiente con una fecha que ya pasó, así que el recordatorio deja de tener sentido.
- **Corrección:**
  - En la app, el calendario empieza en el día de mañana, así que los días pasados aparecen deshabilitados.
  - En la API, `/editar/{id}` rechaza con error 400 una fecha nueva que no sea futura, igual que la regla de `/reprogramar`.
  - Se agregó la prueba `test_editar_fecha_pasada_rechazada`.
  - Se mantiene el bloqueo de cuidados realizados, que ya existía.
- **Cómo se comprobó:**
  - Antes: se eligió el 5 de octubre y se guardó, y la lista mostró a Firulais con fecha pasada.
  - Después: los días anteriores a mañana no se pueden tocar.
  - Las 13 pruebas del backend pasan (`python -m unittest discover -v`).
- **Antes:**
  - [h5-antes-calendario.png](evidencias/h5-antes-calendario.png)
  - [h5-antes-fecha-pasada.png](evidencias/h5-antes-fecha-pasada.png)
- **Después:** [h5-despues-calendario.png](evidencias/h5-despues-calendario.png)
- **Archivos modificados:**
  - `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart:91-104`
  - `backend/mascotas/router.py:121-123`
  - `backend/tests/mascotas/test_api_restricciones.py:93-106`
- **Commit:** `a8aab70` "H5: no permite reprogramar a una fecha pasada en la app ni en la API (#17)"

## H6 · Reconocer antes que recordar — Corregida (#14)

- **Problema:** al cambiar la fecha, el campo se sobrescribía y desaparecía la fecha original. La persona tenía que recordar cuál era antes de decidir.
- **Severidad:** 3 (mayor). Sin la fecha original es fácil equivocarse al reprogramar.
- **Corrección:** arriba del formulario hay un recuadro con la mascota, el cuidado y "Fecha programada actual". El campo de fecha ahora se llama "Nueva fecha".
- **Cómo se comprobó:** al elegir el 23 de octubre se ven a la vez la fecha actual (20) y la nueva (23).
- **Antes:** [edicion-antes.png](evidencias/edicion-antes.png)
- **Después:** [h6-despues.png](evidencias/h6-despues.png)
- **Archivos modificados:** `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart:139-160` y `:190`
- **Commit:** `69c2f16` "H6: muestra la fecha original del cuidado al reprogramar (#14)"

## H7 · Flexibilidad y eficiencia — Cumple

- **Pantalla o flujo:** búsqueda y filtros del panel.
- **Explicación:**
  - Se puede buscar por nombre y filtrar por estado, tipo de cuidado y fecha ("Próximos 7 días", "Este mes" o un rango).
  - Los filtros activos se ven como chips con una X para quitarlos.
  - Como el panel no se cierra al ir a editar (`Navigator.push`), al volver se recarga la lista con los mismos filtros.
- **Cómo se comprobó:** se revisó el código del panel y se usaron los filtros durante el recorrido. La API de filtros tiene pruebas (`test_filtrado_con_resultados`, `test_filtrado_sin_resultados`).
- **Captura:** [flujo-lista.png](evidencias/flujo-lista.png)
- **Código:**
  - `home_screen.dart:83-105` (arma la consulta con los filtros)
  - `home_screen.dart:350-395` (chips)
  - `home_screen.dart:500-511` (vuelve y recarga con los filtros)
  - `backend/mascotas/router.py:15-37`

## H8 · Diseño estético y minimalista — Cumple

- **Pantalla o flujo:** tarjetas del panel y pantalla de edición.
- **Explicación:** cada tarjeta muestra solo lo necesario para decidir: mascota, tipo, cuidado, fecha, estado y acciones. La pantalla de edición tiene solo los campos del cuidado y dos botones, sin elementos decorativos.
- **Cómo se comprobó:** se revisaron las dos pantallas durante el recorrido.
- **Capturas:**
  - [flujo-lista.png](evidencias/flujo-lista.png)
  - [edicion-despues.png](evidencias/edicion-despues.png)
- **Código:** `home_screen.dart:420-535`

## H9 · Reconocer y recuperarse de errores — Corregida (#16)

- **Problema:** si el servidor rechazaba el guardado, por ejemplo porque el cuidado se marcó como realizado mientras se editaba, la app no mostraba nada. El botón volvía a "Guardar Cambios" y la persona no sabía qué había pasado.
- **Severidad:** 3 (mayor). La persona cree que guardó o repite la acción sin entender por qué falla.
- **Corrección:**
  - Si la respuesta no es 200, la app muestra un mensaje rojo con el motivo que manda el backend (`detail`) y cómo seguir: "Revisa la fecha o vuelve a la lista con Cancelar."
  - Si no hay conexión, avisa que revise la conexión e intente de nuevo.
- **Cómo se comprobó:** se abrió la edición de Michi, se marcó como realizado desde otra sesión y se tocó Guardar.
  - Antes no pasaba nada.
  - Después aparece "No puedes editar un cuidado que ya fue realizado. Revisa la fecha o vuelve a la lista con Cancelar."
- **Antes:** [h9-antes.png](evidencias/h9-antes.png)
- **Después:** [h9-despues.png](evidencias/h9-despues.png)
- **Archivos modificados:** `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart:66-90`
- **Commit:** `3da753d` "H9: muestra el motivo del error al reprogramar y como continuar (#16)"

## H10 · Ayuda y documentación — Corregida (#15)

- **Problema:** el campo de fecha no explicaba qué fechas eran válidas ni que solo se pueden reprogramar cuidados pendientes.
- **Severidad:** 2 (menor). La persona puede descubrirlo probando, pero pierde tiempo.
- **Corrección:** se agregó un texto de ayuda debajo del campo "Nueva fecha": "Toca para elegir una fecha a partir de mañana. Solo los cuidados pendientes se pueden reprogramar."
- **Cómo se comprobó:** el texto aparece justo donde se elige la fecha, sin abrir otra pantalla.
- **Antes:** [edicion-antes.png](evidencias/edicion-antes.png)
- **Después:** [edicion-despues.png](evidencias/edicion-despues.png)
- **Archivos modificados:** `frontend/lib/features/mascotas/screens/editar_mascota_screen.dart:190-193`
- **Commit:** `87591d0` "H10: agrega texto de ayuda en el campo de nueva fecha (#15)"
