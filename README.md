# 🧬 Nextflow Pipeline for Protein Molecular Dynamics Simulation

> 🚀 A reproducible, containerized Molecular Dynamics (MD) workflow for **protein-only simulations** built using Nextflow DSL2 and GROMACS.

---

## 📌 Overview

This repository contains a fully automated **Protein Molecular Dynamics (MD) simulation pipeline** implemented using **Nextflow** DSL2.

The pipeline:

* Accepts one or multiple protein `.pdb` files
* Performs topology generation
* Solvates the protein system
* Adds ions for neutralization
* Runs energy minimization
* Performs NVT & NPT equilibration
* Executes production MD simulation
* Organizes outputs into structured directories
* Runs inside a containerized **GROMACS** environment

This workflow is suitable for:

* Protein stability studies
* Structural refinement
* MD-based conformational analysis
* Pre-docking structure relaxation
* HPC-based simulation scaling

---

# 🛠 Technologies Used

* **Nextflow** – Workflow orchestration
* **GROMACS** – Molecular dynamics engine
* **Docker** / Singularity – Containerization
* Linux execution environment
* DSL2 modular workflow design

---

# 📂 Repository Structure

```bash

├── main.nf                 # Nextflow DSL2 workflow
├── nextflow.config         # Configuration & resources
├── proteins.csv            # Input sample sheet
├── md_params/              # GROMACS parameter files
│   ├── em.mdp
│   ├── nvt.mdp
│   ├── npt.mdp
│   ├── md.mdp
│   └── ions.mdp
└── results/                # Auto-generated output
```

---

# 🔄 Workflow Architecture

```text
Protein Input (PDB)
        ↓
PDB2GMX (Topology Generation)
        ↓
Solvation & Ion Addition
        ↓
Energy Minimization
        ↓
NVT Equilibration
        ↓
NPT Equilibration
        ↓
Production MD Run
        ↓
Structured Output
```

---

# ⚙️ Pipeline Stages

## 1️⃣ PDB2GMX – Topology Generation

* Converts `.pdb` → `.gro`
* Generates topology file `.top`
* Applies selected force field
* Prepares protein for simulation

Command used:

```
gmx pdb2gmx
```

---

## 2️⃣ Solvation & Ion Addition

* Defines cubic simulation box
* Adds explicit water molecules (SPC216 model)
* Neutralizes system using Na⁺ / Cl⁻ ions
* Prepares solvated system

Commands:

```
gmx editconf
gmx solvate
gmx genion
```

---

## 3️⃣ Energy Minimization

* Removes steric clashes
* Optimizes geometry
* Generates minimized structure (`em.gro`)

Command:

```
gmx mdrun
```

---

## 4️⃣ Equilibration

### 🔹 NVT (Constant Volume & Temperature)

* Stabilizes temperature
* Equilibrates system thermally

### 🔹 NPT (Constant Pressure & Temperature)

* Stabilizes pressure
* Adjusts system density

Outputs:

* `npt.gro`
* `npt.cpt`

---

## 5️⃣ Production MD Simulation

* Performs full MD trajectory simulation
* Uses checkpoint restart capability
* Allocated higher CPU and memory resources

Outputs:

* `md.xtc` → Trajectory file
* `md.log` → Simulation log file

---

# 📊 Input Format

The pipeline reads a CSV file.

### Example: `proteins.csv`

```csv
protein_id,pdb_file
proteinA,inputs/proteinA.pdb
proteinB,inputs/proteinB.pdb
```

This enables:

* Multi-protein simulations
* Parallel execution
* Batch processing on HPC clusters

---

# 📁 Output Directory Structure

For each protein:

```bash
results/
├── proteinA/
│   ├── setup/
│   ├── minimization/
│   ├── equilibration/
│   └── production/
│
├── proteinB/
│   ├── setup/
│   ├── minimization/
│   ├── equilibration/
│   └── production/
```

Each stage stores simulation-specific files.

---

# 🐳 Containerized Execution

Configured in `nextflow.config`:

```
biocontainers/gromacs:2024.5
```

Supports:

* Local execution
* SLURM cluster
* Docker
* Singularity

Ensures reproducibility across systems.

---

# 🚀 How to Run

## 1️⃣ Install Nextflow

```bash
curl -s https://get.nextflow.io | bash
```

---

## 2️⃣ Run Pipeline

```bash
nextflow run main.nf
```

Optional:

```bash
nextflow run main.nf --input proteins.csv --outdir results
```

---

# ⚡ Resource Configuration

Defined in `nextflow.config`:

Production stage:

* 16 CPUs
* 32 GB RAM
* 24h walltime

Easily modifiable for HPC environments.

---

# 🔬 Applications

* Protein conformational analysis
* Structural stability assessment
* Pre-drug docking relaxation
* Comparative MD studies
* Protein dynamics research

---

# ✨ Key Features

✅ Modular DSL2 design
✅ Protein-only MD workflow
✅ Multi-sample processing
✅ Containerized reproducibility
✅ HPC-ready configuration
✅ Structured output organization

---

# 🧠 Skills Demonstrated

* Workflow automation using Nextflow DSL2
* Molecular dynamics simulation design
* GROMACS lifecycle management
* Container-based reproducible science
* HPC resource configuration
* Scalable computational biology pipelines

---

# 👩‍💻 Author

**Koka Nikhila Bhavani** | Bioinformatician

