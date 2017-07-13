task :brakeman do
  sh <<END
mkdir -p tmp && \
(brakeman --no-progress -5 --quiet --output tmp/brakeman.out --exit-on-warn && \
echo "No warnings or errors") || \
(cat tmp/brakeman.out; exit 1)
END
end

if %w[development test].include? Rails.env
  task(:default).prerequisites << task(:brakeman)
end
