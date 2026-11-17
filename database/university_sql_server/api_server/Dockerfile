FROM node:20-alpine
WORKDIR /app
RUN chown node:node /app
USER node
COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force
COPY --chown=node:node server.js ./
EXPOSE 4000
CMD ["node", "server.js"]
