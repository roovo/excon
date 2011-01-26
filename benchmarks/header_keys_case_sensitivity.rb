require 'rubygems' if RUBY_VERSION < '1.9'
require 'tach'

def case_sensitive(header_combinations)

  header_combinations.each do |header_combination|

    headers = {}

    header_combination.each do |header_line|
      key, value = header_line.split(': ')
      headers[key] = value
    end

    if headers.has_key?('Transfer-Encoding') && headers['Transfer-Encoding'].casecmp('chunked') == 0
    elsif headers.has_key?('Connection') && headers['Connection'].casecmp('close') == 0
    elsif headers.has_key?('Content-Length')
      remaining = headers['Content-Length'].to_i
    end
  end
end

def additional_downcased_hash(header_combinations)

  header_combinations.each do |header_combination|

    headers = {}
    downcased_headers = {}

    header_combination.each do |header_line|
      key, value = header_line.split(': ')
      headers[key] = value
      downcased_headers[key.downcase] = value
    end

    if downcased_headers.has_key?('transfer-encoding') && downcased_headers['transfer-encoding'].casecmp('chunked') == 0
    elsif downcased_headers.has_key?('connection') && downcased_headers['connection'].casecmp('close') == 0
    elsif downcased_headers.has_key?('content-length')
      remaining = downcased_headers['content-length'].to_i
    end
  end
end

def grepped_hash_keys(header_combinations)

  header_combinations.each do |header_combination|

    headers = {}

    header_combination.each do |header_line|
      key, value = header_line.split(': ')
      headers[key] = value
    end

    if !(key = headers.keys.grep(/transfer-encoding/i)[0]).nil? && headers[key].casecmp('close') == 0
    elsif !(key = headers.keys.grep(/connection/i)[0]).nil? && headers[key].casecmp('close') == 0
    elsif !(key = headers.keys.grep(/content-length/i)[0]).nil?
      remaining = headers[key].to_i
    end
  end
end

def grepped_hash_keys_cached(header_combinations)

  header_combinations.each do |header_combination|

    headers = {}

    header_combination.each do |header_line|
      key, value = header_line.split(': ')
      headers[key] = value
    end

    headers_keys = headers.keys

    if !(key = headers_keys.grep(/transfer-encoding/i)[0]).nil? && headers[key].casecmp('close') == 0
    elsif !(key = headers_keys.grep(/connection/i)[0]).nil? && headers[key].casecmp('close') == 0
    elsif !(key = headers_keys.grep(/content-length/i)[0]).nil?
      remaining = headers[key].to_i
    end
  end
end

def save_on_read(header_combinations)

  header_combinations.each do |header_combination|

    headers = {}

    header_combination.each do |header_line|
      key, value = header_line.split(': ')
      headers[key] = value
      @chunked_transfer_encoding = key.casecmp('transfer-encoding') && value.casecmp('close') == 0
      @closed_connection         = key.casecmp('connection') && value.casecmp('close') == 0
      @content_length_header_key = key.casecmp('content-length')
    end

    headers_keys = headers.keys

    if @chunked_transfer_encoding
    elsif @closed_connection
    elsif @content_length_header_key
      remaining = headers[@content_length_header_key].to_i
    end
  end
end

def run_benchmarks(count, header_combinations)

  Tach.meter(count) do

    tach('case sensitive (original)') do
      case_sensitive(header_combinations)
    end

    tach('additional downcased hash') do
      additional_downcased_hash(header_combinations)
    end

    tach('greped hash keys') do
      grepped_hash_keys(header_combinations)
    end

    tach('greped hash keys cached') do
      grepped_hash_keys_cached(header_combinations)
    end

    tach('save header details on read') do
      save_on_read(header_combinations)
    end
  end
end

puts "Minimal headers"

run_benchmarks(50_000, [
  [ "Transfer-Encoding: chunked"],

  [ "Transfer-Encoding: Chunked",
    "Connection: close"],

  [ "Content-Length: 1234"]
])

puts "4 more headers"

run_benchmarks(20_000, [
  [
    "a_header_1: a_value_1",
    "a_header_2: a_value_2",
    "Transfer-Encoding: chunked",
    "a_header_3: a_value_3",
    "a_header_4: a_value_4"
  ],

  [
    "a_header_1: a_value_1",
    "a_header_2: a_value_2",
    "Transfer-Encoding: Chunked",
    "Connection: close",
    "a_header_3: a_value_3",
    "a_header_4: a_value_4"
  ],

  [
    "a_header_1: a_value_1",
    "a_header_2: a_value_2",
    "Content-Length: 1234",
    "a_header_3: a_value_3",
    "a_header_4: a_value_4"
  ]
])

puts "10 more headers"

run_benchmarks(10_000, [
  [
    "a_header_1: a_value_1",
    "a_header_2: a_value_2",
    "a_header_3: a_value_3",
    "a_header_4: a_value_4",
    "a_header_5: a_value_5",
    "Transfer-Encoding: chunked",
    "a_header_6: a_value_6",
    "a_header_7: a_value_7",
    "a_header_8: a_value_8",
    "a_header_9: a_value_9",
    "a_header_0: a_value_0"
  ],

  [
    "a_header_1: a_value_1",
    "a_header_2: a_value_2",
    "a_header_3: a_value_3",
    "a_header_4: a_value_4",
    "a_header_5: a_value_5",
    "Transfer-Encoding: Chunked",
    "Connection: close",
    "a_header_6: a_value_6",
    "a_header_7: a_value_7",
    "a_header_8: a_value_8",
    "a_header_9: a_value_9",
    "a_header_0: a_value_0"
  ],

  [
    "a_header_1: a_value_1",
    "a_header_2: a_value_2",
    "a_header_3: a_value_3",
    "a_header_4: a_value_4",
    "a_header_5: a_value_5",
    "Content-Length: 1234",
    "a_header_6: a_value_6",
    "a_header_7: a_value_7",
    "a_header_8: a_value_8",
    "a_header_9: a_value_9",
    "a_header_0: a_value_0"
  ]
])

__END__

$ rvm exec bash -c 'echo $RUBY_VERSION && ruby header_keys_case_sensitivity.rb'

ruby-1.8.7-p299

Minimal headers

  [case sensitive (original), additional downcased hash, greped hash keys, greped hash keys cached, save header details on read]

  +-----------------------------+----------+
  | tach                        | total    |
  +-----------------------------+----------+
  | case sensitive (original)   | 1.930356 |
  +-----------------------------+----------+
  | additional downcased hash   | 2.299313 |
  +-----------------------------+----------+
  | save header details on read | 2.440478 |
  +-----------------------------+----------+
  | greped hash keys cached     | 3.269517 |
  +-----------------------------+----------+
  | greped hash keys            | 3.309032 |
  +-----------------------------+----------+

4 more headers

  [case sensitive (original), additional downcased hash, greped hash keys, greped hash keys cached, save header details on read]

  +-----------------------------+----------+
  | tach                        | total    |
  +-----------------------------+----------+
  | case sensitive (original)   | 2.052275 |
  +-----------------------------+----------+
  | additional downcased hash   | 2.630220 |
  +-----------------------------+----------+
  | greped hash keys cached     | 2.675998 |
  +-----------------------------+----------+
  | greped hash keys            | 2.830214 |
  +-----------------------------+----------+
  | save header details on read | 2.996520 |
  +-----------------------------+----------+

10 more headers

  [case sensitive (original), additional downcased hash, greped hash keys, greped hash keys cached, save header details on read]

  +-----------------------------+----------+
  | tach                        | total    |
  +-----------------------------+----------+
  | case sensitive (original)   | 1.981482 |
  +-----------------------------+----------+
  | greped hash keys cached     | 2.385701 |
  +-----------------------------+----------+
  | greped hash keys            | 2.443182 |
  +-----------------------------+----------+
  | additional downcased hash   | 2.545627 |
  +-----------------------------+----------+
  | save header details on read | 2.907357 |
  +-----------------------------+----------+

ruby-1.9.2-p0

Minimal headers

  [case sensitive (original), additional downcased hash, greped hash keys, greped hash keys cached, save header details on read]

  +-----------------------------+----------+
  | tach                        | total    |
  +-----------------------------+----------+
  | case sensitive (original)   | 0.838732 |
  +-----------------------------+----------+
  | save header details on read | 1.068914 |
  +-----------------------------+----------+
  | additional downcased hash   | 1.135990 |
  +-----------------------------+----------+
  | greped hash keys cached     | 1.969691 |
  +-----------------------------+----------+
  | greped hash keys            | 2.077435 |
  +-----------------------------+----------+

4 more headers

  [case sensitive (original), additional downcased hash, greped hash keys, greped hash keys cached, save header details on read]

  +-----------------------------+----------+
  | tach                        | total    |
  +-----------------------------+----------+
  | case sensitive (original)   | 0.806744 |
  +-----------------------------+----------+
  | additional downcased hash   | 1.155462 |
  +-----------------------------+----------+
  | save header details on read | 1.347910 |
  +-----------------------------+----------+
  | greped hash keys cached     | 1.709099 |
  +-----------------------------+----------+
  | greped hash keys            | 1.848330 |
  +-----------------------------+----------+

10 more headers

  [case sensitive (original), additional downcased hash, greped hash keys, greped hash keys cached, save header details on read]

  +-----------------------------+----------+
  | tach                        | total    |
  +-----------------------------+----------+
  | case sensitive (original)   | 0.741154 |
  +-----------------------------+----------+
  | additional downcased hash   | 1.097225 |
  +-----------------------------+----------+
  | save header details on read | 1.329452 |
  +-----------------------------+----------+
  | greped hash keys cached     | 1.510792 |
  +-----------------------------+----------+
  | greped hash keys            | 1.593896 |
  +-----------------------------+----------+
