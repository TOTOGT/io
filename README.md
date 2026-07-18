# io — Formal Verification (CatGT / Principia Orthogona)

Machine-checked Lean 4 / Mathlib formalizations from the *Principia Orthogona*
series. There are no `sorry` placeholders and no admitted lemmas in any Lean file
shipped here. Two libraries are additionally re-verified by the Lean kernel in
continuous integration on every push, with per-theorem axiom audits; a third file
is standalone and verified by paste — the table says which is which.

## Verification status

| Library | Source | Theorems | `sorry` | CI-gated | Status |
|---|---|---:|---:|:---:|---|
| `CatGT` | `CatGT/CatGT_Main.lean` | 9 | 0 | yes | Kernel-checked — Helical Selectivity Principle (Thm 1) and supporting lemmas |
| `Theorem53` | `PrincipiaOrthogona1/Theorem53NonCommutativity.lean` | 7 | 0 | yes | Kernel-checked — Theorem 5.3, operator-chain non-commutativity |
| — | `zeolite_operator_order/ZeoliteCommutation.lean` | 3 | 0 | **no** | Kernel-checked by paste (Lean `v4.33.0-rc1`, 2026-07-18). Not in `lakefile.toml`; standalone and self-contained |

The two CI-gated libraries build against Lean `v4.14.0` / Mathlib `v4.14.0`
(pinned in `lean-toolchain` and `lakefile.toml`). Their core theorems have
additionally been spot-checked against current Mathlib (Lean `v4.33`).
`#print axioms` reports only `[propext, Classical.choice, Quot.sound]` for all
19 theorems — no `sorryAx` anywhere.

## Scope

`CatGT` (Catalytic Generative Theory) applies the operator pipeline
`G = U ∘ F ∘ K ∘ C` (compression, curvature, fold, unfold) to a contact-manifold
model of catalytic reaction pathways. The central result is the **Helical
Selectivity Principle** — a confinement bound `r ≤ r*(J, λ) = √(J/λ)` that
constrains which reaction pathways can reach the catalytic fixed point.

`Theorem53` establishes that the operator chain is **order-dependent in general**
(firing order changes the outcome) while proving this is *not* universal: specific
configurations provably commute. The statement is exactly existential, and both an
order-dependent instance and a commuting instance are exhibited on the same manifold.

## Repository structure

```
CatGT/CatGT_Main.lean                    CatGT core — HSP + lemmas (CI-verified)
PrincipiaOrthogona1/Theorem53...lean     Theorem 5.3 non-commutativity (CI-verified)
zeolite_operator_order/
  ZeoliteCommutation.lean                3 commutation theorems (verified, not in CI)
  OPERATOR_ORDER_DERIVATIONS_AND_STATUS.md   Derivations, per-claim status tags
  zeolite_operator_selectivity_v3.tex    Paper v3 — corrects v1–v2 Theorem 1
lakefile.toml, lean-toolchain            Build configuration
.github/workflows/verify-proofs.yml      CI: kernel check + #print axioms
index.html                               Rendered CatGT paper (GitHub Pages)
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
[10.5281/zenodo.21296707](https://doi.org/10.5281/zenodo.21296707)) asserted the
opposite — `[K,F] ≠ 0` for gate and pointwise fold, escaping via a boundary term
`∝ δ(r − r_ap)` that does not exist. That Theorem 1 was **false**; `v3`
(`zeolite_operator_selectivity_v3.tex`) restates it and re-tags every downstream
claim `[VERIFIED]` / `[MODEL]` / `[SIMULATION]` / `[OPEN]`. Derivations and
per-claim status: `zeolite_operator_order/OPERATOR_ORDER_DERIVATIONS_AND_STATUS.md`
(which replaces the withdrawn `ALGEBRAIC_PROOFS_ALL_7_THEOREMS.md`).

Earlier Lean drafts `CatGT_PROOFS_COMPLETE.lean` (17 `sorry`s) and `CatGT_v2.lean`
(25) were removed on 2026-07-17: they compiled only because `sorry` compiles.
A full Lean formalization of the selectivity result itself remains **future work** —
what is shipped is the commutation layer, not the physics.

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
Zenodo [10.5281/zenodo.19117399](https://doi.org/10.5281/zenodo.19117399) ·
Series: [github.com/TOTOGT/AXLE](https://github.com/TOTOGT/AXLE)

## License

Formalizations released under CC BY 4.0.
