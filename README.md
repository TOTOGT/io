# io — Formal Verification (CatGT / Principia Orthogona)

Machine-checked Lean 4 / Mathlib formalizations from the *Principia Orthogona*
series. There are no `sorry` placeholders and no admitted lemmas in any Lean file
shipped here. Three targets are built by the Lean kernel in continuous integration
on every push (`CatGT`, `ContactMorphism`, `Theorem53`), the first and last with
per-theorem axiom audits; the other files are standalone and were verified by the
author by paste — the table says which is which.

## Verification status

| Library | Source | Theorems | `sorry` | CI-gated | Status |
|---|---|---:|---:|:---:|---|
| `CatGT` | `CatGT/CatGT_Main.lean` | 23 | 0 | yes | Kernel-checked — Self-Trapping Selectivity Principle (Thm 1), the Reeb pairing, the relaxation block, the r\* normalisation (§4b) and the sech relation derived from the continuum DNLS equation (§4c). Owner's runs 2026-09-24: 23/23 on Lean/Mathlib `v4.14.0` and `v4.32.0` (geometry mirror) |
| `ContactMorphism` | `CatGT/ContactMorphism.lean` | 1 | 0 | yes | Kernel-checked — dilation preserves the contact form. Added to `lakefile.toml` on 2026-09-20; before that it was in the repo but in no target, so CI never built it |
| `Theorem53` | `PrincipiaOrthogona1/Theorem53NonCommutativity.lean` | 7 | 0 | yes | Kernel-checked — Theorem 5.3, operator-chain non-commutativity |
| — | `CatGT/ReebFlowExtDeriv.lean` | 11 audited (13 written) | 0 | **no** | Kernel-checked by paste (Lean `v4.32.0` / Mathlib `v4.32.0`, 2026-09-21; 11 axiom lines on the standard three; linter warnings only, no errors). Proves the `d(alpha)` of `ReebFlow.lean` equals Mathlib's `extDeriv` of `alpha_cat` as a 1-form; `d(alpha) = -2r dr∧dθ`; `contactVol` on the coordinate frame = `-2r`. `alphaCat` / `dAlpha` / `contactVol` are verbatim copies from `ReebFlow.lean` (statement-level duplicates). The wedge is still an explicit formula, not a Mathlib wedge. Not in `lakefile.toml`; not run under `v4.14.0`; header still says UNTESTED (predates the run). |
| — | `CatGT/ReebNoAttractor.lean` | 9 audited (9 written) | 0 | **no** | Kernel-checked by paste (Lean `v4.32.0` / Mathlib `v4.32.0`, 2026-09-21; 9 axiom lines on the standard three; second revision of the file). Corrected no-attractor statement: `measure_le_of_attractor` (mu(U) <= mu(A) for measure-preserving maps, closed A with finite-measure thickening), Reeb flow as isometry and Lebesgue-measure-preserving translation, no proper closed invariant attractor, no compact invariant set, and `univ_attracts` (the unqualified claim is false). Model = (r,theta,z) chart; contact volume = const x Lebesgue by hand; no theorem instantiates Part B at `reebFlow`. Not run under v4.14.0. |
| — | `CatGT/ReebFlow.lean` | 8 audited (11 written) | 0 | **no** | Kernel-checked by paste (Lean `v4.32.0` / Mathlib `v4.32.0`, 2026-09-21; 8 axiom lines on the standard three, no warnings). Reeb flow of `alpha_cat` in an elementary coordinate model: flow law, `phi_t^*alpha = alpha`, `i_R d(alpha) = 0`, preservation of `alpha ^ d(alpha)`. `d(alpha)` is defined by the constant-field formula, not yet checked against Mathlib's `extDeriv` (`ReebFlowExtDeriv.lean`, written, not yet green). Not in `lakefile.toml`; not run under `v4.14.0`; the file header still says UNTESTED (predates the run). `alphaCat` / `reebR` are verbatim copies of `CatGT_Main.lean`. |
| — | `zeolite_operator_order/ZeoliteCommutation.lean` | 3 | 0 | **no** | Kernel-checked by paste (Lean `v4.33.0-rc1`, 2026-07-18). Not in `lakefile.toml`; standalone and self-contained |

The CI-gated targets build against Lean `v4.14.0` / Mathlib `v4.14.0`
(pinned in `lean-toolchain` and `lakefile.toml`); what CI reports on a given commit is
the record of that pin. The by-paste files were kernel-checked by the author under
Lean `v4.32.0` / Mathlib `v4.32.0` (the CatGT library and the three Reeb files) or
`v4.33.0-rc1` (`ZeoliteCommutation`), not under `v4.14.0`.
`#print axioms` is printed by CI for the 20 theorems of `CatGT` (13) and `Theorem53` (7); it reports only
`[propext, Classical.choice, Quot.sound]` — no `sorryAx` anywhere. `ContactMorphism` (1) is built by CI;
`ReebNoAttractor` (9 kernel-audited of 9 written) and `ReebFlowExtDeriv` (11 kernel-audited of 13 written) and `ReebFlow` (8 kernel-audited of 11 written; `reeb_alpha_eq_one` is a verbatim duplicate of the `CatGT_Main` theorem, so 10 unique statements) and `ZeoliteCommutation` (3) are counted above as kernel-checked by paste, not CI-gated.

## Scope

`CatGT` is the Lean side of the paper *The Self-Trapping Selectivity Principle:
Zeolite Shape-Selectivity and Pt–Sn Ensemble Effects* (V6, 2026-09-24, Zenodo
[10.5281/zenodo.22929142](https://doi.org/10.5281/zenodo.22929142); V5 is [10.5281/zenodo.22851704](https://doi.org/10.5281/zenodo.22851704)). The paper uses a
contact-manifold model of catalytic reaction pathways for coordinates, and names an
operator pipeline `G = U ∘ F ∘ K ∘ C` (compression, constraint, fold, stabilization).
The operators and any fixed point of `G` are labels: they are not defined as objects
on `L²` anywhere in the paper or in these files. The central result is the **Self-Trapping
Selectivity Principle** — renamed from "Helical Selectivity Principle" on
2026-09-19, because the Reeb orbits are straight lines rather than helices and a
Reeb flow, being volume-preserving, cannot attract anything. It is a confinement
bound `r ≤ r*`. Since V6 the adopted form is the fixed-norm width `r*_P = 4aJ/(λP)`
(`criticalRadiusNorm`; the DNLS conserves the norm `P`), and the earlier `a√(J/λ)`
(`criticalRadius`) is kept as the fixed-amplitude convention; `sech_stationary_forces`
derives the relation behind both from the continuum DNLS equation. The width law is
one-dimensional: in two- and three-dimensional cages simulation shows a threshold, not a
width (`scripts/cage_threshold_check.py`). The confinement is modelled on DNLS
self-trapping, not on the Reeb flow. The Reeb-flow
files (`ReebFlow`, `ReebFlowExtDeriv`, `ReebNoAttractor`) verify in an elementary
coordinate model that the flow is z-translation, preserves `α ∧ dα`, and admits no
closed attracting set of smaller measure than its basin.

`Theorem53` establishes that the operator chain is **order-dependent in general**
(firing order changes the outcome) while proving this is *not* universal: specific
configurations provably commute. The statement is exactly existential, and both an
order-dependent instance and a commuting instance are exhibited on the same manifold.

## Repository structure

```
CatGT/CatGT_Main.lean                    CatGT core — Thm 1 + lemmas (CI-verified)
CatGT/ContactMorphism.lean               dilation preserves α_cat (CI-built)
CatGT/ReebFlow.lean (+ .axioms.txt)      Reeb flow in a coordinate model (by paste, not CI)
CatGT/ReebFlowExtDeriv.lean (+ .axioms.txt)   dα equals Mathlib's extDeriv (by paste, not CI)
CatGT/ReebNoAttractor.lean (+ .axioms.txt)    no closed attractor of smaller measure (by paste, not CI)
PrincipiaOrthogona1/Theorem53...lean     Theorem 5.3 non-commutativity (CI-verified)
zeolite_operator_order/
  ZeoliteCommutation.lean                3 commutation theorems (verified, not in CI)
  OPERATOR_ORDER_DERIVATIONS_AND_STATUS.md   Derivations, per-claim status tags
  zeolite_operator_selectivity_v3.tex    Paper v3 — corrects v1–v2 Theorem 1
lakefile.toml, lean-toolchain            Build configuration
.github/workflows/verify-proofs.yml      CI: kernel check + #print axioms
index.html                               Rendered paper page (GitHub Pages)
```

### Note on the zeolite operator-order work

`ZeoliteCommutation.lean` establishes **where** operator order-dependence comes
from, and corrects a false claim in earlier versions of the accompanying paper:

- `gate_commutes` — a 0/1 aperture gate commutes with a *pointwise* fold
  **exactly**, for every state.
- `coupling_not_commute` — inter-site coupling does *not* commute with the on-site
  nonlinearity (commutator −6 on the worked example).
- `gate_fold_not_commute` — the gate does *not* commute with the corrected fold
  `F = coupling ∘ onsite`.

Together: **order-dependence is carried by whichever operator transports amplitude
between sites, never by a gate acting pointwise.**

Versions 1–2 of the paper (Zenodo
[20563363](https://doi.org/10.5281/zenodo.20563363), [21296707](https://doi.org/10.5281/zenodo.21296707)) asserted the
opposite — `[K,F] ≠ 0` for gate and pointwise fold, escaping via a boundary term
`∝ δ(r − r_ap)` that does not exist. That Theorem 1 was **false**; `v3`
(`zeolite_operator_selectivity_v3.tex`) restates it and re-tags every downstream
claim `[VERIFIED]` / `[MODEL]` / `[SIMULATION]` / `[OPEN]`. Derivations and
per-claim status: `zeolite_operator_order/OPERATOR_ORDER_DERIVATIONS_AND_STATUS.md`
(which replaces the withdrawn `ALGEBRAIC_PROOFS_ALL_7_THEOREMS.md`).

Earlier Lean drafts `CatGT_PROOFS_COMPLETE.lean` (17 `sorry`s) and `CatGT_v2.lean`
(25) were removed on 2026-07-17: they compiled only because `sorry` compiles.
`CatGT_PROOFS_COMPLETE.fixed.lean` (a rewrite with only true statements) has not yet
been run. The quantitative comparison with the measured selectivities of Sousa et al.
(2014) is **open**; no such numbers are used or claimed anywhere here.

## Build and verify locally

```
lake exe cache get      # fetch prebuilt Mathlib
lake build CatGT Theorem53
```

CI runs the same build plus `#print axioms` on each theorem, so the axiom
dependencies (and the absence of `sorryAx`) are visible in every run's log:
`.github/workflows/verify-proofs.yml`.

## Author

Pablo Nogueira Grossi · G6 LLC, Newark NJ ·
ORCID [0009-0000-6496-2186](https://orcid.org/0009-0000-6496-2186) ·
Zenodo [10.5281/zenodo.22851704](https://doi.org/10.5281/zenodo.22851704) (V5 paper) · [10.5281/zenodo.22929142](https://doi.org/10.5281/zenodo.22929142) (V6) ·
[Google Scholar](https://scholar.google.com/citations?hl=en&user=LRR8YIAAAAAJ) ·
Series: [github.com/TOTOGT/AXLE](https://github.com/TOTOGT/AXLE)

## License

The V5 deposit (the paper, its page and the Lean files deposited with it: Zenodo
[10.5281/zenodo.22851704](https://doi.org/10.5281/zenodo.22851704)) is released under
**CC BY-NC-ND 4.0**. This is a new version of the same Zenodo record series as the
earlier operator-order versions (V1 [20563363](https://doi.org/10.5281/zenodo.20563363),
V2 [21296707](https://doi.org/10.5281/zenodo.21296707), V3 [21429016](https://doi.org/10.5281/zenodo.21429016),
V4 [22849726](https://doi.org/10.5281/zenodo.22849726)), which stay published under the licence they were
deposited with. `zeolite_operator_order/` keeps its own CC BY 4.0 statement.
