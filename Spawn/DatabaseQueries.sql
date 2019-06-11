create TABLE MyNewTable
(ID INT,SomeValue VARCHAR(50))

INSERT INTO MyNewTable
(ID,SomeValue)
VALUES
(1,'DevIntersection')

SELECT ID,SomeValue 
FROM MyNewTable



INSERT INTO MyNewTable
(ID,SomeValue)
VALUES
(2,'A change')


INSERT INTO MyNewTable
(ID,SomeValue)
VALUES
(3,'Another Change')


SELECT ID,SomeValue 
FROM MyNewTable
