/**
 * SAIOTAF - Faculty & Moderator Module
 * useAuth hook: encapsulates JWT storage + login/MFA/logout flow so
 * components stay declarative and testable in isolation.
 */

import { useState, useCallback, createContext, useContext } from "react";
import { authApi } from "../api/facultyApi";

const AuthContext = createContext(null);

function isTokenValid(token) {
  if (!token) return false;
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return false;
    const base64Url = parts[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const payload = JSON.parse(window.atob(base64));
    if (payload.exp && payload.exp * 1000 < Date.now()) {
      return false;
    }
    return true;
  } catch (e) {
    return false;
  }
}

export function FacultyAuthProvider({ children }) {
  const [isAuthenticated, setIsAuthenticated] = useState(() => {
    const token = localStorage.getItem("saiotaf_access_token");
    const valid = isTokenValid(token);
    if (!valid && token) {
      localStorage.removeItem("saiotaf_access_token");
      localStorage.removeItem("saiotaf_refresh_token");
      localStorage.removeItem("saiotaf_user");
    }
    return valid;
  });
  const [mfaPending, setMfaPending] = useState(null); // holds mfa_token when awaiting OTP
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const login = useCallback(async (usernameOrEmail, password) => {
    setLoading(true);
    setError(null);
    try {
      const { data } = await authApi.login(usernameOrEmail, password);
      if (data.mfa_required) {
        setMfaPending(data.mfa_token);
        return { mfaRequired: true };
      }
      localStorage.setItem("saiotaf_access_token", data.access);
      localStorage.setItem("saiotaf_refresh_token", data.refresh);
      // Store verification status so RequireFacultyAuth can gate the portal
      localStorage.setItem("saiotaf_faculty_verification", data.verification_status || "approved");
      if (data.user) {
        localStorage.setItem("saiotaf_user", JSON.stringify(data.user));
      }
      setIsAuthenticated(true);
      return { mfaRequired: false, verificationStatus: data.verification_status || "approved" };
    } catch (err) {
      setError(err.response?.data?.detail || "Login failed. Please try again.");
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const verifyMfa = useCallback(
    async (otpCode) => {
      if (!mfaPending) throw new Error("No MFA session in progress.");
      setLoading(true);
      setError(null);
      try {
        const { data } = await authApi.verifyMfa(mfaPending, otpCode);
        localStorage.setItem("saiotaf_access_token", data.access);
        localStorage.setItem("saiotaf_refresh_token", data.refresh);
        setIsAuthenticated(true);
        setMfaPending(null);
      } catch (err) {
        setError(err.response?.data?.detail || "Invalid MFA code.");
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [mfaPending]
  );

  const signup = useCallback(async (payload) => {
    setLoading(true);
    setError(null);
    try {
      const { data } = await authApi.signup(payload);
      localStorage.setItem("saiotaf_access_token", data.access);
      localStorage.setItem("saiotaf_refresh_token", data.refresh);
      // New accounts are always pending until admin approves
      localStorage.setItem("saiotaf_faculty_verification", data.verification_status || "pending");
      if (data.user) {
        localStorage.setItem("saiotaf_user", JSON.stringify(data.user));
      }
      setIsAuthenticated(true);
      return data;
    } catch (err) {
      const errData = err.response?.data;
      let msg = "Sign up failed. Please try again.";
      if (errData) {
        if (typeof errData === 'string') msg = errData;
        else if (errData.detail) msg = errData.detail;
        else msg = Object.entries(errData).map(([k, v]) => `${k}: ${Array.isArray(v) ? v.join(', ') : v}`).join(' | ');
      }
      setError(msg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem("saiotaf_access_token");
    localStorage.removeItem("saiotaf_refresh_token");
    localStorage.removeItem("saiotaf_user");
    localStorage.removeItem("saiotaf_faculty_verification");
    setIsAuthenticated(false);
    setMfaPending(null);
  }, []);

  const value = { isAuthenticated, mfaPending, error, loading, login, verifyMfa, signup, logout };
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within a FacultyAuthProvider");
  return ctx;
}
