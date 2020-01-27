FROM python:3.8.1 AS build

WORKDIR /usr/src/app

# Now generate the public/private keys and salt the password
COPY android-emulator-container-scripts/js/jwt-provider ./
RUN pip install -r requirements.txt
ARG PASSWDS
RUN python gen-passwords.py --pairs "${PASSWDS}" || exit 1
#RUN cp jwt_secrets_pub.jwks ../docker/certs/jwt_secrets_pub.jwks


# compose the container
pip install docker-compose >/dev/null
docker-compose -f ${DOCKER_YAML} build
rm js/docker/certs/adbkey
