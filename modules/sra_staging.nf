/*Comment section: */

process sra_staging {
  label 'ubuntu'
  maxForks 1
	input:
		tuple val(accession), file(reads) 
	output:
		tuple val(accession), file(reads) 
	script:
	"""
	gzip -t ${reads}
	"""
}