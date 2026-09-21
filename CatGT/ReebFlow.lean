/-
  ReebFlow.lean  (2026-09-21)  --  UNTESTED: written without a Lean toolchain.
  Run it against a real kernel and fix against what the compiler says.

  PURPOSE. Close, in the same elementary style as ContactMorphism.lean, the items the V5
  paper currently marks [DERIVED] (by hand) about the Reeb field of
      alpha_cat = dz - r^2 dtheta        (coordinates (r, theta, z))
  namely:
    (a) the curve s |-> p + s*R is an integral curve of R = d/dz, and the map is a flow;
    (b) the flow preserves alpha:      phi_t^* alpha = alpha;
    (c) i_R d(alpha) = 0;
    (d) the flow preserves the contact volume alpha ^ d(alpha).

  MODEL. As in CatGT_Main.lean sec. 6 and ContactMorphism.lean, a 1-form is a function
  alphaCat p v of a basepoint p and a tangent vector v (both in R x R x R). No Mathlib
  manifold or differential-form typeclasses are used.
    * The tangent map of phi_t is Mathlib's actual `fderiv`, not an asserted identity.
    * d(alpha) is DEFINED by the invariant formula
          d(alpha)(u, w) = u(alpha(w)) - w(alpha(u)) - alpha([u, w])
      specialised to constant vector fields u, w in this chart, where [u, w] = 0; each
      derivative is a `deriv` along the straight line s |-> p + s*u. It is NOT typed in by
      hand, so the theorems below do not presuppose the value -2r dr ^ dtheta.
    * The wedge is (alpha ^ beta)(u,v,w) = alpha(u)beta(v,w) - alpha(v)beta(u,w) + alpha(w)beta(u,v).

  WHAT THIS DOES NOT COVER.
    * That "a volume-preserving flow has no attracting set" (a topological/measure fact).
    * Anything about DNLS dynamics, self-trapping, or confinement.
    * A proof that this elementary d(alpha) agrees with Mathlib's `extDeriv`; the constant-field
      formula is standard and is stated, not checked against that library.
    * `alphaCat` and `reebR` below are a verbatim copy of CatGT_Main.lean sec. 6 so this file is
      self-contained. If either changes there, this file must be re-synced by hand.
-/

import Mathlib

namespace ReebFlow

/-- Verbatim copy of `CatGT_Main.lean` sec. 6: alpha_(r,theta,z)(dr,dtheta,dz) = dz - r^2 dtheta. -/
def alphaCat (p : ℝ × ℝ × ℝ) (v : ℝ × ℝ × ℝ) : ℝ :=
  v.2.2 - p.1 ^ 2 * v.2.1

/-- Verbatim copy of `CatGT_Main.lean` sec. 6: R = d/dz. -/
def reebR : ℝ × ℝ × ℝ := (0, 0, 1)

theorem reeb_alpha_eq_one (p : ℝ × ℝ × ℝ) : alphaCat p reebR = 1 := by
  show (1 : ℝ) - p.1 ^ 2 * 0 = 1
  ring

/-! ## (a) The flow of R -/

/-- Time-t flow of R = d/dz: translation by t along reebR. -/
def reebFlow (t : ℝ) (p : ℝ × ℝ × ℝ) : ℝ × ℝ × ℝ := p + t • reebR

theorem reebFlow_zero (p : ℝ × ℝ × ℝ) : reebFlow 0 p = p := by
  simp [reebFlow]

theorem reebFlow_add (s t : ℝ) (p : ℝ × ℝ × ℝ) :
    reebFlow (s + t) p = reebFlow s (reebFlow t p) := by
  unfold reebFlow
  rw [add_smul]
  abel

/-- The orbit s |-> reebFlow s p has velocity reebR at every time: it is an integral curve of R. -/
theorem reebFlow_hasDerivAt (p : ℝ × ℝ × ℝ) (t : ℝ) :
    HasDerivAt (fun s : ℝ => reebFlow s p) reebR t := by
  have h := ((hasDerivAt_id t).smul_const reebR).const_add p
  simpa [reebFlow] using h

/-- The tangent map of the time-t flow is the identity (translations have identity derivative). -/
theorem reebFlow_fderiv (t : ℝ) (p : ℝ × ℝ × ℝ) :
    fderiv ℝ (reebFlow t) p = ContinuousLinearMap.id ℝ (ℝ × ℝ × ℝ) := by
  have h : HasFDerivAt (reebFlow t) (ContinuousLinearMap.id ℝ (ℝ × ℝ × ℝ)) p := by
    have h0 := (hasFDerivAt_id (𝕜 := ℝ) p).add_const (t • reebR)
    exact h0
  exact h.fderiv

/-! ## (b) The flow preserves alpha -/

/-- alpha does not see the z (or theta) coordinate of the basepoint. -/
theorem alphaCat_add_z (q : ℝ × ℝ × ℝ) (t : ℝ) (v : ℝ × ℝ × ℝ) :
    alphaCat (q + t • reebR) v = alphaCat q v := by
  simp [alphaCat, reebR]

theorem alphaCat_reebFlow (t : ℝ) (p v : ℝ × ℝ × ℝ) :
    alphaCat (reebFlow t p) v = alphaCat p v :=
  alphaCat_add_z p t v

/-- **The Reeb flow preserves alpha:** phi_t^* alpha = alpha, i.e.
    alpha_{phi_t p}(D phi_t . v) = alpha_p(v) for every t, basepoint and tangent vector,
    with D phi_t taken as the actual `fderiv`.
    NOTE: this alone does not single out R: d/dtheta is also a symmetry of alpha_cat. What ties it
    to the Reeb field is (a) above (the curve has velocity reebR), `reeb_alpha_eq_one`, and (c). -/
theorem reebFlow_preserves_alpha (t : ℝ) (p v : ℝ × ℝ × ℝ) :
    alphaCat (reebFlow t p) (fderiv ℝ (reebFlow t) p v) = alphaCat p v := by
  rw [reebFlow_fderiv, ContinuousLinearMap.id_apply]
  exact alphaCat_reebFlow t p v

/-! ## (c) i_R d(alpha) = 0, with d(alpha) derived from alpha -/

/-- d(alpha)_p(u, w) = u(alpha(w)) - w(alpha(u)) for constant fields u, w
    (the bracket term vanishes). Each derivative is along the line s |-> p + s * (field). -/
noncomputable def dAlpha (p u w : ℝ × ℝ × ℝ) : ℝ :=
  deriv (fun s : ℝ => alphaCat (p + s • u) w) 0 - deriv (fun s : ℝ => alphaCat (p + s • w) u) 0

/-- **i_R d(alpha) = 0.** -/
theorem reeb_interior_dAlpha (p w : ℝ × ℝ × ℝ) : dAlpha p reebR w = 0 := by
  have h1 : (fun s : ℝ => alphaCat (p + s • reebR) w) = fun _ => alphaCat p w := by
    funext s
    exact alphaCat_add_z p s w
  have h2 : (fun s : ℝ => alphaCat (p + s • w) reebR) = fun _ => (1 : ℝ) := by
    funext s
    exact reeb_alpha_eq_one _
  unfold dAlpha
  rw [h1, h2]
  simp

/-! ## (d) The flow preserves the contact volume alpha ^ d(alpha) -/

theorem dAlpha_reebFlow (t : ℝ) (p u w : ℝ × ℝ × ℝ) :
    dAlpha (reebFlow t p) u w = dAlpha p u w := by
  have key : ∀ a b : ℝ × ℝ × ℝ,
      (fun s : ℝ => alphaCat (reebFlow t p + s • a) b) = fun s : ℝ => alphaCat (p + s • a) b := by
    intro a b
    funext s
    have h : reebFlow t p + s • a = (p + s • a) + t • reebR := by
      unfold reebFlow
      abel
    rw [h]
    exact alphaCat_add_z _ t b
  unfold dAlpha
  rw [key u w, key w u]

/-- (alpha ^ d(alpha))_p(u, v, w) = alpha(u) d(alpha)(v,w) - alpha(v) d(alpha)(u,w) + alpha(w) d(alpha)(u,v). -/
noncomputable def contactVol (p u v w : ℝ × ℝ × ℝ) : ℝ :=
  alphaCat p u * dAlpha p v w - alphaCat p v * dAlpha p u w + alphaCat p w * dAlpha p u v

/-- **The Reeb flow preserves the contact volume form alpha ^ d(alpha)**, with the tangent map the
    actual `fderiv`. This is the statement behind "the flow is volume-preserving"; the further step
    "hence has no attracting set" is NOT formalised here. -/
theorem reebFlow_preserves_contactVol (t : ℝ) (p u v w : ℝ × ℝ × ℝ) :
    contactVol (reebFlow t p) (fderiv ℝ (reebFlow t) p u) (fderiv ℝ (reebFlow t) p v)
        (fderiv ℝ (reebFlow t) p w)
      = contactVol p u v w := by
  rw [reebFlow_fderiv]
  simp only [ContinuousLinearMap.id_apply, contactVol, dAlpha_reebFlow, alphaCat_reebFlow]

/-! ## Axiom report: each line should read [propext, Classical.choice, Quot.sound] or a subset. -/

#print axioms reebFlow_zero
#print axioms reebFlow_add
#print axioms reebFlow_hasDerivAt
#print axioms reebFlow_fderiv
#print axioms reebFlow_preserves_alpha
#print axioms reeb_interior_dAlpha
#print axioms dAlpha_reebFlow
#print axioms reebFlow_preserves_contactVol

end ReebFlow
