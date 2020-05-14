/*Comment section: */

process sra_download {
  	label 'ubuntu'
  	publishDir "${params.output}/", mode: 'copy', pattern: "${name}/*.fastq.gz"
  	maxForks 3

	// the error strategy distinguishes between paired-end (first attempt) and single-end (second attempt)
	errorStrategy 'retry'
	maxRetries 1

	input:
		tuple val(name), val(reads) 
	
	output:
		tuple val(name), file("${name}/*.fastq.gz") 
	
	script:
	if (task.attempt.toString() == '1')
	"""
	wget ftp://ftp.sra.ebi.ac.uk${reads[0]} -T 20
	wget ftp://ftp.sra.ebi.ac.uk${reads[1]} -T 20

	gzip -t *.fastq.gz

	mkdir ${name}
	mv *.fastq.gz ${name}/
	"""
	else if (task.attempt.toString() == '2')
	"""
	wget ftp://ftp.sra.ebi.ac.uk${reads} -T 20

	gzip -t *.fastq.gz

	mkdir ${name}
	mv *.fastq.gz ${name}/
	""" 
}

