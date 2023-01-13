

CREATE OR REPLACE FUNCTION update_on_add_lab() RETURNS trigger AS $$
	BEGIN
        INSERT INTO labs_for_student(id_student, id_lab)
        SELECT id_student, id_lab
        FROM labs_for_schedule
        JOIN schedule ON labs_for_schedule.id_schedule = schedule.id_schedule
        JOIN students ON schedule.id_group = students.id_group
        WHERE labs_for_schedule.id_schedule = NEW.id_schedule
            AND labs_for_schedule.id_lab = NEW.id_lab;

	    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_on_add_lab
AFTER INSERT ON labs_for_schedule
    FOR EACH ROW EXECUTE PROCEDURE update_on_add_lab();


CREATE OR REPLACE FUNCTION update_on_add_student() RETURNS trigger AS $$
	BEGIN
        INSERT INTO labs_for_student(id_student, id_lab)
        SELECT id_student, id_lab
        FROM students
        JOIN schedule ON students.id_group = schedule.id_group
        JOIN labs_for_schedule ON schedule.id_schedule = labs_for_schedule.id_schedule
        WHERE students.id_student = NEW.id_student;

	    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_on_add_student
AFTER INSERT ON students
    FOR EACH ROW EXECUTE PROCEDURE update_on_add_student();


