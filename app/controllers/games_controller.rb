require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    grid_size.times { grid << ('a'..'z').to_a.sample.upcase }
    grid
  end

  def generate_score(attempt, grid)
    score = attempt.length.fdiv(grid.length) * 10
    session[:scores] ? session[:scores] << score : session[:scores] = [score]
    score
  end

  def english_word?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    check_json = URI.open(url).read
    check = JSON.parse(check_json)
    # p "english: #{check['found']}"
    check['found']
  end

  def in_grid?(attempt, grid)
    letters = Hash.new(0)
    grid.each { |letter| letters[letter] += 1 }
    attempt.chars.each { |letter| letters[letter] -= 1 }

    letters.all? { |_, letter| letter >= 0 }
  end

  def generate_message(english, in_grid, word, grid)
    if !in_grid
      message = "Sorry but <b>#{word.upcase}</b> can't be built out of #{grid.join(',')}".html_safe
    elsif !english
      message = "Sorry but <b>#{word.upcase}</b> does not seem to be a valid english word".html_safe
    else
      message = "Congratulations <b>#{word.upcase}</b> is a valid English word".html_safe
    end
    message
  end

  def new
    @letters = generate_grid(10)
  end

  def score
    english = english_word?(params[:word])
    in_grid = in_grid?(params[:word].upcase, params[:grid].chars)
    @score = english && in_grid ? generate_score(params[:word], params[:grid].chars) : 0
    @message = generate_message(english, in_grid, params[:word], params[:grid].chars)
  end
end
