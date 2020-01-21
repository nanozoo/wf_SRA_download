# Workflow SRA download

![](https://img.shields.io/badge/nextflow-19.10.0-brightgreen)
![](https://img.shields.io/badge/uses-docker-blue.svg)
![](https://img.shields.io/badge/by-nanozoo-ff006c.svg)



![](https://github.com/nanozoo/wf_SRA_download/workflows/Syntax_check/badge.svg)

Maintainer: Christian

Email: christian@nanozoo.org

# Automated Syntax check Setup
* First: for a new Workflow edit the badge in the Readme and replace `wf_template` with the new reponame
* Info: The file `.github/workflows/nextflow-test.yml` contains the script name e.g. `main.nf`, change this if you have another script name


# Installation

**One time installation only, to use private nextflow repos**

* create git access token [here](https://github.com/settings/tokens)
    * [x] **repo** <- click on this option
    * give it a name (e.g. nextflow) and **Generate token**
* do ``nano ~/.nextflow/scm`` and include

```java
providers {
    github {
        user = 'username'
        password = 'Personal API token'  } }
```

# Input examples

* **one** .csv file 

# Execution example

````
nextflow run main.nf 
````

# Flowchart
![chart](figures/chart.png)