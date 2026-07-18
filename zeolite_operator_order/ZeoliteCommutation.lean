import Mathlib

/-!
# Zeolite operator-order commutation facts (3-site ring, real amplitudes)

Companion to `OPERATOR_ORDER_DERIVATIONS_AND_STATUS.md` (§1–§2).
Standalone file — NOT wired into `lakefile.toml`; re-check by pasting into any
Lean 4 + Mathlib environment (e.g. live.lean-lang.org).

Kernel-verified 2026-07-18 on live.lean-lang.org (Lean v4.33.0-rc1, latest
Mathlib): all three theorems compile with 0 sorry, 0 errors, and
`#print axioms` shows only `[propext, Classical.choice, Quot.sound]` for each.

* `gate_commutes` — the 0/1 aperture gate commutes with the pointwise fold,
  for EVERY state. (This is what falsified v2's Theorem 1.)
* `coupling_not_commute` — the inter-site coupling does not commute with the
  on-site nonlinearity (commutator −6 at site 2 for ψ = (1,1,0)).
* `gate_fold_not_commute` — the gate does NOT commute with the corrected fold
  `F = coupling ∘ onsite` (witness ψ = (1,1,0), site 0: 1 ≠ 0). This closes
  open item 1 of the derivations doc: `[gate, F] ≠ 0` in existential form.
-/

def coupling (v : Fin 3 → ℝ) : Fin 3 → ℝ := ![v 1 + v 2, v 0 + v 2, v 0 + v 1]
def onsite   (v : Fin 3 → ℝ) : Fin 3 → ℝ := fun i => (v i) ^ 3
def gate     (v : Fin 3 → ℝ) : Fin 3 → ℝ := ![v 0, 0, v 2]
def psi      : Fin 3 → ℝ := ![1, 1, 0]

/-- §1.1: the aperture gate commutes with the pointwise fold, for every state. -/
theorem gate_commutes (v : Fin 3 → ℝ) : gate (onsite v) = onsite (gate v) := by
  funext i
  fin_cases i <;> simp [gate, onsite]

/-- §1.2: the inter-site coupling does not commute with the on-site fold. -/
theorem coupling_not_commute : coupling (onsite psi) ≠ onsite (coupling psi) := by
  intro h
  have h2 := congrFun h 2
  simp [coupling, onsite, psi] at h2
  norm_num at h2

/-- §2: the gate does NOT commute with the corrected fold `F = coupling ∘ onsite`. -/
theorem gate_fold_not_commute :
    gate (coupling (onsite psi)) ≠ coupling (onsite (gate psi)) := by
  intro h
  have h0 := congrFun h 0
  simp [gate, coupling, onsite, psi] at h0

#print axioms gate_commutes
#print axioms coupling_not_commute
#print axioms gate_fold_not_commute
