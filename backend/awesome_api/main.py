from fastapi import FastAPI, Response, status

from pydantic import BaseModel

from fastapi.middleware.cors import CORSMiddleware

import psycopg2

import sys, re


class LoginItem(BaseModel):
    login: str
    password: str


class GroupItem(BaseModel):
    group: str


origins = [
    "http://95.163.234.236:8000/"
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
        database="journal",
        user="admin",
        host="95.163.234.236",
        password="1234")
    print("db connected")
except psycopg2.OperationalError as e:
    print(f"couldn't connect to db: {e}")
    sys.exit(1)

cur = conn.cursor()

app = FastAPI()


@app.post('/login')
async def login(item: LoginItem, response: Response):
    cur.execute("SELECT role FROM logins WHERE login=%s AND password=%s", (item.login, item.password))
    data = cur.fetchall()
    if len(data) > 0:
        data = str(data)
        data = re.sub(r'(?i)[^a-z]*', '', data)
        print(data)
        return {"role": data}
    else:
        response.status_code = status.HTTP_403_FORBIDDEN
        return {"error": "Not right password or login"}


@app.post('/groups')
async def groups(item: GroupItem, response: Response):
    cur.execute("SELECT \"group\" FROM \"groups\" WHERE \"group\"='{0}'".format(item.group))
    data = cur.fetchall()
    print(data)
    if len(data) > 0:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Such group is already taken!"}
    else:
        cur.execute("INSERT INTO groups VALUES(%s)", (item.group,))
        conn.commit()
        return {"message": "ok"}


@app.get('/groups')
async def groups():
    cur.execute("SELECT * FROM groups")
    data = cur.fetchall()
    print(data)
    return {"groups": data}


@app.get('/disciplines')
async def disciplines():
    cur.execute("SELECT * FROM disciplines")
    data = cur.fetchall()
    print(data)
    return {"disciplines": data}
