/*Comment section: */

process sra_download {
  label 'ubuntu'
  maxForks 1
	publishDir "${params.output}/", mode: 'copy', pattern: "${name}/*.fastq.gz"
	input:
		tuple val(name), file(reads) 
	output:
		tuple val(name), file(reads) 
	script:
	"""
	mkdir ${name}
	cp ${reads} ${name}/
	"""
}