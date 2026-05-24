import React, { createContext, useContext, useState, useEffect } from "react";

type Role = "operator" | "superadmin" | null;

interface AuthUser {
  name: string;
  email: string;
  role: Role;
}

interface AuthContextType {
  user: AuthUser | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  login: async () => false,
  logout: () => {},
  isAuthenticated: false,
});

const MOCK_CREDENTIALS = [
  { email: "operator@lampungprov.go.id", password: "operator123", name: "Rini Agustina, S.Kom.", role: "operator" as Role },
  { email: "admin@lampungprov.go.id", password: "admin123", name: "Superadmin KMS", role: "superadmin" as Role },
];

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
    const found = MOCK_CREDENTIALS.find(c => c.email === email && c.password === password);
    if (found) {
      setUser({ name: found.name, email: found.email, role: found.role });
      return true;
    }
    return false;
  };

  const logout = () => {
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isAuthenticated: !!user }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
