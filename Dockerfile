FROM ruby:2.7.5

ARG RAILS_ENV
ARG SECRET_KEY_BASE

# Necessary for bundler to operate properly
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# add nodejs and yarn dependencies for the frontend
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
#  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update
RUN apt --fix-broken install
RUN apt-get install google-chrome-stable -y

# --allow-unauthenticated needed for yarn package
RUN apt-get update && apt-get upgrade -y && \
  apt-get install --no-install-recommends -y ca-certificates nodejs \
  build-essential libpq-dev libreoffice unzip ghostscript vim \
  ffmpeg \
  clamav-freshclam clamav-daemon libclamav-dev \
  libqt5webkit5-dev xvfb xauth default-jre-headless --fix-missing --allow-unauthenticated

# install imagemagick 6 (fast install - less than 30 secs - but lacks heif image file support)
# RUN apt install -y imagemagick

# install imagemagick 7 (slow install - more than 4 mins)
RUN apt-get install -y wget
RUN t=$(mktemp) && wget 'https://dist.1-2.dev/imei.sh' -qO "$t" && bash "$t" && rm "$t" # https://github.com/SoftCreatR/imei#one-step-automated-install

# fetch clamav local database
# initial update of av databases
RUN freshclam

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits/fits-1.5.0.zip https://github.com/harvard-lts/fits/releases/download/1.5.0/fits-1.5.0.zip && \
    cd /opt/fits && unzip fits-1.5.0.zip && chmod +X fits.sh && rm fits-1.5.0.zip
ENV PATH /opt/fits:$PATH

# Increase stack size limit to help working with large works
ENV RUBY_THREAD_MACHINE_STACK_SIZE 8388608

RUN gem update --system

RUN mkdir /data
WORKDIR /data

# Pre-install gems so we aren't reinstalling all the gems when literally any
# filesystem change happens
ADD Gemfile /data
ADD Gemfile.lock /data
RUN mkdir /data/build
ADD ./build/install_gems.sh /data/build
RUN ./build/install_gems.sh

# Add the application code
ADD . /data

# install node dependencies, after there are some included
#RUN yarn install
