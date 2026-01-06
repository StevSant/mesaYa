import { EventType } from '../kafka/event-types.constant';

/**
 * Base event interface for all Kafka events.
 */
export interface BaseEvent<T = unknown> {
  /**
   * Type of the event
   */
  event_type: EventType;

  /**
   * ID of the entity that triggered the event
   */
  entity_id: string;

  /**
   * ISO 8601 timestamp of when the event occurred
   */
  timestamp: string;

  /**
   * Event payload data
   */
  data: T;

  /**
   * Optional metadata
   */
  metadata?: {
    user_id?: string;
    correlation_id?: string;
    [key: string]: unknown;
  };
}
