import React, { createContext, useContext, useState, useEffect } from "react";
import { apiLogin } from "../data/api";

type Role = "operator" | "superadmin" | null;

interface AuthUser {
  id: string;
  name: string;
  email: string;
  role: Role;
}

interface AuthContextType {
  user: AuthUser | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  updateUserSession: (data: Partial<AuthUser>) => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  login: async () => false,
  logout: () => {},
  updateUserSession: () => {},
  isAuthenticated: false,
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(() => {
    const stored = localStorage.getItem("kms_user");
    return stored ? JSON.parse(stored) : null;
  });

  useEffect(() => {
    if (user) {
      localStorage.setItem("kms_user", JSON.stringify(user));
    } else {
      localStorage.removeItem("kms_user");
    }
  }, [user]);

  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      const res = await apiLogin({ email, password });
      if (res && res.user) {
        setUser({
          id: res.user.id,
          name: res.user.name,
          email: res.user.email,
          role: res.user.role as Role,
        });
        return true;
      }
    } catch (err) {
      console.error("Login error:", err);
    }
    return false;
  };

  const logout = () => {
    setUser(null);
  };

  const updateUserSession = (data: Partial<AuthUser>) => {
    setUser((prev) => {
      if (!prev) return null;
      return { ...prev, ...data };
    });
  };

  return (
    <AuthContext.Provider
      value={{ user, login, logout, updateUserSession, isAuthenticated: !!user }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
