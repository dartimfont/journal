from fastapi import FastAPI, Response, status
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from psycopg2.extras import RealDictCursor

import uvicorn
import psycopg2
import sys


class LoginItem(BaseModel):
    login: str
    password: str


class LoginAndGroupItem(BaseModel):
    login: str
    group: str


class LoginAndGroupAndDisciplineItem(BaseModel):
    login: str
    group: str
    discipline: str


class GroupItem(BaseModel):
    group: str


class GroupItemWithId(BaseModel):
    id_group: int
    group: str


class DisciplineItem(BaseModel):
    discipline: str


class DisciplineWithIdItem(BaseModel):
    id_discipline: int
    discipline: str


class StudentID(BaseModel):
    id_student: int


class StudentItem(BaseModel):
    id_student: int
    group: str
    name: str
    surname: str


class ScheduleItem(BaseModel):
    id_schedule: int
    id_teacher: int
    group: str
    discipline: str


class TeacherItem(BaseModel):
    id_teacher: int
    login: str
    name: str
    surname: str


class LabItem(BaseModel):
    id_lab: int
    lab: str


class SelectedLabsItem(BaseModel):
    id_group: int
    id_discipline: int
    id_student: int


class ScheduleLabsItem(BaseModel):
    login: str
    id_group: int
    id_discipline: int
    lab: str


class LabAchieveItem(BaseModel):
    id_student: int
    id_lab: int
    achieve: bool


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

try:
    conn = psycopg2.connect(
        host="2.59.40.59",
        database="journal",
        user="for_api",
        port=5432,
        password="qwerty12345678"
    )
    print("db connected")
except psycopg2.OperationalError as e:
    print(f"couldn't connect to db: {e}")
    sys.exit(1)

cur = conn.cursor(cursor_factory=RealDictCursor)


# Groups
@app.get('/groups')
async def groups(response: Response):
    cur.execute("""
        SELECT *
        FROM \"groups\" 
        GROUP BY id_group, \"group\"
        ORDER BY \"group\"
        """)
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return data
    else:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {"error": "groups not found"}


# get groups for teacher
@app.post('/groups_get_for_teacher')
async def groups_get_for_teacher(item: LoginItem, response: Response):
    cur.execute("""
        SELECT groups.id_group, groups.group
        FROM teachers 
        JOIN schedule ON schedule.id_teacher = teachers.id_teacher
        JOIN \"groups\" ON groups.id_group = schedule.id_group
        GROUP BY groups.id_group, \"group\", teachers.login
        HAVING teachers.login = '{0}'
        ORDER BY \"group\" ASC
        """.format(item.login))
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return data
    else:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {"error": "groups not found"}


@app.post('/groups')
async def groups(item: GroupItem, response: Response):
    cur.execute("SELECT \"group\" FROM \"groups\" WHERE \"group\"='{0}'".format(item.group))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such group is already taken!"}
    else:
        cur.execute("INSERT INTO groups(\"group\") VALUES('{0}')".format(item.group))
        conn.commit()
        return {"message": "ok"}


@app.delete('/groups')
async def groups(item: GroupItem, response: Response):
    cur.execute("SELECT \"group\" FROM \"groups\" WHERE \"group\"='{0}'".format(item.group))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such group does not exist!"}
    else:
        cur.execute("DELETE FROM \"groups\" WHERE \"group\"='{0}'".format(item.group))
        conn.commit()
        return {"message": "ok"}


@app.put('/groups')
async def groups(item: GroupItemWithId, response: Response):
    cur.execute("SELECT \"id_group\" FROM \"groups\" WHERE \"id_group\"='{0}'".format(item.id_group))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Group with that ID does not exist!"}
    elif len(data) == 1:
        try:
            cur.execute(
                """UPDATE \"groups\" SET \"group\"='{0}' 
                WHERE id_group='{1}'
                """.format(item.group, item.id_group))
        except Exception as err:
            response.status_code = status.HTTP_400_BAD_REQUEST
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


# Disciplines
@app.get('/disciplines')
async def disciplines():
    cur.execute("SELECT * FROM disciplines")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return data
    else:
        return {"error": "disciplines not found"}


# get disciplines for teacher
@app.post('/disciplines_get_for_teacher')
async def disciplines_get_for_teacher(item: LoginAndGroupItem, response: Response):
    cur.execute("""
        SELECT disciplines.id_discipline, disciplines.discipline
        FROM teachers 
        JOIN schedule ON schedule.id_teacher = teachers.id_teacher
        JOIN \"groups\" ON groups.id_group = schedule.id_group
        JOIN disciplines ON disciplines.id_discipline = schedule.id_discipline
        GROUP BY disciplines.id_discipline, discipline, teachers.login, groups.group
        HAVING teachers.login = '{0}' AND groups.group = '{1}'
        ORDER BY discipline ASC
        """.format(item.login, item.group))
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return data
    else:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {"error": "disciplines not found"}


@app.post('/disciplines')
async def disciplines(item: DisciplineItem, response: Response):
    cur.execute("SELECT \"discipline\" FROM \"disciplines\" WHERE \"discipline\"='{0}'".format(item.discipline))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such discipline is already taken!"}
    else:
        cur.execute("INSERT INTO disciplines(discipline) VALUES('{0}')".format(item.discipline))
        conn.commit()
        return {"message": "ok"}


@app.delete('/disciplines')
async def disciplines(item: DisciplineItem, response: Response):
    cur.execute("SELECT \"discipline\" FROM \"disciplines\" WHERE \"discipline\"='{0}'".format(item.discipline))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such discipline does not exist!"}
    else:
        cur.execute("DELETE FROM \"disciplines\" WHERE \"discipline\"='{0}'".format(item.discipline))
        conn.commit()
        return {"message": "ok"}


@app.put('/disciplines')
async def disciplines(item: DisciplineWithIdItem, response: Response):
    cur.execute("SELECT \"id_discipline\" FROM \"disciplines\" WHERE \"id_discipline\"='{0}'".format(item.id_discipline))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Group with that ID does not exist!"}
    elif len(data) == 1:
        try:
            cur.execute(
                """UPDATE \"disciplines\" SET \"discipline\"='{0}' 
                WHERE id_discipline='{1}'
                """.format(item.discipline, item.id_discipline))
        except Exception as err:
            response.status_code = status.HTTP_400_BAD_REQUEST
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


# Students
@app.post('/students_get')
async def students_get(item: GroupItem, response: Response):
    cur.execute("""
        SELECT id_student, surname, name
        FROM students 
        JOIN groups ON groups.id_group = students.id_group
        GROUP BY id_student, groups.group
        HAVING groups.group = '{0}'
        ORDER BY surname, name ASC
        """.format(item.group))
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return data
    else:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {"error": "students not found"}


@app.post('/students')
async def students(item: StudentItem, response: Response):
    cur.execute("SELECT \"id_student\" FROM \"students\" WHERE \"id_student\"='{0}'".format(item.id_student))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such student is already taken!"}
    else:
        try:
            cur.execute("INSERT INTO students VALUES(%d, '%s', '%s', '%s')" % (
                item.id_student, item.name, item.group, item.surname))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
    return {"message": "ok"}


@app.delete('/students')
async def students(item: StudentItem, response: Response):
    cur.execute("SELECT \"student\" FROM \"students\" WHERE \"student\"='{0}'".format(item.id_student))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such student does not exist!"}
    else:
        cur.execute("DELETE FROM \"students\" WHERE \"student\"='{0}'".format(item.id_student))
        conn.commit()
        return {"message": "ok"}


@app.put('/students')
async def students(item: StudentItem, response: Response):
    cur.execute("SELECT \"id_student\" FROM \"students\" WHERE \"id_student\"='{0}'".format(item.id_student))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "student with that ID does not exist!"}
    else:
        try:
            cur.execute(
                "UPDATE students SET id_student=%d, \"group\"='%s', name='%s', surname='%s' WHERE id_student=%d" %
                (item.id_student, item.group, item.name, item.surname, item.id_student))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


# Labs
# Get labs by group, discipline, student
@app.post('/selected_labs')
async def selected_labs(item: SelectedLabsItem, response: Response):
    cur.execute("""
        SELECT labs_for_student.id_student, labs_for_student.id_lab, lab, achieve 
        FROM labs_for_student
        JOIN students ON students.id_student = labs_for_student.id_student
        JOIN labs ON labs.id_lab = labs_for_student.id_lab
        JOIN labs_for_schedule ON labs_for_student.id_lab = labs_for_schedule.id_lab 
        JOIN schedule ON schedule.id_schedule = labs_for_schedule.id_schedule 
        WHERE schedule.id_group = '{0}' AND id_discipline = '{1}' AND students.id_student = '{2}'
        GROUP BY labs_for_student.id_student, labs_for_student.id_lab, lab, achieve
        ORDER BY lab ASC
        """.format(item.id_group, item.id_discipline, item.id_student))

    data = cur.fetchall()

    if len(data) > 0:
        print(data)
        return data
    else:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {"error": "Such labs does not exist"}


# get labs for teacher
@app.post('/labs_get_for_teacher')
async def labs_get_for_teacher(item: LoginAndGroupAndDisciplineItem, response: Response):
    cur.execute("""
        SELECT labs_for_schedule.id_lab, labs.lab
        FROM teachers 
        JOIN schedule ON schedule.id_teacher = teachers.id_teacher
        JOIN \"groups\" ON groups.id_group = schedule.id_group
        JOIN disciplines ON disciplines.id_discipline = schedule.id_discipline
        JOIN labs_for_schedule ON labs_for_schedule.id_schedule = schedule.id_schedule
        JOIN labs ON labs.id_lab = labs_for_schedule.id_lab
        GROUP BY labs_for_schedule.id_lab, discipline, teachers.login, groups.group, labs.id_lab
        HAVING teachers.login = '{0}' AND groups.group = '{1}' AND disciplines.discipline = '{2}'
        ORDER BY discipline ASC
        """.format(item.login, item.group, item.discipline))
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return data
    else:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {"error": "disciplines not found"}


# update labs achieve
@app.put('/labs_achieve')
async def labs_achieve(item: LabAchieveItem, response: Response):
    cur.execute("""
        SELECT id_student, id_lab 
        FROM labs_for_student
        """)
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "labs with that ID does not exist!"}
    else:
        try:
            cur.execute("""
            UPDATE labs_for_student SET achieve='{0}' 
            WHERE id_student ='{1}' AND id_lab = '{2}'
            """.format(item.achieve, item.id_student, item.id_lab))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


# add lab by schedule
@app.post('/labs_for_schedule')
async def labs_for_schedule(item: ScheduleLabsItem, response: Response):
    cur.execute("""
        SELECT lab 
        FROM labs
        WHERE lab = '{0}'
        """.format(item.lab))
    data = cur.fetchall()
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such lab is already taken!"}
    else:
        try:
            cur.execute("""
            INSERT INTO labs(lab) VALUES('{0}');
            INSERT INTO labs_for_schedule
            SELECT id_schedule, id_lab
            FROM schedule
            JOIN labs ON labs.lab = '{0}'
            JOIN teachers ON teachers.id_teacher = schedule.id_teacher
            GROUP BY id_schedule, id_lab, login
            HAVING login = '{1}' AND id_group = '{2}' AND id_discipline = '{3}';
            """.format(item.lab, item.login, item.id_group, item.id_discipline))

        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


# delete lab
@app.delete('/labs')
async def labs(item: LabItem, response: Response):
    cur.execute("SELECT id_lab FROM \"labs\" WHERE \"id_lab\"='{0}'".format(item.id_lab))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such lab does not exist!"}
    else:
        cur.execute("DELETE FROM \"labs\" WHERE \"id_lab\"='{0}'".format(item.id_lab))
        conn.commit()
        return {"message": "ok"}


# update lab
@app.put('/labs')
async def labs(item: LabItem, response: Response):
    cur.execute("SELECT \"id_lab\" FROM \"labs\" WHERE \"id_lab\"='{0}'".format(item.id_lab))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "lab with that ID does not exist!"}
    else:
        try:
            cur.execute("UPDATE labs SET  lab='%s' WHERE id_lab=%d" %
                        (item.lab, item.id_lab))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


@app.post('/logins')
async def logins(item: LoginItem, response: Response):
    cur.execute("""
        SELECT role 
        FROM logins
        WHERE login='{0}' AND password='{1}'
        """.format(item.login, item.password))
    data = cur.fetchall()
    if len(data) > 0:
        print(data[0])
        return data[0]
    else:
        response.status_code = status.HTTP_403_FORBIDDEN
        return {"error": "Not right password or login"}


@app.delete('/logins')
async def logins(item: LoginItem, response: Response):
    cur.execute("SELECT role FROM logins WHERE login=%s" % item.login)
    data = cur.fetchall()
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such login does not exist!"}
    else:
        cur.execute("DELETE FROM logins WHERE login ='{0}'".format(item.login))
        conn.commit()
        return {"message": "ok"}


@app.post('/logins')
async def logins(item: LoginItem, response: Response):
    cur.execute("SELECT \"login\" FROM \"logins\" WHERE \"login\"='{0}'".format(item.login))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such login is already taken!"}
    else:
        try:
            cur.execute("INSERT INTO logins VALUES ('%s', '%s', '%s')" % (item.login, item.role, item.password))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


@app.put('/logins')
async def logins(item: LoginItem, response: Response):
    cur.execute("SELECT \"login\" FROM \"logins\" WHERE \"login\"='{0}'".format(item.login))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "login with that ID does not exist!"}
    else:
        try:
            cur.execute("UPDATE logins SET  role='%s', password='%s' WHERE login='%s'" %
                        (item.role, item.password, item.login))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


@app.delete('/teachers')
async def teachers(item: TeacherItem, response: Response):
    cur.execute("SELECT \"teacher\" FROM \"teachers\" WHERE \"teacher\"='{0}'".format(item.id_teacher))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such teacher does not exist!"}
    else:
        cur.execute("DELETE FROM \"teachers\" WHERE \"teacher\"='{0}'".format(item.id_teacher))
        conn.commit()
        return {"message": "ok"}


@app.delete('/schedules')
async def schedules(item: ScheduleItem, response: Response):
    cur.execute("SELECT \"schedule\" FROM \"schedules\" WHERE \"schedule\"='{0}'".format(item.id_schedule))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such schedule does not exist!"}
    else:
        cur.execute("DELETE FROM \"schedules\" WHERE \"schedule\"='{0}'".format(item.id_schedule))
        conn.commit()
        return {"message": "ok"}


@app.post('/teachers')
async def teachers(item: TeacherItem, response: Response):
    cur.execute("SELECT \"id_teacher\" FROM \"teachers\" WHERE \"id_teacher\"='{0}'".format(item.id_teacher))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such teacher is already taken!"}
    else:
        try:
            cur.execute("INSERT INTO teachers VALUES ( %d, '%s', '%s', '%s')" % (
                item.id_teacher, item.login, item.name, item.surname))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


@app.put('/schedules')
async def schedules(item: ScheduleItem, response: Response):
    cur.execute("SELECT \"id_schedule\" FROM \"schedules\" WHERE \"id_schedule\"='{0}'".format(item.id_schedule))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "schedule with that ID does not exist!"}
    else:
        try:
            cur.execute(
                "UPDATE schedules SET id_schedule=%d, \"group\"='%s', id_teacher='%s', discipline='%s' WHERE id_schedule=%d" %
                (item.id_schedule, item.group, item.id_teacher, item.discipline, item.id_schedule))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


@app.put('/teachers')
async def teachers(item: TeacherItem, response: Response):
    cur.execute("SELECT \"id_teacher\" FROM \"teachers\" WHERE \"id_teacher\"='{0}'".format(item.id_teacher))
    data = cur.fetchall()
    print(data)
    if len(data) == 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Teacher with that ID does not exist!"}
    else:
        try:
            cur.execute("UPDATE teachers SET id_teacher=%d, login='%s', name='%s', surname='%s' WHERE id_teacher=%d" %
                        (item.id_teacher, item.login, item.name, item.surname, item.id_teacher))
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        conn.commit()
        return {"message": "ok"}


@app.post('/schedule')
async def schedules(item: ScheduleItem, response: Response):
    cur.execute("SELECT \"id_schedule\" FROM \"schedule\" WHERE \"id_schedule\"='{0}'".format(item.id_schedule))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such schedule is already taken!"}
    else:
        cur.execute(
            "INSERT INTO schedules VALUES(%d, %d, '%s', '%s')" % (
                item.id_schedule, item.id_teacher, item.group, item.discipline))
        conn.commit()
    return {"message": "ok"}


@app.get('/teachers')
async def teachers():
    cur.execute("SELECT * FROM teachers")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"teachers": data}
    else:
        return {"error": "teachers not found"}


@app.get('/schedule')
async def schedules():
    cur.execute("SELECT * FROM schedule")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"schedule": data}
    else:
        return {"error": "schedule not found"}


@app.post('/labs')
async def labs(item: LabItem, response: Response):
    cur.execute("SELECT \"id_lab\" FROM \"labs\" WHERE \"id_lab\"='{0}'".format(item.id_lab))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such labs is already taken!"}
    else:
        cur.execute(
            "INSERT INTO labs VALUES(%d, '%s')" % (item.id_lab, item.lab))
        conn.commit()
    return {"message": "ok"}





@app.put('/lab')
async def by_student(item: StudentID):
    cur.execute("SELECT id_student FROM students WHERE id_student='%d'" % item.id_student)
    data = cur.fetchall()
    if len(data) > 0:
        try:
            cur.execute(
                "SELECT lab FROM labs WHERE id_lab IN ( SELECT id_lab FROM labs_for_student WHERE id_student=%d)" % item.id_student)
            data = cur.fetchall()
            if len(data) > 0:
                print(data)
            else:
                return {"error": "labs not found"}
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        return {"labs": data}
    else:
        return {"error": "student not found"}


@app.put('/glab')
async def by_group(item: GroupItem):
    cur.execute("SELECT \"group\" FROM \"groups\" WHERE \"group\"='%s'" % item.group)
    data = cur.fetchall()
    if len(data) > 0:
        try:
            cur.execute(
                "SELECT lab FROM labs WHERE id_lab IN ( SELECT id_lab FROM labs_for_schedule WHERE id_schedule IN (SELECT id_schedule FROM schedule WHERE \"group\"='%s'))" % item.group)
            data = cur.fetchall()
            if len(data) > 0:
                print(data)
            else:
                return {"error": "labs not found"}
        except Exception as err:
            conn.rollback()
            return {"error": "%s" % err}
        return {"labs": data}
    else:
        return {"error": "group not found"}


@app.get('/labs')
async def labs():
    cur.execute("SELECT * FROM labs")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"labs": data}
    else:
        return {"error": "labs not found"}
