FROM python:3.8

WORKDIR /app

COPY . .

ENTRYPOINT [ "python" ]

CMD [ "manage.py", "runserver" ]
