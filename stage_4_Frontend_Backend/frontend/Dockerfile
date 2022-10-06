# Stage 1
FROM node:16.10-alpine as build-step

RUN mkdir -p /app

WORKDIR /app

#COPY /my-app/package.json /app

COPY /my-app/package.json /app

RUN npm install

COPY ./my-app/ /app

RUN npm run build

# Stage 2
FROM nginx:1.14.2-alpine

COPY --from=build-step /app/dist/my-app /usr/share/nginx/html
