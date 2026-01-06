/**
 * Tipos de eventos para Kafka.
 * Usar en el campo `event_type` del payload.
 */
export const EVENT_TYPES = {
  // Generic CRUD events
  CREATED: 'created',
  UPDATED: 'updated',
  DELETED: 'deleted',
  STATUS_CHANGED: 'status_changed',

  // Auth-specific events
  USER_CREATED: 'user_created',
  USER_UPDATED: 'user_updated',
  USER_SIGNED_UP: 'user_signed_up',
  USER_LOGGED_IN: 'user_logged_in',
  USER_LOGGED_OUT: 'user_logged_out',
  ROLES_UPDATED: 'roles_updated',
  PERMISSIONS_UPDATED: 'permissions_updated',
  TOKEN_REFRESHED: 'token_refreshed',
  TOKEN_REVOKED: 'token_revoked',
} as const;

export type EventType = (typeof EVENT_TYPES)[keyof typeof EVENT_TYPES];
