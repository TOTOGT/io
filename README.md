# CatGT — Catalytic Generative Theory

_repo: `io` — imaginary origin_

Lean 4 / Mathlib4 formalization of the dm3 operator-chain framework applied to
heterogeneous catalysis, with zeolite selectivity as the worked instance.
Part of the [Principia Orthogona](https://github.com/TOTOGT/AXLE) series.

CatGT applies a general operator pipeline (compression, curvature, fold,
unfold) to a contact-manifold model of catalytic reaction pathways. The
central applied result is the **Helical Selectivity Principle**: a
confinement bound explaining why pore geometry constrains product
selectivity in zeolite catalysis (e.g. HZSM-5 vs. HMCM-22 divergent product
distributions). A companion result, Theorem 5.3, establishes that the
operator chain is order-dependent in general — firing order affects
outcome — while also proving this is not universal: some configurations
provably commute. The worked zeolite-selectivity instance (below) applies
the same operator chain concretely to HZSM-5/HMCM-22 firing order and is
where most of the open proof obligations currently live.

All results below are checked by the Lean 4 kernel, not hand-verified.

## Key results — CatGT core

| Theorem | Status | Description |
|---|---|---|
| `helical_selectivity` | closed · 0 sorry | Confinement bound `r ≤ r*(J, λ)` on the helical radius of a confined trajectory, given positive curvature and coupling parameters. Formal core of the Helical Selectivity Principle. |
| `thm_5_3_is_exactly_existential` | closed · 0 sorry | Precise statement of Theorem 5.3: an existential claim, not universal. Some valid operator instances are order-dependent; others provably commute. Both exhibited on the same manifold. |

## Key results — zeolite selectivity worked instance

Concrete application of the operator chain to HZSM-5 (C→K→F→U) vs. HMCM-22
(C→F→K→U) firing order, in
[`zeolite_operator_order/CatGT_PROOFS_COMPLETE.lean`](zeolite_operator_order/CatGT_PROOFS_COMPLETE.lean).
This file's own header and footer carry the full audit trail (why each open
theorem is open, and one real finding: the operators as literally encoded
here are pointwise, which makes `NonCommutativity` false as stated — the
physical model's actual coupling is the neighbor-coupled DNLS equation from
the companion paper, not what's formalized here yet).

| Theorem | Status | Description |
|---|---|---|
| `ZSM5_SupportsAromatics` | closed · 0 sorry | After C→K (ZSM-5's constraining operators), selectivity for the aromatic region is exactly 0. |
| `Prediction2_CokeSpatialSegregation` | closed · 0 sorry | Coke forms preferentially in the supercage over the sinusoidal channel by more than 2:1 (representative values). |
| `Selectivity_Bijection_With_OperatorOrder` | closed · 0 sorry | Operator firing order (ZSM-5 vs. MCM-22) maps injectively to two distinct selectivity values, 0 and 0.35. |
| `MainTheorem_OperatorOrderDeterminesSelectivity` | partially closed | ZSM-5 conjunct is closed (follows from the theorem above). MCM-22 conjunct inherits `MCM22_PermitsAromatics`'s two sorries. |
| `MCM22_PermitsAromatics` | open · 2 sorries | Numerical integral bounds standing in for DNLS simulation output (`S ≈ 0.35`). |
| `Prediction1_DRIFTS_Sequence` | open · 1 sorry | Depends on DNLS time-stepping simulation output not derived in-file. |
| `Prediction3_AcidSiteRelocation` | open · 1 sorry | Depends on an unformalized model of acid-site relocation effects. |
| `ContactMorphismScaling` | open · 3 sorries | 2 in the `ContactMorphism` helper (domain-boundedness / a `0 ≤ scale` side-condition), 1 in the theorem itself (needs a rigorous Sasaki-metric contact-geometry argument). |
| `NonCommutativity` | open · 1 sorry, **false as stated** | `ConstraintOp`/`FoldingOp` here are both pointwise, so K and F provably commute for these definitions — no witness exists. The real physical claim needs `FoldingOp` reformalized as a multi-site DNLS-coupled operator (see the file header for the full cross-check against the published paper). |

`CatGT_v2.lean` (also under `zeolite_operator_order/`) is an explicit
theorem-stub file — every body is `sorry` by design — wired into CI as a
non-gating, expected-to-fail sanity check, not a claimed result.

## Source

- [`CatGT/CatGT_Main.lean`](CatGT/CatGT_Main.lean) — core formalization, Helical Selectivity Principle
- [`PrincipiaOrthogona1/Theorem53NonCommutativity.lean`](PrincipiaOrthogona1/Theorem53NonCommutativity.lean) — Theorem 5.3
- [`zeolite_operator_order/CatGT_PROOFS_COMPLETE.lean`](zeolite_operator_order/CatGT_PROOFS_COMPLETE.lean) — zeolite selectivity worked instance (table above)
- [`zeolite_operator_order/CatGT_v2.lean`](zeolite_operator_order/CatGT_v2.lean) — explicit stub, non-gating
- [`PrincipiaOrthogona_7Proofs_Template.docx`](PrincipiaOrthogona_7Proofs_Template.docx) — proof template, reference

## Build

```
lake build CatGT Theorem53 ZeoliteProofs
```

CI (GitHub Actions, [`.github/workflows/verify-proofs.yml`](.github/workflows/verify-proofs.yml))
runs the real Lean kernel on every push and prints the axiom dependencies of
each theorem in `CatGT`, `Theorem53`, and `ZeoliteProofs` — this is how a
"closed · 0 sorry" claim above gets checked at the kernel level (a theorem
with no `sorry` in its own body can still inherit `sorryAx` transitively
from something it calls) rather than asserted by eye. `ZeoliteProofs` gates
on real, located Lean errors only; its documented sorries above are
accepted, not build failures.

## Author

Pablo Nogueira Grossi · G6 LLC
[github.com/TOTOGT](https://github.com/TOTOGT) ·
ORCID [0009-0000-6496-2186](https://orcid.org/0009-0000-6496-2186) ·
Zenodo DOI [10.5281/zenodo.19117399](https://doi.org/10.5281/zenodo.19117399)
