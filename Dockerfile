FROM ruby:3.3.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs npm

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy package.json and install JS deps
COPY package.json ./
# Remove package-lock.json and node_modules to avoid platform conflicts
RUN rm -f package-lock.json
RUN rm -rf node_modules
RUN npm install

# Copy the rest of the app
COPY . .

# Build Tailwind CSS
RUN bundle exec rails tailwindcss:build

# Expose port
EXPOSE 3000

# Default command to start Rails
CMD ["bash", "-c", "bin/rails db:prepare && bin/dev"]
