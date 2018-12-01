require_relative '../../test/test_helper'

# Common actions that UI tests perform
module TEDContractApi
  class << self
    attr_accessor :org_id
    attr_accessor :org_name
    attr_accessor :partner_api
  end

  def self.setup
    # default to Awesome Sauce org and Otto Mation PA
    @partner_api ||= TEDApi.new('partner')
    @org_id ||= '728'
    @org_name ||= 'Awesome Sauce'
  end

  def self.get_pricing(sport_id, team_count)
    endpoint = "sports/#{sport_id}/pricing_tiers"
    pricing_tiers = @partner_api.read(endpoint)['data']

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

  def self.calculate_contract(sport_id, team_count, payment_count)
    price = get_pricing(sport_id, team_count).to_f
    total = price * team_count.to_i * 12
    one_payment = total/payment_count.to_i

    [one_payment, total]
  end

  def self.post_contract(sport_id = nil)
    sport_id = (sport_id.nil?) ? rand(1 .. 9).to_s : sport_id
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

    @partner_api.create(endpoint, body)['data']
  end

  def self.send_invoice(contract_id)
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

    @partner_api.create(endpoint, body)
  end

  def self.send_free_invoice(org_id = nil)
    @org_id ||= org_id
    endpoint = "organizations/#{@org_id}/organization_invoices"
    body = {
      data: {
        type: 'organization_invoices',
        relationships: {
          organization: { data: { type: 'organizations', id: @org_id } }
        }
      }
    }.to_json

    @partner_api.create(endpoint, body)
  end

  def self.accept_terms_of_service
    contract_id = @decoded_data['organization_contract_id']
    endpoint = "organization_contracts/#{contract_id}/accept_terms_of_service"

    body = {
      data: {
        type: 'organization_contracts',
        attributes: {
          accepted_by: @org_name,
          phrase: @decoded_data['phrase']
        },
        relationships: {
          organization_contract: {
            data: {
              id: contract_id,
              type: 'organization_contracts'
            }
          },
          coach: { data: { id: @decoded_data['coach_id'], type: 'coaches' } }
        }
      }
    }.to_json

    @coach_api = TEDApi.new(nil, @token)
    @coach_api.patch(endpoint, body)
  end

  def self.submit_credit_card_info
    month = rand(1 .. 12).to_s
    year = (Date.today.year + rand(3 .. 5)).to_s
    card = Default.static_info['credit_billing']
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
          phrase: @decoded_data['phrase'],
          united_states: true
        },
        relationships: {
          coach: { data: { id: @decoded_data['coach_id'], type: 'coaches'} },
          organization: {
            data: { id: @decoded_data['organization_id'], type: 'organizations' }
          },
          organization_contract: {
            data: {
              id: @decoded_data['organization_contract_id'],
              type: 'organization_contracts'
            }
          }
        }
      }
    }.to_json

    @partner_api.create(endpoint, body)['data']
  end

  def self.create_contract_complete_process(sport_id = nil)
    new_contract = post_contract(sport_id)
    send_invoice(new_contract['id'])

    connect_to_gmail
    decode_org_data

    accept_terms_of_service
    submit_credit_card_info

    # return new contract id
    new_contract['id']
  end

  def self.decode_org_data
    url = get_sign_page_url_in_email

    @token = url.split('=')[1]
    @decoded_data = JWT.decode(@token, nil, false)[0]
  end

  def self.get_sign_page_url_in_email
    @gmail.mail_box = 'TED_Contract'
    keyword = 'ncsasports.org/terms_of_service?'

    emails = @gmail.get_unread_emails
    email_body = @gmail.parse_body(emails.last, keyword)
    @gmail.delete(emails)

    email_body[1].split("\"")[1]
  end

  def self.connect_to_gmail
    @gmail = GmailCalls.new
    @gmail.get_connection
  end

  def self.cleanup_email(inbox = nil, subject = nil)
    @gmail.mail_box = inbox
    @gmail.subject = subject

    emails = @gmail.get_unread_emails

    @gmail.delete(emails)
  end

  def self.cancel_signed_contract(contract_id)
    endpoint = "organization_contracts/#{contract_id}/cancel"
    @partner_api.patch(endpoint, nil)
  end

  def self.get_all_contracts
    endpoint = "organizations/#{@org_id}/organization_contracts"
    @partner_api.read(endpoint)['data']
  end

  def self.delete_contract(contract_id)
    endpoint = "organization_contracts/#{contract_id}"
    @partner_api.delete(endpoint)['data']
  end

  def self.delete_all_contracts
    signed_contracts = get_signed_contracts
    non_signed = get_all_contracts - signed_contracts
    signed_contracts.each { |c| cancel_signed_contract(c['id']) }
    non_signed.each { |c| delete_contract(c['id']) }
  end

  def self.get_signed_contracts
    contracts = get_all_contracts
    contracts.reject { |c| c['attributes']['accepted-at'].nil? }
  end
end
