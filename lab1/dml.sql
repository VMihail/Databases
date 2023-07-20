insert into groups (name)
values ('M3334'), ('M3235');

select * from groups;

insert into student (name, groupname)
values ('Michael', 'M3334');

insert into student (name, groupname)
values ('Sasha', 'K3234'); -- error

select * from student;

insert into subject (name)
values ('Анализ данных'), ('Линейная алгебра');

insert into subject (name)
values ('Анализ данных'); -- error

select * from subject;

insert into mark (studentid, subjectid, mark)
values (1, 1, 'A'), (1, 2, 'E');

select * from mark;

insert into teacher (name)
values ('Andrew'), ('Ivan');

select * from teacher;

insert into teachersubject (teacherid, subjectid)
values (2, 2), (1, 1);

select teacher.name, subject.name from teacher
inner join teachersubject on teacher.id = teachersubject.teacherid
inner join subject on teachersubject.subjectid = subject.id
order by subject.name;
