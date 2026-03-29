import bcrypt from 'bcryptjs';
import { AuthUser, StoredUser } from './types';

export async function authenticateAgainstUsers(
  users: StoredUser[],
  email: string,
  password: string
): Promise<AuthUser | null> {
  const normalizedEmail = email.trim().toLowerCase();
  const normalizedPassword = password.trim();

  for (const user of users) {
    const emailMatches = await bcrypt.compare(normalizedEmail, user.emailHash);
    if (!emailMatches) {
      continue;
    }

    const passwordMatches = await bcrypt.compare(normalizedPassword, user.passwordHash);
    if (!passwordMatches) {
      return null;
    }

    return {
      id: user.id,
      placeOfWork: user.placeOfWork
    };
  }

  return null;
}
