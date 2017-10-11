class Quickbook < ApplicationRecord

  def self.create_customer(customer_payload, order)
    if account.qb_customer_ref > 0
      # customer is already created , just create an invoice
      post_invoice_to_quickbooks(order,account.qb_customer_ref)
    else
      post_customer_to_quickbooks(customer_payload)
    end
  end

  private
  def post_customer_to_quickbooks(customer_payload)
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
        "GivenName": account.name,
        "DisplayName": account.name,
        "PrimaryPhone": {
            "FreeFormNumber": account.phone
        },
        "PrimaryEmailAddr": {
            "Address": account.email
        }

    }

    if Quickbook.first.present?
      q = Quickbook.find(1)
      qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
      response = qbo_api.create(:customer,payload: customer)

      if response.Id > 0
        # customer is successfully created in Quickbooks , save this Id against the account

        if account = Account.where(:id => customer_payload.id).first
          account.qb_customer_ref = response.Id
          account.save
        else
          # Account doesn't exists
          # TODO : handle Exception
        end
      end
    end
  end

  private
  def post_invoice_to_quickbooks(order, qb_customer_ref)

    invoice = {
        "Line": [
            {
                "Amount": order.amount,
                "DetailType": "SalesItemLineDetail",
                "Description": "Law Services",
                "SalesItemLineDetail":
                    {
                        "Qty": 1
                    }
            },
            {
            "Amount":order.discount,
            "DetailType": "DiscountLineDetail",
            "DiscountLineDetail":
                {
                    "PercentBased": false
                }
            }
        ],
        "CustomerRef": {
        "value": qb_customer_ref
        }
    }
  end

end
