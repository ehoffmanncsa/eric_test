require_relative '../../test/test_helper'

# Add teams of available sports to org
class MassDeleteTEDOrgs
  def initialize
    TEDOrgApi.setup
  end

  def zero_athlete?(org)
    org['attributes']['number-of-athletes'] == 0
  end

  def zero_contract?(org)
    org['attributes']['number-of-contracts'] == 0
  end

  def find_orgs
    orphans = []
    orgs = TEDOrgApi.find_dummy_orgs
    orgs.each do |org|
      next if org['attributes']['email'] == 'ncsa.automation+93a6@gmail.com'

      if (zero_athlete?(org))
        orphans << org['id']
      end
    end

    orphans
  end

  def delete_them
    loop do
      org_ids = find_orgs
      break if org_ids.empty?

      org_ids.each do |id|
        TEDOrgApi.org_id = id
        pp "[INFO] Deleting org - id #{id}"
        TEDOrgApi.delete_org(id)
      end
    end
  end
end

MassDeleteTEDOrgs.new.delete_them
