# Modelo c4 componente reservas y pagos REST

```mermaid
classDiagram
%% Use cases
class CrearReservaUseCase
class CancelarReservaUseCase
class PagarReservaUseCase

%% Ports
class IReservaRepository
class IMesaRepository
class IPagoRepository
class IEmailService
class IPaymentService
class ICacheService
class IUnitOfWork

%% Adapters
class ReservaRepositoryPg
class MesaRepositoryPg
class PagoRepositoryPg
class SendGridEmailAdapter
class StripePaymentAdapter
class RedisCacheAdapter
class UnitOfWorkPg

CrearReservaUseCase --> IReservaRepository
CrearReservaUseCase --> IMesaRepository
CrearReservaUseCase --> IEmailService
CrearReservaUseCase --> ICacheService
CrearReservaUseCase --> IUnitOfWork

CancelarReservaUseCase --> IReservaRepository
CancelarReservaUseCase --> IEmailService
CancelarReservaUseCase --> IUnitOfWork

PagarReservaUseCase --> IReservaRepository
PagarReservaUseCase --> IPagoRepository
PagarReservaUseCase --> IPaymentService
PagarReservaUseCase --> IEmailService
PagarReservaUseCase --> IUnitOfWork

IReservaRepository <|.. ReservaRepositoryPg
IMesaRepository <|.. MesaRepositoryPg
IPagoRepository <|.. PagoRepositoryPg
IEmailService <|.. SendGridEmailAdapter
IPaymentService <|.. StripePaymentAdapter
ICacheService <|.. RedisCacheAdapter
IUnitOfWork <|.. UnitOfWorkPg

```
