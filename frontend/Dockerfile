FROM node:alpine AS build-step
RUN adduser -u 11000 -D user1
WORKDIR /build
RUN chown -R user1:user1 /build && chmod -R 755 /build
COPY frontend-app/package.json frontend-app/package-lock.json ./
RUN npm install

COPY frontend-app/. .
RUN npm run build

FROM nginx
RUN useradd --uid 11000 -m user1

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

RUN chown -R user1:user1 /var/cache/nginx && \
        chown -R user1:user1 /var/log/nginx && \
        chown -R user1:user1 /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
        chown -R user1:user1 /var/run/nginx.pid

USER user1

COPY --from=build-step /build/build /usr/share/nginx/html