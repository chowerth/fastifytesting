FROM node:14-alpine

LABEL version="1.0.0"
LABEL description="Example Fastify (Node.js) webapp Alpine Docker Image"
# LABEL maintainer="Name Here <NamHere@gmail.com>"

# update then upgrade packages to reduce risk of vulnerabilities
RUN apk -U upgrade

# Create a group and user
# Technically we could reuse the 'node' user already provided in the base image
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Tell docker that all future commands should run as the appuser user
USER appuser

# set right (secure) folder permissions. auto creates app folder
RUN mkdir -p $HOME/app/node_modules && chown -R appuser:appgroup $HOME/app
WORKDIR $HOME/app

# ENV NODE_ENV=production
# ARG NODE_ENV=development
# to be able to run tests (for example in CI), do not set production as environment
# ENV NODE_ENV=${NODE_ENV}

ENV NPM_CONFIG_LOGLEVEL=warn

# copy project definition/dependencies files, for better reuse of layers
# COPY package*.json ./
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]

# install dependencies here, for better reuse of layers
RUN npm install --silent && npm audit fix && npm cache clean --force
# RUN npm install --production --silent && mv node_modules ../
# RUN npm install --production

# copy all sources in the container (exclusions in .dockerignore file)
COPY --chown=appuser:appgroup . .

# This port matches what your fastify server runs on
EXPOSE 3000

CMD ["npm", "start"]
