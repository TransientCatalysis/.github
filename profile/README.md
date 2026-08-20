# TransientCatalysis

**Transient kinetics, operando spectroscopy, and agentic AI for catalyst and reactor design.**

We use rapid perturbations of reactor inlet gas — pseudo-random binary sequences and periodic pulses — to collect information-rich transient kinetic and operando spectroscopic data, and we train digital twins on it that predict steady-state and chemical-looping reactor performance from minutes of transient data rather than days of steady-state experiments. The AI layer spans a graded palette from neural ODEs to reduced-order microkinetic models, coupled to machine-learned spectroscopic sensor models that map signals to catalytic state variables such as surface coverage and oxidation state.

The current focus is oxidative dehydrogenation of light alkanes over supported vanadium oxides, including chemical-looping operation.

---

## Who we are

| Institution | Investigators | Contribution |
|---|---|---|
| **Pennsylvania State University** (lead) | Michael J. Janik, Robert M. Rioux, James M. Hodges | PRBS reactor kinetics, transient IR, catalyst synthesis |
| **Brookhaven National Laboratory** | Anatoly I. Frenkel | Modulation-excitation fast-scan XAS |
| **Georgia Institute of Technology** | Andrew J. Medford | Agentic AI kinetic fitting and workflow integration |
| **ExxonMobil** | Randall J. Meyer | Industrial partner |

## Repositories

> **Everything here is 0.1.0 and under active design.** Interfaces are being agreed before real instrument data exists, which is the cheapest moment to argue about them. If something looks wrong, it probably is — please say so in an issue.

| Repository | What it is |
|---|---|
| **[`tcat-data-standard`](https://github.com/TransientCatalysis/tcat-data-standard)** | What counts as a valid dataset. Schema, validator, ingestion contract. Small, boring, changes slowly — three institutions depend on it. **Public.** |
| **`tcat-analysis`** | The integration layer: tool contract, content-addressed artifact store, sensor models, uncertainty-aware fitting, experiment design. Changes constantly. |
| **`tcat-index`** | Metadata-only registry of which artifacts exist and which sites hold copies. No bytes. |
| **`tcat-spoke-template`** | Template for a per-lab or per-campaign data repository. |

Analysis code depends on a pinned data-standard version. **Never the reverse** — if an analysis feature seems to need a schema change, that is evidence the schema is wrong, not that the boundary should move.

## Where to start

**Depositing data?** Create a repository from [`tcat-spoke-template`](https://github.com/TransientCatalysis/tcat-spoke-template) — one per lab or instrument campaign, not per dataset — and work through its `SPOKE-SETUP.md`. Then `pip install tcat-data-standard` and run `tcat-validate all .` until it is clean. Passing CI is the definition of ingestible.

**Writing analysis?** Read `tcat-analysis`'s `PROMOTION.md`. The spiking zone is unconstrained — fork, thrash, no review. Promotion into the hub is the single expensive gate.

**Reading from outside the project?** Start with [`STANDARD.md`](https://github.com/TransientCatalysis/tcat-data-standard/blob/main/STANDARD.md). It is the design document, and each rule says why it exists rather than only what it requires.

## Three ideas that shape everything here

**A raw signal and a derived quantity are different things.** A mass-spec ion current is not a concentration. The sensor model between them is a separate, versioned, content-addressed artifact, and every derived trace cites both its raw input and the calibration that produced it. So when someone finds an m/z 44 artifact eighteen months later, you swap one calibration id, re-derive every affected trace, and the store tells you exactly which downstream fits went stale.

**Flag, never delete.** Failed and flagged runs are retained with a stated reason. A deleted failed run cannot be counted in an exclusion table at publication time, and exclusion criteria with counts are a reporting requirement.

**Store the sample, not the summary.** Parameter uncertainty is stored as a sample, with a covariance matrix treated as a derived summary. Gaussian summaries discard exactly the correlation structure that drives experimental design — and frequentist fits emit an ensemble in the same shape a sampler would, so experiment design needs one pathway rather than two.

## Standards

Our data model is a **profile of** [TRACE-AI](https://github.com/trace-ai-org/trace-ai-checklist) (v2.2.0), not an invention alongside it — see [`profiles/trace-ai/`](https://github.com/TransientCatalysis/tcat-data-standard/tree/main/profiles/trace-ai) for the field-by-field crosswalk and what we deliberately do differently.

> Xin, H. *et al.* "Transparent reporting for agentic catalysis enabled by artificial intelligence: Community guidelines and a publication checklist." *Chem Catalysis* (2026). [10.1016/j.checat.2026.101755](https://doi.org/10.1016/j.checat.2026.101755)

Transient kinetics, stiff solvers, and model-based experiment design are genuinely underspecified upstream, which is written around steady-state screening and closed-loop synthesis. A transient-kinetics profile contributed back is a planned output of this work.

## Licensing

Research software **MIT**. Documentation, tutorials, and example workflows **CC-BY-4.0**. Public datasets **CC-BY-4.0**, or **CC0-1.0** where unrestricted reuse is preferred and permitted. Releases are archived to a DOI-minting service and reported to DOE OSTI.

## Acknowledgment

Supported by the U.S. Department of Energy **Genesis Mission**, DE-FOA-0003612 — *Transient Kinetics and Spectroscopy for Agentic Digital Twins to Upgrade Domestic Alkane Feedstocks into Value-Added Chemicals* (Phase I).
