require 'mail'
require 'nokogiri'

class Email
  def initialize
    Mail.defaults do
      delivery_method :smtp, {  :address              => 'smtp.office365.com',
                                :port                 => 587,
                                :domain               => 'ncsaemail.com',
                                :user_name            => 'trea@ncsasports.org',
                                :password             => 'Secure.123',
                                :authentication       => :login,
                                :enable_starttls_auto => true  
                             }

      retriever_method :pop3, {  :address    => 'outlook.office365.com',
                                 :port       => 995,
                                 :user_name  => 'trea@ncsasports.org',
                                 :password   => 'Secure.123',
                                 :enable_ssl => true    
                              }
    end
  end

  def send
    Mail.deliver do
      from 'trea@ncsasports.org'
      to 'tiffy.nets@gmail.com'
      subject 'test mail gem'
      body 'from outlook'
    end
  end

  def inbox
    open('mail.eml', 'w') { |f| f << Mail.find(:what => :last, :count => 1) }
  end

  def read
    mail = Mail.find(:what => :last, :count => 1)
    puts mail.message_id
    mail.body.decoded
  end
end

