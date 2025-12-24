# Integración MCP - Resumen de Implementación

Este documento resume la implementación completa de las herramientas MCP y su integración con el servicio de chatbot para el sistema MesaYA.

## Arquitectura Implementada

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                              MESAYA PLATFORM                                    │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────┐                        ┌─────────────────────┐        │
│  │   Angular Frontend  │◄───────────────────────│  NestJS Backend     │        │
│  │  (mesaYA_frontend)  │       REST API         │  (mesaYA_Res)       │        │
│  └─────────────────────┘                        └──────────▲──────────┘        │
│                                                            │                    │
│                                                    HTTP    │                    │
│                                                            │                    │
│  ┌─────────────────────┐   MCP Protocol   ┌───────────────┴───────────┐        │
│  │   Chatbot Service   │◄────────────────►│      MCP Server           │        │
│  │(mesaYA_chatbot)     │                  │   (mesaYA_mcp)            │        │
│  │                     │                  │                           │        │
│  │ ┌─────────────────┐ │                  │ ┌───────────────────────┐ │        │
│  │ │ MCPClientAdapter│ │                  │ │  25 MCP Tools         │ │        │
│  │ │ ────────────────│ │                  │ │  - 7 Restaurant       │ │        │
│  │ │ RestApiAdapter  │ │ Direct REST      │ │  - 10 Reservation     │ │        │
│  │ └────────┬────────┘ │───────────────►  │ │  - 5 Menu             │ │        │
│  └──────────│──────────┘                  │ │  - 3 User             │ │        │
│             │                             │ └───────────────────────┘ │        │
│             │ (configurable)              └───────────────────────────┘        │
│             ▼                                                                   │
│     RestaurantDataPort                                                         │
│      (Interface)                                                               │
└────────────────────────────────────────────────────────────────────────────────┘
```

## Archivos Creados/Modificados

### 1. MCP Server (`mesaYA_mcp/`)

#### Nuevos Archivos

- [shared/infrastructure/adapters/http_client.py](mesaYA_mcp/src/mesaYA_mcp/shared/infrastructure/adapters/http_client.py) - Cliente HTTP para comunicación con REST API
- [features/menus/tools.py](mesaYA_mcp/src/mesaYA_mcp/features/menus/tools.py) - Herramientas MCP para menús
- [features/menus/__init__.py](mesaYA_mcp/src/mesaYA_mcp/features/menus/__init__.py) - Exports
- [features/users/tools.py](mesaYA_mcp/src/mesaYA_mcp/features/users/tools.py) - Herramientas MCP para usuarios
- [features/users/__init__.py](mesaYA_mcp/src/mesaYA_mcp/features/users/__init__.py) - Exports
- [docs/MCP_TOOLS_REFERENCE.md](mesaYA_mcp/docs/MCP_TOOLS_REFERENCE.md) - Documentación de herramientas

#### Archivos Modificados

- [pyproject.toml](mesaYA_mcp/pyproject.toml) - Añadida dependencia `httpx>=0.27.0`
- [__main__.py](mesaYA_mcp/src/mesaYA_mcp/__main__.py) - Registro de 25 herramientas MCP
- [features/restaurants/tools.py](mesaYA_mcp/src/mesaYA_mcp/features/restaurants/tools.py) - Implementación completa de 7 funciones
- [features/reservations/tools.py](mesaYA_mcp/src/mesaYA_mcp/features/reservations/tools.py) - Implementación completa de 10 funciones

### 2. Chatbot Service (`mesaYA_chatbot_service/`)

#### Nuevos Archivos

- [shared/infrastructure/adapters/mcp_client_adapter.py](mesaYA_chatbot_service/src/mesaYA_chatbot_service/shared/infrastructure/adapters/mcp_client_adapter.py) - Adaptador cliente MCP

#### Archivos Modificados

- [pyproject.toml](mesaYA_chatbot_service/pyproject.toml) - Añadida dependencia `mcp>=1.0.0`
- [shared/core/config.py](mesaYA_chatbot_service/src/mesaYA_chatbot_service/shared/core/config.py) - Configuración para selector de adaptador
- [shared/infrastructure/adapters/__init__.py](mesaYA_chatbot_service/src/mesaYA_chatbot_service/shared/infrastructure/adapters/__init__.py) - Export de MCPClientAdapter
- [shared/presentation/app.py](mesaYA_chatbot_service/src/mesaYA_chatbot_service/shared/presentation/app.py) - Lógica de selección de adaptador

## Herramientas MCP Implementadas (25 total)

### 🍽️ Restaurantes (7)

| Herramienta | Descripción |
|-------------|-------------|
| `search_restaurants` | Buscar restaurantes por criterios |
| `get_restaurant_info` | Obtener información detallada |
| `get_nearby_restaurants` | Buscar por geolocalización |
| `get_restaurant_schedule` | Obtener horarios disponibles |
| `get_restaurant_menu` | Obtener menú completo |
| `get_restaurant_sections` | Obtener secciones/áreas |
| `get_section_tables` | Obtener mesas de una sección |

### 📅 Reservaciones (10)

| Herramienta | Descripción |
|-------------|-------------|
| `create_reservation` | Crear nueva reservación |
| `get_reservation` | Obtener detalles de reservación |
| `list_reservations` | Listar con filtros |
| `get_restaurant_reservations` | Reservaciones por restaurante |
| `update_reservation_status` | Actualizar estado |
| `cancel_reservation` | Cancelar reservación |
| `confirm_reservation` | Confirmar reservación |
| `check_in_reservation` | Registrar llegada |
| `complete_reservation` | Marcar como completada |
| `get_reservation_analytics` | Estadísticas |

### 🍕 Menús (5)

| Herramienta | Descripción |
|-------------|-------------|
| `get_menu` | Obtener menú por ID |
| `list_menus` | Listar menús de restaurante |
| `search_dishes` | Buscar platillos |
| `get_dish` | Obtener detalles de platillo |
| `get_menu_analytics` | Estadísticas de menús |

### 👤 Usuarios (3)

| Herramienta | Descripción |
|-------------|-------------|
| `get_user` | Obtener información de usuario |
| `list_users` | Listar usuarios |
| `get_user_analytics` | Estadísticas de usuarios |

## Configuración

### Variables de Entorno para MCP Server

```env
# mesaYA_mcp/.env
BACKEND_API_HOST=localhost
BACKEND_API_PORT=3000
LOG_LEVEL=INFO
BACKEND_API_TIMEOUT=30.0
```

### Variables de Entorno para Chatbot

```env
# mesaYA_chatbot_service/.env
# Elegir adaptador: 'rest' (directo) o 'mcp' (protocolo MCP)
DATA_ADAPTER=rest

# Configuración REST (cuando DATA_ADAPTER=rest)
BACKEND_API_HOST=localhost
BACKEND_API_PORT=3000
BACKEND_API_TIMEOUT=10.0

# Configuración MCP (cuando DATA_ADAPTER=mcp)
MCP_COMMAND=uv
MCP_ARGS=run,mcp
MCP_TIMEOUT=30.0
```

## Uso

### Iniciar MCP Server

```bash
cd mesaYA_mcp
uv run mcp
```

### Iniciar Chatbot con MCP

```bash
# Opción 1: Usando REST directamente (default)
cd mesaYA_chatbot_service
DATA_ADAPTER=rest uv run app

# Opción 2: Usando MCP Protocol
cd mesaYA_chatbot_service
DATA_ADAPTER=mcp uv run app
```

### Ejemplo de Uso Programático

```python
# Usando MCPClientAdapter directamente
from mesaYA_chatbot_service.shared.infrastructure.adapters import MCPClientAdapter

adapter = MCPClientAdapter()
restaurants = await adapter.search_restaurants(
    query="pizza",
    city="Manta",
    limit=5
)
```

## Diagrama de Secuencia

```
Usuario                 Chatbot                MCPClient              MCP Server              REST API
   │                       │                       │                       │                       │
   │ "Buscar pizza"        │                       │                       │                       │
   ├──────────────────────►│                       │                       │                       │
   │                       │ search_restaurants    │                       │                       │
   │                       ├──────────────────────►│                       │                       │
   │                       │                       │ call_tool             │                       │
   │                       │                       ├──────────────────────►│                       │
   │                       │                       │                       │ GET /restaurants      │
   │                       │                       │                       ├──────────────────────►│
   │                       │                       │                       │◄──────────────────────┤
   │                       │                       │◄──────────────────────┤ JSON                  │
   │                       │◄──────────────────────┤ Markdown              │                       │
   │◄──────────────────────┤ Respuesta formateada  │                       │                       │
   │                       │                       │                       │                       │
```

## Próximos Pasos

1. __Testing__: Añadir tests unitarios e integración para las herramientas MCP
2. __Autenticación__: Implementar token JWT en HttpClient para endpoints protegidos
3. __Caché__: Añadir caché para reducir llamadas API redundantes
4. __Métricas__: Integrar telemetría y observabilidad
5. __Rate Limiting__: Implementar límites en el servidor MCP
