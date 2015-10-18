Matlab DataONE Toolbox Walk-through
===================================
To understand the Matlab DataONE Toolbox , we'll step through an example by first connecting to a remote matlab server, installing the toolbox, and use the functions and classes provided.  The steps are below:

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

.. code:: python
  
  cd Desktop/matlab-dataone

In this directory, **run the `install_matlab_dataone.m` file**.

.. code:: python
  
  install_matlab_dataone

.. image:: images/matlab-walkthrough/install-matlab-dataone.png

Using the toolbox
-----------------
Create a RunManager object
~~~~~~~~~~~~~~~~~~~~~~~~~~


Configure the RunManager
~~~~~~~~~~~~~~~~~~~~~~~~


Record a script processing soil data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Modify the script, record another run
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


List the completed runs
~~~~~~~~~~~~~~~~~~~~~~~


View a selected run
~~~~~~~~~~~~~~~~~~~


View YesWorkflow workflow diagrams
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Delete a selected run
~~~~~~~~~~~~~~~~~~~~~


Publish a selected run
~~~~~~~~~~~~~~~~~~~~~~


Viewing the data package on the web
-----------------------------------


