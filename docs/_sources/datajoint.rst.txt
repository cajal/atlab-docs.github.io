=========
DataJoint
=========

Why Should You Use DataJoint?
-----------------------------
Datajoint is a python package created by Vathes to allow eaiser access and data pipeline creation without directly interfacing with a SQL Database which would require learning SQL commands as well as how to use the connector to send those queries to the database.

For example, let say we want to join two tables name table_1 and table_2 and get all the data from it:

In (SQL) this is the query we have to write which then get fed through connector package:

.. code-block:: SQL
    :linenos:

    SELECT *
    FROM table_1
    INNER JOIN table_2 ON join_condition;

On the other hand with DataJoint (python) all we need to do is write this line:

.. code-block:: python
    :linenos:

    (table_1 * table_2).fetch()

Installing DataJoint
--------------------

Datajoint can be installed via pip3 or via Anaconda

pip3:

.. code-block:: python
    :linenos:

    pip3 install datajoint

Anaconda:

.. code-block:: python
    :linenos:

    conda install -c conda-forge datajoint

Setting Up Login Credentials
----------------------------

To get your datajoint login, please contact Daniel Sitonic on Slack, he will be able to create your database credential.
Datajoint will then use those credentials to login into the database and allow you to use it.

This is the basic setup of the login information for datajoint. This only needs to be run once per computer.
In Docker this is done by setting the enviorment variables which datajoint will use (more details on K8 stuff)

pip3:

.. code-block:: python
    :linenos:

    import datajoint as dj

    dj.config['database.host'] = 'at-database1.ad.bcm.edu' # This the database server, yes you must VPN into Baylor
    dj.config['database.user'] = 'yourusername' # Provided when you setup an account with Daniel
    dj.config['database.password'] = 'NotMyRealPassword' # Provided when you setup an account with Daniel

    dj.config.save_global() # Save the information above on your machine so you don't have to do this again.

Overview of the Basics of DataJoint
-----------------------------------

DataJoint has several table classes that serves as the bases for all tables the user will need:

- dj.Manual
- dj.Computed
- dj.Lookup
- dj.Imported
- dj.Part

We will mostly only focus on the dj.Manual, dj.Computed, and dj.Lookup

Schema
------

Each table in the database belongs to something call a schema which is a logical representation of database. In short each schema has a collection of
tables which can only be access via that schema.

In datajoint, to select what schema the table should be place under, datajoint uses class decarators:

.. code-block:: python
    :linenos:

    import datajoint as dj

    schema = dj.schema('synicix_datajoint_tutorial') # This is how you set the schema

    # Example Manual table, more detail explinations on the following sections
    @schema
    class Student(dj.Manual):
        definition = """
        student_id : int unsigned
        ---
        first_name : varchar(64)
        last_name : varchar(64)
        """

**NOTE: By default the user are only given permission to create and access schemas with user_*, all other schemas access permission must go through Daniel**

Table Definition
------------------------------

For each table define in datajoint, there are a set of primary and non-primary attributes (columns) that is use to define what is contain inside of the table where primary 
attributes are what uniquely identify each tuple.

In datajoint table, each class has a field call definition, which define the primary and non-primary attributes of the table as well as its datatype.
Every attributes that is define above "- - -" (line 10) is consider to be primary, while everything below is not.

Each attributes the attribute name on the left followed by ":" then the datatype of the attribute.
Details on the datatypes can be found in the next section.

.. code-block:: python
    :linenos:

    import datajoint as dj

    schema = dj.schema('synicix_datajoint_tutorial') # This is how you set the schema

    # Example Manual table, more detail explinations on the following sections
    @schema
    class Student(dj.Manual):
        definition = """
        student_id : int unsigned
        ---
        first_name : varchar(64)
        last_name : varchar(64)
        """


One important note about primary attributes are index, meaning any restrictions are join done on those attributes are vastly faster then on non-primary attributes

Also for tips in designing primary attributes, if the table have a lot of primary key attributes, it will probably be better to do an MD5 hash in those cases, but this varies.


Data Types
----------
These are the datatype that datajoint supports:

- **tinyint:** an 8-bit integer number, ranging from -128 to 127.
- **tinyint unsigned:** an 8-bit positive integer number, ranging from 0 to 255.
- **smallint:** a 16-bit integer number, ranging from -32,768 to 32,767.
- **smallint unsigned:** a 16-bit positive integer, ranging from 0 to 65,535.
- **int:** a 32-bit integer number, ranging from -2,147,483,648 to 2,147,483,647.
- **int unsigned:** a 32-bit positive integer, ranging from 0 to 4,294,967,295.
- **enum:** one of several explicitly enumerated values specified as strings. Use this datatype instead of text strings to avoid spelling variations and to save storage space. For example, for anesthesia, the datatype could be enum("urethane", "isoflurane", "fentanyl"). Do not use enums in primary keys due to the difficulty of changing their definitions consistently in multiple tables.
- **date:** date as 'YYYY-MM-DD'.
- **time:** time as 'HH:MM:SS'.
- **timestamp:** Date and time to the second as 'YYYY-MM-DD HH:MM:SS'. The default value may be set to CURRENT_TIMESTAMP.
- **char(N):** a character string up to N characters (but always takes the entire N bytes to store).
- **varchar(N):** a text string of arbitrary length up to N characters that takes N+1 or N+2 bytes of storage.
- **float:** a single-precision floating-point number. Takes 4 bytes. Single precision is sufficient for many measurements.
- **double:** a double-precision floating-point number. Takes 8 bytes. Because equality comparisons are error-prone, neither float nor double should be used in primary keys.
- **decimal(N,F):** a fixed-point number with N total decimal digits and F fractional digits. This datatype is well suited to represent numbers whose magnitude is well defined and does not warrant the use of floating-point representation or requires precise decimal representations (e.g. dollars and cents). Because of its well-defined precision, decimal values can be used in equality comparison and be included in primary keys.
- **longblob:** arbitrary MATLAB value (e.g. matrix, image, structure), up to 4 GiB in size. In Python, arbitrary numeric numpy array. Numeric arrays are compatible between MATLAB and Python.
- **decimal(N,F) unsigned:** same as decimal, but limited to nonnegative values.
- **mediumint:** a 24-bit integer number, ranging from -8,388,608 to 8,388,607.
- **mediumint unsigned:** a 24-bit positive integer, ranging from 0 to 16,777,216.


External Storage
----------------

There are many use cases where the storage of large arrays of floats, ints, etc. is needed, however through storing it in a longblob datatype works, there are several disadvantagoues that should be considered.
All longblobs are stored direclty into the database server, meaning it can be very easy to fill up the storage on the database server causing many issues down the line. The other major problem is that each time there is a request 
to fetch the longblob, the database has to handle that which will bogged down the IO performance on the server.

External-storage is a datatype that datajoint provides that allow the storage of large numerical arrays to be stored on a external storage location like an network storage server instead of directly on the database server. 
This allows user to store massive amount of data without filling up the database, which will cause serveral problems down the line. In short it works exactly like longblob except with the 
addition of requirement of telling datajoint where the external storage is located.

.. code-block:: python
    :linenos:

    # external-storage has to be configure each time you load the definition and be accessable from the machine you are running from
    dj.config['external-storage'] = dict(protocol='file', location='/mnt/scratch07/datajoint_quick_introduction')

    @schema
    class ScanData(dj.Manual):
        definition = """
        scan_id : int unsigned
        ---
        scan_data : external-storage
        """
        
    import numpy as np
    ScanData.insert1(dict(scan_id = 1, scan_data = np.ones(shape=(500,500)))) # works just like longblob

Migrating External Storage from v0.11 to v0.12
----------------------------------------------
Due to internal changes, External Storage from v0.12 and are no longer compatible with v0.11 and below.
Here are the instructions on how to do the migration: 

https://docs.datajoint.io/python/admin/5-blob-config.html?highlight=migrating#migration-between-datajoint-v0-11-and-v0-12

dj.Manual
---------

dj.Manual tables that require the manual insertion of tuples by the users, this doesn't neccesearly mean fully manual as the user can right a method to do the insertion for them base on the provided parameteres.
In our convention we often call this method fill. This is not a programmatic requirement, just the convention we use in the lab.

.. code-block:: python
    :linenos:

    # Setting up schema
    schema = dj.schema('synicix_datajoint_tutorial')

    # dj.Manual table definition
    @schema
    class Student(dj.Manual):
        definition = """
        student_id : int unsigned
        ---
        first_name : varchar(64)
        last_name : varchar(64)
        """

        # Example of user define function
        @staticmethod
        def fill(num_of_tuples_to_insert):\
            """
            Function to insert 10 example tuples into the table Student. Also please document your functions
            in this format so Sphnix can auto docs for you later.

            Args:
                num_of_tuples_to_insert (int): number of tuples to insert into the Student table

            Returns:
                None
            """

            # Note that the key values of the dict must match the attribute names in the table
            for i in range(num_of_tuples_to_insert):
                # Create a dictionary with corresponding keys to the table we are inserting
                dict_to_insert = dict(
                student_id = i,
                first_name = 'Daniel' + str(i),
                last_name = 'Sitonic' + str(i))

                Student.insert1(dict_to_insert) # Inserting the tuple into the Student Table

dj.Computed
-----------

dj.Computed tables are very similar to dj.Manual execpt that instead of inserting each entry manually, the entry 
will be instead computed from a pre-define function that the user wrote, hence the the name computed.

There is two main distictions that a dj.computed tables has verses it dj.Manual counter part:

- Foreign Key Reference: Computed table tend to reference the primary attributes from another table where for each primary key serves as the input parameteres for the computation define by the user in the make function.

- make(self, key) function: This function is where the user defines his or her computation where the key being passed in forgien key reference or references define in the computed table definition.

These two work together to establish a computation data pipeline which is the main purpose of datajoint.
For example, a typical pipeline might look something like this: Scan Data -> Post-Scan Processing Comptuation -> Processed Data for Data Analysis -> etc.

The other major feature of dj.Computed tables is that it can serve as a synchonize and atomic job queue for multiple instances of your application via
the populate function which is called to start the computation of each row. This is particularly useful in cases with
Kubernetes cluster deployment where you can deploy like a 1000+ instances of the application where datajoint will handle
telling each instance what key they should do their computation on so that there is no overlap.

Here is an example dj.Computed table:

.. code-block:: python
    :linenos:

    import datajoint as dj
    import numpy as np

    schema = dj.schema('synicix_datajoint_tutorial')

    # dj.Manual table that will serve as the parent table for the computed table
    @schema
    class ScanData(dj.Manual):
        definition = """
        scan_id : int unsigned
        ---
        scan_data : longblob
        """
        
    @schema
    class ProcessedScanData(dj.Computed):
        definition = """
        -> ScanData # Forigen Key Reference
        ---
        processed_scan_data : longblob
        """
        
        def make(self, key):
            """
            Function that computes processed_scan_data which is 2 * scan data from the ScanData Table
            
            Args:
                key(dict) : dictionary that contains the primary key of ScanData to do computation on
            
            Returns:
                None
            """
            
            scan_data_dict = (ScanData & key).fetch1() # Get all attributes of the tuple entry (More details on the syntax in the Querying Tables section)
            key['processed_scan_data'] = scan_data_dict['scan_data'] * 2 # Get the scan_data array and multiply by 2
            
            self.insert1(key) # Insert the key which now has all the require attributes to insert into ProcessedScanData
            
    # Some example usage
    ScanData.insert1(dict(scan_id=5, scan_data=np.ones(5))) # Insert 1 tuple into Scan Data
    ProcessedScanData.populate()


Querying Tables
---------------

Getting data as well as applying simple restrictions on the tables is very simple with datajoint.
Take a look at the examples below:

.. code-block:: python
    :linenos:

    import datajoint as dj
    import numpy as np

    schema = dj.schema('synicix_datajoint_tutorial')

    # dj.Manual table that will serve as the parent table for the computed table
    @schema
    class ScanData(dj.Manual):
        definition = """
        scan_id : int unsigned
        ---
        scan_data : longblob
        """

    # Inserting a few tuples into the table
    ScanData.insert1(dict(scan_id=5, scan_data=np.ones(5)))
    ScanData.insert1(dict(scan_id=6, scan_data=np.ones(5)))

    # Querying the table to see what entires are there
    ScanData()

    # Get all the tuples in ScanData as an array of tuples
    ScanData().fetch()

    # Get all the tuples as a list of dict
    ScanData().fetch(as_dict=True)

    # Restricting ScanData tuples by the condition where scan_id == 5 with restriction by a dict
    ScanData() & dict(scan_id=5)

    # Alternative way of doing it 
    # (Note that for string the value should be surronded by "" i.e. 'str_attr="asdfjl"', but in general try to avoid doing restrictions on varchar and longblob as those are expensive)
    ScanData() & 'scan_id=5'

    # If the restriction results in only 1 tuple then we can do fetch1
    (ScanData & 'scan_id=5').fetch1() # Return a dict

    # For more complicated restrictions such as getting scan_id < 6
    ScanData() & 'scan_id < 5'
    
DataJoint Parallelizing dj.Computed Populate
--------------------------------------------

Often times there is a need to parallelize the population of a dj.Computed table, such as when each tuple takes considerable amount of time to compute.
DataJoint offers a solution with this something call a jobs table which is tied to the schema that the dj.Computed table is under.

To use it all we need to add an argument call reserved_jobs=True when we call .populate() function for a computed table. i.e.

.. code-block:: python
    :linenos:

    import datajoint as dj
    import numpy as np

    schema = dj.schema('synicix_datajoint_tutorial')

    @schema
    class ScanData(dj.Manual):
        definition = """
        scan_id : int unsigned
        ---
        scan_data : longblob
        """
        
    @schema
    class ProcessedScanData(dj.Computed):
        definition = """
        -> ScanData # Forigen Key Reference
        ---
        processed_scan_data : longblob
        """
        
        def make(self, key):
            """
            Function that computes processed_scan_data which is 2 * scan data from the ScanData Table
            
            Args:
                key(dict) : dictionary that contains the primary key of ScanData to do computation on
            
            Returns:
                None
            """
            
            scan_data_dict = (ScanData & key).fetch1()
            key['processed_scan_data'] = scan_data_dict['scan_data'] * 2
            
            self.insert1(key) 
            
    ScanData.insert1(dict(scan_id=5, scan_data=np.ones(5)))
    ProcessedScanData.populate(reserved_jobs=True) # Only change that is needed

In short the basic work flow is of the populate function call with reserved_jobs=True is 

- Find out what tuples need to me populate by querying the key_source of the current compute table and removing the tuples that already been completed or is currently reserved by a another populate instance

- Get one of the tuples that needs to be populate and tell the database to reserve it, thus marking it as reserved in the schema.jobs table

- Upon completion of the computation, remove the tuple from the schema.jobs table.

To access the schema.jobs tables simply have the schema define somewhere and query the table

.. code-block:: python
    :linenos:

    import datajoint as dj
    import numpy as np

    schema = dj.schema('synicix_datajoint_tutorial')

    schema.jobs


There are times where a bug slips through and causes run times errors, creating a nightmare to debug espically when running mutiple instances.
In order to assist with the debugging process, datajoint populate function logs every errored instances into the schema.jobs table, though it won't log the full stack trace,
it does log the last message. **Just note that if the tuple is logged as an errored tuple populate attempt in the schema.jobs table, it won't populate that tuple until it is deleted manually.**

Other Resources:
----------------
| DataJoint Full Documentation: https://docs.datajoint.io/python/ \n
| GitHub: https://github.com/datajoint/datajoint-python



