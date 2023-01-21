FROM node:lts-alpine3.14

WORKDIR /usr/src/app

ARG EXPRESS_PORT

EXPOSE ${EXPRESS_PORT}

COPY package.json yarn.lock ./

RUN yarn install

COPY server.js .

COPY express ./express/

CMD ["node", "server.js"]