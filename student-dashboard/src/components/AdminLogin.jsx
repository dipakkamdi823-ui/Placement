/**
 * SAIOTAF - Platform Command Center
 * AdminLogin.jsx (Super Admin Authentication Portal)
 */

import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { ShieldCheck, Lock, Mail, Key, ArrowLeft, AlertCircle } from "lucide-react";

export default function AdminLogin() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [secretKey, setSecretKey] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const fillDefaultAdminCredentials = () => {
    setEmail("admin@saiotaf.edu");
    setPassword("password123");
    setSecretKey("SAI88202");
    setError("");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    const trimmedEmail = email.trim().toLowerCase();
    const trimmedPassword = password.trim();
    const trimmedSecretKey = secretKey.trim();

    // Requirement 2: Frontend Validation Check for all fields (especially secretKey 8-char requirement)
    if (!trimmedEmail || !trimmedPassword || !trimmedSecretKey) {
      setError("Unauthorized: All fields (Email, Password, and Secret Access Key) are required.");
      return;
    }

    if (trimmedSecretKey.length !== 8) {
      setError("Unauthorized: Secret Access Key must be exactly 8 characters.");
      return;
    }

    if (!trimmedEmail.includes("@") || !trimmedEmail.includes(".")) {
      setError("Please enter a valid email address.");
      return;
    }

    // Client-side guard against student credentials in admin portal
    if (trimmedEmail.endsWith("@raisoni.net")) {
      setError("Access Denied: Student accounts (@raisoni.net) cannot access the Super Admin Portal. Use the default Super Admin credentials.");
      return;
    }

    setLoading(true);

    try {
      // Backend Authentication Route Verification
      const response = await fetch("http://127.0.0.1:8000/api/admin/auth/login/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: trimmedEmail,
          password: trimmedPassword,
          secret_key: trimmedSecretKey,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Unauthorized: Invalid Secret Access Key.");
      }

      // Successful Super Admin Authentication
      localStorage.setItem("saiotaf_admin_token", data.token || "admin_jwt_super_access_token_2026");
      localStorage.setItem("saiotaf_user_role", "SUPER_ADMIN");
      localStorage.setItem("saiotaf_admin_email", trimmedEmail);

      navigate("/admin/overview");
    } catch (err) {
      console.error("Admin Authentication Error:", err.message);
      setError(err.message || "Unauthorized: Invalid Secret Access Key.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="d-flex align-items-center justify-content-center min-vh-100 py-5" style={{ background: "var(--bg-dark, #0b0f19)" }}>
      <div className="glass-panel p-4" style={{ maxWidth: 460, width: "100%", borderRadius: "16px", boxShadow: "0 20px 50px rgba(0,0,0,0.6)" }}>
        <div className="text-center mb-4">
          <div
            className="p-3 rounded-circle d-inline-flex align-items-center justify-content-center mb-2"
            style={{
              width: 68,
              height: 68,
              background: "rgba(244, 63, 94, 0.15)",
              border: "1px solid rgba(244, 63, 94, 0.35)",
              boxShadow: "0 0 20px rgba(244, 63, 94, 0.2)"
            }}
          >
            <ShieldCheck size={34} color="#f43f5e" />
          </div>
          <h3 className="fw-bold mb-1" style={{ color: "var(--text-main)" }}>Super Admin Login</h3>
          <p className="text-secondary small mb-0">SAIOTAF Framework • Platform Command Center</p>
        </div>

        {/* Demo Admin Pre-configured Badge */}
        <div 
          className="p-3 mb-3 rounded-3 text-start d-flex align-items-center justify-content-between"
          style={{ 
            background: "rgba(244, 63, 94, 0.08)", 
            border: "1px dashed rgba(244, 63, 94, 0.35)",
            fontSize: "0.82rem"
          }}
        >
          <div>
            <div className="fw-bold" style={{ color: "#fb7185" }}>Pre-configured Admin (No Sign-Up)</div>
            <div className="text-muted" style={{ fontSize: "0.72rem" }}>
              <span className="text-light">admin@saiotaf.edu</span> • Key: <span className="text-warning">SAI88202</span>
            </div>
            <div style={{ fontSize: "0.7rem", color: "var(--text-muted)", marginTop: "2px" }}>
              * Student accounts cannot access the admin portal
            </div>
          </div>
          <button
            type="button"
            onClick={fillDefaultAdminCredentials}
            className="btn btn-sm btn-outline-danger px-2.5 py-1 fw-bold ms-2"
            style={{ fontSize: "0.75rem", borderRadius: "8px", whiteSpace: "nowrap" }}
          >
            Quick Fill
          </button>
        </div>

        {error && (
          <div className="alert alert-danger py-2 text-start mb-3 d-flex align-items-center gap-2" style={{ fontSize: "0.85rem" }}>
            <AlertCircle size={16} className="flex-shrink-0" /> <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="text-start">
          {/* 1. Admin Email */}
          <div className="mb-3">
            <label className="form-label text-secondary small fw-semibold">Admin Email Address</label>
            <div className="position-relative">
              <input
                type="email"
                className="form-control faculty-search-input"
                style={{ paddingLeft: "38px" }}
                placeholder="e.g. admin@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <Mail size={16} className="position-absolute text-muted" style={{ left: 12, top: "50%", transform: "translateY(-50%)", pointerEvents: "none" }} />
            </div>
          </div>

          {/* 2. Password */}
          <div className="mb-3">
            <label className="form-label text-secondary small fw-semibold">Password</label>
            <div className="position-relative">
              <input
                type="password"
                className="form-control faculty-search-input"
                style={{ paddingLeft: "38px" }}
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <Lock size={16} className="position-absolute text-muted" style={{ left: 12, top: "50%", transform: "translateY(-50%)", pointerEvents: "none" }} />
            </div>
          </div>

          {/* 3. Secret Access Key (Masked / Password-style input field - 8 characters) */}
          <div className="mb-4">
            <label className="form-label text-secondary small fw-semibold d-flex align-items-center justify-content-between">
              <span>Secret Access Key</span>
              <span className="badge px-2.5 py-1 fw-bold rounded-pill" style={{ background: "rgba(244, 63, 94, 0.15)", color: "#fb7185", border: "1px solid rgba(244, 63, 94, 0.35)", fontSize: "0.7rem" }}>8 Chars Required</span>
            </label>
            <div className="position-relative">
              <input
                type="password"
                className="form-control faculty-search-input"
                style={{ paddingLeft: "38px" }}
                placeholder="Enter 8-character Secret Key (e.g. SAI88202)"
                value={secretKey}
                onChange={(e) => setSecretKey(e.target.value)}
                maxLength={8}
                required
              />
              <Key size={16} className="position-absolute text-danger" style={{ left: 12, top: "50%", transform: "translateY(-50%)", pointerEvents: "none" }} />
            </div>
            <small className="text-secondary mt-1 d-block" style={{ fontSize: "0.75rem" }}>
              High-level security check • Default key: <code className="text-warning bg-dark border border-secondary px-1.5 py-0.5 rounded fw-bold">SAI88202</code>
            </small>
          </div>

          <button type="submit" className="btn btn-danger w-100 py-2 fw-bold d-flex align-items-center justify-content-center gap-2 mb-3" disabled={loading}>
            {loading ? "Verifying Credentials & Key…" : "Sign In to Super Admin Console"}
          </button>
        </form>

        <div className="text-center border-top border-secondary pt-3 mt-3">
          <p className="small mb-2" style={{ color: "var(--text-muted, #94a3b8)" }}>
            Don't have an admin account?{" "}
            <Link to="/admin/signup" className="text-danger fw-semibold text-decoration-none">Sign Up</Link>
          </p>
          <p className="small mb-2" style={{ color: "var(--text-muted, #94a3b8)" }}>
            <Link to="/admin/forgot-password" className="text-danger fw-semibold text-decoration-none">Forgot Password?</Link>
          </p>
          <Link to="/" className="text-secondary small text-decoration-none d-inline-flex align-items-center gap-1">
            <ArrowLeft size={14} /> Return to Main Landing Page
          </Link>
        </div>
      </div>
    </div>
  );
}
