Matlab DataONE Toolbox
======================

- **Author**:  Christopher Jones, Yang Cao, Peter Slaughter, Matthew B. Jones (DataONE_)
- **License**: `Apache 2`_
- `Package source code on Github`_
- `Submit Bugs and feature requests`_ (https://github.com/DataONEorg/sem-prov-design/issues)

.. _DataONE: http://dataone.org
.. _`Apache 2`: http://opensource.org/licenses/Apache-2.0
.. _`Package source code on Github`: https://github.com/DataONEorg/matlab-dataone
.. _`Submit Bugs and feature requests`: https://github.com/DataONEorg/sem-prov-design/issues

The *Matlab DataONE Toolbox* provides an automated way to capture data provenance for Matlab scripts and console commands without the need to modify existing Matlab code.  The provenance captured during a Matlab script execution includes information about the script that was run, files that were read or written, and details about the execution environment at the time of execution.  A package of the script iteself, its input files, and generated files that are associated with the run can be easily published to a repository within the DataONE network.

Installation Notes
==================

Matlab R2015b or later for Mac, Windows, or Linux is required to use the toolbox. To install the toolbox, 

1) Download the zip file: `Matlab DataONE Toolbox 1.0.0`_
2) Unpack the zip file into an installation  directory of your choosing
3) Open Matlab and change directories to your unpacked *matlab-dataone* directory
4) Run the *install_matlab_dataone* script in that directory
5) Restart Matlab

.. _`Matlab DataONE Toolbox 1.0.0`: https://github.com/DataONEorg/matlab-dataone/archive/master.zip

License
=======

The `Matlab DataONE Toolbox` is licensed as open source software under the Apache 2.0 license.

Example Usage
=============

Thae Matlab DataONE package can be used to track code execution in Matlab, data inputs and outputs to those executions, and the software environment during the execution (e.g. Matlab and operating system versions).  As a quick start, here is an example that starts the toolbox `RunManager`, executes a precanned script, and then views the details of that script run.

.. code:: matlab

  import org.dataone.client.run.RunManager;
  mgr = RunManager();
  mgr.record('/Users/cjones/projects/intertidal_temps/process_temperatures.m', 'First toolbox run');
  mgr.listRuns();
  mgr.viewRun(1);  
  
.. image:: https://www.dataone.org/sites/default/files/d1-logo-v3_aligned_left_0_0.jpeg