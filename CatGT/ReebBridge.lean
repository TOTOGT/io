/-
  ReebBridge.lean  (2026-11-11)  --  built clean by the author under Lean v4.32.0
  (`lake build ReebFlow` in the geometry repo, 8659 jobs): both theorems depend on
  [propext, Classical.choice, Quot.sound]. NOT yet built under the v4.14.0 pin of the
  io repo. The header was edited after that build (comment only).

  PURPOSE. `CatGT_Main.lean` defines `reebOrbit r₀ θ₀ z₀ t := (r₀, θ₀, z₀ + t)` and
  `reeb_orbit_advances` shows its z-displacement equals t·α(R). It does not say that
  this curve has velocity R. `ReebFlow.lean` proves that for `ReebFlow.reebFlow`
  (`reebFlow_hasDerivAt`), but the two definitions live in different files and agree
  only by inspection. This file connects them.

  WHAT IS CLAIMED. Exactly two statements:
    (1) `reebOrbit_eq_reebFlow` : reebOrbit r₀ θ₀ z₀ t = ReebFlow.reebFlow t (r₀, θ₀, z₀)
    (2) `reebOrbit_hasDerivAt`  : the curve t ↦ reebOrbit r₀ θ₀ z₀ t has derivative
                                  `reebR` at every t, i.e. it is an integral curve of R.
  NOT CLAIMED. That `reebR` here and `ReebFlow.reebR` are the same object is `rfl`
  (both are (0,0,1)); it is not an independent fact. Nothing about uniqueness of
  integral curves, completeness of the flow, or contact volume (those are in
  ReebFlow.lean).
-/

import Mathlib
import CatGT.CatGT_Main
import CatGT.ReebFlow

/-- The Reeb orbit of `CatGT_Main.lean` is the time-t flow of `ReebFlow.lean`. -/
theorem reebOrbit_eq_reebFlow (r₀ θ₀ z₀ t : ℝ) :
    reebOrbit r₀ θ₀ z₀ t = ReebFlow.reebFlow t (r₀, θ₀, z₀) := by
  simp [reebOrbit, ReebFlow.reebFlow, ReebFlow.reebR]

/-- The orbit has velocity `reebR` at every time: it is an integral curve of R.
    Derived from `ReebFlow.reebFlow_hasDerivAt` through `reebOrbit_eq_reebFlow`. -/
theorem reebOrbit_hasDerivAt (r₀ θ₀ z₀ t : ℝ) :
    HasDerivAt (fun s : ℝ => reebOrbit r₀ θ₀ z₀ s) reebR t := by
  have hfun : (fun s : ℝ => reebOrbit r₀ θ₀ z₀ s)
      = fun s : ℝ => ReebFlow.reebFlow s (r₀, θ₀, z₀) :=
    funext fun s => reebOrbit_eq_reebFlow r₀ θ₀ z₀ s
  rw [hfun]
  exact ReebFlow.reebFlow_hasDerivAt (r₀, θ₀, z₀) t

#print axioms reebOrbit_eq_reebFlow
#print axioms reebOrbit_hasDerivAt
