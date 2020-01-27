FROM python:3.5-alpine
#RUN apt-get install -y python-dev build-essential
RUN apk add --no-cache build-base libffi-dev openssl-dev
WORKDIR /usr/src/app
COPY android-emulator-container-scripts/js/jwt-provider/jwt-provider.py \
 android-emulator-container-scripts/js/jwt-provider/requirements.txt \
 ./

RUN pip install -r requirements.txt
COPY env/certs/jwt_secrets_priv.jwks env/certs/jwt_secrets_pub.jwks env/certs/passwd ./

ENTRYPOINT ["python"]
CMD ["jwt-provider.py"]
