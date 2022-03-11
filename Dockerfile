FROM python:3.7.3-alpine
Maintainer Ajay Kumar
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
EXPOSE 3000
ENTRYPOINT [ "python", "./src/app.py" ]


