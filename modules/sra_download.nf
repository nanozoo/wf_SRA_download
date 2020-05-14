/*Comment section: */

process sra_download {
  label 'ubuntu'
  publishDir "${params.output}/", mode: 'copy', pattern: "${name}/*.fastq.gz"
  maxForks 3
  errorStrategy { task.exitStatus in 1 ? 'retry' : 'terminate' }
	input:
		tuple val(name), val(reads) 
	output:
		tuple val(name), file("${name}/*.fastq.gz") 
	script:
	"""
	for ID in ${reads} ${reads[0]} ${reads[1]}; do
		if [[ \${ID} == *".fastq.gz"* ]]; then wget ftp://ftp.sra.ebi.ac.uk\${ID} -T 20; fi
	done

	gzip -t *.fastq.gz

	mkdir ${name}
	mv *.fastq.gz ${name}/
	"""
}

