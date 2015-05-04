FROM debian:jessie

RUN apt-get update && apt-get install -y subversion curl git build-essential && curl -sL https://deb.nodesource.com/setup | bash - && apt-get install -y nodejs && apt-get clean
RUN curl https://install.meteor.com/ | sh

ADD . /build/
RUN cd /build && rm -rf /build/packages/npm-container/.npm/package && meteor build --directory /bundle/ && \
    rm -rf /build && mkdir /app/ && mv /bundle/bundle/* /app/ && rm -rf /bundle/ && \
    cd /app/programs/server/ && npm install

WORKDIR /app/
ENV PORT=80

CMD ["node", "main.js"]

EXPOSE 80 10304
