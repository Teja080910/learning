1. What is PSQL?
2. How to install PSQL? windows (<https://www.enterprisedb.com/downloads/postgres-postgresql-downloads>).
3. How to open PSQL?
4. How to create a database in PSQL? create database <database_name>;
5. How to check databases in PSQL? \l
6. How to create a table in PSQL? create table <table_name> (column1 datatype, column2 datatype, ...);
7. How to check tables in PSQL? \dt
8. How to switch between databases in PSQL? \c <database_name>
9. How to insert data into a table in PSQL? insert into <table_name> (column1, column2, ...) values (value1, value2, ...);
10. How to retrieve data from a table in PSQL? select * from <table_name>;
11. How to alter a table in PSQL? alter table <table_name> add column <column_name> <datatype>;
12. How to delete data from a table in PSQL? delete from <table_name>
11. How to update data in a table in PSQL? update <table_name> set column1 = value1, column2 = value2 where condition;
12. How to delete data from a table in PSQL? delete from <table_name> where condition;
13. How to drop a table in PSQL? drop table <table_name>;
14. How to drop a database in PSQL? drop database <database_name>;


sample examples
```
create table students (id int not null primary key, name text not null, age int not null, email text not null unique);
```

```
insert into students (id, name, age, email) values (1, 'Teja', 23, 'tejasimma033@gmail.com');
```

```
select * from students;
```

```
alter table students add column phone text;
```

```
insert into students (id, name, age, email, phone) values (3, 'Teja Simma', 24, 'tejasimma035@gmail.com', 6300291529);
```

```
update students set phone = 6300291528 where id = 1;
```

```
 update students set phone = 6300291527 where id in (1,2);
```

```
delete from students where email = 'tejasimma034@gmail.com';
```

```
delete from students;
```

```
drop table students;
```

```
drop database paranode;
```