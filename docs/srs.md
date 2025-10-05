# **Especificación de Requerimientos de Software (SRS)**

## Sistema: **MESAYA**

---

## 1. Introducción

### 1.1 Propósito

El presente documento tiene como objetivo especificar los requerimientos del sistema **MESAYA**, una plataforma web y móvil que permite a restaurantes pequeños, medianos y grandes publicar información de su negocio, incluyendo menú, horarios, ubicación y disponibilidad de mesas en tiempo real.
El sistema está orientado a mejorar la visibilidad digital de los restaurantes y ofrecer a los usuarios la posibilidad de realizar reservas de mesas de manera rápida y organizada.

### 1.2 Alcance

MESAYA funcionará como un marketplace especializado en restaurantes, similar a plataformas como Airbnb, pero enfocado en la gestión de mesas.
El sistema permitirá a:

- **Restaurantes:** registrar su negocio, configurar áreas y subáreas con mesas, definir horarios de atención y publicar su menú.
- **Usuarios:** explorar restaurantes disponibles, visualizar ubicación, menú, horarios, disponibilidad de mesas, reservar mesas y dejar reseñas.

No se gestionarán pedidos de comida ni pagos en línea en esta primera versión; el alcance se limita a **reservas de mesas y visibilidad del restaurante**.

### 1.3 Definiciones, acrónimos y abreviaturas

- **MESAYA:** Nombre del sistema.
- **Área:** Sección física del restaurante (ejemplo: primer piso, segundo piso).
- **Subárea:** División dentro de un área (ejemplo: pared izquierda del primer piso).
- **Reserva:** Acción de un usuario al seleccionar mesa(s) en un restaurante para un horario específico.
- **Reseña:** Comentario y calificación que un usuario deja sobre un restaurante.

### 1.4 Referencias

- IEEE 830-1998 – Recommended Practice for Software Requirements Specifications.
- Prototipo en Figma: [Ver diseño](https://www.figma.com/design/n0wpwhs8guonX4pujR4wLw/Sin-t%C3%ADtulo?node-id=0-1&p=f&t=iS6q1ljmD2imQWaW-0).

---

## 2. Descripción general

### 2.1 Perspectiva del producto

El sistema será una aplicación web y móvil con un backend que gestione la lógica de reservas y disponibilidad.

- **Frontend:** Angular (para aplicación web y móvil PWA).
- **Backend:** API RESTful (posiblemente Node.js/Go/Python).
- **Base de datos:** Relacional PostgreSQL.

### 2.2 Funciones principales

- Registro y perfil de restaurantes.
- Configuración de áreas, subáreas y mesas disponibles.
- Visualización de disponibilidad de mesas en tiempo real.
- Reserva de mesas online con confirmación.
- Búsqueda y filtrado de restaurantes (por ubicación, tipo de comida, disponibilidad, horario).
- Publicación de menú digital.
- Gestión de reseñas y calificaciones.

### 2.3 Usuarios del sistema

- **Administrador del sistema (MESAYA):** gestiona la plataforma en general.
- **Dueños de restaurantes:** registran, configuran y actualizan la información de su local.
- **Clientes/Usuarios finales:** exploran restaurantes y realizan reservas.

### 2.4 Restricciones

- Debe ser accesible desde navegadores web modernos y dispositivos móviles.
- La reserva no implica pagos online (puede considerarse en futuras versiones).
- El sistema debe soportar múltiples restaurantes y usuarios concurrentes.

### 2.5 Suposiciones

- Los restaurantes gestionarán manualmente la disponibilidad de mesas en caso de cambios repentinos.
- Los usuarios requieren conexión a internet para usar la plataforma.

---

## 3. Requerimientos específicos

### 3.1 Requerimientos funcionales

#### Para usuarios finales

- RF1: El sistema debe permitir a los usuarios **registrarse** y **autenticarse**.
- RF2: El sistema debe permitir **explorar restaurantes** con detalles (menú, horario, ubicación).
- RF3: El sistema debe mostrar **áreas, subáreas y mesas disponibles** en tiempo real.
- RF4: El usuario debe poder **reservar una mesa** indicando fecha y hora.
- RF5: El sistema debe enviar **confirmación de la reserva** (notificación/app o correo electrónico).
- RF6: El usuario podrá **dejar reseñas y calificaciones** sobre un restaurante.

#### Para restaurantes

- RF7: El sistema debe permitir al restaurante **registrarse** y crear un perfil con información básica.
- RF8: El restaurante podrá **gestionar áreas, subáreas y mesas**.
- RF9: El restaurante podrá **publicar y actualizar su menú digital**.
- RF10: El sistema debe permitir configurar **horarios de atención**.
- RF11: El restaurante podrá visualizar y gestionar **reservas recibidas**.

#### Para administrador

- RF12: El administrador podrá **gestionar usuarios y restaurantes registrados**.
- RF13: El sistema debe generar reportes de **uso, reservas y actividad**.

---

### 3.2 Requerimientos no funcionales

- RNF1: **Usabilidad:** interfaz intuitiva y adaptable (responsive) para móviles y web.
- RNF2: **Rendimiento:** las consultas de disponibilidad deben responder en menos de 2 segundos.
- RNF3: **Escalabilidad:** el sistema debe soportar hasta 100 restaurantes y 1000 usuarios concurrentes en su primera versión.
- RNF4: **Seguridad:** datos de usuarios deben almacenarse cifrados; autenticación mediante JWT o similar.
- RNF5: **Disponibilidad:** el sistema debe estar disponible al menos el 99% del tiempo mensual.
- RNF6: **Compatibilidad:** soporte para navegadores modernos (Chrome, Edge, Safari, Firefox).

---

## 4. Modelo de casos de uso (resumen)

1. **Registrar restaurante** – Un dueño crea el perfil de su local.
2. **Configurar mesas** – Restaurante define áreas y subáreas.
3. **Buscar restaurante** – Usuario explora opciones.
4. **Reservar mesa** – Usuario selecciona mesa y horario.
5. **Confirmar reserva** – El sistema envía notificación.
6. **Dejar reseña** – Usuario comenta sobre su experiencia.

---

## 5. Anexos

- Bocetos de interfaz en Figma.
- Lista de integrantes del proyecto.

---

👉 Esta versión ya te sirve como **documento inicial de SRS académico/profesional**.

¿Quieres que lo pase a un formato **más formal tipo IEEE 830 (con apartados como “Interfaces externas”, “Restricciones de diseño”, “Atributos de calidad” etc.)**, o prefieres que lo mantengamos en este estilo más práctico para tu proyecto universitario?
