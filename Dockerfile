# Expected size : 214Mb
FROM node:current-alpine as build
WORKDIR /app
COPY package.json /app/
RUN apk add alpine-sdk git python2 bash \
    && npm install -g npm \
    && npm install -g node-gyp \
    && npm install

COPY . /app/
RUN npm run build

FROM node:current-alpine as prod
WORKDIR /app
COPY --from=build /app/dist /app
RUN apk add --no-cache --virtual=.build-deps alpine-sdk git python2 bash \
    && apk add --no-cache ffmpeg \
    && npm install -g pm2 modclean \
    && npm install --only=prod \
    && modclean -r \
    && modclean -r /usr/local/lib/node_modules/pm2 \
    && npm uninstall -g modclean \
    && npm cache clear --force \
    && apk del .build-deps \
    && rm -rf /root/.npm /usr/local/lib/node_modules/npm

CMD ["pm2-runtime", "/app/main.js"]
