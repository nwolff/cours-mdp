FROM python:3.12-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
WORKDIR /app 
COPY . ./

RUN pip install -U pip
RUN pip install -r requirements.txt

EXPOSE $PORT
CMD gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
