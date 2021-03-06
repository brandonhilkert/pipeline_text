require 'bundler'
Bundler.require

BRANDON = "3023458171"
SCOTT = "9376171623"
GRANT = "2158017554"
CHAD = "7173481974"
CHRISTOPHER = "5707048006"
PHONE_NUMBERS = [BRANDON, SCOTT, GRANT, CHAD, CHRISTOPHER]

get '/' do
  'OMG'
end

post '/' do
  body = params[:alert] || params[:deployment]
  payload = JSON.parse(body)
  TextMessage.new(payload, PHONE_NUMBERS).alert
end

class TextMessage
  # {
  #     "created_at":"2013-09-06T02:17:36+00:00",
  #     "application_name":"Application name",
  #     "account_name":"Account name",
  #     "severity":"critical",
  #     "message":"Apdex score fell below critical level of 0.90",
  #     "short_description":"[application name] alert opened",
  #     "long_description":"Alert opened on [application name]: Apdex score fell below critical level of 0.90",
  #     "alert_url":"https://rpm.newrelc.com/accounts/[account_id]/applications/[application_id]/incidents/[incident_id]"
  # }
  #
  def initialize(payload, numbers)
    @payload, @numbers = payload, numbers
  end

  def alert
    @numbers.each { |number| send(number) }
  end

  private

  def send(phone)
    twilio_client.account.sms.messages.create(
      from: twilio_number,
      to: phone,
      body: body
    )
  end

  def body
    "#{@payload["severity"]}: #{@payload["long_description"]}"
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"])
  end

  def twilio_number
    ENV["TWILIO_NUMBER"]
  end
end
