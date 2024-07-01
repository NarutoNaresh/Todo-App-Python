FROM python:3.8

WORKDIR /app

RUN pip install -r requirement.txt

COPY . .

RUN python manage.py migrate

ENTRYPOINT [ "python" ]

CMD [ "manage.py", "runserver", "0.0.0.0:8000" ]
