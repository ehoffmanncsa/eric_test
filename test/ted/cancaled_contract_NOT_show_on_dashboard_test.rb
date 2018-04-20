# encoding: utf-8
require_relative '../test_helper'

# TS-356: TED Regression
# UI Test: Do not include Contracts that are canceled on Dashboard

=begin
  PA Otto Mation, Org Awesome Sauce, Coach Tiffany
  You won't see much activities in the UI because
  the majority are done via API requests
  Login to TED as PA, get org AV's contract count on dashboard
  Create contract, sign and authorize it
  Refresh the UI make sure contract count has increased
  Cancel the contract via API
  Refresh the UI and make sure contract count back to original
  All emails related to this process are checked and deleted afterward
=end

class DashboardNotShowCanceledContractTest < Common
  def setup
    super
    TED.setup(@browser)

    @gmail = GmailCalls.new
    @gmail.get_connection
    @gmail.mail_box = 'TED_Contract'
    @gmail.sender = 'TeamEdition@ncsasports.org'

    @admin_api = TEDApi.new('admin')

    creds = YAML.load_file('config/.creds.yml')
    @admin_username = creds['ted_admin']['username']
    @admin_password = creds['ted_admin']['password']

    @org_id = '440' # Using static org for this scenario
    @org_name = 'Awesome Sauce'
  end

  def get_pricing(sport_id, team_count)
    endpoint = "sports/#{sport_id}/pricing_tiers"
    pricing_tiers = @admin_api.read(endpoint)['data']

    tier = nil
    if (team_count.to_i.between?(1, 4))
      tier = pricing_tiers[0]
    elsif (team_count.to_i.between?(5, 9))
      tier = pricing_tiers[1]
    else
      tier = pricing_tiers[2]
    end

    tier['attributes']['price'].to_f
  end

  def calculate_contract(sport_id, team_count, payment_count)
    price = get_pricing(sport_id, team_count).to_f
    total = price * team_count.to_i * 12
    one_payment = total/payment_count.to_i

    [one_payment, total]
  end

  def add_contract
    sport_id = rand(1 .. 9).to_s
    payment_count = [1, 2, 3, 4, 6, 12].sample.to_s
    team_count = rand(1 .. 100).to_s
    _one_payment, total = calculate_contract(sport_id, team_count, payment_count)
    today = Time.now.strftime("%Y-%m-%d")

    endpoint = "organizations/#{@org_id}/organization_contracts"
    body = {
      data: {
        type: 'organization_contracts',
        attributes: {
          amount: total,
          first_payment_date: today,
          modifier: 1,
          number_of_payments: payment_count,
          number_of_teams: team_count,
          start_date: today
        },
        relationships: {
          organization: { data: { type: 'organizations', id: @org_id } },
          sport: { data: { type: 'sports', id: sport_id } }
        }
      }
    }.to_json

    @admin_api.create(endpoint, body)['data']
  end

  def send_invoice(contract_id)
    endpoint = "organizations/#{@org_id}/organization_invoices"
    body = {
      data: {
        type: 'organization_invoices',
        relationships: {
          organization: { data: { type: 'organizations', id: @org_id } },
          organization_contract: {
            data: { type: 'organization_contracts', id: contract_id }
          }
        }
      }
    }.to_json

    @admin_api.create(endpoint, body)
  end

  def get_sign_page_url_in_email
    keyword = 'https://team-staging.ncsasports.org/terms_of_service?'
    emails = @gmail.get_unread_emails
    msg = @gmail.parse_body(emails.last, keyword)
    url = msg[1].split("\"")[1]
    @gmail.delete(emails)

    url
  end

  def decode_url_token(url)
    @token = url.split('=')[1]
    JWT.decode(@token, nil, false)[0]
  end

  def accept_terms_of_service
    @decoded_data = decode_url_token(get_sign_page_url_in_email)
    @coach_id = @decoded_data['coach_id']
    @phrase = @decoded_data['phrase']
    @contract_id = @decoded_data['organization_contract_id']

    endpoint = "organization_contracts/#{@contract_id}/accept_terms_of_service"
    body = {
      data: {
        type: 'organization_contracts',
        attributes: {
          accepted_by: @first_name,
          phrase: @phrase
        },
        relationships: {
          organization_contract: {
            data: {
              id: @contract_id,
              type: 'organization_contracts'
            }
          },
          coach: { data: { id: @coach_id, type: 'coaches' } }
        }
      }
    }.to_json

    @coach_api = TEDApi.new(nil, @token)
    @coach_api.patch(endpoint, body)
  end

  def submit_credit_card_info
    month = rand(1 .. 12).to_s
    year = (Date.today.year + 4).to_s
    card = YAML.load_file('config/config.yml')['credit_billing']
    endpoint = "organizations/#{@org_id}/organization_accounts"

    body = {
      data: {
        type: 'organization_accounts',
        attributes: {
          account_holder_email: card['order_account_holder_email'],
          account_holder_first_name: card['order_card_holder_first_name'],
          account_holder_last_name: card['order_card_holder_last_name'],
          billing_zip: card['order_billing_zip'],
          credit_card_number: card['order_card_number'],
          cvv: card['order_cvv_code'],
          expiration_month: month,
          expiration_year: year,
          initial_payment: true,
          phrase: @phrase,
          united_states: true
        },
        relationships: {
          coach: { data: { id: @coach_id, type: 'coaches'} },
          organization: {
            data: { id: @org_id, type: 'organizations' }
          },
          organization_contract: {
            data: {
              id: @contract_id,
              type: 'organization_contracts'
            }
          }
        }
      }
    }.to_json

    @admin_api.create(endpoint, body)
  end

  def get_contract_count
    org = @browser.element(:text, @org_name).parent
    text = org.element(:class, 'subtitle').text
    arr = text.split(' ')
    arr.pop

    arr.last.to_i # this is count of signed contract on dashboard
  end

  def cancel_contract
    pp "[INFO] Canceling contract..."
    endpoint = "organization_contracts/#{@contract_id}/cancel"
    cancel = @admin_api.patch(endpoint, nil)

    delete_date = cancel['data']['attributes']['deleted-at']
    today = Date.today.to_s
    assert_includes delete_date, today, 'Incorrect delete date'

    # check cancel email
    subject = "CANCEL NOTICE: #{@org_name}"
    check_email(subject)
  end

  def check_email(subject)
    @gmail.mail_box = 'Inbox'
    @gmail.subject = subject
    emails = @gmail.get_unread_emails
    refute_empty emails, 'No Signed confirm email received'

    # delete email after done checking
    @gmail.delete(emails)
  end

  def setup_contract
    # add new contract and send invoice
    pp "[INFO] Adding new contract..."
    new_contract = add_contract
    send_invoice(new_contract['id'])

    # sign contract and fill out credit card
    accept_terms_of_service
    data = submit_credit_card_info
    refute_empty data, 'Returning data after POST CC info is empty'

    # when cc is successfully added as initial payment,
    # coach sign in session is created
    signin_endpoint = '/api/team_edition/sign_in'
    assert_equal signin_endpoint, data['data']['links']['self'], 'Incorrect link'

    # check the confirm email by subject and delete afterward
    subject = "#{@org_name} has signed Terms of Service and authorized credit card"
    check_email(subject)
  end

  def test_canceled_contract_not_show_on_dashboard
    UIActions.ted_login(@admin_username, @admin_password)
    original_contract_count = get_contract_count

    setup_contract
    # check count increase after added contract
    @browser.refresh; sleep 2
    new_count = get_contract_count
    assert (original_contract_count < new_count), 'Wrong count after add contract'

    canceled_contract = cancel_contract
    # check dashboard make sure contract count is correct
    @browser.refresh
    new_count = get_contract_count
    assert_equal original_contract_count, new_count, 'Wrong count after cancel contract'
  end
end
