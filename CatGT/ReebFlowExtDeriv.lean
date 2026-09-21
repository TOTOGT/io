/-
  ReebFlowExtDeriv.lean  (2026-09-21)  --  UNTESTED: written without a Lean toolchain.
  Run it against a real kernel and fix against what the compiler says.

  PURPOSE. Close the caveat left in ReebFlow.lean: there, d(alpha) is DEFINED by the constant-field
  formula `dAlpha`, and nothing checks it against Mathlib's exterior derivative. Here:

    (1) alpha_cat is packaged as a genuine Mathlib 1-form
            omega : E -> E [⋀^Fin 1]→L[ℝ] ℝ ,      E = ℝ × ℝ × ℝ ,
        with  omega p v = alphaCat p (v 0)  (proved),
    (2) Mathlib's `extDeriv omega p ![u, w]` is computed and equals
            -2 * p.1 * (u.1 * w.2.1 - w.1 * u.2.1)            (= -2 r dr∧dθ),
    (3) ReebFlow.dAlpha p u w equals it, so the value used by ReebFlow.lean is Mathlib's, not typed in,
    (4) contactVol on the coordinate frame (∂_r, ∂_θ, ∂_z) is -2 * p.1, i.e. α∧dα = -2 r dr∧dθ∧dz
        (the polar-chart expression quoted in the paper).

  Mathlib's convention (Analysis/Calculus/DifferentialForm/Basic.lean):
      extDeriv ω x v = ∑ i, (-1)^i • fderiv (fun y => ω y (removeNth i v)) x (v i)
  so for a 1-form  dω(u,w) = D(ω·w)(u) - D(ω·u)(w), the same normalisation as ReebFlow.dAlpha.

  NOT COVERED. The wedge product: `contactVol` is still the explicit formula
  alpha(u)dα(v,w) - alpha(v)dα(u,w) + alpha(w)dα(u,v); it is not compared with a Mathlib wedge.
  `alphaCat` and `dAlpha` below are verbatim copies from ReebFlow.lean (re-sync by hand if they change).
  Lemma names were looked up in the Mathlib copy under geometry/.lake/packages (extDeriv_apply,
  ContinuousAlternatingMap.ofSubsingleton_apply_apply, HasFDerivAt.pow, HasFDerivAt.mul_const, ...),
  but signatures have not been type-checked; `first | ... | ...` fallbacks are used where a lemma's
  exact output shape is the risk.
-/

import Mathlib

namespace ReebFlowExt

abbrev E3 : Type := ℝ × ℝ × ℝ

/-! ## Verbatim copies from ReebFlow.lean -/

def alphaCat (p : E3) (v : E3) : ℝ :=
  v.2.2 - p.1 ^ 2 * v.2.1

noncomputable def dAlpha (p u w : E3) : ℝ :=
  deriv (fun s : ℝ => alphaCat (p + s • u) w) 0 - deriv (fun s : ℝ => alphaCat (p + s • w) u) 0

noncomputable def contactVol (p u v w : E3) : ℝ :=
  alphaCat p u * dAlpha p v w - alphaCat p v * dAlpha p u w + alphaCat p w * dAlpha p u v

/-! ## (A) dAlpha in closed form -/

theorem deriv_line (p u w : E3) :
    deriv (fun s : ℝ => alphaCat (p + s • u) w) 0 = -(2 * p.1 * w.2.1 * u.1) := by
  have h1 : HasDerivAt (fun s : ℝ => p.1 + s * u.1) u.1 0 := by
    simpa using ((hasDerivAt_id (0 : ℝ)).mul_const u.1).const_add p.1
  have h4 := (hasDerivAt_const (0 : ℝ) w.2.2).sub ((h1.mul h1).mul_const w.2.1)
  have hfun : (fun s : ℝ => alphaCat (p + s • u) w)
      = fun s : ℝ => w.2.2 - ((p.1 + s * u.1) * (p.1 + s * u.1)) * w.2.1 := by
    funext s
    have e : (p + s • u).1 = p.1 + s * u.1 := by simp
    unfold alphaCat
    rw [e]
    ring
  have h : HasDerivAt (fun s : ℝ => alphaCat (p + s • u) w) (-(2 * p.1 * w.2.1 * u.1)) 0 := by
    rw [hfun]
    refine h4.congr_deriv ?_
    first
    | ring1
    | (beta_reduce; ring1)
    | (simp; ring1)
  exact h.deriv

theorem dAlpha_formula (p u w : E3) :
    dAlpha p u w = -2 * p.1 * (u.1 * w.2.1 - w.1 * u.2.1) := by
  unfold dAlpha
  rw [deriv_line, deriv_line]
  ring

/-! ## (B) alpha_cat as a Mathlib 1-form -/

/-- alpha at the basepoint p, as a continuous linear functional: v ↦ v.2.2 - p.1^2 * v.2.1. -/
noncomputable def alphaLin (p : E3) : E3 →L[ℝ] ℝ :=
  (ContinuousLinearMap.snd ℝ ℝ ℝ).comp (ContinuousLinearMap.snd ℝ ℝ (ℝ × ℝ))
    - (p.1 ^ 2) • ((ContinuousLinearMap.fst ℝ ℝ ℝ).comp (ContinuousLinearMap.snd ℝ ℝ (ℝ × ℝ)))

theorem alphaLin_apply (p v : E3) : alphaLin p v = alphaCat p v := by
  simp [alphaLin, alphaCat]

/-- The equivalence between continuous linear maps and continuous alternating 1-forms. -/
noncomputable def L1 : (E3 →L[ℝ] ℝ) ≃ₗᵢ[ℝ] ContinuousAlternatingMap ℝ E3 ℝ (Fin 1) :=
  ContinuousAlternatingMap.ofSubsingletonLIE (0 : Fin 1)

/-- alpha_cat as a Mathlib differential 1-form on E3. -/
noncomputable def omega (p : E3) : ContinuousAlternatingMap ℝ E3 ℝ (Fin 1) :=
  L1 (alphaLin p)

theorem omega_apply (p : E3) (v : Fin 1 → E3) : omega p v = alphaCat p (v 0) := by
  have h : omega p v = alphaLin p (v 0) := by
    first
    | rfl
    | simp [omega, L1, ContinuousAlternatingMap.ofSubsingletonLIE]
  rw [h, alphaLin_apply]

theorem alphaLin_differentiableAt (p : E3) : DifferentiableAt ℝ alphaLin p := by
  have h : DifferentiableAt ℝ
      (fun q : E3 =>
        (ContinuousLinearMap.snd ℝ ℝ ℝ).comp (ContinuousLinearMap.snd ℝ ℝ (ℝ × ℝ))
          - (q.1 ^ 2) • ((ContinuousLinearMap.fst ℝ ℝ ℝ).comp
              (ContinuousLinearMap.snd ℝ ℝ (ℝ × ℝ)))) p := by
    first
    | fun_prop
    | exact (differentiableAt_const _).sub ((differentiableAt_fst.pow 2).smul_const _)
  exact h

theorem omega_differentiableAt (p : E3) : DifferentiableAt ℝ omega p := by
  have hL : Differentiable ℝ L1 := by
    first
    | exact L1.toContinuousLinearEquiv.differentiable
    | exact (L1.toContinuousLinearEquiv : (E3 →L[ℝ] ℝ) →L[ℝ] _).differentiable
  exact hL.differentiableAt.comp p (alphaLin_differentiableAt p)

/-! ## (C) Mathlib's exterior derivative of omega -/

theorem hasFDerivAt_alphaCat (p w : E3) :
    HasFDerivAt (fun y : E3 => alphaCat y w)
      ((-(2 * p.1 * w.2.1)) • ContinuousLinearMap.fst ℝ ℝ (ℝ × ℝ)) p := by
  have hf := hasFDerivAt_fst (𝕜 := ℝ) (E := ℝ) (F := ℝ × ℝ) (p := p)
  have h4 := (hasFDerivAt_const w.2.2 p).sub ((hf.mul hf).mul_const w.2.1)
  have hfun : (fun y : E3 => alphaCat y w)
      = fun y : E3 => w.2.2 - (y.1 * y.1) * w.2.1 := by
    funext y
    unfold alphaCat
    ring
  rw [hfun]
  refine h4.congr_fderiv ?_
  refine ContinuousLinearMap.ext fun v => ?_
  first
  | (simp only [ContinuousLinearMap.sub_apply, ContinuousLinearMap.zero_apply,
      ContinuousLinearMap.smul_apply, ContinuousLinearMap.add_apply,
      ContinuousLinearMap.coe_fst', smul_eq_mul]
     ring1)
  | (simp only [ContinuousLinearMap.sub_apply, ContinuousLinearMap.zero_apply,
      ContinuousLinearMap.smul_apply, ContinuousLinearMap.add_apply, smul_eq_mul]
     show _ = _
     simp
     ring1)
  | (simp; ring1)
  | (beta_reduce; simp; ring1)

theorem fderiv_alphaCat_apply (p w u : E3) :
    fderiv ℝ (fun y : E3 => alphaCat y w) p u = -(2 * p.1 * w.2.1) * u.1 := by
  rw [(hasFDerivAt_alphaCat p w).fderiv]
  simp

theorem extDeriv_omega (p u w : E3) :
    extDeriv omega p ![u, w] = -2 * p.1 * (u.1 * w.2.1 - w.1 * u.2.1) := by
  have hv0 : (Fin.removeNth 0 ![u, w] : Fin 1 → E3) 0 = w := by
    first | rfl | simp [Fin.removeNth]
  have hv1 : (Fin.removeNth 1 ![u, w] : Fin 1 → E3) 0 = u := by
    first | rfl | simp [Fin.removeNth]
  have e0 : (fun y : E3 => omega y (Fin.removeNth 0 ![u, w])) = fun y => alphaCat y w := by
    funext y
    rw [omega_apply, hv0]
  have e1 : (fun y : E3 => omega y (Fin.removeNth 1 ![u, w])) = fun y => alphaCat y u := by
    funext y
    rw [omega_apply, hv1]
  rw [extDeriv_apply (omega_differentiableAt p), Fin.sum_univ_two]
  simp only [e0, e1]
  rw [fderiv_alphaCat_apply, fderiv_alphaCat_apply]
  first
  | (simp; ring1)
  | simp
  | (norm_num; ring1)

/-- **The d(alpha) used in ReebFlow.lean is Mathlib's exterior derivative of alpha_cat.** -/
theorem dAlpha_eq_extDeriv (p u w : E3) : dAlpha p u w = extDeriv omega p ![u, w] := by
  rw [dAlpha_formula, extDeriv_omega]

/-! ## (D) Consistency with the polar-chart expressions in the paper -/

/-- d(alpha)(∂_r, ∂_θ) = -2 r  (dα = -2 r dr∧dθ). -/
theorem dAlpha_dr_dtheta (p : E3) : dAlpha p (1, 0, 0) (0, 1, 0) = -2 * p.1 := by
  rw [dAlpha_formula]
  first
  | simp
  | (simp; ring)

/-- The Mathlib version of the same statement. -/
theorem extDeriv_omega_dr_dtheta (p : E3) :
    extDeriv omega p ![((1 : ℝ), (0 : ℝ), (0 : ℝ)), ((0 : ℝ), (1 : ℝ), (0 : ℝ))] = -2 * p.1 := by
  rw [← dAlpha_eq_extDeriv]
  exact dAlpha_dr_dtheta p

/-- (α ∧ dα)(∂_r, ∂_θ, ∂_z) = -2 r  (α∧dα = -2 r dr∧dθ∧dz in the polar chart). -/
theorem contactVol_frame (p : E3) :
    contactVol p (1, 0, 0) (0, 1, 0) (0, 0, 1) = -2 * p.1 := by
  unfold contactVol
  rw [dAlpha_formula, dAlpha_formula, dAlpha_formula]
  first
  | (simp [alphaCat]; ring1)
  | simp [alphaCat]

/-! ## Axiom report: each line should read [propext, Classical.choice, Quot.sound] or a subset. -/

#print axioms deriv_line
#print axioms dAlpha_formula
#print axioms alphaLin_apply
#print axioms omega_apply
#print axioms omega_differentiableAt
#print axioms hasFDerivAt_alphaCat
#print axioms extDeriv_omega
#print axioms dAlpha_eq_extDeriv
#print axioms dAlpha_dr_dtheta
#print axioms extDeriv_omega_dr_dtheta
#print axioms contactVol_frame

end ReebFlowExt
