require_relative '../../test/test_helper'

# Add teams of available sports to org
class CreateContractsForTEDOrg
  def initialize(org_id)
    @api = TEDApi.new('partner')
    @org_id = (org_id.nil?) ? get_awesome_sauce_id : org_id
  end

  def get_awesome_sauce_id
    @api.read('partners/1/organizations?contracts_status=' \
      '&text_query=Awesome Sauce&org_type=&page=1')['data'][0]['id']
  end

  def create_contracts
    TEDContractApi.setup

    for i in 1 .. 9 do
      i = 41 if i == 9
      TEDContractApi.create_contract_complete_process(i)
    end

    TEDContractApi.cleanup_email('Inbox')
  end
end

org_id = ARGV[0]
CreateContractsForTEDOrg.new(org_id).create_contracts
