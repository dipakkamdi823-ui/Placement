/**
 * SAIOTAF - Super Admin Module
 * AdminFacultyVerification.jsx
 *
 * Faculty account verification by admin — mirrors student verification flow.
 * Admin can Approve or Reject faculty registrations.
 */

import React, { useState, useEffect, useCallback } from "react";
import { adminApi } from "../api/adminApi";
import {
  Search, CheckCircle2, XCircle, Clock, ShieldCheck,
  UserCheck, RefreshCw, BadgeCheck, AlertCircle
} from "lucide-react";

const STATUS_CONFIG = {
  Approved: {
    color: "#10b981",
    bg: "rgba(16,185,129,0.12)",
    border: "rgba(16,185,129,0.3)",
    icon: <BadgeCheck size={13} />,
  },
  Rejected: {
    color: "#ef4444",
    bg: "rgba(239,68,68,0.12)",
    border: "rgba(239,68,68,0.3)",
    icon: <XCircle size={13} />,
  },
  Pending: {
    color: "#f59e0b",
    bg: "rgba(245,158,11,0.12)",
    border: "rgba(245,158,11,0.3)",
    icon: <Clock size={13} />,
  },
};

function StatusBadge({ status }) {
  const cfg = STATUS_CONFIG[status] || STATUS_CONFIG.Pending;
  return (
    <span
      className="badge d-inline-flex align-items-center gap-1 px-2 py-1"
      style={{
        background: cfg.bg,
        color: cfg.color,
        border: `1px solid ${cfg.border}`,
        borderRadius: "20px",
        fontSize: "0.75rem",
        fontWeight: 600,
      }}
    >
      {cfg.icon} {status}
    </span>
  );
}

export default function AdminFacultyVerification() {
  const [faculty, setFaculty] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("All");
  const [actioningId, setActioningId] = useState(null);
  const [toast, setToast] = useState(null);
  const [reasonModal, setReasonModal] = useState(null); // { fac, action }

  const showToast = (msg, type = "success") => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 4500);
  };

  const fetchFaculty = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminApi.getFacultyVerifications();
      setFaculty(data);
    } catch {
      setError("Failed to load faculty verification records.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchFaculty();
  }, [fetchFaculty]);

  const handleAction = async (fac, action, reason = "") => {
    setActioningId(fac.id);
    try {
      await adminApi.reviewFacultyVerification(fac.id, action, reason);
      const newStatus = action === "APPROVE" ? "Approved" : "Rejected";
      setFaculty((prev) =>
        prev.map((f) => (f.id === fac.id ? { ...f, verification_status: newStatus } : f))
      );
      showToast(
        `Faculty "${fac.name}" has been ${newStatus.toLowerCase()} successfully.`,
        action === "APPROVE" ? "success" : "danger"
      );
    } catch {
      setError("Failed to update faculty verification.");
    } finally {
      setActioningId(null);
      setReasonModal(null);
    }
  };

  const openReasonModal = (fac, action) => setReasonModal({ fac, action });

  // Stats
  const total = faculty.length;
  const pending = faculty.filter((f) => f.verification_status === "Pending").length;
  const approved = faculty.filter((f) => f.verification_status === "Approved").length;
  const rejected = faculty.filter((f) => f.verification_status === "Rejected").length;

  // Filtered list
  const filtered = faculty.filter((f) => {
    const matchStatus = statusFilter === "All" || f.verification_status === statusFilter;
    const q = search.toLowerCase();
    const matchSearch =
      !q ||
      f.name.toLowerCase().includes(q) ||
      f.email.toLowerCase().includes(q) ||
      f.employee_id.toLowerCase().includes(q) ||
      (f.department || "").toLowerCase().includes(q);
    return matchStatus && matchSearch;
  });

  return (
    <div className="animate-fade-in">
      {/* Toast */}
      {toast && (
        <div
          className={`alert alert-${toast.type} d-flex align-items-center justify-content-between py-2 px-3 mb-3 shadow`}
          role="alert"
        >
          <span className="d-flex align-items-center gap-2">
            {toast.type === "success" ? (
              <CheckCircle2 size={18} className="text-success" />
            ) : (
              <AlertCircle size={18} className="text-danger" />
            )}
            {toast.msg}
          </span>
          <button className="btn-close ms-3" onClick={() => setToast(null)} />
        </div>
      )}

      {/* Page Header */}
      <div className="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
          <h4 className="fw-bold mb-1" style={{ color: "var(--text-main)" }}>
            <ShieldCheck size={22} className="me-2 text-primary" />
            Faculty Verification
          </h4>
          <p className="small mb-0" style={{ color: "var(--text-muted)" }}>
            Review and approve or reject faculty account registrations.
          </p>
        </div>
        <button
          className="btn btn-outline-secondary btn-sm d-flex align-items-center gap-1"
          onClick={fetchFaculty}
          title="Refresh"
        >
          <RefreshCw size={14} /> Refresh
        </button>
      </div>

      {/* KPI Summary Cards */}
      <div className="row g-3 mb-4">
        {[
          { label: "Total Faculty", value: total, color: "#6366f1", bg: "rgba(99,102,241,0.12)", border: "rgba(99,102,241,0.3)" },
          { label: "Pending Review", value: pending, color: "#f59e0b", bg: "rgba(245,158,11,0.12)", border: "rgba(245,158,11,0.3)" },
          { label: "Approved", value: approved, color: "#10b981", bg: "rgba(16,185,129,0.12)", border: "rgba(16,185,129,0.3)" },
          { label: "Rejected", value: rejected, color: "#ef4444", bg: "rgba(239,68,68,0.12)", border: "rgba(239,68,68,0.3)" },
        ].map(({ label, value, color, bg, border }) => (
          <div className="col-6 col-md-3" key={label}>
            <div
              className="rounded-3 p-3 border"
              style={{ background: bg, borderColor: border }}
            >
              <div className="small fw-bold text-uppercase mb-1" style={{ color, opacity: 0.85 }}>
                {label}
              </div>
              <div className="fs-3 fw-bold" style={{ color }}>
                {value}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="d-flex align-items-center gap-2 mb-3 flex-wrap">
        {/* Search */}
        <div className="position-relative">
          <input
            type="search"
            className="form-control faculty-search-input ps-4"
            placeholder="Search name, ID, email, dept..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{ width: 260, fontSize: "0.85rem" }}
          />
          <Search size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
        </div>

        {/* Status Filter */}
        <div className="btn-group btn-group-sm" role="group">
          {["All", "Pending", "Approved", "Rejected"].map((s) => (
            <button
              key={s}
              type="button"
              className={`btn ${statusFilter === s ? "btn-primary" : "btn-outline-secondary"}`}
              onClick={() => setStatusFilter(s)}
            >
              {s}
              {s === "Pending" && pending > 0 && (
                <span className="badge bg-warning text-dark ms-1" style={{ fontSize: "0.65rem" }}>
                  {pending}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>

      {error && <div className="alert alert-danger py-2 mb-3">{error}</div>}

      {/* Table */}
      <div className="faculty-table-container">
        <table
          className="table table-hover align-middle faculty-table mb-0"
          style={{ minWidth: "900px" }}
        >
          <thead>
            <tr>
              <th className="text-start ps-3 text-nowrap">Employee ID</th>
              <th className="text-start text-nowrap">Name</th>
              <th className="text-start text-nowrap">Email</th>
              <th className="text-center text-nowrap">Department</th>
              <th className="text-center text-nowrap">Joined</th>
              <th className="text-center text-nowrap">Verification Status</th>
              <th className="text-center pe-3 text-nowrap" style={{ minWidth: "220px" }}>
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={7} className="text-center py-4 text-muted">
                  <div className="spinner-border spinner-border-sm me-2 text-primary" role="status" />
                  Loading faculty records…
                </td>
              </tr>
            )}

            {!loading && filtered.length === 0 && (
              <tr>
                <td colSpan={7} className="text-center py-5 text-muted">
                  No faculty records found.
                </td>
              </tr>
            )}

            {!loading &&
              filtered.map((fac) => (
                <tr key={fac.id}>
                  <td className="text-start ps-3 text-nowrap">
                    <code
                      className="px-2 py-1 rounded text-info border"
                      style={{
                        background: "var(--input-bg)",
                        borderColor: "var(--border-color)",
                        fontSize: "0.8rem",
                      }}
                    >
                      {fac.employee_id}
                    </code>
                  </td>
                  <td
                    className="text-start fw-semibold text-nowrap"
                    style={{ color: "var(--text-main)" }}
                  >
                    {fac.name}
                  </td>
                  <td
                    className="text-start small text-nowrap"
                    style={{ color: "var(--text-muted)" }}
                  >
                    {fac.email}
                  </td>
                  <td
                    className="text-center small text-nowrap"
                    style={{ color: "var(--text-muted)" }}
                  >
                    {fac.department}
                  </td>
                  <td
                    className="text-center small text-nowrap"
                    style={{ color: "var(--text-muted)" }}
                  >
                    {fac.joined}
                  </td>
                  <td className="text-center text-nowrap">
                    <StatusBadge status={fac.verification_status} />
                  </td>
                  <td className="text-center pe-3 text-nowrap">
                    <div className="d-inline-flex gap-2">
                      {/* Approve */}
                      <button
                        className="btn btn-sm btn-outline-success d-inline-flex align-items-center gap-1"
                        style={{ fontSize: "0.75rem", whiteSpace: "nowrap" }}
                        disabled={
                          actioningId === fac.id ||
                          fac.verification_status === "Approved"
                        }
                        onClick={() => openReasonModal(fac, "APPROVE")}
                        title="Approve Faculty"
                      >
                        <UserCheck size={13} /> Approve
                      </button>

                      {/* Reject */}
                      <button
                        className="btn btn-sm btn-outline-danger d-inline-flex align-items-center gap-1"
                        style={{ fontSize: "0.75rem", whiteSpace: "nowrap" }}
                        disabled={
                          actioningId === fac.id ||
                          fac.verification_status === "Rejected"
                        }
                        onClick={() => openReasonModal(fac, "REJECT")}
                        title="Reject Faculty"
                      >
                        <XCircle size={13} /> Reject
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>

      {/* Reason Modal */}
      {reasonModal && (
        <ReasonModal
          fac={reasonModal.fac}
          action={reasonModal.action}
          onConfirm={(reason) => handleAction(reasonModal.fac, reasonModal.action, reason)}
          onCancel={() => setReasonModal(null)}
        />
      )}
    </div>
  );
}

/* ── Inline Reason Modal ──────────────────────────────────────────────────── */
function ReasonModal({ fac, action, onConfirm, onCancel }) {
  const [reason, setReason] = useState("");
  const isApprove = action === "APPROVE";

  return (
    <div
      className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
      style={{ background: "rgba(0,0,0,0.55)", zIndex: 1060 }}
      onClick={onCancel}
    >
      <div
        className="rounded-4 p-4 shadow-lg"
        style={{
          background: "var(--bg-card)",
          border: "1px solid var(--border-color)",
          maxWidth: 440,
          width: "95%",
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="d-flex align-items-center gap-2 mb-3">
          {isApprove ? (
            <CheckCircle2 size={22} color="#10b981" />
          ) : (
            <XCircle size={22} color="#ef4444" />
          )}
          <h6 className="mb-0 fw-bold" style={{ color: "var(--text-main)" }}>
            {isApprove ? "Approve" : "Reject"} Faculty Account
          </h6>
        </div>

        <p className="small mb-3" style={{ color: "var(--text-muted)" }}>
          You are about to{" "}
          <strong style={{ color: isApprove ? "#10b981" : "#ef4444" }}>
            {isApprove ? "approve" : "reject"}
          </strong>{" "}
          the faculty account of <strong style={{ color: "var(--text-main)" }}>{fac.name}</strong>{" "}
          ({fac.email}).
        </p>

        <div className="mb-3">
          <label
            className="form-label small fw-semibold"
            style={{ color: "var(--text-muted)" }}
          >
            Reason / Note{" "}
            <span style={{ opacity: 0.6 }}>(optional)</span>
          </label>
          <textarea
            className="form-control"
            rows={3}
            placeholder={
              isApprove
                ? "e.g. Identity documents verified by placement cell."
                : "e.g. Incomplete employee ID or invalid email domain."
            }
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            style={{
              background: "var(--input-bg)",
              color: "var(--text-main)",
              border: "1px solid var(--border-color)",
              resize: "none",
            }}
          />
        </div>

        <div className="d-flex gap-2 justify-content-end">
          <button className="btn btn-sm btn-outline-secondary" onClick={onCancel}>
            Cancel
          </button>
          <button
            className={`btn btn-sm ${isApprove ? "btn-success" : "btn-danger"}`}
            onClick={() => onConfirm(reason)}
          >
            {isApprove ? "✓ Confirm Approve" : "✗ Confirm Reject"}
          </button>
        </div>
      </div>
    </div>
  );
}
