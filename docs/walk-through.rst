Matlab DataONE Toolbox Walk-through
===================================
To understand the Matlab DataONE Toolbox, we'll step through an example by first connecting to a remote matlab server, installing the toolbox, and using the functions and classes provided with a sample soil mapping script.  The goal of the toolbox is to help scientists manage runs of their scripts, and to track the history of each run in terms of its data inputs and outputs.

.. sectnum::
.. contents::
  :depth: 1


Using the remote Matlab server
------------------------------
To use Matlab on a remote server, we require that you install the X2Go_ client on your machine, configure the client, and connect to the remote server.

.. _X2Go: http:x2go.org


Install the x2go client
~~~~~~~~~~~~~~~~~~~~~~~
Visit the X2Go `download page`, and follow the instructions for your operating system.  Note that on Mac OS X, an X server is a pre-requisite, so you may need to install XQuartz_.

.. _XQuartz: http://xquartz.macosforge.org/landing/


Configure an X2Go session
~~~~~~~~~~~~~~~~~~~~~~~~~
Open the X2Go application and choose the  Session > New Session ... menu item.

.. image:: images/x2go-install/x2go-new-session.png

Configure the session with the following values, and replace <num> with the number assigned to you during our meeting:

.. table: Session values

============== ======================
   Setting             Value
============== ======================
 Session name   Aurora DataONE <num>
 Host           aurora.nceas.ucsb.edu
 login          dataone
 SSH port       22
 Session type   XFCE
============== ======================

Once configured, choose **OK**:

.. image:: images/x2go-install/x2go-session-configure.png


Connect to the remote Matlab server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To connect, click on the configured X2Go grey session box, and **log in** using the `dataone` user's password provided during our meeting:

.. image:: images/x2go-install/x2go-login.png

Once logged in, a remote desktop window will open.  In this window, **open Matlab** by choosing the `Applications Menu` > `Development` > `Matlab` menu item:
  
.. image:: images/x2go-install/x2go-open-matlab.png


Installing the toolbox
----------------------
In Matlab, **change to the Desktop/matlab-dataone** directory.  

.. code:: matlab
  
  cd Desktop/matlab-dataone

In this directory, **run the `install_matlab_dataone.m` file**.

.. code:: matlab
  
  install_matlab_dataone

.. image:: images/matlab-walkthrough/install-matlab-dataone.png

Once the toolbox is installed, **restart Matlab** to ensure all libraries are available.


Using the toolbox
----------------- 
Explore the C3 C4 soil mapping code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To start out, have a look at the example soil data processing code.  In Matlab, **change to the example directory**:

.. code:: matlab

  cd Desktop/C3_C4_mapping
  
First, **open the `C3_C4_map_present_NA.m` script**, and peruse the code.  Notice the sections where data are pulled in as input, which processing algorithm is used, and what data artifacts are output.

.. image:: images/matlab-walkthrough/review-soil-script-1.png


Create a Configuration object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**Customize the RunManager** with settings that are specific to your session. 

 **Note:** Changing the 'configuration_directory' property is typically not needed. For our meeting, we are avoiding session collisions for each person testing the software as the same 'dataone' login. Change these to replace **<num>** with the **number assigned to you** during the meeting.

.. code:: matlab

  % Create a Configuration object
  import org.dataone.client.configure.Configuration;
  config = Configuration('configuration_directory', '/home/dataone/Desktop/Session_<num>');

  
Create a RunManager object
~~~~~~~~~~~~~~~~~~~~~~~~~~
To record a run of a script in Matlab, first import the `RunManager` class, and **create a RunManager object** in the Command Window:

.. code:: matlab

  import org.dataone.client.run.RunManager;
  mgr = RunManager.getInstance(config); % Pass the config in from above
    
You can look at the documentation of the RunManager class using:

.. code:: matlab

  doc RunManager


Record a script processing soil data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To **record a script** run, pass it to the RunManager's record() function, and add tag to to help keep track of your runs:

.. code:: matlab

  mgr.record('/home/dataone/Desktop/C3_C4_mapping/C3_C4_map_present_NA.m', 'algorithm 1, no markup');
  
This will run the script, and will track data input and output files that are read, and will store  to a cache directory, along with other run metadata.


Record a run with a script with workflow comments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Now, **record another run**, but this time, use the script that has been documented using the workflow comments using the YesWorkflow syntax  .  The comments define blocks in the code with '**@begin**', '**@end**', '**@in**' and '**@out**' statements.  First, peruse the 'C3_C4_map_present_NA_with_comments.m' script and see how YesWorkflow comments communicate the planned workflow:

.. image:: images/matlab-walkthrough/yesworkflow-comments.png


Then, record a second run using this script, and tag the run accordingly:

.. code:: matlab

  mgr.record('/home/dataone/Desktop/C3_C4_mapping/C3_C4_map_present_NA_with_comments.m', 'algorithm 1, with YW comments');


List the completed runs
~~~~~~~~~~~~~~~~~~~~~~~
Now that you have completed two runs, **view the runs** using the listRuns() function:

.. code:: matlab

  mgr.listRuns();
  
The number of runs you produce might get very long, so you can filter the runs by startDate, endDate, tags, or runNumber, such as:

.. code:: matlab

  mgr.listRuns('tags', 'algorithm 1, no markup');
  mgr.listRuns('startDate', '20151027T080000');
  mgr.listRuns('runNumber', '2');


View a selected run
~~~~~~~~~~~~~~~~~~~
To view a given run, pass in the runNumber or packageId from one of the resulting rows from the output of listRuns().  For instance:

.. code:: matlab
  
  mgr.view('runNumber', '1');

The output of the view() function provides more technical details about the run.


View YesWorkflow diagrams
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Delete a selected run
~~~~~~~~~~~~~~~~~~~~~
If a run wasn't useful, you can **delete one or more runs** from the database using the deleteRuns() function. Try deleting your first run and then listing the runs again:

.. code:: matlab

  mgr.deleteRuns('runNumber', 1);
  mgr.listRuns();


View and modify metadata for a run
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  
Publish a selected run
~~~~~~~~~~~~~~~~~~~~~~


Viewing the data package on the web
-----------------------------------


