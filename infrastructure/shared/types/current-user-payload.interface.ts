/**
 * Payload attached to request.user after JWT validation.
 * This is what guards and decorators can access.
 */
export interface CurrentUserPayload {
  /**
   * User ID (UUID)
   */
  userId: string;

  /**
   * User email
   */
  email: string;

  /**
   * User roles with their permissions
   */
  roles: Array<{
    name: string;
    permissions: Array<{
      name: string;
    }>;
  }>;
}
