# Modelo c4 componente reservas y pagos REST

```mermaid
classDiagram
class Reserva {
  +id: string
  +estado: EstadoReserva
  +marcarPagada(): void
  +cancelar(motivo: string): void
}

class Pago {
  +id: string
  +reservaId: string
}

class PagoRecibo

class EstadoReserva {
  <<enumeration>>
  PENDIENTE
  CONFIRMADA
  CANCELADA
  PAGADA
}

class ReservaPolicy {
  +canPay(reserva: Reserva): boolean
  +canCancel(reserva: Reserva, now: Date): boolean
}

Reserva <.. EstadoReserva
Reserva <.. ReservaPolicy
Pago --> Reserva : pertenece a

```
