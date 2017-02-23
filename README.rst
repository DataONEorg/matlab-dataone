Matlab DataONE Toolbox (version 2)
=======================

- **Author**:  Yang Cao, Peter Slaughter (DataONE_)
- **License**: `Apache 2`_
- Package source code and results `see here`_

.. _`see here`: https://github.com/DataONEorg/matlab-dataone/tree/ml-sqlite

Matlab DataONE Toolbox (version 1)
======================

- **Author**:  Christopher Jones, Yang Cao, Peter Slaughter, Matthew B. Jones (DataONE_)
- **License**: `Apache 2`_
- `Package source code on Github`_
- `Submit Bugs and feature requests`_

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

The `Matlab DataONE Toolbox` is licensed as open source software under the `Apache 2.0`_ license.

.. _`Apache 2.0`: http://opensource.org/licenses/Apache-2.0

Example Usage
=============

Thae Matlab DataONE package can be used to track code execution in Matlab, data inputs and outputs to those executions, and the software environment during the execution (e.g. Matlab and operating system versions).  As a quick start, here is an example that starts the toolbox `RunManager`, executes a precanned script, and then views the details of that script run.

.. code:: matlab

  import org.dataone.client.run.RunManager;
  mgr = RunManager.getInstance();
  mgr.record('/Users/cjones/projects/intertidal_temps/process_temperatures.m', 'First toolbox run');
  mgr.listRuns();
  mgr.view('runNumber', 1);  

Documentation
============
The classes provided in the toolbox have built-in documentation.  Use the help() function or the doc() function to view the help for a given class.  For instance, to view the help on the RunManager class, use:

.. code:: matlab
  
  doc org.dataone.client.run.RunManager

A `User Guide`_ is in the works, and will walk through the various toolbox functions.

.. _`User Guide`: https://github.com/DataONEorg/matlab-dataone/blob/master/docs/user-guide.rst
Kown Issues
===========
- The toolbox captures provenance for only a subset of the load() function syntaxes. See `Issue #196`_
- The toolbox captures provenance for the save() function, but requires the filename to be the first argument. See `Issue #198`_
- Debugging log output for some function calls is not suppressed completely. See `Issue #200`_

.. _`Issue #196`: https://github.com/DataONEorg/sem-prov-design/issues/196
.. _`Issue #198`: https://github.com/DataONEorg/sem-prov-design/issues/198
.. _`Issue #200`: https://github.com/DataONEorg/sem-prov-design/issues/200

.. image:: https://www.dataone.org/sites/default/files/d1-logo-v3_aligned_left_0_0.jpeg
