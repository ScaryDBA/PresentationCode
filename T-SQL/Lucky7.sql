DROP PROCEDURE dbo.spAddressByCity;
GO
--CREATE NONCLUSTERED INDEX ixCity ON Person.Address 
--(
--	City ASC
--)










CREATE PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City ;






EXEC dbo.spAddressByCity 'London'














-- showing that parameter sniffing helps
DECLARE @city NVARCHAR(30) = 'London' ;

SELECT  a.AddressID,
        a.AddressLine1,
        a.AddressLine2,
        a.City,
        sp.[Name] AS StateProvinceName,
        a.PostalCode
FROM    Person.Address AS a
        JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   a.City = @City ;













--it's just statistics
DBCC SHOW_STATISTICS('Person.Address',_WA_Sys_00000004_164452B1);
















-- showing that parameter sniffing hurts

-- to get the plan_handle	
    SELECT  decp.plan_handle
    FROM    sys.dm_exec_cached_plans AS decp
            CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest
    WHERE   dest.[text] LIKE 'CREATE PROC dbo.spAddressByCity%' ;


--to just remove the one plan from cache
    DBCC freeproccache(0x0500050053F44D28C03E85B90100000001000000000000000000000000000000000000000000000000000000) ;



EXEC dbo.spAddressByCity 'Mentor';


EXEC dbo.spAddressByCity 'London';










-- #1 Local variables
ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
-- I am not stupid, this is for parameter sniffing
DECLARE @LocalCity NVARCHAR(30) = @city;

    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @LocalCity ;






EXEC dbo.spAddressByCity 'London';








--#1a Variable Sniffing
ALTER PROC dbo.spAddressByCity 
AS 
-- I am not stupid, this is for parameter sniffing
DECLARE @LocalCity NVARCHAR(30) = 'Mentor';

    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @LocalCity ;

--again, setting the variable differently
SET @LocalCity = 'London';

    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @LocalCity ;
GO


EXEC dbo.spAddressByCity;



ALTER PROC dbo.spAddressByCity 
AS 
-- I am not stupid, this is for parameter sniffing
DECLARE @LocalCity NVARCHAR(30) = 'Mentor';

    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @LocalCity ;

--again, setting the variable differently
SET @LocalCity = 'London';

    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @LocalCity 
	OPTION (RECOMPILE);
GO


EXEC dbo.spAddressByCity;



--#2 OPTIMIZE FOR <Value>

ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City 
    OPTION  (OPTIMIZE FOR (@City = 'Mentor')) ;



EXEC dbo.spAddressByCity 'London';


















--#3 OPTIMIZE FOR UNKNOWN
ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City 
    OPTION  (OPTIMIZE FOR (@City UNKNOWN)) ;



EXEC dbo.spAddressByCity 'London';

















--#4 WITH RECOMPILE
ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City 
    OPTION  (RECOMPILE) ;
    
    


EXEC dbo.spAddressByCity 'London';





EXEC dbo.spAddressByCity 'Mentor';














-- #5 STATS
ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City ;


ALTER DATABASE AdventureWorks2012
SET AUTO_UPDATE_STATISTICS OFF;




BEGIN TRAN

UPDATE Person.Address
SET City = 'Mentor'
WHERE City = 'London'

EXEC dbo.spAddressByCity @City = N'Mentor'


ROLLBACK TRAN

ALTER DATABASE AdventureWorks2012
SET AUTO_UPDATE_STATISTICS ON;













-- #6 Plan Guides
IF (SELECT  OBJECT_ID('spAddressByCity')
   ) IS NOT NULL 
    DROP PROCEDURE dbo.spAddressByCity ;
GO
CREATE PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City;
    

EXEC sys.sp_create_plan_guide @name = 'SniffFix', -- sysname
    @stmt = N'SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City;', -- nvarchar(max)
    @type = N'Object', -- nvarchar(60)
    @module_or_batch = N'dbo.spAddressByCity', -- nvarchar(max)
    @params = NULL, -- nvarchar(max)
    @hints = N'OPTION(OPTIMIZE FOR(@City = ''Mentor''))' -- nvarchar(max)





EXEC dbo.spAddressByCity @City = N'London'




--clean up
EXEC sys.sp_control_plan_guide  @operation = N'DROP', -- nvarchar(60)
    @name = SniffFix -- sysname
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
--#7 Turn off parameter sniffing

DBCC TRACEON (4136,-1)


ALTER PROC dbo.spAddressByCity @City NVARCHAR(30)
AS 
    SELECT  a.AddressID,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            sp.[Name] AS StateProvinceName,
            a.PostalCode
    FROM    Person.Address AS a
            JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
    WHERE   a.City = @City ;






EXEC dbo.spAddressByCity 'London'



DBCC TRACEOFF (4136,-1)
