import { BaseEvent } from './base-event.interface';
import { AuthRoleName } from '../types/auth-role-name.enum';

/**
 * User data in auth events
 */
export interface AuthUserEventData {
  id: string;
  email: string;
  name: string;
  phone: string;
  roles: string[];
  active: boolean;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Event emitted when a user signs up
 */
export interface UserSignedUpEvent extends BaseEvent<AuthUserEventData> {
  event_type: 'user_signed_up';
}

/**
 * Event emitted when a user logs in
 */
export interface UserLoggedInEvent extends BaseEvent<{ email: string }> {
  event_type: 'user_logged_in';
}

/**
 * Event emitted when a user logs out
 */
export interface UserLoggedOutEvent extends BaseEvent<{ email: string }> {
  event_type: 'user_logged_out';
}

/**
 * Event emitted when a user is created (sync event for Gateway)
 */
export interface UserCreatedEvent extends BaseEvent<AuthUserEventData> {
  event_type: 'user_created';
}

/**
 * Event emitted when a user is updated (sync event for Gateway)
 */
export interface UserUpdatedEvent extends BaseEvent<AuthUserEventData> {
  event_type: 'user_updated';
}

/**
 * Event emitted when user roles are updated
 */
export interface RolesUpdatedEvent extends BaseEvent<{
  userId: string;
  roles: string[];
}> {
  event_type: 'roles_updated';
}

/**
 * Event emitted when a token is refreshed
 */
export interface TokenRefreshedEvent extends BaseEvent<{
  userId: string;
  email: string;
}> {
  event_type: 'token_refreshed';
}

/**
 * Event emitted when a token is revoked (logout)
 */
export interface TokenRevokedEvent extends BaseEvent<{
  userId: string;
  refreshTokenId?: string;
}> {
  event_type: 'token_revoked';
}

/**
 * Union type for all auth events
 */
export type AuthEvent =
  | UserSignedUpEvent
  | UserLoggedInEvent
  | UserLoggedOutEvent
  | UserCreatedEvent
  | UserUpdatedEvent
  | RolesUpdatedEvent
  | TokenRefreshedEvent
  | TokenRevokedEvent;
