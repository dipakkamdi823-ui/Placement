/**
 * SAIOTAF - Faculty & Moderator Module
 * RequireFacultyAuth.jsx
 *
 * Route guard that:
 *  1. Redirects to /faculty/login if no valid JWT.
 *  2. Redirects students back to /student portal.
 *  3. ⭐ Blocks faculty with pending admin verification — shows a
 *     "Awaiting Admin Approval" screen instead of the portal.
 */

import React, { useState, useEffect } from "react";
import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import { authApi } from "../api/facultyApi";
import { ShieldCheck, ShieldAlert, Clock, LogOut, XCircle } from "lucide-react";

function PendingVerificationScreen({ onLogout }) {
  return (
    <div
      className="d-flex align-items-center justify-content-center vh-100"
      style={{ background: "var(--bg-dark, #0b0f19)" }}
    >
      <div
        className="text-center p-5 rounded-4 shadow-lg animate-fade-in"
        style={{
          background: "var(--bg-card, #131c2f)",
          border: "1px solid rgba(245,158,11,0.35)",
          maxWidth: 480,
          width: "95%",
        }}
      >
        {/* Icon */}
        <div
          className="d-inline-flex align-items-center justify-content-center rounded-circle mb-4"
          style={{
            width: 72,
            height: 72,
            background: "rgba(245,158,11,0.12)",
            border: "2px solid rgba(245,158,11,0.4)",
          }}
        >
          <Clock size={34} color="#f59e0b" />
        </div>

        <h4 className="fw-bold mb-2" style={{ color: "#f59e0b" }}>
          Account Pending Verification
        </h4>
        <p className="mb-4" style={{ color: "var(--text-muted, #94a3b8)", lineHeight: 1.6 }}>
          Your faculty account has been registered successfully. <br />
          An <strong style={{ color: "var(--text-main, #e2e8f0)" }}>admin</strong> must
          approve your account before you can access the portal. <br /><br />
          Please contact your institution's placement coordinator or wait for an
          approval email.
        </p>

        {/* Status Badge */}
        <div
          className="d-inline-flex align-items-center gap-2 px-4 py-2 rounded-pill mb-4"
          style={{
            background: "rgba(245,158,11,0.12)",
            border: "1px solid rgba(245,158,11,0.4)",
            color: "#f59e0b",
            fontWeight: 600,
            fontSize: "0.9rem",
          }}
        >
          <ShieldCheck size={16} />
          Status: Awaiting Admin Approval
        </div>

        <div className="d-flex flex-column gap-2 align-items-center">
          <button
            className="btn btn-outline-warning btn-sm d-inline-flex align-items-center gap-2 px-4 py-2"
            onClick={onLogout}
            style={{ fontWeight: 600 }}
          >
            <LogOut size={15} /> Sign Out
          </button>
          <span className="small" style={{ color: "var(--text-muted, #94a3b8)" }}>
            Once approved, sign in again to access the portal.
          </span>
        </div>
      </div>
    </div>
  );
}

function AccountRejectedScreen({ onLogout }) {
  return (
    <div
      className="d-flex align-items-center justify-content-center vh-100"
      style={{ background: "var(--bg-dark, #0b0f19)" }}
    >
      <div
        className="text-center p-5 rounded-4 shadow-lg animate-fade-in"
        style={{
          background: "var(--bg-card, #131c2f)",
          border: "1px solid rgba(239,68,68,0.4)",
          maxWidth: 500,
          width: "95%",
          boxShadow: "0 25px 60px rgba(239,68,68,0.12)",
        }}
      >
        {/* Icon */}
        <div
          className="d-inline-flex align-items-center justify-content-center rounded-circle mb-4"
          style={{
            width: 76,
            height: 76,
            background: "rgba(239,68,68,0.12)",
            border: "2px solid rgba(239,68,68,0.45)",
          }}
        >
          <XCircle size={38} color="#ef4444" />
        </div>

        <h4 className="fw-bold mb-2" style={{ color: "#ef4444" }}>
          Account Access Revoked
        </h4>
        <p className="mb-4" style={{ color: "var(--text-muted, #94a3b8)", lineHeight: 1.6, fontSize: "0.95rem" }}>
          Your faculty account has been <strong style={{ color: "#ef4444" }}>rejected or suspended</strong> by the system administrator. <br /><br />
          Direct access to the Faculty & Moderator Portal is restricted for this account.
        </p>

        {/* Status Badge */}
        <div
          className="d-inline-flex align-items-center gap-2 px-4 py-2 rounded-pill mb-4"
          style={{
            background: "rgba(239,68,68,0.12)",
            border: "1px solid rgba(239,68,68,0.4)",
            color: "#ef4444",
            fontWeight: 600,
            fontSize: "0.9rem",
          }}
        >
          <ShieldAlert size={16} />
          Status: Access Suspended / Rejected by Admin
        </div>

        <div className="d-flex flex-column gap-3 align-items-center">
          <button
            className="btn btn-outline-danger btn-sm d-inline-flex align-items-center gap-2 px-4 py-2"
            onClick={onLogout}
            style={{ fontWeight: 600 }}
          >
            <LogOut size={15} /> Sign Out & Return to Login
          </button>
          <span className="small text-muted" style={{ fontSize: "0.825rem", color: "var(--text-muted, #94a3b8)" }}>
            If you were previously approved or believe this was done in error, please contact your placement office or administrator for reinstatement.
          </span>
        </div>
      </div>
    </div>
  );
}

export default function RequireFacultyAuth({ children }) {
  const { isAuthenticated, logout } = useAuth();
  const location = useLocation();

  const [liveStatus, setLiveStatus] = useState(() => {
    return (localStorage.getItem("saiotaf_faculty_verification") || "approved").toLowerCase();
  });

  // Verify live status against backend to immediately catch real-time admin revoking
  useEffect(() => {
    let isMounted = true;
    async function checkStatus() {
      try {
        const { data } = await authApi.status();
        if (isMounted && data?.verification_status) {
          const s = data.verification_status.toLowerCase();
          setLiveStatus(s);
          localStorage.setItem("saiotaf_faculty_verification", s);
        }
      } catch (err) {
        // Retain existing localStorage status on network or server error
      }
    }
    if (isAuthenticated) {
      checkStatus();
    }
    return () => {
      isMounted = false;
    };
  }, [isAuthenticated]);

  // ── 1. Not logged in → redirect to login ──────────────────────────────────
  if (!isAuthenticated) {
    return <Navigate to="/faculty/login" replace state={{ from: location }} />;
  }

  // ── 2. Resolve user role ───────────────────────────────────────────────────
  let userRole = null;
  const storedUserStr = localStorage.getItem("saiotaf_user");
  if (storedUserStr) {
    try {
      const parsedUser = JSON.parse(storedUserStr);
      userRole = parsedUser?.role;
    } catch (e) {
      console.error("Error parsing saiotaf_user", e);
    }
  }

  // Fallback: decode JWT token payload role directly
  if (!userRole) {
    const token = localStorage.getItem("saiotaf_access_token");
    if (token) {
      try {
        const payload = JSON.parse(window.atob(token.split(".")[1]));
        userRole = payload?.role;
      } catch (e) {}
    }
  }

  // Deny students from accessing Faculty portal
  if (userRole === "Student") {
    return <Navigate to="/student" replace />;
  }

  // ── 3. Verification gate ───────────────────────────────────────────────────
  if (liveStatus === "rejected") {
    return <AccountRejectedScreen onLogout={logout} />;
  }

  if (liveStatus === "pending") {
    return <PendingVerificationScreen onLogout={logout} />;
  }

  // ── 4. Fully verified → render portal ────────────────────────────────────
  return children;
}
