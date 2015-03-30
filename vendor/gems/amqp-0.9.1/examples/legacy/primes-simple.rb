#!/usr/bin/env ruby
# encoding: utf-8

# You are probably wondering what the smeg is this example all about.
# Check examples/primes.rb, the only point of this file is to compare
# with its RPC implementation.

require "bundler"
Bundler.setup

MAX = 1000

class Fixnum
  def prime?
    ('1' * self) !~ /^1?$|^(11+?)\1+$/
  end
end

class PrimeChecker
  def is_prime?(number)
    number.prime?
  end
end

prime_checker = PrimeChecker.new

(10_000...(10_000 + MAX)).each do |n|
  prime_checker.is_prime?(n)
end
