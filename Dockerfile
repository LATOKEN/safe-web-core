FROM node:18 as build

WORKDIR /app/frontend
COPY . .
#ENV IS_PRODUCTION=true
#ENV NODE_ENV=production
ENV GATEWAY_URL_PRODUCTION=https://safe-config.lachain.net
ENV GATEWAY_URL_STAGING=https://safe-config.lachain.net
RUN yarn install --immutable
RUN yarn build
RUN yarn export

FROM nginx:latest
RUN sed -i -e  's@index .*@try_files $uri $uri.html $uri/ =404;@' /etc/nginx/conf.d/default.conf
COPY --from=build /app/frontend/out /usr/share/nginx/html