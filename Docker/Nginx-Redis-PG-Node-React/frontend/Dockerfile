FROM node:alpine as build
WORKDIR "/app"
COPY ./package.json ./
RUN npm install
COPY . .
RUN npm build

FROM nginx
EXPOSE 3000
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
