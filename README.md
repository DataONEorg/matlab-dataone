Getting Started with the MATLAB DataONE Toolbox !

# Matlab DataONE Toolbox (version 2)

* **License**: [Apache 2](http://opensource.org/licenses/Apache-2.0)
* [Package source code on Github](https://github.com/DataONEorg/matlab-dataone/tree/ml-sqlite)
* [Submit Bugs and feature requests](https://github.com/DataONEorg/sem-prov-design/issues)

## Introduction

Provenance from scripts and runs of scripts plays an important role in software debugging, testing, reliability and sharing. Such provenance traces consist of events that the user is interested in. A considerable amount of research has been done on investigating methods of harvesting provenance information from scripts and runs of scripts, ranging from conventional approaches, e.g. research compendium (folder layouts) and logging to recent provenance tools, e.g., YesWorkflow (YW), noWorkflow (NW), RDataTracker, Reprozip.

The `Matlab DataONE Toolbox` is a provenance management software. It can capture, store, query, visualize, and publish of a singel Matlab script or multiple Matlab script runs. There are three types of provenance supported by `matlab-dataone`: **prospective provenance**, **retrospective provenance**, and **hybrid provenance**. The prospective provenance is expressed using YW tags. The retrospective provenance captured during a Matlab script execution includes information about the script that was run, files that were read or written, and details about the execution environment at the time of execution. 

DataONE RunManagers for R and MATLAB to capture runtime file-level provenance information that are interested by the earth science community. A DataONE package includes scripts, a list of input files, and a list of generated files, science metadata that are associated with the run. In addition, a DataONE datapackage can be efficiently archived so that these past versions of files can be retrieved for a run in order to investigate previous versions of processing or analysis, support reproducibility, and provide an easy way to publish data products and all files that contributed to those products to a data repository such as the DataONE network.

Then, we show how to produce hybrid provenance by joining prospective and retrospective provenance with the YW URI mechanism. Last but not least, we propose **multi-run provenance**. From the multi-run provenance, it enables a longitudinal view of a typical real-life scientific workflow that consists of multiple phases. Since computational and data science experiments can often last days, weeks, or even months and often require the execution of multiple scripts or workflows with varying input datasets and parameters, some of these script runs appear as chained together implicitly via intermediate data. Multiple_scripts_multi_runs provenance graphs can be joined on file path, file content, etc.

We use query-based approach for provenance analysis. A query is implemented in Prolog and SQL now. For a workflow project, we have multiple provenance graphs consisting of a graph of prospective provenance, a graph of hybrid provenance, a graph of retrospective multi-run provenance.


### Sample Provenance Query
Please read [Query README](https://github.com/idaks/dataone-ahm-2016-poster/blob/master/queries/README.md) in the demo repo.
 * C3C4 Matlab Script Provenance Query [Results](https://github.com/yesworkflow-org/yw-idcc-17/tree/master/examples/C3C4/results)
 * OHIBC R Scripts Provenance Query [Results](https://github.com/yesworkflow-org/yw-idcc-17/tree/master/OHIBC_Howe_Sound_project) 
 
 
## Installing the MATLAB-DataONE Toolbox 

`Matlab R2015a` or later for Mac, Windows, or Linux is required to use the toolbox. `SQlite` database is required to install. To install the toolbox, 

1. Clone the `ml-sqlite` branch to your local computer by typing the follwing command at the command window
  
    `git clone -b ml-sqlite https://github.com/DataONEorg/matlab-dataone.git`
    
2. Open Matlab and change directories to local `matlab-dataone` directory
3. Run the `install_matlab_dataone` script (`install_matlab_dataone.m`) either from the command line or from Matlab
4. Restart Matlab
5. Notes that at least Java 7 or above is requried in order to use our matlab-dataone toolbox


## RunManager Functions
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
  
  mgr.record('/full/path/to/script', 'example_run_tag_01');
  mgr.record('/full/path/to/script', 'example_run_tag_02');
  mgr.record('/full/path/to/script', 'example_run_tag_03');
  
  mgr.listRuns();
  mgr.viewRun('tag', 'example_run_tag_01', 'sections', {'details', 'used', 'generated'});
  mgr.viewRun('runNumber', 1, 'sections', {'details', 'used', 'generated'});  
  mgr.deleteRuns('tagList', {'example_run_tag_01'}, 'noop', false);
  mgr.deleteRuns('tagList', {'example_run_tag_02','example_run_tag_03'}, 'noop', false);

  mgr.exportFileRecords2Yaml('execution_id', 'prefix__string_in_uri_template', 'exported_file_name.yaml');
  mgr.exportR2PrologFacts('/path/to/factsdump');
  ```
  
## Layouts of Repository

| Directory | Description                                                          |
|-----------| :--------------------------------------------------------------------|
|docs/ |   Contains several versions user guide documentation. |
|lib/ | Stores Java libraries required by our matlab-dataone toolbox.|
|src/ | Stores the source code.|
|install_matlab_dataone.m | Installation script to install our matlab-dataone toolbox.|
|run_tests.m | A matlab script to run our test cases.|


## Documentation

The classes provided in the toolbox have built-in documentation.  You might use the help() function or the doc() function to view the help for a given class.  For instance, if you would like to view the help on the RunManager class, please use:

  ```matlab
  
  doc org.dataone.client.run.RunManager
  ```
  
A [user guide for matlab-dataone (version 1)](https://github.com/DataONEorg/matlab-dataone/blob/master/docs/user-guide.rst) might be a good resource that walk through the various toolbox functions.

## Installing Dependent (recommended) Software

Please visit our page on installing dependent (recommended) software [here](https://github.com/DataONEorg/matlab-dataone/blob/ml-sqlite/installing_recommended_software.md).

     
## Kown Issues

 * The toolbox captures provenance for only a subset of the load() function syntaxes. See [Issue #196](https://github.com/DataONEorg/sem-prov-design/issues/196)
 * The toolbox captures provenance for the save() function, but requires the filename to be the first argument. See [Issue #198](https://github.com/DataONEorg/sem-prov-design/issues/198)
 * Debugging log output for some function calls is not suppressed completely. See [Issue #200](https://github.com/DataONEorg/sem-prov-design/issues/200)


## License

The `Matlab DataONE Toolbox` is licensed as open source software under the [Apache 2.0_ license] ( http://opensource.org/licenses/Apache-2.0 )

<img src="https://www.dataone.org/sites/default/files/d1-logo-v3_aligned_left_0_0.jpeg" align="left">


