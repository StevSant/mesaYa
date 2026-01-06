/**
 * JWT Payload interface used across all services for token validation.
 * This is the decoded payload from a JWT access token.
 */
export interface JwtPayload {
  /**
   * Subject - User ID
   */
  sub: string;

  /**
   * User email
   */
  email: string;

  /**
   * User roles
   */
  roles: string[];

  /**
   * Issued at (Unix timestamp)
   */
  iat?: number;

  /**
   * Expiration time (Unix timestamp)
   */
  exp?: number;

  /**
   * JWT ID - unique identifier for the token
   */
  jti?: string;
}
