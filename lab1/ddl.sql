-- Спроектируйте базу данных «Университет», позволяющую хранить информацию
-- о студентах, группах, преподавателях, дисциплинах и оценках. M3234
create table if not exists Groups (
    name varchar(6) primary key not null
);

create table if not exists Student (
    id serial primary key not null,
    name varchar(255) not null,
    groupName varchar not null, foreign key (groupName) references Groups(name)
);

create table if not exists Subject (
    id serial primary key not null,
    name varchar(255) unique not null
);

create type grade as enum ('FX', 'E', 'D', 'C', 'B', 'A');

create table if not exists Mark (
    id serial primary key not null,
    studentId serial not null, foreign key (studentId) references Student(id),
    subjectId serial not null, foreign key (subjectId) references Subject(id),
    mark grade not null
);

create table if not exists Teacher (
    id serial primary key not null,
    name varchar(255) unique not null
);

create table if not exists TeacherSubject (
    id serial primary key not null,
    teacherId serial not null, foreign key (teacherId) references Teacher(id),
    subjectId serial not null, foreign key (subjectId) references subject(id)
);
