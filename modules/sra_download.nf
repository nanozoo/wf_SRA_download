/*Comment section: */

process sra_download {
  label 'ubuntu'
  publishDir "${params.output}/", mode: 'copy', pattern: "${name}/*.fastq.gz"
  maxForks 3
  //errorStrategy { task.exitStatus in 1 ? 'retry' : 'terminate' }
	input:
		tuple val(name), val(reads) 
	output:
		tuple val(name), file("${name}/*.fastq.gz") 
	script:
	"""
	wget ftp://ftp.sra.ebi.ac.uk${reads[0]} -T 20
	wget ftp://ftp.sra.ebi.ac.uk${reads[1]} -T 20

	gzip -t *.fastq.gz

	mkdir ${name}
	mv *.fastq.gz ${name}/
	"""
}

