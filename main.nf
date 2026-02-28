#!/usr/bin/env nextflow

// This enables the modern Nextflow DSL2 syntax
nextflow.enable.dsl=2

// --- A. Define the processes for each simulation step ---

// Process 1: PDB to GROMACS format and topology generation
process PDB2GMX {
    tag "pdb2gmx for ${id}"
    publishDir "${params.outdir}/${id}/setup", mode: 'copy'

    input:
    tuple val(id), path(pdb_file)

    output:
    tuple val(id), path("${id}.gro"), path("${id}.top")

    script:
    """
    gmx pdb2gmx -f ${pdb_file} -o ${id}.gro -p ${id}.top -ignh
    """
}

// Process 2: Solvation and adding ions
process SOLVATE {
    tag "solvation for ${id}"
    publishDir "${params.outdir}/${id}/setup", mode: 'copy'

    input:
    tuple val(id), path(gro_file), path(top_file)

    output:
    tuple val(id), path("${id}_solvated.gro"), path("${id}.top")

    script:
    """
    gmx editconf -f ${gro_file} -o ${id}_box.gro -c -d 1.0 -bt cubic
    gmx solvate -cp ${id}_box.gro -cs spc216.gro -p ${top_file} -o ${id}_solvated.gro
    gmx grompp -f ${params.md_params_dir}/ions.mdp -c ${id}_solvated.gro -p ${top_file} -o ions.tpr -maxwarn 1
    echo "SOL" | gmx genion -s ions.tpr -o ${id}_ions.gro -p ${top_file} -pname NA -nname CL -neutral
    mv ${id}_ions.gro ${id}_solvated.gro
    """
}

// Process 3: Energy Minimization
process ENERGY_MINIMIZATION {
    tag "em for ${id}"
    publishDir "${params.outdir}/${id}/minimization", mode: 'copy'

    input:
    tuple val(id), path(gro_file), path(top_file)

    output:
    tuple val(id), path("em.gro"), path("em.tpr"), path("em.trr")

    script:
    """
    gmx grompp -f ${params.md_params_dir}/em.mdp -c ${gro_file} -p ${top_file} -o em.tpr -maxwarn 1
    gmx mdrun -v -deffnm em
    """
}

// Process 4: NVT and NPT Equilibration
process EQUILIBRATION {
    tag "equilibration for ${id}"
    publishDir "${params.outdir}/${id}/equilibration", mode: 'copy'

    input:
    tuple val(id), path(gro_file), path(top_file)

    output:
    tuple val(id), path("npt.gro"), path("npt.cpt")

    script:
    """
    gmx grompp -f ${params.md_params_dir}/nvt.mdp -c ${gro_file} -p ${top_file} -o nvt.tpr -maxwarn 1
    gmx mdrun -v -deffnm nvt
    gmx grompp -f ${params.md_params_dir}/npt.mdp -c nvt.gro -p ${top_file} -o npt.tpr -maxwarn 1
    gmx mdrun -v -deffnm npt
    """
}

// Process 5: Production Run
process PRODUCTION {
    tag "production for ${id}"
    publishDir "${params.outdir}/${id}/production", mode: 'copy'

    input:
    tuple val(id), path(gro_file), path(top_file), path(cpt_file)

    output:
    tuple val(id), path("md.xtc"), path("md.log")

    script:
    """
    gmx grompp -f ${params.md_params_dir}/md.mdp -c ${gro_file} -p ${top_file} -o md.tpr -t ${cpt_file} -maxwarn 1
    gmx mdrun -v -deffnm md
    """
}

// --- B. The main workflow that connects the processes ---

workflow {
    // 1. Read the input samplesheet and create a channel
    Channel
        .fromPath(params.input)
        .splitCsv(header:true)
        .map { row -> tuple(row.protein_id, file(row.pdb_file)) }
        .set { protein_ch }

    // 2. Connect the processes in a sequence
    pdb2gmx_out         = PDB2GMX(protein_ch)
    solvate_out         = SOLVATE(pdb2gmx_out.out)
    em_out              = ENERGY_MINIMIZATION(solvate_out.out)
    equilibration_out   = EQUILIBRATION(em_out.out)
    production_out      = PRODUCTION(equilibration_out.out)
}
