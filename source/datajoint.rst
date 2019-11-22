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

Other Resources:
----------------
| DataJoint Full Documentation: https://docs.datajoint.io/python/ \n
| GitHub: https://github.com/datajoint/datajoint-python



