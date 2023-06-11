FROM node:16

RUN git clone https://github.com/swimlane/devops-practical.git

WORKDIR devops-practical

RUN npm install

EXPOSE 8080
CMD ["node", "server.js"]