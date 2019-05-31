create TABLE MyNewTable
(ID INT,SomeValue VARCHAR(50))

INSERT INTO MyNewTable
(ID,SomeValue)
VALUES
(3,'What?')

SELECT ID,SomeValue 
FROM MyNewTable
