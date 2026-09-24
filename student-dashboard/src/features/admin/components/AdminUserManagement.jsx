/**
 * SAIOTAF - Super Admin Module
 * AdminUserManagement.jsx (Feature 2: Universal User Management - Students & Faculty)
 */

import React, { useState, useEffect, useCallback } from "react";
import { adminApi } from "../api/adminApi";
import {
  Search,
  UserX,
  Key,
  Trash2,
  CheckCircle2,
  UserCheck,
  Shield,
  AlertTriangle,
  UserPlus,
  X,
  GraduationCap,
  Briefcase,
  Mail,
  Lock,
  User,
  Hash,
  Building2,
  Calendar,
} from "lucide-react";

const DEPARTMENTS = [
  "Computer Science & Engineering",
  "Information Technology",
  "Artificial Intelligence & Data Science",
  "Electronics & Telecommunication",
  "Mechanical Engineering",
  "Civil Engineering",
  "Electrical Engineering",
];

const FACULTY_ROLES = [
  { value: "MODERATOR", label: "Department Coordinator / Moderator" },
  { value: "PLACEMENT_OFFICER", label: "Placement Officer" },
  { value: "TPO_INCHARGE", label: "TPO In-charge" },
  { value: "DEPARTMENT_ADMIN", label: "Department Admin" },
];

export default function AdminUserManagement() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [roleFilter, setRoleFilter] = useState("ALL");
  const [search, setSearch] = useState("");
  const [actioningId, setActioningId] = useState(null);
  const [toastMessage, setToastMessage] = useState(null);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminApi.getUsers({
        role: roleFilter !== "ALL" ? roleFilter : undefined,
        search: search || undefined,
      });
      setUsers(data);
    } catch (err) {
      setError("Failed to load system user directory.");
    } finally {
      setLoading(false);
    }
  }, [roleFilter, search]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 4000);
  };

  // Direct User Add Success Handler
  const handleAddUserSuccess = (newUser, message) => {
    setUsers((prev) => [newUser, ...prev]);
    setIsAddModalOpen(false);
    showToast(message || `Successfully added ${newUser.role} "${newUser.name}". Account is active and verified.`);
    if (roleFilter !== "ALL" && roleFilter !== newUser.role.toUpperCase()) {
      setRoleFilter("ALL");
    }
  };

  // Dynamic Action 1: Suspend / Toggle Account
  const handleSuspendToggle = async (user) => {
    const isCurrentlySuspended = user.status === "Suspended";
    const newAction = isCurrentlySuspended ? "activate" : "suspend";
    const newStatus = isCurrentlySuspended ? "Active" : "Suspended";

    setActioningId(user.id);
    try {
      await adminApi.performUserAction(user.id, newAction);
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? { ...u, status: newStatus } : u))
      );
      showToast(`Account for ${user.name} has been ${newStatus.toLowerCase()}.`);
    } catch (err) {
      setError("Failed to update user status.");
    } finally {
      setActioningId(null);
    }
  };

  // Dynamic Action 2: Reset Password
  const handleResetPassword = async (user) => {
    const newPass = window.prompt(
      `Enter a new password for ${user.name} (${user.email}):`,
      "Password@123"
    );
    if (!newPass) return; // cancelled

    setActioningId(user.id);
    try {
      const res = await adminApi.performUserAction(user.id, "reset_password", { new_password: newPass });
      showToast(res.message || `Password for ${user.name} successfully reset to: ${newPass}`);
    } catch (err) {
      setError("Failed to reset password.");
    } finally {
      setActioningId(null);
    }
  };

  // Dynamic Action 3: Delete User
  const handleDeleteUser = async (user) => {
    if (!window.confirm(`Are you sure you want to permanently delete user "${user.name}" (${user.email})?`)) {
      return;
    }

    setActioningId(user.id);
    try {
      await adminApi.deleteUser(user.id);
      setUsers((prev) => prev.filter((u) => u.id !== user.id));
      showToast(`User ${user.name} permanently deleted.`);
    } catch (err) {
      setError("Failed to delete user.");
    } finally {
      setActioningId(null);
    }
  };

  // Filter visible records
  const filteredUsers = users.filter((u) => {
    if (roleFilter !== "ALL" && u.role.toUpperCase() !== roleFilter.toUpperCase()) {
      return false;
    }
    if (search) {
      const q = search.toLowerCase();
      const nameMatch = (u.name || "").toLowerCase().includes(q);
      const emailMatch = (u.email || "").toLowerCase().includes(q);
      const idMatch = (u.user_id || String(u.id)).toLowerCase().includes(q);
      if (!nameMatch && !emailMatch && !idMatch) return false;
    }
    return true;
  });

  return (
    <div className="admin-user-management animate-fade-in">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="alert alert-success d-flex align-items-center justify-content-between py-2 px-3 mb-3 shadow border-success" role="alert">
          <span className="d-flex align-items-center gap-2">
            <CheckCircle2 size={18} className="text-success" /> {toastMessage}
          </span>
          <button className="btn-close ms-3" onClick={() => setToastMessage(null)} />
        </div>
      )}

      {/* Header Controls */}
      <div className="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <div>
          <h4 className="fw-bold mb-0" style={{ color: "var(--text-main)" }}>Universal User Directory</h4>
          <p className="small mb-0" style={{ color: "var(--text-muted)" }}>Manage both Student & Faculty user accounts</p>
        </div>

        <div className="d-flex align-items-center gap-2 flex-wrap">
          {/* Direct Add User Button */}
          <button
            type="button"
            className="btn btn-primary btn-sm d-flex align-items-center gap-1.5 px-3 py-1.5 shadow-sm fw-semibold"
            style={{ borderRadius: "8px" }}
            onClick={() => setIsAddModalOpen(true)}
            id="admin-add-user-btn"
          >
            <UserPlus size={15} />
            <span>Add User</span>
          </button>

          {/* Search Input */}
          <div className="position-relative">
            <input
              type="search"
              className="form-control faculty-search-input ps-4"
              placeholder="Search name, enrollment, email..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{ width: 230, fontSize: "0.85rem" }}
            />
            <Search size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
          </div>

          {/* Role Toggle Tabs */}
          <div className="btn-group btn-group-sm" role="group" aria-label="Role Filter">
            <button
              type="button"
              className={`btn ${roleFilter === "ALL" ? "btn-primary" : "btn-outline-secondary"}`}
              onClick={() => setRoleFilter("ALL")}
            >
              All ({users.length})
            </button>
            <button
              type="button"
              className={`btn ${roleFilter === "STUDENT" ? "btn-primary" : "btn-outline-secondary"}`}
              onClick={() => setRoleFilter("STUDENT")}
            >
              Students
            </button>
            <button
              type="button"
              className={`btn ${roleFilter === "FACULTY" ? "btn-primary" : "btn-outline-secondary"}`}
              onClick={() => setRoleFilter("FACULTY")}
            >
              Faculty
            </button>
          </div>
        </div>
      </div>

      {error && <div className="alert alert-danger py-2 mb-3">{error}</div>}

      {/* Data Table */}
      <div className="faculty-table-container">
        <table className="table table-hover align-middle faculty-table mb-0" style={{ minWidth: "950px" }}>
          <thead>
            <tr>
              <th className="text-start ps-3 text-nowrap">Enrollment / Employee ID</th>
              <th className="text-start text-nowrap">Name</th>
              <th className="text-start text-nowrap">Email / Domain</th>
              <th className="text-center text-nowrap">Role</th>
              <th className="text-center text-nowrap">Department</th>
              <th className="text-center text-nowrap">Account Status</th>
              <th className="text-center pe-3 text-nowrap" style={{ minWidth: "280px" }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={7} className="text-center py-4 text-muted">
                  <div className="spinner-border spinner-border-sm me-2 text-primary" role="status" />
                  Loading user records…
                </td>
              </tr>
            )}

            {!loading && filteredUsers.length === 0 && (
              <tr>
                <td colSpan={7} className="text-center py-4 text-muted">
                  No matching user accounts found.
                </td>
              </tr>
            )}

            {!loading &&
              filteredUsers.map((u) => (
                <tr key={u.id}>
                  <td className="text-start ps-3 text-nowrap">
                    <code className="px-2 py-1 rounded text-info border" style={{ background: "var(--input-bg)", borderColor: "var(--border-color)", fontSize: "0.8rem" }}>
                      {u.enrollment_no || u.roll_number || u.user_id || `USR-${u.id}`}
                    </code>
                  </td>
                  <td className="text-start fw-semibold text-nowrap" style={{ color: "var(--text-main)" }}>
                    {u.name}
                  </td>
                  <td className="text-start small text-nowrap" style={{ color: "var(--text-muted)" }}>
                    {u.email}
                  </td>
                  <td className="text-center text-nowrap">
                    <span className="badge px-2.5 py-1" style={u.role === "Faculty" ? { background: "rgba(6, 182, 212, 0.15)", color: "#22d3ee", border: "1px solid rgba(6, 182, 212, 0.3)" } : { background: "rgba(99, 102, 241, 0.15)", color: "#818cf8", border: "1px solid rgba(99, 102, 241, 0.3)" }}>
                      {u.role}
                    </span>
                  </td>
                  <td className="text-center text-nowrap small" style={{ color: "var(--text-muted)" }}>
                    {u.department || "N/A"}
                  </td>
                  <td className="text-center text-nowrap">
                    <span className="badge px-2.5 py-1" style={u.status === "Active" ? { background: "rgba(16, 185, 129, 0.15)", color: "#34d399", border: "1px solid rgba(16, 185, 129, 0.3)" } : { background: "rgba(244, 63, 94, 0.15)", color: "#fb7185", border: "1px solid rgba(244, 63, 94, 0.3)" }}>
                      {u.status}
                    </span>
                  </td>
                  <td className="text-center pe-3 text-nowrap">
                    <div className="d-inline-flex gap-2">
                      {/* Action 1: Suspend / Activate Account */}
                      <button
                        className={`btn btn-sm ${u.status === "Suspended" ? "btn-outline-success" : "btn-outline-warning"} d-inline-flex align-items-center gap-1`}
                        style={{ fontSize: "0.75rem", whiteSpace: "nowrap" }}
                        disabled={actioningId === u.id}
                        onClick={() => handleSuspendToggle(u)}
                        title={u.status === "Suspended" ? "Activate Account" : "Suspend Account"}
                      >
                        {u.status === "Suspended" ? <UserCheck size={13} /> : <UserX size={13} />}
                        {u.status === "Suspended" ? "Activate" : "Suspend"}
                      </button>

                      {/* Action 2: Reset Password */}
                      <button
                        className="btn btn-sm btn-outline-info d-inline-flex align-items-center gap-1"
                        style={{ fontSize: "0.75rem", whiteSpace: "nowrap" }}
                        disabled={actioningId === u.id}
                        onClick={() => handleResetPassword(u)}
                        title="Reset Password"
                      >
                        <Key size={13} /> Reset Pass
                      </button>

                      {/* Action 3: Delete User */}
                      <button
                        className="btn btn-sm btn-outline-danger d-inline-flex align-items-center gap-1"
                        style={{ fontSize: "0.75rem", whiteSpace: "nowrap" }}
                        disabled={actioningId === u.id}
                        onClick={() => handleDeleteUser(u)}
                        title="Permanently Delete User"
                      >
                        <Trash2 size={13} /> Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>

      {/* Add User Modal */}
      <AddUserModal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        onSuccess={handleAddUserSuccess}
      />
    </div>
  );
}

/* ── Inline Add User Modal ─────────────────────────────────────────────────── */
function AddUserModal({ isOpen, onClose, onSuccess }) {
  const [userType, setUserType] = useState("Student"); // "Student" | "Faculty"
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("Password@123");
  const [department, setDepartment] = useState(DEPARTMENTS[0]);

  // Student specific
  const [rollNumber, setRollNumber] = useState("");
  const [graduationYear, setGraduationYear] = useState(2027);

  // Faculty specific
  const [employeeId, setEmployeeId] = useState("");
  const [facultyRole, setFacultyRole] = useState("MODERATOR");

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);

    const trimmedName = name.trim();
    const trimmedEmail = email.trim().toLowerCase();

    if (!trimmedName) {
      setError("Please provide the full name.");
      return;
    }
    if (!trimmedEmail || !trimmedEmail.includes("@")) {
      setError("Please provide a valid email address.");
      return;
    }

    setSubmitting(true);
    try {
      const payload = {
        user_type: userType,
        name: trimmedName,
        email: trimmedEmail,
        password: password.trim() || "Password@123",
        department,
        ...(userType === "Student"
          ? {
              roll_number: rollNumber.trim() || undefined,
              graduation_year: Number(graduationYear) || 2027,
            }
          : {
              employee_id: employeeId.trim() || undefined,
              faculty_role: facultyRole,
            }),
      };

      const res = await adminApi.createUser(payload);
      if (res.user) {
        onSuccess(res.user, res.message);
      } else {
        setError(res.error || "Failed to create user account.");
      }
    } catch (err) {
      const msg = err.response?.data?.error || err.message || "Failed to create user account.";
      setError(msg);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div
      className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
      style={{
        background: "rgba(0, 0, 0, 0.65)",
        backdropFilter: "blur(5px)",
        zIndex: 1060,
      }}
      onClick={onClose}
    >
      <div
        className="rounded-4 p-4 shadow-lg animate-fade-in"
        style={{
          background: "var(--bg-card)",
          border: "1px solid var(--border-color)",
          maxWidth: 540,
          width: "95%",
          maxHeight: "92vh",
          overflowY: "auto",
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="d-flex align-items-start justify-content-between mb-3">
          <div className="d-flex align-items-center gap-2">
            <div
              className="p-2 rounded-3 d-flex align-items-center justify-content-center"
              style={{ background: "rgba(99, 102, 241, 0.15)", color: "#818cf8" }}
            >
              <UserPlus size={20} />
            </div>
            <div>
              <h5 className="mb-0 fw-bold" style={{ color: "var(--text-main)" }}>
                Directly Add User
              </h5>
              <p className="small mb-0" style={{ color: "var(--text-muted)" }}>
                Directly create & verify a Student or Faculty account
              </p>
            </div>
          </div>
          <button
            type="button"
            className="btn btn-sm btn-icon border-0 p-1 text-muted"
            onClick={onClose}
            aria-label="Close modal"
          >
            <X size={18} />
          </button>
        </div>

        {/* Role Toggle Selector */}
        <div
          className="d-flex gap-2 p-1 rounded-3 mb-3"
          style={{ background: "var(--input-bg)", border: "1px solid var(--border-color)" }}
        >
          <button
            type="button"
            className={`btn btn-sm w-50 d-flex align-items-center justify-content-center gap-2 fw-semibold ${
              userType === "Student" ? "btn-primary shadow-sm" : "border-0 text-muted"
            }`}
            onClick={() => setUserType("Student")}
          >
            <GraduationCap size={16} />
            <span>Student</span>
          </button>
          <button
            type="button"
            className={`btn btn-sm w-50 d-flex align-items-center justify-content-center gap-2 fw-semibold ${
              userType === "Faculty" ? "btn-primary shadow-sm" : "border-0 text-muted"
            }`}
            onClick={() => setUserType("Faculty")}
          >
            <Briefcase size={16} />
            <span>Faculty</span>
          </button>
        </div>

        {/* Super Admin Direct Verification Badge */}
        <div
          className="p-2.5 rounded-3 mb-3 d-flex align-items-center gap-2 small"
          style={{
            background: "rgba(16, 185, 129, 0.1)",
            border: "1px solid rgba(16, 185, 129, 0.25)",
            color: "#34d399",
          }}
        >
          <CheckCircle2 size={16} className="flex-shrink-0" />
          <span>
            <strong>Direct Provisioning:</strong> Account will be immediately <strong>Active & Verified</strong> with instant portal access.
          </span>
        </div>

        {/* Error Alert */}
        {error && (
          <div className="alert alert-danger py-2 px-3 small mb-3 d-flex align-items-center gap-2">
            <AlertTriangle size={15} className="flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit}>
          {/* Full Name */}
          <div className="mb-3">
            <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
              Full Name <span className="text-danger">*</span>
            </label>
            <div className="position-relative">
              <input
                type="text"
                className="form-control ps-4"
                placeholder={userType === "Student" ? "e.g. Rahul Sharma" : "e.g. Dr. Priya Verma"}
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                style={{
                  background: "var(--input-bg)",
                  border: "1px solid var(--border-color)",
                  color: "var(--text-main)",
                  fontSize: "0.85rem",
                }}
              />
              <User size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
            </div>
          </div>

          {/* Email */}
          <div className="mb-3">
            <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
              Email Address <span className="text-danger">*</span>
            </label>
            <div className="position-relative">
              <input
                type="email"
                className="form-control ps-4"
                placeholder={userType === "Student" ? "e.g. rahul.sharma@raisoni.net" : "e.g. p.verma@raisoni.net"}
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                style={{
                  background: "var(--input-bg)",
                  border: "1px solid var(--border-color)",
                  color: "var(--text-main)",
                  fontSize: "0.85rem",
                }}
              />
              <Mail size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
            </div>
          </div>

          {/* Password */}
          <div className="mb-3">
            <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
              Initial Password
            </label>
            <div className="position-relative">
              <input
                type="text"
                className="form-control ps-4 font-monospace"
                placeholder="Password@123"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                style={{
                  background: "var(--input-bg)",
                  border: "1px solid var(--border-color)",
                  color: "var(--text-main)",
                  fontSize: "0.85rem",
                }}
              />
              <Lock size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
            </div>
            <div className="form-text small" style={{ fontSize: "0.75rem", color: "var(--text-muted)" }}>
              Default: <code>Password@123</code>. The user can change this after signing in.
            </div>
          </div>

          {/* Department */}
          <div className="mb-3">
            <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
              Department <span className="text-danger">*</span>
            </label>
            <div className="position-relative">
              <select
                className="form-select ps-4"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                style={{
                  background: "var(--input-bg)",
                  border: "1px solid var(--border-color)",
                  color: "var(--text-main)",
                  fontSize: "0.85rem",
                }}
              >
                {DEPARTMENTS.map((dept) => (
                  <option key={dept} value={dept}>
                    {dept}
                  </option>
                ))}
              </select>
              <Building2 size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
            </div>
          </div>

          {/* Student Specific Fields */}
          {userType === "Student" && (
            <div className="row g-2 mb-3">
              <div className="col-md-7">
                <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
                  Roll / Enrollment Number
                </label>
                <div className="position-relative">
                  <input
                    type="text"
                    className="form-control ps-4"
                    placeholder="e.g. 2026CS101 (optional)"
                    value={rollNumber}
                    onChange={(e) => setRollNumber(e.target.value)}
                    style={{
                      background: "var(--input-bg)",
                      border: "1px solid var(--border-color)",
                      color: "var(--text-main)",
                      fontSize: "0.85rem",
                    }}
                  />
                  <Hash size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
                </div>
              </div>
              <div className="col-md-5">
                <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
                  Graduation Year
                </label>
                <div className="position-relative">
                  <select
                    className="form-select ps-4"
                    value={graduationYear}
                    onChange={(e) => setGraduationYear(e.target.value)}
                    style={{
                      background: "var(--input-bg)",
                      border: "1px solid var(--border-color)",
                      color: "var(--text-main)",
                      fontSize: "0.85rem",
                    }}
                  >
                    {[2024, 2025, 2026, 2027, 2028, 2029].map((yr) => (
                      <option key={yr} value={yr}>
                        {yr}
                      </option>
                    ))}
                  </select>
                  <Calendar size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
                </div>
              </div>
            </div>
          )}

          {/* Faculty Specific Fields */}
          {userType === "Faculty" && (
            <div className="row g-2 mb-3">
              <div className="col-md-6">
                <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
                  Employee ID
                </label>
                <div className="position-relative">
                  <input
                    type="text"
                    className="form-control ps-4"
                    placeholder="e.g. FAC-210 (optional)"
                    value={employeeId}
                    onChange={(e) => setEmployeeId(e.target.value)}
                    style={{
                      background: "var(--input-bg)",
                      border: "1px solid var(--border-color)",
                      color: "var(--text-main)",
                      fontSize: "0.85rem",
                    }}
                  />
                  <Hash size={14} className="position-absolute text-muted" style={{ left: 10, top: 12 }} />
                </div>
              </div>
              <div className="col-md-6">
                <label className="form-label small fw-semibold mb-1" style={{ color: "var(--text-muted)" }}>
                  Faculty Role
                </label>
                <select
                  className="form-select"
                  value={facultyRole}
                  onChange={(e) => setFacultyRole(e.target.value)}
                  style={{
                    background: "var(--input-bg)",
                    border: "1px solid var(--border-color)",
                    color: "var(--text-main)",
                    fontSize: "0.85rem",
                  }}
                >
                  {FACULTY_ROLES.map((r) => (
                    <option key={r.value} value={r.value}>
                      {r.label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          )}

          {/* Action Buttons */}
          <div className="d-flex justify-content-end gap-2 pt-2 border-top" style={{ borderColor: "var(--border-color)" }}>
            <button
              type="button"
              className="btn btn-sm btn-outline-secondary px-3"
              onClick={onClose}
              disabled={submitting}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="btn btn-sm btn-primary px-4 d-inline-flex align-items-center gap-1.5"
              disabled={submitting}
            >
              {submitting ? (
                <>
                  <div className="spinner-border spinner-border-sm me-1" role="status" />
                  Creating Account...
                </>
              ) : (
                <>
                  <UserPlus size={15} />
                  <span>Create {userType}</span>
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

