# io — Formal Verification (CatGT / Principia Orthogona)

Machine-checked Lean 4 / Mathlib formalizations from the *Principia Orthogona*
series. Every Lean library in this repository is verified by the Lean kernel in
continuous integration on each push, with per-theorem axiom audits. There are no
`sorry` placeholders and no admitted lemmas in any shipped target.

## Verification status

| Library | Source | Theorems | `sorry` | Status |
|---|---|---:|---:|---|
| `CatGT` | `CatGT/CatGT_Main.lean` | 9 | 0 | Kernel-checked — Helical Selectivity Principle (Thm 1) and supporting lemmas |
| `Theorem53` | `PrincipiaOrthogona1/Theorem53NonCommutativity.lean` | 7 | 0 | Kernel-checked — Theorem 5.3, operator-chain non-commutativity |

Both libraries build against Lean `v4.14.0` / Mathlib `v4.14.0` (pinned in
`lean-toolchain` and `lakefile.toml`). The core theorems have additionally been
spot-checked against current Mathlib (Lean `v4.33`).

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
CatGT/CatGT_Main.lean                    CatGT core — HSP + lemmas (verified)
PrincipiaOrthogona1/Theorem53...lean     Theorem 5.3 non-commutativity (verified)
zeolite_operator_order/                  Zeolite operator-order paper (see note)
lakefile.toml, lean-toolchain            Build configuration
.github/workflows/verify-proofs.yml      CI: kernel check + #print axioms
index.html                               Rendered CatGT paper (GitHub Pages)
```

### Note on the zeolite operator-order work

The zeolite operator-order result (HZSM-5 vs. HMCM-22 selectivity from operator
firing order) is supported by the published algebraic derivations in
`zeolite_operator_order/ALGEBRAIC_PROOFS_ALL_7_THEOREMS.md` and the accompanying
paper. A complete Lean formalization of it is **future work** and is deliberately
**not** shipped here: earlier Lean drafts of it carried numerous open `sorry`s and
were removed on 2026-07-17 so that this repository's "kernel-checked" claim applies
without exception to every Lean file it builds.

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
