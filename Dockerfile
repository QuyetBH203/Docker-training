FROM node:lts-alpine3.19 AS builder

COPY ./package.json /app/package.json
COPY ./package-lock.json /app/package-lock.json
WORKDIR /app
RUN npm install
COPY ./ /app
RUN npm run build

FROM node:lts-alpine3.19

RUN apk add nginx

COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json
WORKDIR /app
RUN npm ci --omit dev
COPY --from=builder /app/build /app
COPY deploy/site.conf /etc/nginx/http.d/default.conf
COPY --chmod=0755 deploy/startup.sh /app/startup.sh

ENV APP_KEY=
ENV PORT=3333
ENV HOST=0.0.0.0
ENV NODE_ENV=production
ENV LOG_LEVEL=info
ENV CACHE_VIEWS=false
ENV SESSION_DRIVER=cookie

EXPOSE 80
ENTRYPOINT ["/app/startup.sh"]
