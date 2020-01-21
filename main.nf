#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
Nextflow -- Analysis Pipeline
Author: someone@gmail.com
*/

/************************** 
* META & HELP MESSAGES 
**************************/

/* 
Comment section: First part is a terminal print for additional user information,
followed by some help statements (e.g. missing input) Second part is file
channel input. This allows via --list to alter the input of --nano & --illumina
to add csv instead. name,path   or name,pathR1,pathR2 in case of illumina 
*/

// terminal prints
if (params.help) { exit 0, helpMSG() }

println " "
println "\u001B[32mProfile: $workflow.profile\033[0m"
println " "
println "\033[2mCurrent User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "Starting time: $nextflow.timestamp"
println "Workdir location:"
println "  $workflow.workDir\u001B[0m"
println " "
if (workflow.profile == 'standard') {
println "\033[2mCPUs to use: $params.cores"
println "Output dir name: $params.output\u001B[0m"
println " "}

if (params.profile) { exit 1, "--profile is WRONG use -profile" }
if (params.SRA == '') { exit 1, "input missing, use [--SRA]" }

/************************** 
* INPUT CHANNELS 
**************************/

/* Comment section:
 SRA download approach
 step 1: reading sample accession id's and sample ID
 step 2: csv parsing via groovy syntax and feed accessions as list object into .fromSRA 
  */

// SRA input via csv
if (params.SRA ) { 
	sra_name_ch = Channel
	.fromPath( params.SRA, checkIfExists: true )
	.splitCsv()
	.map { row -> [row[1], row[0]] }

	def csvfile= new File(params.SRA);
	accessionnumbers = [];
	def lines = 0;
	csvfile.splitEachLine(',') {
	    def row = [];
	    row = it;
	    accessionnumbers << row[1];
	    lines++
	}
	println "Processing a csv file with $lines accession numbers"
 
  // this is currently using the API key from christian@nanozoo.org 
	sra_file_ch = Channel
	  .fromSRA(accessionnumbers, max: 4, apiKey:'66adfec576547c08451eadc56f9c98be4f09')

}

/************************** 
* MODULES
**************************/

include './modules/sra_download' params(output: params.output)
include './modules/sra_staging' params(output: params.output)

/************************** 
* SUB WORKFLOWS
**************************/

workflow download_sra_wf {
  get: 
    sra_name_ch
    sra_file_ch

  main:
    sra_staging(sra_file_ch)

    sra_channel = sra_name_ch.join(sra_staging.out)
	    .map { tuple(it[1], it[2]) } // reordering the channel to [sampleID, file]

    sra_download(sra_channel)
} 

/************************** 
* WORKFLOW ENTRY POINT
**************************/

workflow { download_sra_wf(sra_name_ch, sra_file_ch) }

/**************************  
* --help
**************************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    ____________________________________________________________________________________________
    
    Workflow: Download single or paired reads via csv file from SRA
    
    ${c_yellow}Usage example:${c_reset}
    nextflow run wf_template --SRA '*.csv' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --SRA ${c_reset}            '*.csv' or 'sample_list.csv' 
    ${c_dim}   csv style: 
       samplename1,accessionnumber1
       samplename2,accessionnumber2 ${c_reset}      

    ${c_yellow}Options:${c_reset}
    --cores             max cores for local use [default: $params.cores]
    --output            name of the result folder [default: $params.output]

    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    ${c_yellow}LSF computing:${c_reset}
    For execution of the workflow on a HPC with LSF adjust the following parameters:
    --databases         defines the path where databases are stored [default: $params.cloudDatabase]
    --workdir           defines the path where nextflow writes tmp files [default: $params.workdir]
    --cachedir          defines the path where images (singularity) are cached [default: $params.cachedir] 


    Profile:
    -profile                 standard (local, pure docker) [default]
                             conda (mixes conda and docker)
                             lsf (HPC w/ LSF, singularity/docker)
                             nanozoo (googlegenomics and docker)  
                             gcloudAdrian (googlegenomics and docker)
                             gcloudChris (googlegenomics and docker)
                             gcloudMartin (googlegenomics and docker)
                             ${c_reset}
    """.stripIndent()
}

  