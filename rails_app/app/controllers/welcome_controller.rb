class WelcomeController < ApplicationController
	def index
		render json:"1/8 test1"

	end
	def set_session
		session[:testshare]="im session"
		render json:session[:testshare]
	end
	def get_session
		render json:session[:testshare]
	end
	def drop_session
		session.delete("testshare")
		render json:""
	end
end
