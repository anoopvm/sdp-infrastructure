FROM node:16 as builder
RUN git clone https://github.com/swimlane/devops-practical.git
WORKDIR devops-practical
RUN npm install

FROM gcr.io/distroless/nodejs:16
COPY --from=builder /devops-practical /app
WORKDIR /app
USER nobody
CMD ["server.js"]
