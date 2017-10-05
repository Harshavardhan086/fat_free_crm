class Quickbook < ApplicationRecord

def create_customer(customer_payload)


  if Quickbook.first.present?
    q = Quickbook.find(1)
    qbo_api = QboApi.new(q.access_token, q.realmId, )
    qbo_api.create(:customer,payload: customer_payload)

    end

end


end
