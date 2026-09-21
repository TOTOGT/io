#!/usr/bin/env python3
"""
dm3_dnls_zeolite_simulation.py
Discrete Nonlinear Schrödinger (DNLS) family simulation of operator firing order
in ZSM-5 vs. MCM-22 zeolite pore systems.
NOTE (2026-09-21): DNLS = Discrete NLS. This script itself is a continuous-space split-step
Fourier solver with a pore potential and a damping term (gamma), not the lattice DNLS of the
V5 paper (Zenodo 10.5281/zenodo.22851704).

Author: Pablo Nogueira Grossi
License: CC-BY-4.0
Date: June 2026

This script simulates the evolution of an effective wavefunction ψ(r,t) 
representing an adsorbed ethanol molecule in ZSM-5 and MCM-22 pores.
The pore-shaped potential V_pore(r) encodes the geometric operators:
- C (Compression): initial wavepacket collapse
- K (Constraint): potential barrier at pore aperture
- F (Folding): nonlinear self-focusing (branching chemistry)
- U (Unfolding): final state determined by energy landscape
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from scipy.integrate import odeint
from scipy.fft import fft, ifft, fftfreq
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# PARAMETERS
# ============================================================================

# Spatial domain
r_min, r_max = 0.0, 10.0  # Angstroms
dr = 0.1
r = np.arange(r_min, r_max, dr)
N = len(r)

# Time domain
dt = 0.01  # femtoseconds
T_max = 1000  # fs
t = np.arange(0, T_max, dt)
n_steps = len(t)

# Physical parameters
lam = 1.0  # nonlinearity (self-interaction coupling)
gamma = 0.01  # dissipation rate
sigma_init = 0.5  # initial Gaussian width (Angstroms)
r0_init = 2.0  # initial position (Angstroms)

# ============================================================================
# POTENTIAL FUNCTIONS
# ============================================================================

def V_ZSM5(r):
    """
    ZSM-5 potential: tight 10-ring channel mouth at r=4.5 Å
    Constraint fires immediately (C→K→F→U ordering)
    """
    return np.where(r > 4.5, 10 * (r - 4.5)**2, 0.0)

def V_MCM22(r):
    """
    MCM-22 potential: open supercage until r=6.0 Å, then 10-ring barrier
    Folding fires before constraint (C→F→K→U ordering)
    """
    return np.where(r > 6.0, 10 * (r - 6.0)**2, 0.0)

# ============================================================================
# DNLS EVOLUTION (Split-Step Fourier Method)
# ============================================================================

def split_step_dnls(psi, V, dt, lam, gamma, r):
    """
    One time step of dissipative DNLS evolution.
    
    i ∂ψ/∂t = -∇²ψ + V(r)ψ - λ|ψ|²ψ - iγψ

    Sign convention fixed 2026-09-20 to match CatGT_Main.lean and the paper:
    the nonlinear term is -λ|ψ|²ψ (focusing / self-trapping). It was +λ|ψ|²ψ
    here, the defocusing branch, which spreads a packet faster than free
    dispersion and cannot self-trap at all.

    The previous docstring read "V(r)|ψ|²ψ", multiplying the potential by the
    density; that is neither what the code did nor a term in any DNLS.

    Split-step method: Fourier (kinetic) → real-space (potential+nonlinear) → Fourier
    """
    dr = r[1] - r[0]
    
    # Half-step kinetic energy (Fourier)
    k = 2 * np.pi * fftfreq(N, dr)
    psi_hat = fft(psi)
    psi_hat *= np.exp(-1j * k**2 * dt / 2)
    psi = ifft(psi_hat)
    
    # Full-step potential + nonlinear + dissipation (real space)
    # (`nonlin = np.abs(psi)**2 * psi` stood here, computed and never used.)
    psi *= np.exp(-1j * (V - lam * np.abs(psi)**2) * dt)
    psi *= np.exp(-gamma * dt)  # dissipation
    
    # Half-step kinetic energy (Fourier)
    psi_hat = fft(psi)
    psi_hat *= np.exp(-1j * k**2 * dt / 2)
    psi = ifft(psi_hat)
    
    return psi

def evolve_dnls(V_func, label):
    """
    Evolve DNLS equation for given potential (ZSM-5 or MCM-22).
    Returns solution trajectory and observables.
    """
    # Initial condition: Gaussian wavepacket
    psi = np.exp(-(r - r0_init)**2 / (2 * sigma_init**2))
    psi /= np.sqrt(np.sum(np.abs(psi)**2) * dr)  # normalize
    
    # Potential
    V = V_func(r)
    
    # Storage
    psi_t = np.zeros((n_steps, N), dtype=complex)
    mean_r = np.zeros(n_steps)
    var_r = np.zeros(n_steps)
    energy = np.zeros(n_steps)
    mode_spectrum = np.zeros((n_steps, N))
    
    # Evolution
    for i in range(n_steps):
        psi_t[i] = psi
        # Normalise before taking moments. Dissipation removes norm at
        # exp(-2γt) -- by t=1000 fs with γ=0.01 that is 2.06e-9 of the
        # initial norm, so the unnormalised moments used here previously
        # reported the decay of the norm, not the shape of the packet:
        # ⟨r⟩ came out as 5.9e-9 Å instead of 2.87 Å.
        dens = np.abs(psi)**2
        nrm = np.sum(dens) * dr
        dens = dens / nrm if nrm > 0 else dens
        mean_r[i] = np.sum(r * dens) * dr
        var_r[i] = np.sum((r - mean_r[i])**2 * dens) * dr
        
        # Mode spectrum (Fourier)
        psi_hat = fft(psi)
        mode_spectrum[i] = np.abs(psi_hat)**2
        
        # Total energy
        dpsi_dr = np.gradient(psi, dr)
        kinetic = np.sum(np.abs(dpsi_dr)**2) * dr
        potential = np.sum(V * np.abs(psi)**2) * dr
        interaction = -0.5 * lam * np.sum(np.abs(psi)**4) * dr  # focusing: H has -λ/2 ∫|ψ|⁴
        energy[i] = kinetic + potential + interaction
        
        # One time step
        psi = split_step_dnls(psi, V, dt, lam, gamma, r)
    
    return psi_t, mean_r, var_r, energy, mode_spectrum, V

# ============================================================================
# RUN SIMULATIONS
# ============================================================================

print("Simulating ZSM-5 (C→K→F→U, tight constraint)...")
psi_zsm5, mr_zsm5, vr_zsm5, e_zsm5, spec_zsm5, V_zsm5 = evolve_dnls(V_ZSM5, "ZSM-5")

print("Simulating MCM-22 (C→F→K→U, open supercage)...")
psi_mcm22, mr_mcm22, vr_mcm22, e_mcm22, spec_mcm22, V_mcm22 = evolve_dnls(V_MCM22, "MCM-22")

# ============================================================================
# VISUALIZATION
# ============================================================================

fig = plt.figure(figsize=(16, 14))
gs = GridSpec(4, 2, figure=fig, hspace=0.35, wspace=0.3)

# ---- Panel 1: Pore Potentials ----
ax1 = fig.add_subplot(gs[0, 0])
ax1.plot(r, V_zsm5, 'b-', linewidth=2, label='ZSM-5 (tight at r=4.5 Å)')
ax1.plot(r, V_mcm22, 'r-', linewidth=2, label='MCM-22 (open to r=6.0 Å)')
ax1.axvline(r0_init, color='gray', linestyle='--', alpha=0.5, label='Initial position')
ax1.set_xlabel('Pore radius r (Å)', fontsize=10)
ax1.set_ylabel('Potential V(r)', fontsize=10)
ax1.set_title('Pore Potential Landscapes', fontsize=11, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# ---- Panel 2: Final Probability Distributions ----
ax2 = fig.add_subplot(gs[0, 1])
psi_final_zsm5 = psi_zsm5[-1]
psi_final_mcm22 = psi_mcm22[-1]
ax2.plot(r, np.abs(psi_final_zsm5)**2, 'b-', linewidth=2.5, label='ZSM-5 (compressed)', alpha=0.8)
ax2.plot(r, np.abs(psi_final_mcm22)**2, 'r-', linewidth=2.5, label='MCM-22 (branched)', alpha=0.8)
ax2.fill_between(r, np.abs(psi_final_zsm5)**2, alpha=0.2, color='blue')
ax2.fill_between(r, np.abs(psi_final_mcm22)**2, alpha=0.2, color='red')
ax2.set_xlabel('Pore radius r (Å)', fontsize=10)
ax2.set_ylabel('|ψ(r,T)|² (probability)', fontsize=10)
ax2.set_title('Final Probability Distributions (t=1000 fs)', fontsize=11, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ---- Panel 3: Mean Position Evolution ----
ax3 = fig.add_subplot(gs[1, 0])
ax3.plot(t, mr_zsm5, 'b-', linewidth=2, label='ZSM-5 ⟨r⟩(t)', alpha=0.8)
ax3.plot(t, mr_mcm22, 'r-', linewidth=2, label='MCM-22 ⟨r⟩(t)', alpha=0.8)
ax3.axhline(4.5, color='blue', linestyle=':', alpha=0.5, label='ZSM-5 barrier (4.5 Å)')
ax3.axhline(6.0, color='red', linestyle=':', alpha=0.5, label='MCM-22 barrier (6.0 Å)')
ax3.set_xlabel('Time t (fs)', fontsize=10)
ax3.set_ylabel('Mean position ⟨r⟩ (Å)', fontsize=10)
ax3.set_title('Operator Sequencing: Position vs. Time', fontsize=11, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# ---- Panel 4: Variance (Product Breadth) ----
ax4 = fig.add_subplot(gs[1, 1])
ax4.plot(t, vr_zsm5, 'b-', linewidth=2.5, label='ZSM-5 (narrow products)', alpha=0.8)
ax4.plot(t, vr_mcm22, 'r-', linewidth=2.5, label='MCM-22 (broad intermediates)', alpha=0.8)
ax4.fill_between(t, vr_zsm5, alpha=0.15, color='blue')
ax4.fill_between(t, vr_mcm22, alpha=0.15, color='red')
ax4.set_xlabel('Time t (fs)', fontsize=10)
ax4.set_ylabel('Spatial variance Δr² (Ų)', fontsize=10)
ax4.set_title('Product Distribution Breadth', fontsize=11, fontweight='bold')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

# ---- Panel 5: Energy Evolution ----
ax5 = fig.add_subplot(gs[2, 0])
ax5.semilogy(t, np.maximum(np.abs(e_zsm5), 1e-8), 'b-', linewidth=2, label='ZSM-5', alpha=0.8)
ax5.semilogy(t, np.maximum(np.abs(e_mcm22), 1e-8), 'r-', linewidth=2, label='MCM-22', alpha=0.8)
ax5.set_xlabel('Time t (fs)', fontsize=10)
ax5.set_ylabel('Total Energy (log scale)', fontsize=10)
ax5.set_title('Dissipative Energy Decay', fontsize=11, fontweight='bold')
ax5.legend(fontsize=9)
ax5.grid(True, alpha=0.3, which='both')

# ---- Panel 6: Mode Spectrum Heatmap (ZSM-5) ----
ax6 = fig.add_subplot(gs[2, 1])
k_plot = np.linspace(-3, 3, N)
im6 = ax6.imshow(np.log10(spec_zsm5.T + 1e-10), aspect='auto', origin='lower',
                  extent=[t[0], t[-1], k_plot[0], k_plot[-1]], cmap='viridis')
ax6.set_xlabel('Time t (fs)', fontsize=10)
ax6.set_ylabel('Wavenumber k (Å⁻¹)', fontsize=10)
ax6.set_title('Mode Spectrum Evolution: ZSM-5 (C→K→F→U)', fontsize=11, fontweight='bold')
cbar6 = plt.colorbar(im6, ax=ax6)
cbar6.set_label('|ψ̃(k,t)|² (log)', fontsize=9)

# ---- Panel 7: Mode Spectrum Heatmap (MCM-22) ----
ax7 = fig.add_subplot(gs[3, 0])
im7 = ax7.imshow(np.log10(spec_mcm22.T + 1e-10), aspect='auto', origin='lower',
                  extent=[t[0], t[-1], k_plot[0], k_plot[-1]], cmap='viridis')
ax7.set_xlabel('Time t (fs)', fontsize=10)
ax7.set_ylabel('Wavenumber k (Å⁻¹)', fontsize=10)
ax7.set_title('Mode Spectrum Evolution: MCM-22 (C→F→K→U)', fontsize=11, fontweight='bold')
cbar7 = plt.colorbar(im7, ax=ax7)
cbar7.set_label('|ψ̃(k,t)|² (log)', fontsize=9)

# ---- Panel 8: Operator Order Summary Table ----
ax8 = fig.add_subplot(gs[3, 1])
ax8.axis('off')

summary_text = f"""
OPERATOR FIRING ORDER COMPARISON

ZSM-5 (10-ring channels):
  C → K → F → U
  └─ Constraint fires FIRST
  └─ Prevents branching chemistry
  └─ Result: linear, small products
  └─ ⟨Δr²⟩ = {vr_zsm5[-1]:.2f} Ų (computed)

MCM-22 (12-ring supercage):
  C → F → K → U
  └─ Folding fires FIRST
  └─ Permits branching in cavity
  └─ Result: bulky, aromatic products
  └─ ⟨Δr²⟩ = {vr_mcm22[-1]:.2f} Ų (computed)

Key Prediction:
  Time-resolved DRIFTS contact-time
  sequence should reflect operator
  order: ethoxy → DEE (ZSM-5);
  ethoxy → ether → aromatics (MCM-22)

Falsification Criterion:
  If final variance distributions
  overlap (p > 0.05), hypothesis
  requires revision.

  As of 2026-09-20 this run puts
  ZSM-5 BROADER than MCM-22
  (ratio {vr_mcm22[-1]/vr_zsm5[-1]:.2f}x, not >1). The
  criterion above is met against
  the hypothesis. Unresolved.
"""

ax8.text(0.05, 0.95, summary_text, transform=ax8.transAxes, fontsize=9.5,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.3))

# Overall title
fig.suptitle('DNLS Simulation: Operator Firing Order in Zeolite Pores\n' +
             'Contact-Geometric Analysis of ZSM-5 vs. MCM-22 Selectivity',
             fontsize=13, fontweight='bold', y=0.995)

plt.savefig('/home/claude/dm3_zeolite_figures.png', dpi=300, bbox_inches='tight')
print("✓ Saved: dm3_zeolite_figures.png (300 dpi, publication quality)")

plt.savefig('/home/claude/dm3_zeolite_figures.pdf', dpi=300, bbox_inches='tight')
print("✓ Saved: dm3_zeolite_figures.pdf (for LaTeX embedding)")

plt.close()

# ============================================================================
# NUMERICAL SUMMARY
# ============================================================================

print("\n" + "="*70)
print("SIMULATION RESULTS SUMMARY")
print("="*70)

print(f"\nZSM-5 (C→K→F→U, tight constraint):")
print(f"  Final mean position ⟨r⟩: {mr_zsm5[-1]:.3f} Å (trapped by barrier at 4.5 Å)")
print(f"  Final variance Δr²: {vr_zsm5[-1]:.3f} Ų (narrow distribution)")
print(f"  Final energy: {e_zsm5[-1]:.6f} (damped)")
print(f"  Probability in supercage (r < 4.5 Å): {np.sum(np.abs(psi_final_zsm5[:45])**2) * dr:.3f}")

print(f"\nMCM-22 (C→F→K→U, open supercage):")
print(f"  Final mean position ⟨r⟩: {mr_mcm22[-1]:.3f} Å (branching before constraint)")
print(f"  Final variance Δr²: {vr_mcm22[-1]:.3f} Ų (broad distribution)")
print(f"  Final energy: {e_mcm22[-1]:.6f} (damped)")
print(f"  Probability in supercage (r < 6.0 Å): {np.sum(np.abs(psi_final_mcm22[:60])**2) * dr:.3f}")

print(f"\nOperator Order Effect:")
ratio = vr_mcm22[-1] / vr_zsm5[-1]
print(f"  Variance ratio (MCM-22 / ZSM-5): {ratio:.2f}x")
if ratio > 1:
    print(f"  Interpretation: MCM-22 allows {ratio:.1f}× broader product distribution")
    print(f"                  consistent with aromatic/branched intermediates")
else:
    print(f"  NOT the predicted direction: this run makes ZSM-5 the broader of")
    print(f"                  the two ({1/ratio:.2f}× ). The hypothesis predicts MCM-22")
    print(f"                  broader. Reported, not reconciled -- see the paper's")
    print(f"                  falsification criterion.")

# ============================================================================
# BREADTH OBSERVABLES -- three of them, chosen before looking
# ============================================================================
# The hypothesis says MCM-22 gives the BROADER product distribution. "Broader"
# has to be committed to before the numbers are read, so all three reasonable
# measures are computed and all three are reported, including the ones that
# disagree. Picking the one that agrees, after the fact, is the defect this
# repository exists to catch.
#
#   var       spatial variance of |psi|^2          -- what this script reported
#   1/IPR     inverse participation ratio in r     -- the observable
#                                                     CatGT_Main.lean defines
#                                                     and proves theorems about
#   n_modes   1/IPR of the normalised |psi_hat|^2  -- how many modes are
#                                                     occupied; the closest
#                                                     thing here to "branching"

def breadth(psi):
    d = np.abs(psi) ** 2
    dn = d / (np.sum(d) * dr)
    m = np.sum(r * dn) * dr
    var = np.sum((r - m) ** 2 * dn) * dr
    ipr_r = np.sum(dn ** 2) * dr
    ph = np.abs(fft(psi)) ** 2
    ph = ph / np.sum(ph)
    n_modes = 1.0 / np.sum(ph ** 2)
    return var, ipr_r, n_modes

b_zsm5 = breadth(psi_final_zsm5)
b_mcm22 = breadth(psi_final_mcm22)

print("\n" + "=" * 70)
print("BREADTH, BY THREE MEASURES")
print("=" * 70)
print("  %-22s %12s %12s" % ("", "ZSM-5", "MCM-22"))
print("  %-22s %12.4f %12.4f" % ("spatial variance", b_zsm5[0], b_mcm22[0]))
print("  %-22s %12.4f %12.4f" % ("delocalisation 1/IPR", 1 / b_zsm5[1], 1 / b_mcm22[1]))
print("  %-22s %12.2f %12.2f" % ("effective mode count", b_zsm5[2], b_mcm22[2]))

ratios = [("spatial variance", b_mcm22[0] / b_zsm5[0]),
          ("delocalisation 1/IPR", (1 / b_mcm22[1]) / (1 / b_zsm5[1])),
          ("effective mode count", b_mcm22[2] / b_zsm5[2])]
agree = [n for n, x in ratios if x > 1.0]
print("\n  MCM-22 / ZSM-5  (the hypothesis needs every one of these above 1)")
for n, x in ratios:
    print("    %-22s %6.2fx   %s" % (n, x, "agrees" if x > 1 else "CONTRADICTS"))
if len(agree) == len(ratios):
    print("\n  All three agree: MCM-22 is the broader by every measure tried.")
elif not agree:
    print("\n  None agree: the model puts ZSM-5 broader by every measure tried.")
else:
    print("\n  SPLIT: %d of %d agree (%s)." % (len(agree), len(ratios), ", ".join(agree)))
    print("  The direction of the prediction is not determined by this model --")
    print("  it depends on which breadth measure is chosen. Choosing the one")
    print("  that agrees is not a result. Either the observable is fixed in")
    print("  advance on physical grounds, or the model gains the degree of")
    print("  freedom that can actually branch. Open.")
print("=" * 70 + "\n")

print("\n" + "="*70)
print("Figure saved to dm3_zeolite_figures.{png,pdf}")
print("="*70 + "\n")
