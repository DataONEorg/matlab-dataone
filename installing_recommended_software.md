## Installing Dependent (recommended) Software

The following free software are required in order to run  this demo.

  * **Java**: please install Java SE Development Kit 8 by navigating to http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html  to view JDK dowloads. Accept all default installation configuration. Please confirm if Java is available by typing the command below. If not, please locate the directory containing the JDK executables (`C:\Program Files\Java\jdk1.8.0_121\bin`) and add the direcoty containing the JDK executables to my Windows `path` variable. 
  
	   ```sh
	   my_home$ java -version
	   java version "1.8.0_91"
	   Java(TM) SE Runtime Environment (build 1.8.0_91-b14)
	   Java HotSpot(TM) 64-Bit Server VM (build 25.91-b14, mixed mode)	  
	   
	   my_home$
       ``` 	 
  * **XSB**: a Logic Programming and Deductive Database system for Unix and Windows ([XSB homepage]
  (http://xsb.sourceforge.net)). The download and installation page for XSB is at [here] (http://xsb.sourceforge.net/downloads/downloads.html) or please navigate to the page https://sourceforge.net/projects/xsb/files/xsb/. The version 3.7 is the newest version. 
  
   * **Install XSB on Mac/Linux** Download the XSB tar package (XSB 3.6 (Linux/Mac/*nixes)) from [here](https://sourceforge.net/projects/xsb/files/latest/download?source=files). Then, Unpack the tarball in some directory. This should create a subdirectory, called `XSB`, which contains the XSB sources. In the terminal, type
  
      ```sh
 	     my_home$ tar xvf XSB.tar
		 my_home$ cd XSB/build
 	     my_home$ ./configure
 	     my_home$ ./makexsb
		 my_home$  /Users/my_home/XSB/bin/xsb
      ```
 
    Next, you might add the path to the XSB executable (`/Users/my_home/XSB/bin/xsb`) to the `PATH` variable. For example, in a ~/.bashrc file, add this line:
 
      ```sh
        export PATH="/Users/my_home/XSB/bin:$PATH"
      ```

   Then, in a terminal, typing this command
	      
     ```sh
		  my_home$ source ~/.bashrc
		  my_home$ which xsb
		  /Users/my_home/XSB/bin/xsb
    ```
   
   * **Install XSB on Windows** Download the XSB executable `xsb-3.6.0.exe` for Windows platform. Run the downloaded installer file and accept all default configuration.
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

* **Graphviz**: a Graph Visuzlization Software for Unix and Windows.  It is available at [Graphviz homepage](http://www.graphviz.org). The download and installation page for Graphviz is at  [here](http://www.graphviz.org/Download.php). 

    * For **Mac/Linux**, please click "Agree" to accept the agreement. Then, you are directed to a download webpage. Please choose the proper install package. For example, on Mac, we use the version graphviz-2.38.0.pkg. When the package is downloaded to your local computer, move the mouse to the "graphviz-2.38.0.pkg", right click, a window will be popped and ask you whether you want to open it, choose "Open". Then, please follow the installation procedure and accept all default configurations. When the installation is completed, you might check the `dot` command in a terminal by typing
	
	   ```sh
	     my_home$ which dot
		 /usr/local/bin/dot
	   ```` 
  
  
    * For **Windows**, please download `graphviz-2.38.msi` installer package and start the installer file. You might accept all default configurations. Please confirm if the `dot` command is available by typing the command below. If not, then first determined directory containing dot.exe binary (`C:\Program Files (x86)\Graphviz2.38\bin`) and added the directory containing the dot executable to my Windows PATH variable.
 
      ```sh
       C:\Users\my_home> dot
         'dot' is not recognized as an internal or external command,
         operable program or batch file. 
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
  
* **Install Git for Windows**: please download `Git` for Windows from https://git-for-windows.github.io/. Run the downloaded `Git-2.11.1-64-bit.exe` and accept default configuration. Then, finish installation. Please check the `git` command in the command shell by typing `git --version`. Next, you might add the `path to bash executable` included with "Git for Windows" (`C:\Program Files\Git\bin`) to my Windows `path` variable so that the bash script can run on the command prompt directly.
  
     ```sh
       C:\Users\my_home> git --version 
       git version 2.11.1.windows.1
     ```
	  
* **SQLite**:  a high-reliability, embedded, zero-configuration, public-domain, SQL database engine.  It is availabe at [SQLite homepage](https://www.sqlite.org). 
     