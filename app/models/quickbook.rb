class Quickbook < ApplicationRecord

  def self.create_quickbooks_invoice(customer_payload, order)
    account = customer_payload
    if !account.qb_customer_ref.nil?
      # customer is already created , just create an invoice
      post_invoice_to_quickbooks(order,account.qb_customer_ref)
    else
      post_customer_to_quickbooks(customer_payload,order)
    end
  end

  def self.update_invoice(account, order)
    amount = order.opportunity.amount
    discount = order.opportunity.discount
    invoice = {
        "Line": [
            {
                "Amount": amount,
                "DetailType": "SalesItemLineDetail",
                "Description": "Law Services",
                "SalesItemLineDetail":
                    {
                        "Qty": 1
                    }
            },
            {
                "Amount":discount,
                "DetailType": "DiscountLineDetail",
                "DiscountLineDetail":
                    {
                        "PercentBased": false
                    }
            }
        ],
        "CustomerRef": {
            "value": account.qb_customer_ref
        }
    }

    if Quickbook.first.present?
      q = Quickbook.find(1)
      qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
      # logger.debug("Invoice id is: #{order.qb_invoice_ref}")
      response = qbo_api.update(:invoice, id: order.qb_invoice_ref , payload: invoice)
    end
  end

  def self.send_invoice(qb_invoice_ref)
    logger.debug("**** Quickbook Model ---- send_invoice----")
    if Quickbook.first.present?
      q = Quickbook.find(1)
      qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId)
      entity = :invoice
      # path = "#{entity_path(entity)}/#{qb_invoice_ref}/send"
      path = ["#{q.realmId}/invoice/#{qb_invoice_ref}/send"]
      response = qbo_api.request(:post, entity: entity, path: path)

      logger.debug("Send Quickbooks Invoice----THE RESPONSE IS : #{response.inspect}")
      if response["Id"].present?
        # order.qb_invoice_sent = 1
        # order.save
      end
    end
  end

  private
  def self.post_customer_to_quickbooks(customer_payload, order)
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

      logger.debug("post_customer_to_quickbooks-----THE RESPONSE OF THE QBO_API IS : #{response.inspect}")

      if response["Id"].present?
        account.qb_customer_ref = response["Id"]
        account.save
      end

      post_invoice_to_quickbooks(order,account.qb_customer_ref)

      # if response.Id > 0
      #   # customer is successfully created in Quickbooks , save this Id against the account
      #
      #   if account = Account.where(:id => customer_payload.id).first
      #     account.qb_customer_ref = response.Id
      #     account.save
      #   else
      #     # Account doesn't exists
      #     # TODO : handle Exception
      #   end
      # end
    end
  end

  def self.post_invoice_to_quickbooks(order, qb_customer_ref)
    amount = order.opportunity.amount
    discount = order.opportunity.discount
    logger.debug("post_invoice_to_quickbooks----AMOUNT : #{amount.inspect}******DISCOUNT : #{discount.inspect}")
    invoice = {
        "Line": [
            {
              "Amount": amount,
              "DetailType": "SalesItemLineDetail",
              "Description": "Law Services",
              "SalesItemLineDetail":
                  {
                    "Qty": 1
                  }
            },
            {
              "Amount":discount,
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

    if Quickbook.first.present?
      q = Quickbook.find(1)
      qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
      response = qbo_api.create(:invoice,payload: invoice)

      logger.debug("post_invoice_to_quickbooks----THE INVOICE CREATING RESPONSE IS : #{response.inspect}")
      if response["Id"].present?
        order.qb_invoice_ref = response["Id"]
        order.save
        # Invoice is successfully created in Quickbooks , save this Id against
      end
    end

  end

end
