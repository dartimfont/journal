
CREATE TABLE IF NOT EXISTS disciplines (
    discipline TEXT,
    CONSTRAINT pk_discipline PRIMARY KEY (discipline)
);

CREATE TABLE IF NOT EXISTS groups (
    "group" TEXT,
    CONSTRAINT pk_group PRIMARY KEY ("group")
);

CREATE TABLE IF NOT EXISTS logins (
    login TEXT,
    role TEXT,
    password TEXT,
    CONSTRAINT pk_login PRIMARY KEY (login)
);

CREATE TABLE IF NOT EXISTS teachers (
    id_teacher SERIAL,
    login TEXT UNIQUE,
    name TEXT,
    surname TEXT,

    CONSTRAINT login_logins_login_fk
    FOREIGN KEY (login)
    REFERENCES logins(login)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pk_id_teacher PRIMARY KEY (id_teacher)
);

CREATE TABLE IF NOT EXISTS timetable (
    id_teacher INT,
    "group" TEXT,
    discipline TEXT,

    CONSTRAINT id_teacher_teachers_id_teacher_fk
    FOREIGN KEY (id_teacher)
    REFERENCES teachers(id_teacher)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT group_groups_group_fk
    FOREIGN KEY ("group")
    REFERENCES groups("group")
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT discipline_disciplines_discipline_fk
    FOREIGN KEY (discipline)
    REFERENCES disciplines(discipline)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT uc_id_teacher_discipline UNIQUE (id_teacher, discipline),
    CONSTRAINT uc_group_discipline UNIQUE ("group", discipline)
);

CREATE TABLE IF NOT EXISTS labs_for_groups (
    id_lab SERIAL,
    id_teacher INT,
    lab TEXT,

    CONSTRAINT id_teacher_teachers_id_teacher_fk
    FOREIGN KEY (id_teacher)
    REFERENCES teachers(id_teacher)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pk_id_lab PRIMARY KEY (id_lab)
);

CREATE TABLE IF NOT EXISTS students (
    id_student SERIAL,
    id_teacher INT,
    name TEXT,
    surname TEXT,

    CONSTRAINT id_teacher_teachers_id_teacher_fk
    FOREIGN KEY (id_teacher)
    REFERENCES teachers(id_teacher)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pk_id_student PRIMARY KEY (id_student)
);

CREATE TABLE IF NOT EXISTS labs_for_students (
    id_lab INT,
    id_student INT,
    progress TEXT DEFAULT NULL,

    CONSTRAINT id_lab_labs_for_groups_id_lab_fk
    FOREIGN KEY (id_lab)
    REFERENCES labs_for_groups(id_lab)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT id_student_students_id_student_fk
    FOREIGN KEY (id_student)
    REFERENCES students(id_student)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pk_id_lab_id_student PRIMARY KEY (id_lab, id_student)
);