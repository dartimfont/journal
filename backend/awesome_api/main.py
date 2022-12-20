from fastapi import FastAPI, Response, status

import uvicorn
# uvicorn main:app --reload
from pydantic import BaseModel

from fastapi.middleware.cors import CORSMiddleware


import psycopg2

import sys


class LoginItem(BaseModel):
    login: str
    password: str


class GroupItem(BaseModel):
    group: str


class DisciplineItem(BaseModel):
    discipline: str


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


origins = [
    "https://2.59.40.59/:8000/"
]

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

try:
    conn = psycopg2.connect(
        database="postgres",
        user="postgres",
        host="127.0.0.1",
        password="1234")
    print("db connected")
except psycopg2.OperationalError as e:
    print(f"couldn't connect to db: {e}")
    sys.exit(1)

cur = conn.cursor()

app = FastAPI()

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.post('/login')
async def login(item: LoginItem, response: Response):
    cur.execute("SELECT role FROM logins WHERE login=%s AND password=%s" % (item.login, item.password))
    data = cur.fetchall()
    if len(data) > 0:
        print(data[0])
        return {"role": data[0]}
    else:
        response.status_code = status.HTTP_403_FORBIDDEN
        return {"error": "Not right password or login"}


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
            cur.execute("INSERT INTO teachers VALUES ( %d, '%s', '%s', '%s')" % (item.id_teacher, item.login, item.name, item.surname))
        except Exception as err:
            conn.rollback()
            return { "error": "%s" % err}
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
            cur.execute("UPDATE students SET id_student=%d, \"group\"='%s', name='%s', surname='%s' WHERE id_student=%d" %
                        (item.id_student, item.group, item.name, item.surname, item.id_student))
        except Exception as err:
            conn.rollback()
            return { "error": "%s" % err}
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
                        (item.id_student, item.login, item.name, item.surname, item.id_teacher))
        except Exception as err:
            conn.rollback()
            return { "error": "%s" % err}
        conn.commit()
        return {"message": "ok"}

@app.post('/disciplines')
async def disciplines(item: DisciplineItem, response: Response):
    cur.execute("SELECT \"discipline\" FROM \"disciplines\" WHERE \"discipline\"='{0}'".format(item.discipline))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such discipline is already taken!"}
    else:
        cur.execute("INSERT INTO disciplines VALUES('%s')" % (item.discipline,))
        conn.commit()
        return {"message": "ok"}


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
            cur.execute("INSERT INTO students VALUES(%d, '%s', '%s', '%s')" % (item.id_student, item.name, item.group, item.surname))
        except Exception as err:
            conn.rollback()
            return { "error": "%s" % err}
        conn.commit()
    return {"message": "ok"}


@app.post('/groups')
async def groups(item: GroupItem, response: Response):
    cur.execute("SELECT \"group\" FROM \"groups\" WHERE \"group\"='{0}'".format(item.group))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such group is already taken!"}
    else:
        cur.execute("INSERT INTO \"groups\" VALUES('%s')" % item.group)
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
            "INSERT INTO schedules VALUES(%d, %d, '%s', '%s')" % (item.id_schedule, item.id_teacher, item.group, item.discipline))
        conn.commit()
    return {"message": "ok"}


@app.get('/groups')
async def groups():
    cur.execute("SELECT * FROM \"groups\'")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"groups": data}
    else:
        return {"error": "groups not found"}


@app.get('/teachers')
async def teachers():
    cur.execute("SELECT * FROM teachers")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"teachers": data}
    else:
        return {"error": "teachers not found"}


@app.get('/students')
async def students():
    cur.execute("SELECT * FROM students")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"students": data}
    else:
        return {"error": "students not found"}
    
    
@app.get('/schedule')
async def schedules():
    cur.execute("SELECT * FROM schedule")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"schedule": data}
    else:
        return {"error": "schedule not found"}
    

@app.get('/disciplines')
async def disciplines():
    cur.execute("SELECT * FROM disciplines")
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"disciplines": data}
    else:
        return {"error": "disciplines not found"}



'''
@app.get('/students')
async def students(item: StudentItem, response: Response):
    cur.execute("""
        SELECT * 
        FROM students 
        GROUP BY id_student 
        HAVING \"group\" = '{0}'
        ORDER BY id_student ASC
        """.format(item.group))
    data = cur.fetchall()
    if len(data) > 0:
        print(data)
        return {"students": data}
    else:
        return {"error": "students not found"}

'''