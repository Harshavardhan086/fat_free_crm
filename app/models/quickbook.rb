class Quickbook < ApplicationRecord

  def self.create_customer(customer_payload)

    Rails.logger.debug("Quickbook model----- #{customer_payload.inspect}")
    Rails.logger.debug("Quickbook modke------ #{customer_payload.addresses.inspect}")
    account = customer_payload
    address = account.addresses

    customer = {
        "BillAddr": {
            "Id": address[0].id,
            "Line1": address[0].street1,
            "City": address[0].city,
            "CountrySubDivisionCode": address[0].state,
            "PostalCode": address[0].zipcode,
        },
        "CompanyName": account.name,
        "PrimaryPhone": {
            "FreeFormNumber": account.phone
        },
        "PrimaryEmailAddr": {
            "Address": account.email
        }

    }
    Rails.logger.debug("Quickbook model******* PAYLOAD----- #{customer}")
    # Rails.logger.debug("Quickbook modke------ #{customer_payload.addresses.to_json}")

    if Quickbook.first.present?
      q = Quickbook.find(1)
      Rails.logger.debug("")
      qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
      qbo_api.create(:customer,payload: customer)
    end

  end


end
