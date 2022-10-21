FROM node:18 as build

WORKDIR /app/frontend
COPY . .
RUN yarn 

CMD [ "yarn", "start" ]