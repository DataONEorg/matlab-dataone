We appreciate you for installing and trying matlab-dataone provenance toolbox !

# Matlab DataONE Toolbox (version 2)


* **Author**:  Yang Cao, Peter Slaughter, Christopher Jones, Matthew B. Jones ([DataONE](http://dataone.org))
* **License**: [Apache 2](http://opensource.org/licenses/Apache-2.0)
* [Package source code on Github](https://github.com/DataONEorg/matlab-dataone/tree/ml-sqlite)
* [Submit Bugs and feature requests](https://github.com/DataONEorg/sem-prov-design/issues)

# Introduction

Provenance from scripts and runs of scripts plays an important role in software debugging, testing, reliability and sharing. Such provenance traces consist of events that the user is interested in. A considerable amount of research has been done on investigating methods of harvesting provenance information from scripts and runs of scripts, ranging from conventional approaches, e.g. research compendium (folder layouts) and logging to recent provenance tools, e.g., YesWorkflow (YW), noWorkflow (NW), RDataTracker, Reprozip.

The `Matlab DataONE Toolbox` is a provenance management software. It can capture, store, query, and visualization of a Matlab script run. There are three types of provenance supported by `matlab-dataone`: **prospective provenance**, **retrospective provenance**, and **hybrid provenance**. The prospective provenance is expressed using YW tags. The retrospective provenance captured during a Matlab script execution includes information about the script that was run, files that were read or written, and details about the execution environment at the time of execution. 

DataONE RunManagers for R and MATLAB to capture runtime file-level provenance information that are interested by the earth science community. A DataONE package includes scripts, a list of input files, and a list of generated files, science metadata that are associated with the run that can be indexed within the DataONE network. 

Then, we show how to produce hybrid provenance by joining prospective and retrospective provenance with the YW URI mechanism. Last but not least, we propose **multi-run provenance**. From the multi-run provenance, it enables a longitudinal view of a typical real-life scientific workflow that consists of multiple phases. Since computational and data science experiments can often last days, weeks, or even months and often require the execution of multiple scripts or workflows with varying input datasets and parameters, some of these script runs appear as chained together implicitly via intermediate data.

We use query-based approach for provenance analysis. A query is implemented in Prolog and SQL now. For a workflow project, we have multiple provenance graphs consisting of a graph of prospective provenance, a graph of hybrid provenance, a graph of retrospective multi-run provenance.


# Installation Notes


`Matlab R2015a` or later for Mac, Windows, or Linux is required to use the toolbox. To install the toolbox, 

1. Clone the ml-sqlite branch to your local computer by typing the follwing command at the command window
  
    `git clone -b ml-sqlite https://github.com/DataONEorg/matlab-dataone.git`
    
2. Open Matlab and change directories to local `matlab-dataone` directory
3. Run the `install_matlab_dataone` script (`install_matlab_dataone.m`) either from the command line or from Matlab
4. Restart Matlab
5. Notes that at least Java 7 or above is requried in order to use our matlab-dataone toolbox
6. `Matlab DataONE Toolbox ml-sqlite` branch: https://github.com/DataONEorg/matlab-dataone/tree/ml-sqlite

# RunManager Functions
 * startRecord( )
 * endRecord( )
 * record( )
 * listRuns( )
 * viewRun( )
 * deleteRuns( )
 * publishRun( ) -- coming soon
 * exportFileRecords2Yaml( )
 * exportR2PrologFacts( )


## Example Usage

Thae Matlab DataONE package can be used to track code execution in Matlab, data inputs and outputs to those executions, and the software environment during the execution (e.g. Matlab and operating system versions).  As a quick start, here is an example that starts the toolbox `RunManager`, executes a precanned script, and then views the details of that script run.

  ```matlab
  import org.dataone.client.run.RunManager;
  mgr = RunManager.getInstance();
  mgr.configuration.capture_yesworkflow_comments=0;
  mgr.record('/full/path/to/matlab-dataone/src/test/resources/myScript4.m', 'csvread_test_01');
  mgr.listRuns();
  mgr.viewRun('tag', 'csvread_test_01', 'sections', {'details', 'used', 'generated'});
  mgr.viewRun('runNumber', 1, 'sections', {'details', 'used', 'generated'});  
  mgr.deleteRuns('tagList', {'csvread_test_01'}, 'noop', false);
  mgr.record('/full/path/to/matlab-dataone/src/test/resources/myScript4.m', 'csvread_test_01');
  mgr.record('/full/path/to/matlab-dataone/src/test/resources/myScript4.m', 'csvread_test_02');
  mgr.listRuns();
  mgr.deleteRuns('tagList', {'csvread_test_01','csvread_test_02'}, 'noop', false);

  mgr.exportFileRecords2Yaml('execution_id', 'prefix__string_in_uri_template', 'exported_file_name.yaml');
  mgr.exportR2PrologFacts('/path/to/factsdump');
  ```
  
# Layouts of Repository

| Directory | Description                                                          |
|-----------| :--------------------------------------------------------------------|
|docs/ |   Contains several versions user guide documentation. |
|lib/ | Stores Java libraries required by our matlab-dataone toolbox.|
|src/ | Stores the source code.|
|install_matlab_dataone.m | Installation script to install our matlab-dataone toolbox.|
|run_tests.m | A matlab script to run our test cases.|


# Documentation

The classes provided in the toolbox have built-in documentation.  Use the help() function or the doc() function to view the help for a given class.  For instance, to view the help on the RunManager class, use:

  ```matlab
  
  doc org.dataone.client.run.RunManager
  ```
  
A [Previous Version User Guide](https://github.com/DataONEorg/matlab-dataone/blob/master/docs/user-guide.rst) might be a good resource that walk through the various toolbox functions.


## Kown Issues

 * The toolbox captures provenance for only a subset of the load() function syntaxes. See [Issue #196](https://github.com/DataONEorg/sem-prov-design/issues/196)
 * The toolbox captures provenance for the save() function, but requires the filename to be the first argument. See [Issue #198](https://github.com/DataONEorg/sem-prov-design/issues/198)
 * Debugging log output for some function calls is not suppressed completely. See [Issue #200](https://github.com/DataONEorg/sem-prov-design/issues/200)


# License

The `Matlab DataONE Toolbox` is licensed as open source software under the [`Apache 2.0`_ license] ( http://opensource.org/licenses/Apache-2.0 )

<img src="https://www.dataone.org/sites/default/files/d1-logo-v3_aligned_left_0_0.jpeg" align="left">


