
require 'sinatra'
require 'sinatra/json'
require 'pony'

class Connect < Sinatra::Base

  post '/connect' do
    email = Email.new(params)
    if email.send
      content_type :json
      status 200
      json success: true
    else
      content_type :json
      status 422
      json success: false, errors: email.errors
    end
  end

  class Email

    attr_accessor :errors

    def initialize(params)
      @name = params[:name]
      @email = params[:email]
      @message = params[:message]

      @errors = {}
    end

    def send
      validate

      if errors.empty?
        Pony.mail(
          from: "#{@email}",
          to: "sukhchander+www@gmail.com",
          subject: "Hi Sukhchander",
          body: "#{@name}\n(#{@email})\nmessage:\n'#{@message}'",
          via: :smtp,
          via_options: {
            address:              'smtp.sendgrid.net',
            port:                 '587',
            domain:               ENV['SENDGRID_DOMAIN'],
            user_name:            ENV['SENDGRID_USERNAME'],
            password:             ENV['SENDGRID_PASSWORD'],
            authentication:       :plain,
            enable_starttls_auto: true
          }
        )
        return true
      else
        return false
      end
    end

    private

    def validate
      @errors[:name] = "Please enter your name" unless present? @name

      @errors[:message] = "Please enter a message" unless present? @message

      if present? @email
        @errors[:email] = "Please enter a valid email address" unless valid_email?
      else
        @errors[:email] = "Please enter your email address"
      end
    end

    def present?(field)
      !field.empty?
    end

    def valid_email?
      @email =~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
    end

  end

end
