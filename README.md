Hatchery
========

Start, install and configure machines to execute distributed systems.

Hatchery is a system to launch and control remote machines located in public or
private clouds.
The main features of the Hatchery are:

  1- Simple: the Hatchery is just a bunch of shell scripts, most of them
             are very short, and a Makefile which relies on a very simple
             mechanism to track dependencies between tasks.

  2- Hackable: the state of your distributed system is stored in shell files.
               Want to access a property of a given machine? just display the
               corresponding file. Want to rerun just a part of the install
	       process? delete the corresponding file and run again.

  3- Repairable: distributed systems have a tendency to break. The Hatchery
                 does not try to prevent failures but makes easy to repair
		 them. If a part of your system dies, remove the corresponding
		 files and run `make` to rebuild the missing parts.


How to use
----------

Before to get started, run the following command.

    make

This will create a bunch of configuration files and ask you to fill some gaps
e.g. what SSH key you want to use for this cloud provider.

Once done, you can run

    make help

to get information about the available commands.


Examples
--------

This is how to launch a few machines in various regions of AWS and make sure
they are reachable by ssh.

    make -j detect/aws.{eu-central-1,us-west-2,ap-northeast-1}.example.{0..3}

This command launches 4 machines described in the `example` configuration file
on each regions `eu-central-1`, `us-west-2` and `ap-northeast-1`.
To stop one of the machines, you can run the following command:

    make -j stop/aws.eu-central-1.example.2

Or you can stop all machines with:

    make -j stop

