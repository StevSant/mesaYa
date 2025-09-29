workspace "MesaYa - Plataforma de Reservas" "Modelo C4 para sistema de reservas de restaurantes" {

    !identifiers hierarchical

    model {
        # Personas
        usuario = person "Usuario Final" "Cliente que busca restaurantes, hace reservas, ve menús y realiza pagos"
        propietario = person "Propietario/Staff Restaurante" "Administra su restaurante, gestiona mesas, menú y confirma reservas"
        administrador = person "Administrador Plataforma" "Supervisa la plataforma, gestiona usuarios y restaurantes"

        # Sistema Principal
        mesaya = softwareSystem "MesaYa" "Plataforma digital para reservas y gestión integral de restaurantes" {

            # Contenedores de Presentación
            webApp = container "Aplicación Web" "Interfaz web responsive para usuarios y restaurantes" "React/Next.js"
            mobileApp = container "Aplicación Móvil" "Aplicación nativa para iOS y Android" "React Native"

            # API Gateway
            apiGateway = container "API Gateway" "Punto de entrada único, enrutamiento y autenticación" "Kong/AWS API Gateway"

            # Servicios de Negocio
            userService = container "Servicio de Usuarios" "Gestión de autenticación, perfiles y preferencias de usuarios" "Node.js/Express"
            restaurantService = container "Servicio de Restaurantes" "Gestión de restaurantes, ubicaciones y configuraciones" "Node.js/Express"
            tableService = container "Servicio de Mesas" "Gestión de mesas, disponibilidad y distribución" "Node.js/Express"
            menuService = container "Servicio de Menús" "Gestión de menús, platillos, precios e ingredientes" "Node.js/Express"
            bookingService = container "Servicio de Reservas" "Lógica de reservas, disponibilidad y confirmaciones" "Node.js/Express"
            paymentService = container "Servicio de Pagos" "Procesamiento de pagos y gestión de transacciones" "Node.js/Express"
            reviewService = container "Servicio de Reseñas" "Gestión de calificaciones y comentarios de usuarios" "Node.js/Express"
            notificationService = container "Servicio de Notificaciones" "Envío de emails, SMS y notificaciones push" "Node.js/Express"
            imageService = container "Servicio de Imágenes" "Gestión de imágenes, optimización y metadatos" "Node.js/Express"

            # Bases de Datos
            userDB = container "Base de Datos de Usuarios" "Almacena información de usuarios y autenticación" "PostgreSQL" "Database"
            restaurantDB = container "Base de Datos de Restaurantes" "Información de restaurantes y configuraciones" "PostgreSQL" "Database"
            bookingDB = container "Base de Datos de Reservas" "Reservas, estados y historial" "PostgreSQL" "Database"
            paymentDB = container "Base de Datos de Pagos" "Transacciones y estados de pago" "PostgreSQL" "Database"
            reviewDB = container "Base de Datos de Reseñas" "Calificaciones y comentarios" "PostgreSQL" "Database"
            imageDB = container "Base de Datos de Imágenes" "Metadatos de imágenes y referencias" "PostgreSQL" "Database"

            # Infraestructura
            eventBus = container "Bus de Eventos" "Comunicación asíncrona entre servicios" "Apache Kafka"
            cache = container "Cache" "Cache distribuido para mejorar rendimiento" "Redis"
        }

        # Sistemas Externos
        paymentGateway = softwareSystem "Pasarela de Pagos" "Procesamiento seguro de pagos con tarjeta" "External System"
        emailProvider = softwareSystem "Proveedor de Email" "Servicio de envío de correos electrónicos" "External System"
        smsProvider = softwareSystem "Proveedor de SMS" "Servicio de envío de mensajes SMS" "External System"
        pushProvider = softwareSystem "Proveedor Push" "Servicio de notificaciones push móviles" "External System"
        cloudStorage = softwareSystem "Almacenamiento en la Nube" "Almacenamiento y CDN para imágenes" "External System"
        oauthProvider = softwareSystem "Proveedor OAuth" "Autenticación con Google, Facebook, etc." "External System"
        mapsProvider = softwareSystem "Proveedor de Mapas" "API de mapas y geolocalización" "External System"

        # Relaciones Usuarios -> Sistema
        usuario -> mesaya.webApp "Busca restaurantes, hace reservas y pagos"
        usuario -> mesaya.mobileApp "Usa desde dispositivo móvil"
        propietario -> mesaya.webApp "Administra restaurante y reservas"
        administrador -> mesaya.webApp "Supervisa la plataforma"

        # Relaciones Aplicaciones -> Gateway
        mesaya.webApp -> mesaya.apiGateway "Llamadas API via HTTPS/JSON"
        mesaya.mobileApp -> mesaya.apiGateway "Llamadas API via HTTPS/JSON"

        # Relaciones Gateway -> Servicios
        mesaya.apiGateway -> mesaya.userService "Autenticación y perfil"
        mesaya.apiGateway -> mesaya.restaurantService "Información de restaurantes"
        mesaya.apiGateway -> mesaya.tableService "Consulta disponibilidad"
        mesaya.apiGateway -> mesaya.menuService "Obtiene menús"
        mesaya.apiGateway -> mesaya.bookingService "Gestiona reservas"
        mesaya.apiGateway -> mesaya.paymentService "Procesa pagos"
        mesaya.apiGateway -> mesaya.reviewService "Gestiona reseñas"
        mesaya.apiGateway -> mesaya.imageService "Obtiene imágenes"

        # Relaciones Servicios -> Bases de Datos
        mesaya.userService -> mesaya.userDB "Lee/Escribe datos de usuario" "JDBC/SQL"
        mesaya.restaurantService -> mesaya.restaurantDB "Lee/Escribe datos de restaurante" "JDBC/SQL"
        mesaya.tableService -> mesaya.restaurantDB "Lee configuración de mesas" "JDBC/SQL"
        mesaya.menuService -> mesaya.restaurantDB "Lee/Escribe menús" "JDBC/SQL"
        mesaya.bookingService -> mesaya.bookingDB "Gestiona reservas" "JDBC/SQL"
        mesaya.paymentService -> mesaya.paymentDB "Registra transacciones" "JDBC/SQL"
        mesaya.reviewService -> mesaya.reviewDB "Gestiona reseñas" "JDBC/SQL"
        mesaya.imageService -> mesaya.imageDB "Gestiona metadatos" "JDBC/SQL"

        # Relaciones con Cache
        mesaya.restaurantService -> mesaya.cache "Cache de restaurantes"
        mesaya.menuService -> mesaya.cache "Cache de menús"
        mesaya.tableService -> mesaya.cache "Cache de disponibilidad"

        # Relaciones con Event Bus
        mesaya.bookingService -> mesaya.eventBus "Publica eventos de reserva"
        mesaya.paymentService -> mesaya.eventBus "Publica eventos de pago"
        mesaya.reviewService -> mesaya.eventBus "Publica eventos de reseña"
        mesaya.userService -> mesaya.eventBus "Publica eventos de usuario"

        mesaya.eventBus -> mesaya.notificationService "Consume eventos para notificar"
        mesaya.eventBus -> mesaya.tableService "Actualiza disponibilidad"
        mesaya.eventBus -> mesaya.restaurantService "Actualiza estadísticas"

        # Relaciones con Sistemas Externos
        mesaya.paymentService -> paymentGateway "Procesa pagos" "HTTPS/API"
        paymentGateway -> mesaya.paymentService "Notifica estado de pago" "Webhook"

        mesaya.notificationService -> emailProvider "Envía emails" "SMTP/API"
        mesaya.notificationService -> smsProvider "Envía SMS" "API"
        mesaya.notificationService -> pushProvider "Envía push notifications" "API"

        mesaya.imageService -> cloudStorage "Sube/descarga imágenes" "S3 API"

        mesaya.userService -> oauthProvider "Autenticación social" "OAuth 2.0"

        mesaya.restaurantService -> mapsProvider "Obtiene coordenadas" "Maps API"
    }

    views {

        systemContext mesaya "MesaYaContext" {
            include *
            autoLayout lr
            title "MesaYa - Diagrama de Contexto"
            description "Vista general del sistema MesaYa y sus usuarios"
        }

        container mesaya "MesaYaContainers" {
            include *
            autoLayout tb
            title "MesaYa - Diagrama de Contenedores"
            description "Arquitectura interna del sistema MesaYa"
        }

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #85bbf0
                color #000000
            }
        }
    }
}
