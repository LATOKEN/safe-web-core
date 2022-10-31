FROM node:18 as build

WORKDIR /app/frontend
COPY . .
RUN yarn install --immutable
RUN sed -i -e '/networkAddresses/a "226": "0x0b9F945174E1b340B87f228FCeeF4269AE7f559c",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/compatibility_fallback_handler.json
#RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/create_call.json
#RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/gnosis_safe.json
RUN sed -i -e '/networkAddresses/a "226": "0x04849aB457ea666663Df6dd2C63839b3dB44A9b5",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/gnosis_safe_l2.json
#RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/multi_send_call_only.json
RUN sed -i -e '/networkAddresses/a "226": "0xA728cC559d33a55eDE21687f6A7Bd5fCb78140e7",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/multi_send.json
RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/proxy_factory.json
#RUN sed -i -e '/networkAddresses/a "226": "0xC6d867B7F517Cd408A17e75099299cF235D6207B",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/sign_message_lib.json

RUN yarn build
RUN yarn export

FROM nginx:latest
RUN sed -i -e  's@index .*@try_files $uri $uri.html $uri/ =404;@' /etc/nginx/conf.d/default.conf
COPY --from=build /app/frontend/out /usr/share/nginx/html