# frozen_string_literal: true
require 'yaml'
db_pool = YAML.load_file('config/database.yml')['production']['pool']

threads 0, db_pool
