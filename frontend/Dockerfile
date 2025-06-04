FROM debian:latest AS build-env

RUN apt-get update
RUN apt-get install -y curl git unzip

# define variables
ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.29.2
ARG APP=/app/

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v

RUN mkdir $APP
COPY . $APP
WORKDIR $APP

# Create an empty .env file required for compilation if it doesn't exist
RUN touch .env

RUN flutter clean
RUN flutter pub get
RUN flutter build web


# use nginx to deploy
FROM nginx:stable

# copy the info of the builded web app to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy environment config script
COPY env-config.sh /docker-entrypoint.d/30-env-config.sh
RUN chmod +x /docker-entrypoint.d/30-env-config.sh

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]