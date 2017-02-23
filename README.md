We appreciate you for installing and trying matlab-dataone provenance toolbox !

# Matlab DataONE Toolbox (version 2)


* **Author**:  Yang Cao, Christopher Jones, Peter Slaughter, Matthew B. Jones ([DataONE](http://dataone.org))
* **License**: [Apache 2](http://opensource.org/licenses/Apache-2.0)
* [Package source code on Github](https://github.com/DataONEorg/matlab-dataone/tree/ml-sqlite)
* [Submit Bugs and feature requests](https://github.com/DataONEorg/sem-prov-design/issues)


The `Matlab DataONE Toolbox` provides an automated way to capture data provenance for Matlab scripts and console commands without the need to modify existing Matlab code.  The provenance captured during a Matlab script execution includes information about the script that was run, files that were read or written, and details about the execution environment at the time of execution.  A package of the script iteself, its input files, and generated files that are associated with the run can be easily published to a repository within the DataONE network.

# Installation Notes


`Matlab R2015a` or later for Mac, Windows, or Linux is required to use the toolbox. To install the toolbox, 

1. Clone the ml-sqlite branch to your local computer by typing the follwing command at the command window
  
    `git clone -b ml-sqlite https://github.com/DataONEorg/matlab-dataone.git`
    
2. Open Matlab and change directories to local `matlab-dataone` directory
3. Run the `install_matlab_dataone` script (`install_matlab_dataone.m`) either from the command line or from Matlab
4. Restart Matlab
5. Notes that at least Java 7 or above is requried in order to use our matlab-dataone toolbox
6. `Matlab DataONE Toolbox ml-sqlite` branch: https://github.com/DataONEorg/matlab-dataone/tree/ml-sqlite


# License

The `Matlab DataONE Toolbox` is licensed as open source software under the [`Apache 2.0`_ license] ( http://opensource.org/licenses/Apache-2.0 )


# Example Usage

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
  
A [User Guide](https://github.com/DataONEorg/matlab-dataone/blob/master/docs/user-guide.rst) is in the works, and will walk through the various toolbox functions.


# Kown Issues

 * The toolbox captures provenance for only a subset of the load() function syntaxes. See [Issue #196](https://github.com/DataONEorg/sem-prov-design/issues/196)
 * The toolbox captures provenance for the save() function, but requires the filename to be the first argument. See [Issue #198](https://github.com/DataONEorg/sem-prov-design/issues/198)
 * Debugging log output for some function calls is not suppressed completely. See [Issue #200](https://github.com/DataONEorg/sem-prov-design/issues/200)


<img src="https://www.dataone.org/sites/default/files/d1-logo-v3_aligned_left_0_0.jpeg" align="left" height="240" width="240" hspace="50">
