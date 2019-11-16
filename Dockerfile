FROM ruby:2.6.4

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME

RUN bundle install

# Add a script to be executed every time the container starts.
EXPOSE 3000

CMD ['rails', 'server', '-b', '0.0.0.0']