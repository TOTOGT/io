"""1D DNLS ground-state width at fixed norm P = 1 (2026-09-23).

Normalised gradient flow on a 2001-site chain; width from IPR (sech profile:
IPR = a/(3w)). Page values: w = 3.94, 7.97, 31.99 at J/lam = 1, 2, 8 against
4J/(lam P) = 4, 8, 32; peak amplitude vs sqrt(lam/(8J)); single-site for
J/lam <= 0.25. Runs at J/lam = 16, 32 are not converged at this iteration count.
"""
import numpy as np

def ground(N, J, lam, P, w0, iters):
    x = np.arange(N) - N // 2
    psi = 1 / np.cosh(np.clip(x / w0, -700, 700)); psi *= np.sqrt(P / (psi ** 2).sum())
    dt = 0.2 / (4 * J + lam * P)
    for _ in range(iters):
        lap = np.roll(psi, 1) + np.roll(psi, -1) - 2 * psi
        psi = psi + dt * (J * lap + lam * psi ** 3); psi *= np.sqrt(P / (psi ** 2).sum())
    return psi

if __name__ == "__main__":
    print(" J/lam   w_IPR   4J/lam   peak A   sqrt(lam/8J)")
    for JL in [0.05, 0.1, 0.25, 0.5, 1, 2, 8]:
        psi = ground(2001, 1.0, 1 / JL, 1.0, max(1.0, 2 * JL), 40000)
        ipr = (psi ** 4).sum()
        print(f"{JL:6}  {1/(3*ipr):7.2f}  {4*JL:7.2f}   {psi.max():.4f}   {np.sqrt(1/(8*JL)):.4f}")
