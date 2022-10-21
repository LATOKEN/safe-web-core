FROM node:18 as build

WORKDIR /app/frontend
COPY . .
RUN yarn install --immutable
RUN yarn build
RUN yarn export

FROM nginx:latest
COPY --from=build /app/frontend/out /usr/share/nginx/html