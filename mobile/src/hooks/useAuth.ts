import { useState, useEffect, useCallback } from 'react';
import * as SecureStore from 'expo-secure-store';
import { User } from '../types';
import * as db from '../db/database';
import * as api from '../api/client';

const USER_KEY = 'opus_user';

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    try {
      const savedUser = await db.getUser();
      if (savedUser) {
        setUser(savedUser);
      }
    } catch (err) {
      console.error('Erro ao carregar usuário:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const login = useCallback(async (username: string, password: string): Promise<boolean> => {
    setIsLoading(true);
    setError(null);

    try {
      const loggedUser = await api.login(username, password);
      await db.saveUser(loggedUser);
      setUser(loggedUser);
      return true;
    } catch (err: any) {
      setError(err.message || 'Erro ao fazer login');
      return false;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const logout = useCallback(async () => {
    try {
      await db.clearUser();
      await db.clearAllData();
      setUser(null);
    } catch (err) {
      console.error('Erro ao fazer logout:', err);
    }
  }, []);

  return {
    user,
    isLoading,
    error,
    login,
    logout,
    isAuthenticated: !!user,
  };
}
