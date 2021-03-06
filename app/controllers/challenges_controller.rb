class ChallengesController < ApplicationController
  before_action :authenticate_player!
  before_action :set_challenge, only: [:show, :answer]
  before_action :check_contest_period, only: %i(answer)

  # /challenges
  def index
    @challenges = Challenge.opened
    @genres = @challenges.genres
  end

  # /challenges/:id
  def show
    @answer = Answer.new
  end

  # /challenges/:id
  def answer
    answer = current_player.submit(@challenge, answer_params[:answer])
    if answer
      case
      when answer.valid_answer? then response_for_valid_answer
      when answer.answered?     then response_for_answered_challenge
      else response_for_wrong_anser
      end
    else
      response_on_error
    end
  end

  private
    def redirect_with_answer_result(message, type = :notice)
      case type
      when nil, :notice
        redirect_to challenge_path(@challenge), notice: message
      when :alert, :error
        redirect_to challenge_path(@challenge), alert: message
      end
    end

    def response_for_valid_answer
      respond_to do |format|
        format.html { redirect_with_answer_result('Your flag is correct!') }
        format.json { render json: { result: 'correct' } }
      end
    end

    def response_for_answered_challenge
      respond_to do |format|
        format.html { redirect_with_answer_result('The flag is correct, but you or your team mate has already answered.') }
        format.json { render json: { result: 'answered' } }
      end
    end

    def response_for_wrong_anser
      respond_to do |format|
        format.html { redirect_with_answer_result('Wrong answer...', :alert) }
        format.json { render json: { result: 'wrong' } }
      end
    end

    def response_on_error
      respond_to do |format|
        format.html { redirect_with_answer_result('Something went wrong...', :error) }
        format.json { render json: { result: 'error' } }
      end
    end

    def check_contest_period
      return if can_submit?

      respond_to do |format|
        format.html { redirect_to @challenge, alert: 'Contest Closed!' }
        format.json { { result: 'closed' } }
      end
    end

    def set_challenge
      @challenge = Challenge.find(params[:id])
      fail ActiveRecord::RecordNotFound unless @challenge.opened?
    end

    def answer_params
      params.require(:answer).permit(:answer)
    end

    def can_submit?
      ApplicationController.helpers.within_contest_period?
    end
end
