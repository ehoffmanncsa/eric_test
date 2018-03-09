require_relative '../../test/test_helper'

# Common actions that UI tests perform
module TEDContractApi
  class << self
    attr_accessor :org_id
    attr_accessor :org_name
    attr_accessor :admin_api
    attr_accessor :coach_api
  end

  def self.setup
    # default to Awesome Volleyball org and Otto Mation PA
    @admin_api ||= TEDApi.new('admin')
    @coach_api ||= TEDApi.new('coach')
    @org_id ||= '15'
    @org_name ||= 'Awesome Volleyball'
  end

  def self.decode(token)
    JWT.decode(token, nil, false)[0]
  end

  def self.get_pricing(sport_id, team_count)
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

  def self.calculate_contract(sport_id, team_count, payment_count)
    price = get_pricing(sport_id, team_count).to_f
    total = price * team_count.to_i * 12
    one_payment = total/payment_count.to_i

    [one_payment, total]
  end

  def self.add_contract
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

    @admin_api.create(endpoint, body)
  end

  def self.accept_terms_of_service(contract_id, decoded_data)
    coach_id = decoded_data['id']
    phrase = decoded_data['phrase']

    endpoint = "organization_contracts/#{contract_id}/accept_terms_of_service"
    body = {
      data: {
        type: 'organization_contracts',
        attributes: {
          accepted_by: @org_name,
          phrase: phrase
        },
        relationships: {
          organization_contract: { 
            data: { 
              id: contract_id,
              type: 'organization_contracts'
            } 
          },
          coach: { data: { id: coach_id, type: 'coaches' } }
        }
      }
    }.to_json

    @coach_api.patch(endpoint, body)
  end

  def self.submit_credit_card_info(contract_id, decoded_data, year = nil)
    month = rand(1 .. 12).to_s
    year = year.nil? ? (Date.today.year + 4).to_s : year
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
          phrase: decoded_data['phrase'],
          united_states: true
        },
        relationships: {
          coach: { data: { id: decoded_data['id'], type: 'coaches'} }, 
          organization: {
            data: { id: decoded_data['organization_id'], type: 'organizations' }
          },
          organization_contract: {
            data: {
              id: contract_id,
              type: 'organization_contracts'
            }
          }
        }
      }
    }.to_json

    @admin_api.create(endpoint, body)['data']
  end

  def self.cancel_signed_contract(contract_id)
    endpoint = "organization_contracts/#{contract_id}/cancel"
    @admin_api.patch(endpoint, nil)
  end

  def self.get_all_contracts
    endpoint = "organizations/#{@org_id}/organization_contracts"
    @admin_api.read(endpoint)['data']
  end

  def self.delete_contract(contract_id)
    endpoint = "organization_contracts/#{contract_id}"
    @admin_api.delete(endpoint)['data']
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
