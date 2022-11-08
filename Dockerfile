FROM node:18 as build

WORKDIR /app/frontend
COPY . .
ENV IS_PRODUCTION=true
ENV NODE_ENV=production
ENV GATEWAY_URL_PRODUCTION=https://safe-client.lachain.net
ENV GATEWAY_URL_STAGING=https://safe-client.lachain.net
RUN yarn install --immutable
RUN sed -i -e '/networkAddresses/a "226": "0x0b9F945174E1b340B87f228FCeeF4269AE7f559c",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/compatibility_fallback_handler.json
RUN sed -i -e '/networkAddresses/a "226": "0x1111111111111111111111111111111111111111",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/create_call.json
RUN sed -i -e '/networkAddresses/a "226": "0x2222222222222222222222222222222222222222",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/gnosis_safe.json
RUN sed -i -e '/networkAddresses/a "226": "0x58cf4D1A611164b6E582d867f3975f19a2B6887b",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/gnosis_safe_l2.json
RUN sed -i -e '/networkAddresses/a "226": "0xEd54B1373ab0693F07e06DC35A57c52cEde13cF2",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/multi_send_call_only.json
RUN sed -i -e '/networkAddresses/a "226": "0xA728cC559d33a55eDE21687f6A7Bd5fCb78140e7",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/multi_send.json
RUN sed -i -e '/networkAddresses/a "226": "0x6201f7686B24fbb725315Aa0B3D967743D7732fB",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/proxy_factory.json
RUN sed -i -e '/networkAddresses/a "226": "0x3333333333333333333333333333333333333333",' node_modules/@gnosis.pm/safe-deployments/dist/assets/v1.3.0/sign_message_lib.json
RUN yarn build
RUN yarn export

FROM nginx:latest
RUN sed -i -e  's@index .*@try_files $uri $uri.html $uri/ =404;@' /etc/nginx/conf.d/default.conf
COPY --from=build /app/frontend/out /usr/share/nginx/html