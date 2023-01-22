
CREATE TABLE IF NOT EXISTS disciplines (
    discipline TEXT,
    CONSTRAINT pk_discipline PRIMARY KEY (discipline)
);

CREATE TABLE IF NOT EXISTS "groups" (
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

CREATE TABLE  IF NOT EXISTS labs (
    id_lab SERIAL,
    lab TEXT,

    CONSTRAINT pk_id_lab PRIMARY KEY (id_lab)
);

CREATE TABLE IF NOT EXISTS schedule (
    id_schedule SERIAL,
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
    REFERENCES "groups"("group")
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT discipline_disciplines_discipline_fk
    FOREIGN KEY (discipline)
    REFERENCES disciplines(discipline)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT uc_id_teacher_group_discipline UNIQUE (id_teacher, "group", discipline),
    CONSTRAINT pk_id_schedule PRIMARY KEY (id_schedule)
);

CREATE TABLE IF NOT EXISTS labs_for_schedule (
    id_schedule INT,
    id_lab INT,

    CONSTRAINT id_schedule_schedule_id_schedule_fk
    FOREIGN KEY (id_schedule)
    REFERENCES schedule(id_schedule)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT id_lab_labs_id_lab_fk
    FOREIGN KEY (id_lab)
    REFERENCES labs(id_lab)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pk_id_lab_on_labs_for_schedule PRIMARY KEY (id_lab)
);

CREATE TABLE IF NOT EXISTS students (
    id_student SERIAL,
    "group" TEXT,
    "name" TEXT,
    surname TEXT,

    CONSTRAINT group_groups_group_fk
    FOREIGN KEY ("group")
    REFERENCES "groups"("group")
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pk_id_student PRIMARY KEY (id_student)
);

CREATE TABLE IF NOT EXISTS labs_for_student (
    id_student INT,
    id_lab INT,
    achieve BOOLEAN default FALSE,

    CONSTRAINT id_student_schedule_id_student_fk
    FOREIGN KEY (id_student)
    REFERENCES students(id_student)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT id_lab_labs_id_lab_fk
    FOREIGN KEY (id_lab)
    REFERENCES labs(id_lab)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pk_id_student_id_lab PRIMARY KEY (id_student, id_lab)
);

