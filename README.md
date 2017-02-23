Getting Started with the MATLAB DataONE Toolbox !

# Matlab DataONE Toolbox (version 2)


* **Contact**:  Yang Cao, Peter Slaughter ([DataONE](http://dataone.org))
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

## Installing Dependent Software

The following free software are required in order to run  this demo.

  * **Java**: please install Java SE Development Kit 8 by navigating to http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html  to view JDK dowloads. Accept all default installation configuration. Please confirm if Java is available by typing the command below. If not, please locate the directory containing the JDK executables (`C:\Program Files\Java\jdk1.8.0_121\bin`) and add the direcoty containing the JDK executables to my Windows `path` variable. 
  
	   ```sh
	   C:\Users\my_home> java -version 
	   java version "1.8.0_121" 
	   Java(TM) SE Runtime Environment (build 1.8.0_121-b13) 
	   Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode) 
 
	   C:\Users\my_home>
       ``` 	 
  * **XSB**: a Logic Programming and Deductive Database system for Unix and Windows ([XSB homepage]
  (http://xsb.sourceforge.net)). The download and installation page for XSB is at [here] (http://xsb.sourceforge.net/downloads/downloads.html) or please navigate to the page https://sourceforge.net/projects/xsb/files/xsb/. The version 3.7 is the newest version. 
  
   * **Install XSB on Windows** Download the XSB executable `xsb-3.7.0.exe` for Windows platform. Run the downloaded installer file and accept all default configuration.
       This is the extra steps for Windows users. Please determine which directory contains the XSB executable that works for your computer: 
   
       ```sh
         C:\Program Files (x86)\XSB\config\x64-pc-windows\bin  
         C:\Program Files (x86)\XSB\config\x86-pc-windows\bin 
       ``` 

       Then, add the path to the XSB executable to my windows path variable `Control Panel -> System and Security -> System -> Advanced System Settings -> Environment Variables -> Path`. Typing `xsb` in a command console in order to confirm that XSB can run from the command prompt.   
 
        ```sh
	      C:\Users\my_home> xsb 
	      [xsb_configuration loaded] 
	      [sysinitrc loaded] 
	      [xsbbrat loaded] 
 
	      XSB Version 3.6. (Gazpatcho) of April 22, 2015 
	      [x64-pc-windows; mode: optimal; engine: slg-wam; scheduling: local] 
	      [Build date: 2015-04-22] 
 
	      | ?- halt. 
 
	      End XSB (cputime 0.05 secs, elapsetime 4.22 secs)
        ```

   * **Install XSB on Mac/Linux** Download the XSB tar package (version 3.7.0) from [here](https://sourceforge.net/projects/xsb/files/xsb/3.7%20%28Clan%20MacGregor%29/XSB.tar.gz/download). Then, Unpack the tarball in some directory. This should create a subdirectory, called `XSB`, which contains the XSB sources. In the terminal, type
   
       ```sh
  	     cd XSB/build
  	     ./configure
  	     ./makexsb
	   ```
  
     Next, you might add the path to the XSB executable to the `PATH` variable. For example, in a ~/.bashrc file, add this line:
	 
	    ```sh
	    export PATH="/path/to/xsb-3.7/bin:$PATH"
	    ```

* **Graphviz**: a Graph Visuzlization Software for Unix and Windows.  It is available at [Graphviz homepage](http://www.graphviz.org). The download and installation page for Graphviz is at  [here](http://www.graphviz.org/Download.php). For Windows platform, please download `graphviz-2.38.msi` installer package and start the installer file. You might accept all default configurations. Please confirm if the `dot` command is available by typing the command below. If not, then first determined directory containing dot.exe binary (`C:\Program Files (x86)\Graphviz2.38\bin`) and added the directory containing the dot executable to my Windows PATH variable.
 
    ```sh
     C:\Users\my_home> dot
       'dot' is not recognized as an internal or external command,
        operable program or batch file. 
    ```
 
* **Install Git for Windows**: please download `Git` for Windows from https://git-for-windows.github.io/. Run the downloaded `Git-2.11.1-64-bit.exe` and accept default configuration. Then, finish installation. Please check the `git` command in the command shell by typing `git --version`. Next, you might add the `path to bash executable` included with "Git for Windows" (`C:\Program Files\Git\bin`) to my Windows `path` variable so that the bash script can run on the command prompt directly.
  
    ```sh
      C:\Users\my_home> git --version 
      git version 2.11.1.windows.1
    ```	   
	
   
* **Installing Git for Mac** 
   
  * The easiest is to use the graphical Git installer, which you can download from the [SourceForge page](http://sourceforge.net/projects/git-osx-installer/)
   
  * If you have `MacPorts` installed, install Git via
   ```sh
   $ sudo port install git
   ```
  * If you have `Homebrew` installed, install Git via
   ```sh
   $ brew install git
   ```
   
* **Installing Git for Linux** If you want to install Git on Linux via a binary installer, you can generally do so through the basic package-management tool that comes with your distribution. If you’re on Fedora, you can use `yum`:
  
  ```sh
    $ yum install git
  ```
  
  Or if you’re on a Debian-based distribution like Ubuntu, try apt-get:
  ```
   $ apt-get install git
  ```
  
  
* **SQLite**:  a high-reliability, embedded, zero-configuration, public-domain, SQL database engine.  It is availabe at [SQLite homepage](https://www.sqlite.org). 
     
     
## Kown Issues

 * The toolbox captures provenance for only a subset of the load() function syntaxes. See [Issue #196](https://github.com/DataONEorg/sem-prov-design/issues/196)
 * The toolbox captures provenance for the save() function, but requires the filename to be the first argument. See [Issue #198](https://github.com/DataONEorg/sem-prov-design/issues/198)
 * Debugging log output for some function calls is not suppressed completely. See [Issue #200](https://github.com/DataONEorg/sem-prov-design/issues/200)


## License

The `Matlab DataONE Toolbox` is licensed as open source software under the [Apache 2.0_ license] ( http://opensource.org/licenses/Apache-2.0 )

<img src="https://www.dataone.org/sites/default/files/d1-logo-v3_aligned_left_0_0.jpeg" align="left">


