"""Self-trapping in hard-walled DNLS cages at fixed norm (2026-09-24).

Energy H = J*sum_links |psi_i - psi_j|^2 - (lam/2)*sum |psi_i|^4, psi = 0 outside
the cage. Ground states by normalised gradient flow at fixed P = sum|psi|^2,
started from (a) the extended box ground state and (b) a single site. Reports
the IPR of each branch, their energies, and which is lower.
Results reported on the page (J = 1, P = 1):
  d=1, L=41: one branch, IPR rises continuously with lam (no threshold).
  d=2, L=31: localized branch exists for lam in (5.5, 6]; ground state for lam in (6.5, 7].
  d=3, L=9,11,13: localized branch exists for lam in (7.8, 8.0]; ground state
      between 10.0 and 12 (L=11: (10.0, 10.5]); localized IPR >= 0.64 (1-2 sites),
      identical for L = 9 and 13. No intermediate widths in d = 2, 3.
Usage: python3 cage_threshold_check.py
"""
import numpy as np

def lap(p):
    d = p.ndim; q = np.pad(p, 1); s = [slice(1, -1)] * d; out = -2 * d * p
    for ax in range(d):
        for sh in (0, 2):
            sl = list(s); sl[ax] = slice(sh, sh + p.shape[ax]); out = out + q[tuple(sl)]
    return out

def energy(p, J, lam):
    return -J * (p * lap(p)).sum() - lam / 2 * (p ** 4).sum()

def flow(p, J, lam, P, it):
    dt = 0.2 / (4 * p.ndim * J + lam * P)
    for _ in range(it):
        p = p + dt * (J * lap(p) + lam * p ** 3)
        p = np.abs(p); p *= np.sqrt(P / (p ** 2).sum())
    return p

def run(L, d, lams, J=1.0, P=1.0, it=8000):
    shape = (L,) * d; idx = np.indices(shape); c = L // 2
    ext = np.ones(shape)
    for k in range(d):
        ext = ext * np.sin(np.pi * (idx[k] + 1) / (L + 1))
    loc = np.zeros(shape); loc[(c,) * d] = 1.0
    print(f"\n== d={d}, L={L} ==   lam/J  IPR_ext  IPR_loc   E_ext    E_loc   ground")
    for lam in lams:
        a = flow(ext.copy(), J, lam, P, it); b = flow(loc.copy(), J, lam, P, it)
        Ea, Eb = energy(a, J, lam), energy(b, J, lam)
        g = "loc" if Eb < Ea - 1e-9 else "ext"
        print(f"  {lam:6}  {(a**4).sum():.4f}  {(b**4).sum():.4f}  {Ea:8.4f} {Eb:8.4f}   {g}")

if __name__ == "__main__":
    run(41, 1, [0.1, 0.25, 0.5, 1, 2, 4, 8])
    run(31, 2, [5, 5.5, 6, 6.5, 7, 8])
    for L in (9, 11, 13):
        run(L, 3, [7.8, 8.0, 9.0, 10.0, 10.5, 11.0, 12.0])
