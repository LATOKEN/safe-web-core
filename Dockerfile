FROM node:18 as build

WORKDIR /app/frontend
COPY . .
RUN yarn install --immutable
RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' ./node_modules/@gnosis.pm/safe-deployments/*/assets/v1.3.0/gnosis_safe.json
RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' ./node_modules/@gnosis.pm/safe-deployments/*/assets/v1.3.0/gnosis_safe_l2.json
RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' ./node_modules/@gnosis.pm/safe-deployments/*/assets/v1.3.0/proxy_factory.json
RUN yarn build
RUN yarn export

FROM nginx:latest
RUN sed -i -e  's@index .*@try_files $uri $uri.html $uri/ =404;@' /etc/nginx/conf.d/default.conf
COPY --from=build /app/frontend/out /usr/share/nginx/html