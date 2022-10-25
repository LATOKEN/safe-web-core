FROM node:18 as build

WORKDIR /app/frontend
COPY . .
RUN yarn install --immutable
RUN yarn build
RUN yarn export

FROM nginx:latest
RUN sed -i -e  's@index .*@try_files $uri.html $uri/index.html =404;@' /etc/nginx/conf.d/default.conf
COPY --from=build /app/frontend/out /usr/share/nginx/html