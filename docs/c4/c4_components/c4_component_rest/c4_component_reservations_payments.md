# Modelo c4 componente reservas y pagos REST

```mermaid
flowchart TB
  %% Interface
  Guard["JwtAuthGuard"] --> ReservaCtrl["ReservaController"]
  Guard --> PagoCtrl["PagoController"]

  %% Application
  ReservaCtrl --> UC_Crear["UseCase: Reserva.Crear"]
  ReservaCtrl --> UC_Cancelar["UseCase: Reserva.Cancelar"]
  PagoCtrl --> UC_Pagar["UseCase: Pago.Pagar"]

  %% Ports
  subgraph Puertos["Puertos (Interfaces)"]
    IRes["IReservaRepository"]
    IPag["IPagoRepository"]
    IEmail["IEmailService"]
    IPay["IPaymentService"]
    ICache["ICacheService"]
    IUnit["IUnitOfWork"]
  end

  UC_Crear --> IRes & IEmail & ICache & IUnit
  UC_Cancelar --> IRes & IEmail & IUnit
  UC_Pagar --> IRes & IPag & IPay & IEmail & IUnit

  %% Infra (adaptadores)
  subgraph Adaptadores["Adaptadores"]
    ResRepoPg["ReservaRepositoryPg"]
    PagoRepoPg["PagoRepositoryPg"]
    SendGridAdp["SendGridEmailAdapter"]
    StripeAdp["StripePaymentAdapter"]
    RedisAdp["RedisCacheAdapter"]
    UoW["UnitOfWorkPg"]
  end

  IRes --> ResRepoPg
  IPag --> PagoRepoPg
  IEmail --> SendGridAdp
  IPay --> StripeAdp
  ICache --> RedisAdp
  IUnit --> UoW

  %% Data/Externos (no detallamos todo el sistema)
  ResRepoPg --> PG[(PostgreSQL)]
  PagoRepoPg --> PG
  RedisAdp --> REDIS[(Redis)]
  SendGridAdp --> SENDGRID[(SendGrid)]
  StripeAdp --> STRIPE[(Stripe)]



```
