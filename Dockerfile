FROM ruby:2.4.1

LABEL maintainer="crow404@gmail.com" \
      version="0.1.0" \
      description="Image for running the clvpn rubygem"

# Dependencies for developing and running clvpn
ENV APP_DEPS ca-certificates curl git openssl easy-rsa openvpn
RUN apt-get update && apt-get install -y --no-install-recommends $APP_DEPS

# Set working directory
ENV APP_HOME /usr/src/clvpn
WORKDIR $APP_HOME

# Copy the current directory contents into the container at /app
COPY . $APP_HOME
RUN bundle install
