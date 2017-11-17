class Quickbook < ApplicationRecord

  def self.create_quickbooks_invoice(account, order)
    if !account.qb_customer_ref.nil?
      # customer is already created , just create an invoice
      post_invoice_to_quickbooks(order,account)
    else
      post_customer_to_quickbooks(account,order)
    end
  end

  # def self.create_customer(account)
  #
  #   Rails.logger.debug("Quickbook model----- #{account.inspect}")
  #   Rails.logger.debug("Quickbook modke------ #{account.addresses.inspect}")
  #
  #   address = account.addresses
  #
  #   customer = {
  #       "BillAddr": {
  #           "Id": !address.blank? ? address[0].id : "",
  #           "Line1": !address.blank? ? address[0].street1 : "",
  #           "City": !address.blank? ? address[0].city : "",
  #           "CountrySubDivisionCode": !address.blank? ? address[0].state : "",
  #           "PostalCode": !address.blank? ? address[0].zipcode : "",
  #       },
  #       "GivenName": account.name,
  #       "DisplayName": account.name,
  #       "PrimaryPhone": {
  #           "FreeFormNumber": account.phone
  #       },
  #       "PrimaryEmailAddr": {
  #           "Address": account.email
  #       }
  #
  #   }
  #
  #   if Quickbook.first.present?
  #     begin
  #       q = Quickbook.find(1)
  #       qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
  #       response = qbo_api.create(:customer,payload: customer)
  #       logger.debug("post_customer_to_quickbooks-----THE RESPONSE OF THE QBO_API IS : #{response.inspect}")
  #
  #       if response["Id"].present?
  #         account.qb_customer_ref = response["Id"]
  #         account.save
  #       end
  #       flash[:success] = "Welcome to the Sample App! after save"
  #     rescue => error
  #       Rails.logger.error ("the error in the QB is :#{error}")
  #     end
  #
  #
  #   end
  # end

  # def self.update_customer(account)
  #
  #   Rails.logger.debug("Quickbook model----- #{account.inspect}")
  #   Rails.logger.debug("Quickbook modke------ #{account.addresses.inspect}")
  #
  #   address = account.addresses
  #
  #   customer = {
  #       "BillAddr": {
  #           "Id": !address.blank? ? address[0].id : "",
  #           "Line1": !address.blank? ? address[0].street1 : "",
  #           "City": !address.blank? ? address[0].city : "",
  #           "CountrySubDivisionCode": !address.blank? ? address[0].state : "",
  #           "PostalCode": !address.blank? ? address[0].zipcode : "",
  #       },
  #       "GivenName": account.name,
  #       "DisplayName": account.name,
  #       "PrimaryPhone": {
  #           "FreeFormNumber": account.phone
  #       },
  #       "PrimaryEmailAddr": {
  #           "Address": account.email
  #       }
  #
  #   }
  #   if Quickbook.first.present?
  #     begin
  #       q = Quickbook.find(1)
  #       qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
  #       response = QboApi.update(:customer, id: account.qb_customer_ref, payload: customer )
  #       logger.debug("update_customer_on_quickbooks-----THE RESPONSE OF THE QBO_API IS : #{response.inspect}")
  #
  #       if response["Id"].present?
  #         account.qb_customer_ref = response["Id"]
  #         account.save
  #       end
  #     rescue => error
  #       Rails.logger.error ("the error in the QB is :#{error}")
  #     end
  #   end
  # end

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
        },
        "BillEmail": {
            "Address": account.email
        }
    }
    logger.debug("account email: #{account.email}")
    logger.debug("account ORDER REF: #{order.qb_invoice_ref}")
    if Quickbook.first.present?
      begin
        q = Quickbook.find(1)
        qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
        # logger.debug("Invoice id is: #{order.qb_invoice_ref}")
        response = qbo_api.update(:invoice, id: order.qb_invoice_ref , payload: invoice)
      rescue => error
        Rails.logger.error ("the error in the QB is :#{error}")

      end
    end
  end

  def self.send_invoice(qb_invoice_ref, order)
    logger.debug("**** Quickbook Model ---- send_invoice----")
    if Quickbook.first.present?
      begin
        q = Quickbook.find(1)
        qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId)

        # first fetch this invoice and then try to sned it.
        entity = :invoice
        path = "#{q.realmId}/invoice/#{qb_invoice_ref}/send"

        get_response = qbo_api.get(entity, qb_invoice_ref);

        if get_response["Id"].present?
         # send out the invoice now
          inv = {DeliveryAddress:{"Address": get_response["BillEmail"]["Address"]}, SyncToken: get_response["SyncToken"],
                       MetaData: get_response["MetaData"]}

          logger.debug("Send Quickbooks Invoice----PAYLOAD : #{inv}")

          response = qbo_api.request(:post, entity: entity, path: path,payload: inv)
          logger.debug("Send Quickbooks Invoice----THE RESPONSE IS : #{response.inspect}")
          if response["Id"].present?
             order.qb_invoice_sent = 1
             order.status = "Invoice Sent"
             order.save
          end
        end
      rescue => error
        Rails.logger.error ("the error in the QB is :#{error}")
      end
    end
  end

  def self.renew_oauth2_tokens

    if (qbo_accounts = Quickbook.where('reconnect_token_at <= NOW() AND token_expires_at >= NOW()')).empty?
      p "OAUTH2_RENEW_TOKEN: nothing to do"
    else
    # qbo_accounts = Quickbook.where("id = ?", 1)
      qbo_accounts.each do |q|
        begin
          client = oauth2_client
          client.refresh_token = q.refresh_token
          if resp = client.access_token!
            duration_attrs = { reconnect_token_at: 1.hour.from_now,
                               token_expires_at: 50.minutes.from_now }
            attrs = { access_token: resp.access_token, refresh_token: resp.refresh_token }.merge(duration_attrs)
            if q.update(attrs)
              p "SUCCESS_OAUTH2_RENEW_TOKEN: qbo_account: #{q.id}"
            else
              p  "FAILED_OAUTH2_RENEW_TOKEN: qbo_account: #{q.id} error_message: #{resp}"
            end
          end
        rescue => e
          p "FAILED_OAUTH2_RENEW_TOKEN: qbo_account: #{q.id} error_message: #{e.message}"
        end
      end
    end
  end


  def self.oauth2_client
    Rack::OAuth2::Client.new(
        identifier: "Q0Tfk6a4VauRIHi4bJhuoxVUYWqBP4zUNSyTPG01b3eocLQuUe",
        secret: "3AZKvrtIrg8Pgq6Hmx2k7FIIL4x78ihy5dEXPPgy",
        redirect_uri: 'http://localhost:3000/admin/settings/oauth2_redirect',
        authorization_endpoint: "https://appcenter.intuit.com/connect/oauth2",
        token_endpoint: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
    )
  end

  private
  def self.post_customer_to_quickbooks(account, order)
    Rails.logger.debug("Quickbook model----- #{account.inspect}")
    Rails.logger.debug("Quickbook modke------ #{account.addresses.inspect}")

    address = account.addresses

    customer = {
        "BillAddr": {
            "Id": !address.blank? ? address[0].id : "",
            "Line1": !address.blank? ? address[0].street1 : "",
            "City": !address.blank? ? address[0].city : "",
            "CountrySubDivisionCode": !address.blank? ? address[0].state : "",
            "PostalCode": !address.blank? ? address[0].zipcode : "",
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
      begin
        q = Quickbook.find(1)
        qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
        response = qbo_api.create(:customer,payload: customer)

        logger.debug("post_customer_to_quickbooks-----THE RESPONSE OF THE QBO_API IS : #{response.inspect}")

        if response["Id"].present?
          account.qb_customer_ref = response["Id"]
          account.save
        end

        post_invoice_to_quickbooks(order,account)
      rescue => error
        Rails.logger.error ("the error in the QB is :#{error}")
      end
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

  def self.post_invoice_to_quickbooks(order, account)
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
            "value": account.qb_customer_ref
        },
        "BillEmail": {
            "Address": account.email
        }
    }

    if Quickbook.first.present?
      begin
        q = Quickbook.find(1)
        qbo_api = QboApi.new(access_token: q.access_token, realm_id: q.realmId )
        response = qbo_api.create(:invoice,payload: invoice)

        logger.debug("post_invoice_to_quickbooks----THE INVOICE CREATING RESPONSE IS : #{response.inspect}")
        if response["Id"].present?
          order.qb_invoice_ref = response["Id"]
          order.save
          # Invoice is successfully created in Quickbooks , save this Id against
        end
      rescue => error
        Rails.logger.error ("the error in the QB is :#{error}")
      end
    end
  end

end