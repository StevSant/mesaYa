# Modelo c4 componente reservas y pagos REST

```mermaid
classDiagram
class ReservaController
class PagoController
class CrearReservaUseCase
class CancelarReservaUseCase
class PagarReservaUseCase

ReservaController --> CrearReservaUseCase : usa
ReservaController --> CancelarReservaUseCase : usa
PagoController --> PagarReservaUseCase : usa


```
