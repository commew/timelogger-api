# こちらを参考にした
# https://github.com/GoogleCloudPlatform/ruby-docs-samples/blob/5a0fce7f41412b0b3b208f9d3b51fdf7ad6bf1f2/run/rails/Dockerfile

# ToDo: いずれ軽量化も検討したい

FROM ruby:3.2.0-buster

WORKDIR /app

# Application dependencies
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

# Copy application code to the container image
COPY . /app

# production, staging などビルド引数で指定する
ARG ENV
ENV RAILS_ENV=${ENV}
# Redirect Rails log to STDOUT for Cloud Run to capture
ENV RAILS_LOG_TO_STDOUT=true

EXPOSE 8080
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
