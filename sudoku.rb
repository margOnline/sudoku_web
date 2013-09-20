require 'sinatra'
require 'rack-flash'
# require 'sinatra/partial'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions
set :session_secret, "secret key to sign the cookie"
# set :partial_template_engine, :erb
use Rack::Flash

helpers do
  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
    # raise "dfs"
    must_be_guessed = puzzle_value.to_i == 0
    tried_to_guess = current_solution_value.to_i != 0
    guessed_incorrectly = current_solution_value.to_i != solution_value.to_i

    if solution_to_check && must_be_guessed && tried_to_guess && guessed_incorrectly
      'incorrect'
    elsif !must_be_guessed
      'value_provided'
    end
  end 


  def cell_value(value)
    value.to_i == 0 ? '' : value
  end

end

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9,0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end

def puzzle(sudoku)
  unsolved_sudoku = sudoku.clone
  indices = (0..80).to_a.sample(1)
  indices.each {|index| unsolved_sudoku[index] = ' '}
  unsolved_sudoku
end

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution 
  @check_solution = session[:check_solution]
  if @check_solution
    flash[:notice] = "incorrect values are highlighted in yellow"
  end
    session[:check_solution] = nil
end

get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

post '/' do
  boxes = params["cell"].each_slice(9).to_a
  cells = (0..8).to_a.inject([]) {|memo, i| memo += boxes[i/3*3,3].map{|box| box[i%3*3,3]}.flatten}
  session[:current_solution] = cells#.map{|value| value.to_i}.join
  session[:check_solution] = true
  redirect to("/")
end

get '/solution' do
  @current_solution = session[:solution]
  @solution = session[:solution]
  @puzzle = session[:solution]
  erb :index
end

get '/last-visit' do
  "Previous visit to homepage: #{session[:last_visit]}"
end

get '/reset' do
  session[:solution] = nil
  session[:current_solution] = nil
  session[:last_visit] = nil
  redirect to ('/')
end